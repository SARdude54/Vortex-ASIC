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
`include "VX_commit_sched_if.vh"
`include "VX_commit_csr_if.vh"
`include "VX_commit_if.vh"
`include "VX_writeback_if.vh"

module VX_commit import VX_gpu_pkg::*; #(
    parameter `STRING INSTANCE_ID = ""
) (
    input wire              clk,
    input wire              reset,

    // inputs
    // VX_commit_if.slave      commit_if [NUM_EX_UNITS * `ISSUE_WIDTH],
    `VX_COMMIT_IF_CONSUMER_PORTS(commit_if, NUM_EX_UNITS * `ISSUE_WIDTH),

    // outputs
    // VX_writeback_if.master  writeback_if  [`ISSUE_WIDTH],
    `VX_WRITEBACK_IF_PRODUCER_PORTS(writeback_if, `ISSUE_WIDTH),

    // VX_commit_csr_if.master commit_csr_if,
    `VX_COMMIT_CSR_IF_PRODUCER_PORTS(commit_csr_if),
    // VX_commit_sched_if.master commit_sched_if
    `VX_COMMIT_SCHED_IF_PRODUCER_PORTS(commit_sched_if)
);
    `UNUSED_SPARAM (INSTANCE_ID)
    localparam OUT_DATAW = $bits(commit_t);
    localparam COMMIT_SIZEW = `CLOG2(`SIMD_WIDTH + 1);
    localparam COMMIT_ALL_SIZEW = COMMIT_SIZEW + `ISSUE_WIDTH - 1;

    // commit arbitration

    // VX_commit_if commit_arb_if[`ISSUE_WIDTH]();\
    `VX_COMMIT_IF_SIGNALS(commit_arb_if, `ISSUE_WIDTH);

    wire [`ISSUE_WIDTH-1:0] per_issue_commit_fire;
    wire [`ISSUE_WIDTH-1:0][NW_WIDTH-1:0] per_issue_commit_wid;
    wire [`ISSUE_WIDTH-1:0][`SIMD_WIDTH-1:0] per_issue_commit_tmask;
    wire [`ISSUE_WIDTH-1:0] per_issue_commit_eop;

    for (genvar i = 0; i < `ISSUE_WIDTH; ++i) begin : g_commit_arbs

        wire [NUM_EX_UNITS-1:0]            valid_in;
        wire [NUM_EX_UNITS-1:0][OUT_DATAW-1:0] data_in;
        wire [NUM_EX_UNITS-1:0]            ready_in;

        for (genvar j = 0; j < NUM_EX_UNITS; ++j) begin : g_data_in
            assign valid_in[j] = commit_if_valid[j * `ISSUE_WIDTH + i];
            assign data_in[j]  = commit_if_data[j * `ISSUE_WIDTH + i];
            assign commit_if_ready[j * `ISSUE_WIDTH + i] = ready_in[j];
        end

        VX_stream_arb #(
            .NUM_INPUTS (NUM_EX_UNITS),
            .DATAW      (OUT_DATAW),
            .ARBITER    ("P"),
            .OUT_BUF    (1)
        ) commit_arb (
            .clk        (clk),
            .reset      (reset),
            .valid_in   (valid_in),
            .ready_in   (ready_in),
            .data_in    (data_in),
            .data_out   (commit_arb_if_data[i]),
            .valid_out  (commit_arb_if_valid[i]),
            .ready_out  (commit_arb_if_ready[i]),
            `UNUSED_PIN (sel_out)
        );

        assign per_issue_commit_fire[i] = commit_arb_if_valid[i] && commit_arb_if_ready[i];
        assign per_issue_commit_tmask[i]= {`SIMD_WIDTH{per_issue_commit_fire[i]}} & commit_arb_if_data[i].tmask;
        assign per_issue_commit_wid[i]  = commit_arb_if_data[i].wid;
        assign per_issue_commit_eop[i]  = commit_arb_if_data[i].eop;
    end

    // CSRs update

    wire [`ISSUE_WIDTH-1:0][COMMIT_SIZEW-1:0] commit_size, commit_size_r;
    wire [COMMIT_ALL_SIZEW-1:0] commit_size_all_r, commit_size_all_rr;
    wire commit_fire_any, commit_fire_any_r, commit_fire_any_rr;

    assign commit_fire_any = (| per_issue_commit_fire);

    for (genvar i = 0; i < `ISSUE_WIDTH; ++i) begin : g_commit_size
        wire [COMMIT_SIZEW-1:0] count;
        `POP_COUNT(count, per_issue_commit_tmask[i]);
        assign commit_size[i] = count;
    end

    VX_pipe_register #(
        .DATAW  (1 + `ISSUE_WIDTH * COMMIT_SIZEW),
        .RESETW (1)
    ) commit_size_reg1 (
        .clk      (clk),
        .reset    (reset),
        .enable   (1'b1),
        .data_in  ({commit_fire_any, commit_size}),
        .data_out ({commit_fire_any_r, commit_size_r})
    );

    VX_reduce_tree #(
        .IN_W  (COMMIT_SIZEW),
        .OUT_W (COMMIT_ALL_SIZEW),
        .N     (`ISSUE_WIDTH),
        .OP    ("+")
    ) commit_size_reduce (
        .data_in  (commit_size_r),
        .data_out (commit_size_all_r)
    );

    VX_pipe_register #(
        .DATAW  (1 + COMMIT_ALL_SIZEW),
        .RESETW (1)
    ) commit_size_reg2 (
        .clk      (clk),
        .reset    (reset),
        .enable   (1'b1),
        .data_in  ({commit_fire_any_r, commit_size_all_r}),
        .data_out ({commit_fire_any_rr, commit_size_all_rr})
    );

    reg [PERF_CTR_BITS-1:0] instret;
    always @(posedge clk) begin
       if (reset) begin
            instret <= '0;
        end else begin
            if (commit_fire_any_rr) begin
                instret <= instret + PERF_CTR_BITS'(commit_size_all_rr);
            end
        end
    end
    assign commit_csr_if_instret = instret;

    // Track committed instructions

    reg [`NUM_WARPS-1:0] committed_warps;

    always @(*) begin
        committed_warps = 0;
        for (integer i = 0; i < `ISSUE_WIDTH; ++i) begin
            if (per_issue_commit_fire[i] && per_issue_commit_eop[i]) begin
                committed_warps[per_issue_commit_wid[i]] = 1;
            end
        end
    end

    VX_pipe_register #(
        .DATAW  (`NUM_WARPS),
        .RESETW (`NUM_WARPS)
    ) committed_pipe_reg (
        .clk      (clk),
        .reset    (reset),
        .enable   (1'b1),
        .data_in  (committed_warps),
        .data_out ({commit_sched_if_committed_warps})
    );

    // Writeback

    for (genvar i = 0; i < `ISSUE_WIDTH; ++i) begin : g_writeback
        assign writeback_if_valid[i]     = commit_arb_if_valid[i] && commit_arb_if_data[i].wb;
        assign writeback_if_data[i].uuid = commit_arb_if_data[i].uuid;
        assign writeback_if_data[i].wis  = wid_to_wis(commit_arb_if_data[i].wid);
        assign writeback_if_data[i].sid  = commit_arb_if_data[i].sid;
        assign writeback_if_data[i].PC   = commit_arb_if_data[i].PC;
        assign writeback_if_data[i].tmask= commit_arb_if_data[i].tmask;
        assign writeback_if_data[i].rd   = commit_arb_if_data[i].rd;
        assign writeback_if_data[i].data = commit_arb_if_data[i].data;
        assign writeback_if_data[i].sop  = commit_arb_if_data[i].sop;
        assign writeback_if_data[i].eop  = commit_arb_if_data[i].eop;
        assign commit_arb_if_ready[i]    = 1;
    end

`ifdef DBG_TRACE_PIPELINE
    for (genvar i = 0; i < `ISSUE_WIDTH; ++i) begin : g_trace
        for (genvar j = 0; j < NUM_EX_UNITS; ++j) begin : g_j
            always @(posedge clk) begin
                if (commit_if_valid[j * `ISSUE_WIDTH + i] && commit_if_ready[j * `ISSUE_WIDTH + i]) begin
                    `TRACE(1, ("%t: %s: wid=%0d, sid=%0d, PC=0x%0h, ex=", $time, INSTANCE_ID, commit_if_data[j * `ISSUE_WIDTH + i].wid, commit_if_data[j * `ISSUE_WIDTH + i].sid, to_fullPC(commit_if_data[j * `ISSUE_WIDTH + i].PC)))
                    VX_trace_pkg::trace_ex_type(1, j);
                    `TRACE(1, (", tmask=%b, wb=%0d, rd=%0d, sop=%b, eop=%b, data=", commit_if_data[j * `ISSUE_WIDTH + i].tmask, commit_if_data[j * `ISSUE_WIDTH + i].wb, commit_if_data[j * `ISSUE_WIDTH + i].rd, commit_if_data[j * `ISSUE_WIDTH + i].sop, commit_if_data[j * `ISSUE_WIDTH + i].eop))
                    `TRACE_ARRAY1D(1, "0x%0h", commit_if_data[j * `ISSUE_WIDTH + i].data, `SIMD_WIDTH)
                    `TRACE(1, (" (#%0d)\n", commit_if_data[j * `ISSUE_WIDTH + i].uuid))
                end
            end
        end
    end
`endif

endmodule
