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
`include "VX_mem_bus_if.vh"

`include "VX_dcr_bus_if.vh"

module VX_socket import VX_gpu_pkg::*; #(
    parameter SOCKET_ID = 0,
    parameter `STRING INSTANCE_ID = "",
    parameter int NPORTS = `L1_MEM_PORTS
) (
    `SCOPE_IO_DECL

    // Clock
    input wire              clk,
    input wire              reset,

`ifdef PERF_ENABLE
    input sysmem_perf_t     sysmem_perf,
`endif
    // memory bus signals (flattened)
    // mem_req_data [NPORTS]. Flattened input  vx_mem_req_data_t  mem_req_data [NPORTS],
    `VX_MEM_BUS_PORTS_IN(mem, NPORTS, ADDR_WIDTH, DATA_SIZE, FLAGS_WIDTH, UUID_WIDTH, TAG_WIDTH),
    // DCRs
    // flatten: VX_dcr_bus_if.slave     dcr_bus_if,
    `VX_DCR_BUS_CONSUMER_PORTS(dcr_bus_if, VX_DCR_ADDR_WIDTH, VX_DCR_DATA_WIDTH),


`ifdef GBAR_ENABLE
    // Barrier
    VX_gbar_bus_if.master   gbar_bus_if,
`endif
    // Status
    output wire             busy
);

`ifdef SCOPE
    localparam scope_core = 0;
    `SCOPE_IO_SWITCH (`SOCKET_SIZE);
`endif

`ifdef GBAR_ENABLE
    VX_gbar_bus_if per_core_gbar_bus_if[`SOCKET_SIZE]();

    VX_gbar_arb #(
        .NUM_REQS (`SOCKET_SIZE),
        .OUT_BUF  ((`SOCKET_SIZE > 1) ? 2 : 0)
    ) gbar_arb (
        .clk        (clk),
        .reset      (reset),
        .bus_in_if  (per_core_gbar_bus_if),
        .bus_out_if (gbar_bus_if)
    );
`endif

    ///////////////////////////////////////////////////////////////////////////

`ifdef PERF_ENABLE
    cache_perf_t icache_perf, dcache_perf;
    sysmem_perf_t sysmem_perf_tmp;
    always @(*) begin
        sysmem_perf_tmp = sysmem_perf;
        sysmem_perf_tmp.icache = icache_perf;
        sysmem_perf_tmp.dcache = dcache_perf;
    end
`endif

    ///////////////////////////////////////////////////////////////////////////

    VX_mem_bus_if #(
        .DATA_SIZE (ICACHE_WORD_SIZE),
        .TAG_WIDTH (ICACHE_TAG_WIDTH)
    ) per_core_icache_bus_if[`SOCKET_SIZE]();


    // flattened per_core_icache_bus_if

    // VX_mem_bus_if #(
    //     .DATA_SIZE (ICACHE_WORD_SIZE),
    //     .TAG_WIDTH (ICACHE_TAG_WIDTH)
    // ) per_core_icache_bus_if[`SOCKET_SIZE]();

    `VX_MEM_BUS_SIGNALS(per_core_icache, `SOCKET_SIZE, ADDR_W, ICACHE_WORD_SIZE, FLAGS_W, UUID_W, ICACHE_TAG_WIDTH)


    // flattened icache_mem_bus_if
    // VX_mem_bus_if #(
    //     .DATA_SIZE (ICACHE_LINE_SIZE),
    //     .TAG_WIDTH (ICACHE_MEM_TAG_WIDTH)
    // ) icache_mem_bus_if[1]();

    `VX_MEM_BUS_SIGNALS(icache, 1, ADDR_W, ICACHE_LINE_SIZE, FLAGS_W, UUID_W, ICACHE_MEM_TAG_WIDTH)
    

    `RESET_RELAY (icache_reset, reset);

    // TODO: flatten signals

    VX_cache_cluster #(
        .INSTANCE_ID    (`SFORMATF(("%s-icache", INSTANCE_ID))),
        .NUM_UNITS      (`NUM_ICACHES),
        .NUM_INPUTS     (`SOCKET_SIZE),
        .TAG_SEL_IDX    (0),
        .CACHE_SIZE     (`ICACHE_SIZE),
        .LINE_SIZE      (ICACHE_LINE_SIZE),
        .NUM_BANKS      (1),
        .NUM_WAYS       (`ICACHE_NUM_WAYS),
        .WORD_SIZE      (ICACHE_WORD_SIZE),
        .NUM_REQS       (1),
        .MEM_PORTS      (1),
        .CRSQ_SIZE      (`ICACHE_CRSQ_SIZE),
        .MSHR_SIZE      (`ICACHE_MSHR_SIZE),
        .MRSQ_SIZE      (`ICACHE_MRSQ_SIZE),
        .MREQ_SIZE      (`ICACHE_MREQ_SIZE),
        .TAG_WIDTH      (ICACHE_TAG_WIDTH),
        .WRITE_ENABLE   (0),
        .REPL_POLICY    (`ICACHE_REPL_POLICY),
        .NC_ENABLE      (0),
        .CORE_OUT_BUF   (3),
        .MEM_OUT_BUF    (2)
    ) icache (
    `ifdef PERF_ENABLE
        .cache_perf     (icache_perf),
    `endif
        .clk            (clk),
        .reset          (icache_reset),
        // replaces: .core_bus_if    (per_core_icache_bus_if),
        `VX_MEM_BUS_PASS_SIGNALS(per_core_icache, `SOCKET_SIZE, ADDR_W, ICACHE_WORD_SIZE, FLAGS_W, UUID_W, ICACHE_TAG_WIDTH),
        // replace: .mem_bus_if     (icache_mem_bus_if)
        `VX_MEM_BUS_PASS_SIGNALS(icache, 1, ADDR_W, ICACHE_LINE_SIZE, FLAGS_W, UUID_W, ICACHE_MEM_TAG_WIDTH)
        

    );

    ///////////////////////////////////////////////////////////////////////////

    // flattened per_core_dcache_bus_if()
    // VX_mem_bus_if #(
    //     .DATA_SIZE (DCACHE_WORD_SIZE),
    //     .TAG_WIDTH (DCACHE_TAG_WIDTH)
    // ) per_core_dcache_bus_if[`SOCKET_SIZE * DCACHE_NUM_REQS]();

    `VX_MEM_BUS_SIGNALS(per_core_dcache, `SOCKET_SIZE * DCACHE_NUM_REQS, ADDR_W, DCACHE_WORD_SIZE, FLAGS_W, UUID_W, DCACHE_TAG_WIDTH)

    // dcache_mem_bus_if
    // VX_mem_bus_if #(
    //     .DATA_SIZE (DCACHE_LINE_SIZE),
    //     .TAG_WIDTH (DCACHE_MEM_TAG_WIDTH)
    // ) dcache_mem_bus_if[`L1_MEM_PORTS]();
    `VX_MEM_BUS_SIGNALS(dcache, `L1_MEM_PORTS, ADDR_W, DCACHE_LINE_SIZE, FLAGS_W, UUID_W, DCACHE_MEM_TAG_WIDTH)

    `RESET_RELAY (dcache_reset, reset);

    // TODO: Flatten this module
    VX_cache_cluster #(
        .INSTANCE_ID    (`SFORMATF(("%s-dcache", INSTANCE_ID))),
        .NUM_UNITS      (`NUM_DCACHES),
        .NUM_INPUTS     (`SOCKET_SIZE),
        .TAG_SEL_IDX    (0),
        .CACHE_SIZE     (`DCACHE_SIZE),
        .LINE_SIZE      (DCACHE_LINE_SIZE),
        .NUM_BANKS      (`DCACHE_NUM_BANKS),
        .NUM_WAYS       (`DCACHE_NUM_WAYS),
        .WORD_SIZE      (DCACHE_WORD_SIZE),
        .NUM_REQS       (DCACHE_NUM_REQS),
        .MEM_PORTS      (`L1_MEM_PORTS),
        .CRSQ_SIZE      (`DCACHE_CRSQ_SIZE),
        .MSHR_SIZE      (`DCACHE_MSHR_SIZE),
        .MRSQ_SIZE      (`DCACHE_MRSQ_SIZE),
        .MREQ_SIZE      (`DCACHE_WRITEBACK ? `DCACHE_MSHR_SIZE : `DCACHE_MREQ_SIZE),
        .TAG_WIDTH      (DCACHE_TAG_WIDTH),
        .WRITE_ENABLE   (1),
        .WRITEBACK      (`DCACHE_WRITEBACK),
        .DIRTY_BYTES    (`DCACHE_DIRTYBYTES),
        .REPL_POLICY    (`DCACHE_REPL_POLICY),
        .NC_ENABLE      (1),
        .CORE_OUT_BUF   (3),
        .MEM_OUT_BUF    (2)
    ) dcache (
    `ifdef PERF_ENABLE
        .cache_perf     (dcache_perf),
    `endif
        .clk            (clk),
        .reset          (dcache_reset),
        .core_bus_if    (per_core_dcache_bus_if),

        // replace: .mem_bus_if     (dcache_mem_bus_if)

        `VX_MEM_BUS_PASS_SIGNALS(dcache, N, ADDR_W, DATA_SIZE, FLAGS_W, UUID_W, TAG_W)
    );

    ///////////////////////////////////////////////////////////////////////////

    for (genvar i = 0; i < `L1_MEM_PORTS; ++i) begin : g_mem_bus_if
        if (i == 0) begin : g_i0


            // l1_mem_bus_if()
            // VX_mem_bus_if #(
            //     .DATA_SIZE (`L1_LINE_SIZE),
            //     .TAG_WIDTH (L1_MEM_TAG_WIDTH)
            // ) l1_mem_bus_if[2]();

            `VX_MEM_BUS_SIGNALS(l1_mem, 2, ADDR_W, `L1_LINE_SIZE, FLAGS_W, UUID_W, L1_MEM_TAG_WIDTH)

            // l1_mem_arb_bus_if()
            // VX_mem_bus_if #(
            //     .DATA_SIZE (`L1_LINE_SIZE),
            //     .TAG_WIDTH (L1_MEM_ARB_TAG_WIDTH)
            // ) l1_mem_arb_bus_if[1]();

            `VX_MEM_BUS_SIGNALS(l1_mem_arb, 1, ADDR_W, L1_LINE_SIZE, FLAGS_W, UUID_W, L1_MEM_ARB_TAG_WIDTH)

            // Modified: `ASSIGN_VX_MEM_BUS_IF_EX (l1_mem_bus_if[0], icache_mem_bus_if[0], L1_MEM_TAG_WIDTH, ICACHE_MEM_TAG_WIDTH, UUID_WIDTH);
            `ASSIGN_VX_MEM_BUS_FLAT_EX(l1_mem, icache_mem, N, L1_ADDR_W, ICACHE_ADDR_W,
                           (L1_MEM_TAG_WIDTH-`UP(UUID_W)), //
                           (ICACHE_MEM_TAG_WIDTH-`UP(UUID_W)))

            // `ASSIGN_VX_MEM_BUS_IF_EX (l1_mem_bus_if[1], dcache_mem_bus_if[0], L1_MEM_TAG_WIDTH, DCACHE_MEM_TAG_WIDTH, UUID_WIDTH);
            `ASSIGN_VX_MEM_BUS_FLAT_EX(l1_mem, dcache_mem, N, L1_ADDR_W, DCACHE_ADDR_WIDTH,
                           (L1_MEM_TAG_WIDTH-`UP(UUID_W)), //
                           (DCACHE_TAG_WIDTH-`UP(UUID_W)))

            // `ASSIGN_VX_MEM_BUS_FLAT_EX(dst, src, \
            //                      ADDR_D, ADDR_S, \
            //                      TAG_D, TAG_S, UUID_W

            // TODO: flatten this module
            VX_msem_arb #(
                .NUM_INPUTS (2),
                .NUM_OUTPUTS(1),
                .DATA_SIZE  (`L1_LINE_SIZE),
                .TAG_WIDTH  (L1_MEM_TAG_WIDTH),
                .TAG_SEL_IDX(0),
                .ARBITER    ("P"), // prioritize the icache
                .REQ_OUT_BUF(3),
                .RSP_OUT_BUF(3)
            ) mem_arb (
                .clk        (clk),
                .reset      (reset),
                .bus_in_if  (l1_mem_bus_if),
                .bus_out_if (l1_mem_arb_bus_if)
            );

            `VX_MEM_BUS_SIGNALS(prefix, N, ADDR_W, DATA_SIZE, FLAGS_W, UUID_W, TAG_W)



            // modified: `ASSIGN_VX_MEM_BUS_IF (mem_bus_if[0], l1_mem_arb_bus_if[0]);
            `ASSIGN_VX_MEM_BUS_IF (mem, l1_mem_arb, 0);


            
            /*
            
            `define ASSIGN_VX_MEM_BUS_IF(dst, src) \
                assign dst.req_valid  = src.req_valid; \
                assign dst.req_data   = src.req_data; \
                assign src.req_ready  = dst.req_ready; \
                assign src.rsp_valid  = dst.rsp_valid; \
                assign src.rsp_data   = dst.rsp_data; \
                assign dst.rsp_ready  = src.rsp_ready
            
            */


        end else begin : g_i

            // flattened: l1_mem_arb_bus_if()
            // VX_mem_bus_if #(
            //     .DATA_SIZE (`L1_LINE_SIZE),
            //     .TAG_WIDTH (L1_MEM_ARB_TAG_WIDTH)
            // ) l1_mem_arb_bus_if();

            `VX_MEM_BUS_SIGNALS(l1_mem_arb, N, ADDR_W, `L1_LINE_SIZE, FLAGS_W, UUID_W, L1_MEM_ARB_TAG_WIDTH)

            // Modified: `ASSIGN_VX_MEM_BUS_IF_EX (l1_mem_arb_bus_if, dcache_mem_bus_if[i], L1_MEM_ARB_TAG_WIDTH, DCACHE_MEM_TAG_WIDTH, UUID_WIDTH);
            `ASSIGN_VX_MEM_BUS_FLAT_EX(l1_mem_arb, dcache_mem, N, L1_ADDR_W, DCACHE_ADDR_WIDTH,
                           (L1_MEM_ARB_TAG_WIDTH-`UP(UUID_W)), //
                           (DCACHE_MEM_TAG_WIDTH-`UP(UUID_W)))
            
            // modified: `ASSIGN_VX_MEM_BUS_IF (mem_bus_if[i], l1_mem_arb_bus_if);
            
            `ASSIGN_VX_MEM_BUS_FLAT_EX(mem, l1_mem_arb, ADDR_D, ADDR_S, TAG_D, TAG_S, UUID_W)
        
        end
    end

    ///////////////////////////////////////////////////////////////////////////

    wire [`SOCKET_SIZE-1:0] per_core_busy;

    // Generate all cores
    for (genvar core_id = 0; core_id < `SOCKET_SIZE; ++core_id) begin : g_cores

        `RESET_RELAY (core_reset, reset);

        // flatten: VX_dcr_bus_if core_dcr_bus_if();
        `VX_DCR_BUS_SIGNALS(core_dcr_bus_if, VX_DCR_ADDR_WIDTH, VX_DCR_DATA_WIDTH)

        // modified
        `BUFFER_DCR_BUS_IF (core_dcr_bus_if, dcr_bus_if, 1'b1, (`SOCKET_SIZE > 1))

        VX_core #(
            .CORE_ID  ((SOCKET_ID * `SOCKET_SIZE) + core_id),
            .INSTANCE_ID (`SFORMATF(("%s-core%0d", INSTANCE_ID, core_id)))
        ) core (
            `SCOPE_IO_BIND  (scope_core + core_id)
            
            .clk            (clk),
            .reset          (core_reset),

        `ifdef PERF_ENABLE
            .sysmem_perf    (sysmem_perf_tmp),
        `endif

            // .dcr_bus_if     (core_dcr_bus_if),
            `VX_DCR_BUS_PASS_PORTS(dcr_bus_if, core_dcr_bus_if),

            .dcache_bus_if  (per_core_dcache_bus_if[core_id * DCACHE_NUM_REQS +: DCACHE_NUM_REQS]),

            .icache_bus_if  (per_core_icache_bus_if[core_id]),

        `ifdef GBAR_ENABLE
            .gbar_bus_if    (per_core_gbar_bus_if[core_id]),
        `endif

            .busy           (per_core_busy[core_id])
        );
    end

    `BUFFER_EX(busy, (| per_core_busy), 1'b1, 1, (`SOCKET_SIZE > 1));

endmodule