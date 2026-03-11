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
`include "VX_writeback_if.vh"
`include "VX_scoreboard_if.vh"
`include "VX_operands_if.vh"

module VX_operands import VX_gpu_pkg::*; #(
    parameter `STRING INSTANCE_ID = "",
    parameter ISSUE_ID  = 0
) (
    input wire              clk,
    input wire              reset,

`ifdef PERF_ENABLE
    output wire [PERF_CTR_BITS-1:0] perf_stalls,
`endif

    // VX_writeback_if.slave   writeback_if,
    input wire writeback_if_valid,
    input writeback_t writeback_if_data,

    // VX_scoreboard_if.slave  scoreboard_if,
    `VX_SCOREBOARD_IF_CONSUMER_PORTS(scoreboard_if),

    // VX_operands_if.master   operands_if
    `VX_OPERANDS_IF_PRODUCER_PORTS(operands_if)
);
    `UNUSED_SPARAM (ISSUE_ID)

    localparam OUT_DATAW = $bits(operands_t);

    // LSU cannot handle partial requests from multiple warps at the same time
    // this ensure that OPCs are dispatched atomically
    localparam OUT_ARB_STICKY = (`NUM_OPCS != 1) && (SIMD_COUNT != 1);

`ifdef PERF_ENABLE
    wire [`NUM_OPCS-1:0][PERF_CTR_BITS-1:0] per_opc_perf_stalls;
`endif

    // VX_operands_if per_opc_operands_if[`NUM_OPCS]();
    `VX_OPERANDS_IF_SIGNALS_N(per_opc_operands_if, `NUM_OPCS);

    wire [NUM_OPCS_W-1:0] sb_opc, wb_opc;
    if (`NUM_OPCS != 1) begin : g_wis_opc
        assign sb_opc = scoreboard_if_data.wis[NUM_OPCS_W-1:0];
        assign wb_opc = writeback_if_data.wis[NUM_OPCS_W-1:0];
    end else begin : g_wis_opc
        assign sb_opc = 0;
        assign wb_opc = 0;
    end

    wire [`NUM_OPCS-1:0] scoreboard_ready_in;
    assign scoreboard_if_ready = scoreboard_ready_in[sb_opc];

    for (genvar i = 0; i < `NUM_OPCS; i++) begin : g_collectors
        // select scoreboard interface
        // VX_scoreboard_if opc_scoreboard_if();
        `VX_SCOREBOARD_IF_SIGNALS(opc_scoreboard_if);
        assign opc_scoreboard_if_valid = scoreboard_if_valid && (sb_opc == i);
        assign opc_scoreboard_if_data  = scoreboard_if_data;
        assign scoreboard_ready_in[i]  = opc_scoreboard_if_ready;

        // select writeback interface
        VX_writeback_if opc_writeback_if();
        logic       opc_writeback_if_valid;
        writeback_t opc_writeback_if_data;

        assign opc_writeback_if_valid = writeback_if_valid && (wb_opc == i);
        assign opc_writeback_if_data  = writeback_if_data;

        VX_opc_unit #(
            .INSTANCE_ID  (`SFORMATF(("%s-collector%0d", INSTANCE_ID, i))),
            .NUM_BANKS    (`NUM_GPR_BANKS),
            .OUT_BUF      (3)
        ) opc_unit (
            .clk          (clk),
            .reset        (reset),
        `ifdef PERF_ENABLE
            .perf_stalls  (per_opc_perf_stalls[i]),
        `endif
            // .writeback_if (opc_writeback_if),
            `VX_WRITEBACK_IF_PASS_PORTS(writeback_if, opc_writeback_if),
            // .scoreboard_if(opc_scoreboard_if),
            `VX_SCOREBOARD_IF_PASS_PORTS(scoreboard_if, opc_scoreboard_if),
            // .operands_if  (per_opc_operands_if[i])
            `VX_OPERANDS_IF_PASS_PORTS_I(operands_if, per_opc_operands_if, i)
        );
    end

    `ITF_TO_AOS (per_opc_operands, per_opc_operands_if, `NUM_OPCS, OUT_DATAW)

    VX_stream_arb #(
        .NUM_INPUTS  (`NUM_OPCS),
        .NUM_OUTPUTS (1),
        .DATAW       (OUT_DATAW),
        .ARBITER     ("P"),
        .STICKY      (OUT_ARB_STICKY),
        .OUT_BUF     ((`NUM_OPCS > 1) ? 3 : 0)
    ) output_arb (
        .clk       (clk),
        .reset     (reset),
        .valid_in  (per_opc_operands_valid),
        .data_in   (per_opc_operands_data),
        .ready_in  (per_opc_operands_ready),
        .valid_out (operands_if_valid),
        .data_out  (operands_if_data),
        .ready_out (operands_if_ready),
        `UNUSED_PIN (sel_out)
    );

`ifdef PERF_ENABLE
    wire [PERF_CTR_BITS-1:0] perf_stalls_w;
    VX_reduce_tree #(
        .IN_W (PERF_CTR_BITS),
        .N    (`NUM_OPCS),
        .OP   ("+")
    ) perf_stalls_reduce (
        .data_in  (per_opc_perf_stalls),
        .data_out (perf_stalls_w)
    );
    `BUFFER(perf_stalls, perf_stalls_w);
`endif

endmodule
