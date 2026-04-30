// Copyright © 2019-2023
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

`include "VX_define.vh"
`include "VX_sched_csr_if.vh"
`include "VX_commit_csr_if.vh"
`include "VX_execute_if.vh"
`include "VX_result_if.vh"

module VX_csr_unit import VX_gpu_pkg::*; #(
    parameter `STRING INSTANCE_ID = "",
    parameter CORE_ID = 0,
    parameter NUM_LANES = 1
) (
    input wire                  clk,
    input wire                  reset,

    input base_dcrs_t           base_dcrs,

`ifdef PERF_ENABLE
    input sysmem_perf_t         sysmem_perf,
    input pipeline_perf_t       pipeline_perf,
`endif

`ifdef EXT_F_ENABLE
    VX_fpu_csr_if.slave         fpu_csr_if [`NUM_FPU_BLOCKS],
`endif

    // VX_commit_csr_if.slave      commit_csr_if,
    `VX_COMMIT_CSR_IF_CONSUMER_PORTS(commit_csr_if),
    // flatten: VX_sched_csr_if.slave       sched_csr_if,
    `VX_SCHED_CSR_IF_CONSUMER_PORTS(sched_csr_if),
    // VX_execute_if.slave         execute_if,
    `VX_EXECUTE_IF_CONSUMER_PORTS(execute_if, sfu_exe_t),
    // VX_result_if.master         result_if
    `VX_RESULT_IF_PRODUCER_PORTS(result_if, sfu_res_t)
);
    `UNUSED_SPARAM (INSTANCE_ID)
    localparam PID_BITS   = `CLOG2(`NUM_THREADS / NUM_LANES);
    localparam PID_WIDTH  = `UP(PID_BITS);
    localparam DATAW      = UUID_WIDTH + NW_WIDTH + NUM_LANES + PC_BITS + NUM_REGS_BITS + 1 + NUM_LANES * `XLEN + PID_WIDTH + 1 + 1;

    `UNUSED_VAR (execute_if_data.rs3_data)

    reg [NUM_LANES-1:0][`XLEN-1:0]  csr_read_data;
    reg  [`XLEN-1:0]                csr_write_data;
    wire [`XLEN-1:0]                csr_read_data_ro, csr_read_data_rw;
    wire [`XLEN-1:0]                csr_req_data;
    reg                             csr_rd_enable;
    wire                            csr_wr_enable;
    wire                            csr_req_ready;

    wire [`VX_CSR_ADDR_BITS-1:0] csr_addr = execute_if_data.op_args.csr.addr;
    wire [RV_REGS_BITS-1:0] csr_imm = execute_if_data.op_args.csr.imm;

    wire is_fpu_csr = (csr_addr <= `VX_CSR_FCSR);

    // wait for all pending instructions for current warp to complete
    assign sched_csr_if_alm_empty_wid = execute_if_data.wid;
    wire no_pending_instr = sched_csr_if_alm_empty || ~is_fpu_csr;

    wire csr_req_valid = execute_if_valid && no_pending_instr;
    assign execute_if_ready = csr_req_ready && no_pending_instr;

    wire [NUM_LANES-1:0][`XLEN-1:0] rs1_data;
    `UNUSED_VAR (rs1_data)
    for (genvar i = 0; i < NUM_LANES; ++i) begin : g_rs1_data
        assign rs1_data[i] = execute_if_data.rs1_data[i];
    end

    wire csr_write_enable = (execute_if_data.op_type == INST_SFU_CSRRW);

    VX_csr_data #(
        .INSTANCE_ID (INSTANCE_ID),
        .CORE_ID     (CORE_ID)
    ) csr_data (
        .clk            (clk),
        .reset          (reset),

        .base_dcrs      (base_dcrs),

    `ifdef PERF_ENABLE
        .sysmem_perf    (sysmem_perf),
        .pipeline_perf  (pipeline_perf),
    `endif

        // .commit_csr_if  (commit_csr_if),
        `VX_COMMIT_CSR_IF_PASS_PORTS(commit_csr_if),
        .cycles         (sched_csr_if_cycles),
        .active_warps   (sched_csr_if_active_warps),
        .thread_masks   (sched_csr_if_thread_masks),

    `ifdef EXT_F_ENABLE
        .fpu_csr_if     (fpu_csr_if),
    `endif

        .read_enable    (csr_req_valid && csr_rd_enable),
        .read_uuid      (execute_if_data.uuid),
        .read_wid       (execute_if_data.wid),
        .read_addr      (csr_addr),
        .read_data_ro   (csr_read_data_ro),
        .read_data_rw   (csr_read_data_rw),

        .write_enable   (csr_req_valid && csr_wr_enable),
        .write_uuid     (execute_if_data.uuid),
        .write_wid      (execute_if_data.wid),
        .write_addr     (csr_addr),
        .write_data     (csr_write_data)
    );

    // CSR read

    wire [NUM_LANES-1:0][`XLEN-1:0] wtid, gtid;

    for (genvar i = 0; i < NUM_LANES; ++i) begin : g_wtid
        if (PID_BITS != 0) begin : g_pid
            assign wtid[i] = `XLEN'(execute_if_data.pid * NUM_LANES + i);
        end else begin : g_no_pid
            assign wtid[i] = `XLEN'(i);
        end
    end

    for (genvar i = 0; i < NUM_LANES; ++i) begin : g_gtid
        assign gtid[i] = (`XLEN'(CORE_ID) << (NW_BITS + NT_BITS)) + (`XLEN'(execute_if_data.wid) << NT_BITS) + wtid[i];
    end

    always @(*) begin
        csr_rd_enable = 0;
        case (csr_addr)
        `VX_CSR_THREAD_ID : csr_read_data = wtid;
        `VX_CSR_MHARTID   : csr_read_data = gtid;
        default : begin
            csr_read_data = {NUM_LANES{csr_read_data_ro | csr_read_data_rw}};
            csr_rd_enable = 1;
        end
        endcase
    end

    // CSR write

    assign csr_req_data = execute_if_data.op_args.csr.use_imm ? `XLEN'(csr_imm) : rs1_data[0];
    assign csr_wr_enable = csr_write_enable || (| csr_req_data);

    always @(*) begin
        case (execute_if_data.op_type)
            INST_SFU_CSRRW: begin
                csr_write_data = csr_req_data;
            end
            INST_SFU_CSRRS: begin
                csr_write_data = csr_read_data_rw | csr_req_data;
            end
            //INST_SFU_CSRRC
            default: begin
                csr_write_data = csr_read_data_rw & ~csr_req_data;
            end
        endcase
    end

    // unlock the warp
    assign sched_csr_if_unlock_warp = csr_req_valid && csr_req_ready && execute_if_data.eop && is_fpu_csr;
    assign sched_csr_if_unlock_wid = execute_if_data.wid;

    VX_elastic_buffer #(
        .DATAW (DATAW),
        .SIZE  (2)
    ) rsp_buf (
        .clk       (clk),
        .reset     (reset),
        .valid_in  (csr_req_valid),
        .ready_in  (csr_req_ready),
        .data_in   ({execute_if_data.uuid, execute_if_data.wid, execute_if_data.tmask, execute_if_data.PC, execute_if_data.rd, execute_if_data.wb, csr_read_data,       execute_if_data.pid, execute_if_data.sop, execute_if_data.eop}),
        .data_out  ({result_if_data.uuid,  result_if_data.wid,  result_if_data.tmask,  result_if_data.PC,  result_if_data.rd,  result_if_data.wb,  result_if_data.data, result_if_data.pid,  result_if_data.sop,  result_if_data.eop}),
        .valid_out (result_if_valid),
        .ready_out (result_if_ready)
    );

endmodule
