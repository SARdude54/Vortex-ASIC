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
`include "VX_decode_if.vh"
`include "VX_issue_sched_if.vh"
`include "VX_dispatch_if.vh"
`include "VX_writeback_if.vh"

module VX_issue import VX_gpu_pkg::*; #(
    parameter `STRING INSTANCE_ID = ""
) (
    `SCOPE_IO_DECL

    input wire              clk,
    input wire              reset,

`ifdef PERF_ENABLE
    output issue_perf_t     issue_perf,
`endif

    //flatten: VX_decode_if.slave      decode_if,
    `VX_DECODE_IF_CONSUMER_PORTS(decode_if),

    // VX_writeback_if.slave   writeback_if [`ISSUE_WIDTH],
    `VX_WRITEBACK_IF_CONSUMER_PORTS(writeback_if, `ISSUE_WIDTH),

    // VX_dispatch_if.master   dispatch_if [NUM_EX_UNITS * `ISSUE_WIDTH],
    `VX_DISPATCH_IF_PRODUCER_PORTS(dispatch_if, NUM_EX_UNITS * `ISSUE_WIDTH),
    
    // flatten: VX_issue_sched_if.master issue_sched_if[`ISSUE_WIDTH]
    `VX_ISSUE_SCHED_IF_PRODUCER_PORTS(issue_sched_if, `ISSUE_WIDTH)
);
    `STATIC_ASSERT ((`ISSUE_WIDTH <= `NUM_WARPS), ("invalid parameter"))

`ifdef PERF_ENABLE
    issue_perf_t per_issue_perf [`ISSUE_WIDTH];
    `PERF_COUNTER_ADD (issue_perf, per_issue_perf, ibf_stalls, PERF_CTR_BITS, `ISSUE_WIDTH, (`ISSUE_WIDTH > 2))
    `PERF_COUNTER_ADD (issue_perf, per_issue_perf, scb_stalls, PERF_CTR_BITS, `ISSUE_WIDTH, (`ISSUE_WIDTH > 2))
    `PERF_COUNTER_ADD (issue_perf, per_issue_perf, opd_stalls, PERF_CTR_BITS, `ISSUE_WIDTH, (`ISSUE_WIDTH > 2))
    for (genvar i = 0; i < NUM_EX_UNITS; ++i) begin : g_issue_perf_units_uses
        `PERF_COUNTER_ADD (issue_perf, per_issue_perf, units_uses[i], PERF_CTR_BITS, `ISSUE_WIDTH, (`ISSUE_WIDTH > 2))
    end
    for (genvar i = 0; i < NUM_SFU_UNITS; ++i) begin : g_issue_perf_sfu_uses
        `PERF_COUNTER_ADD (issue_perf, per_issue_perf, sfu_uses[i], PERF_CTR_BITS, `ISSUE_WIDTH, (`ISSUE_WIDTH > 2))
    end
`endif

    wire [ISSUE_ISW_W-1:0] decode_isw = wid_to_isw(decode_if_data.wid);

    wire [`ISSUE_WIDTH-1:0] decode_ready_in;
    assign decode_if_ready = decode_ready_in[decode_isw];

    `SCOPE_IO_SWITCH (`ISSUE_WIDTH);

    for (genvar issue_id = 0; issue_id < `ISSUE_WIDTH; ++issue_id) begin : g_slices
        // flatten: VX_decode_if slice_decode_if();
        `VX_DECODE_IF_SIGNALS(slice_decode_if)


        // VX_dispatch_if per_issue_dispatch_if[NUM_EX_UNITS]();
        `VX_DISPATCH_IF_SIGNALS(per_issue_dispatch_if, NUM_EX_UNITS);

        assign slice_decode_if_valid = decode_if_valid && (decode_isw == issue_id);
        assign slice_decode_if_data  = decode_if_data;
        assign decode_ready_in[issue_id] = slice_decode_if_ready;

    `ifndef L1_ENABLE
        assign decode_if_ibuf_pop[issue_id * PER_ISSUE_WARPS +: PER_ISSUE_WARPS] = slice_decode_if_ibuf_pop;
    `endif

        VX_issue_slice #(
            .INSTANCE_ID (`SFORMATF(("%s%0d", INSTANCE_ID, issue_id))),
            .ISSUE_ID (issue_id)
        ) issue_slice (
            `SCOPE_IO_BIND(issue_id)
            .clk          (clk),
            .reset        (reset),
        `ifdef PERF_ENABLE
            .issue_perf   (per_issue_perf[issue_id]),
        `endif
            // flatten: .decode_if    (slice_decode_if),
            `VX_DECODE_IF_PASS_PORTS(decode_if, slice_decode_if),
            // .writeback_if (writeback_if[issue_id]),
            .writeback_if_valid(`VX_WRITEBACK_IF_SLICE_VALID(writeback_if, issue_id)),
            .writeback_if_data(`VX_WRITEBACK_IF_SLICE_DATA(writeback_if, issue_id)),
            // .dispatch_if  (per_issue_dispatch_if),
            `VX_DISPATCH_IF_PASS_PORTS(dispatch_if, per_issue_dispatch_if),
            // flatten passing ports and multidimensional .issue_sched_if(issue_sched_if[issue_id])
            .issue_sched_if_valid(`VX_ISSUE_SCHED_IF_VALID_BIT(issue_sched_if, issue_id)),
            .issue_sched_if_wis(`VX_ISSUE_SCHED_IF_WIS_SLICE(issue_sched_if, issue_id))
        );

        // Assign transposed dispatch_if
        for (genvar ex_id = 0; ex_id < NUM_EX_UNITS; ++ex_id) begin : g_dispatch_if
            // do this manually: `ASSIGN_VX_IF(dispatch_if[ex_id * `ISSUE_WIDTH + issue_id], per_issue_dispatch_if[ex_id]);
            assign dispatch_if_valid[ex_id * `ISSUE_WIDTH + issue_id] = per_issue_dispatch_if_valid[ex_id];
            assign dispatch_if_data[ex_id * `ISSUE_WIDTH + issue_id] = per_issue_dispatch_if_data[ex_id];
            assign per_issue_dispatch_if_ready[ex_id] = dispatch_if_ready[ex_id * `ISSUE_WIDTH + issue_id];
 
        end
     end

endmodule
