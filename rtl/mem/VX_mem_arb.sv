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

module VX_mem_arb import VX_gpu_pkg::*; #(
    parameter NUM_INPUTS     = 1,
    parameter NUM_OUTPUTS    = 1,
    parameter DATA_SIZE      = 1,
    parameter TAG_WIDTH      = 1,
    parameter TAG_SEL_IDX    = 0,
    parameter REQ_OUT_BUF    = 0,
    parameter RSP_OUT_BUF    = 0,
    parameter `STRING ARBITER = "R",
    parameter MEM_ADDR_WIDTH = `MEM_ADDR_WIDTH,
    parameter ADDR_WIDTH     = (MEM_ADDR_WIDTH-`CLOG2(DATA_SIZE)),
    parameter FLAGS_WIDTH    = MEM_FLAGS_WIDTH,
    parameter LOG_NUM_REQS   = `ARB_SEL_BITS(NUM_INPUTS, NUM_OUTPUTS),
    parameter ARB_TAG_WIDTH  = TAG_WIDTH + LOG_NUM_REQS
) (
    input wire              clk,
    input wire              reset,

    // VX_mem_bus_if.slave     bus_in_if [NUM_INPUTS],
    `VX_MEM_BUS_IF_CONSUMER_PORTS_N(bus_in_if, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH, NUM_INPUTS),
    //VX_mem_bus_if.master    bus_out_if [NUM_OUTPUTS]
    `VX_MEM_BUS_IF_PRODUCER_PORTS_N(bus_out_if, DATA_SIZE, ARB_TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH, NUM_OUTPUTS)

);
    localparam DATA_WIDTH   = (8 * DATA_SIZE);
    localparam REQ_DATAW    = 1 + ADDR_WIDTH + DATA_WIDTH + DATA_SIZE + FLAGS_WIDTH + TAG_WIDTH;
    localparam RSP_DATAW    = DATA_WIDTH + TAG_WIDTH;
    localparam SEL_COUNT    = `MIN(NUM_INPUTS, NUM_OUTPUTS);

    // Need to chack these
    `STATIC_ASSERT(NUM_INPUTS > 0, ("NUM_INPUTS must be > 0"))
    `STATIC_ASSERT(NUM_OUTPUTS > 0, ("NUM_OUTPUTS must be > 0"))
    `STATIC_ASSERT(DATA_SIZE > 0, ("DATA_SIZE must be > 0"))
    `STATIC_ASSERT(TAG_WIDTH >= `UP(UUID_WIDTH), ("invalid TAG_WIDTH"))
    `STATIC_ASSERT(ARB_TAG_WIDTH >= TAG_WIDTH, ("invalid ARB_TAG_WIDTH"))

    wire [NUM_INPUTS-1:0]                 req_valid_in;
    wire [NUM_INPUTS-1:0][REQ_DATAW-1:0]  req_data_in;
    wire [NUM_INPUTS-1:0]                 req_ready_in;

    wire [NUM_OUTPUTS-1:0]                req_valid_out;
    wire [NUM_OUTPUTS-1:0][REQ_DATAW-1:0] req_data_out;
    wire [SEL_COUNT-1:0][`UP(LOG_NUM_REQS)-1:0] req_sel_out;
    wire [NUM_OUTPUTS-1:0]                req_ready_out;

    for (genvar i = 0; i < NUM_INPUTS; ++i) begin : g_req_data_in
        assign req_valid_in[i] = bus_in_if_req_valid[i];
        assign req_data_in[i] = {
            bus_in_if_req_data_rw[i],
            bus_in_if_req_data_addr[i],
            bus_in_if_req_data_data[i],
            bus_in_if_req_data_byteen[i],
            bus_in_if_req_data_flags[i],
            bus_in_if_req_data_tag_uuid[i],
            bus_in_if_req_data_tag_value[i]
        };
        assign bus_in_if_req_ready[i] = req_ready_in[i];
    end

    VX_stream_arb #(
        .NUM_INPUTS  (NUM_INPUTS),
        .NUM_OUTPUTS (NUM_OUTPUTS),
        .DATAW       (REQ_DATAW),
        .ARBITER     (ARBITER),
        .OUT_BUF     (REQ_OUT_BUF)
    ) req_arb (
        .clk       (clk),
        .reset     (reset),
        .valid_in  (req_valid_in),
        .ready_in  (req_ready_in),
        .data_in   (req_data_in),
        .data_out  (req_data_out),
        .sel_out   (req_sel_out),
        .valid_out (req_valid_out),
        .ready_out (req_ready_out)
    );

    for (genvar i = 0; i < NUM_OUTPUTS; ++i) begin : g_bus_out_if
        wire [TAG_WIDTH-1:0]     req_tag_out;
        wire [ARB_TAG_WIDTH-1:0] req_tag_out_w;

        assign bus_out_if_req_valid[i] = req_valid_out[i];

        assign {
            bus_out_if_req_data_rw[i],
            bus_out_if_req_data_addr[i],
            bus_out_if_req_data_data[i],
            bus_out_if_req_data_byteen[i],
            bus_out_if_req_data_flags[i],
            req_tag_out
        } = req_data_out[i];

        assign req_ready_out[i] = bus_out_if_req_ready[i];

        if (NUM_INPUTS > NUM_OUTPUTS) begin : g_req_tag_sel_out
            VX_bits_insert #(
                .N   (TAG_WIDTH),
                .S   (LOG_NUM_REQS),
                .POS (TAG_SEL_IDX)
            ) bits_insert (
                .data_in  (req_tag_out),
                .ins_in   (req_sel_out[i]),
                .data_out (req_tag_out_w)
            );
        end else begin : g_req_tag_out
            `UNUSED_VAR (req_sel_out)
            assign req_tag_out_w = req_tag_out;
        end

        assign {
            bus_out_if_req_data_tag_uuid[i],
            bus_out_if_req_data_tag_value[i]
        } = req_tag_out_w;
    end

    ///////////////////////////////////////////////////////////////////////////

    wire [NUM_INPUTS-1:0]                 rsp_valid_out;
    wire [NUM_INPUTS-1:0][RSP_DATAW-1:0]  rsp_data_out;
    wire [NUM_INPUTS-1:0]                 rsp_ready_out;

    wire [NUM_OUTPUTS-1:0]                rsp_valid_in;
    wire [NUM_OUTPUTS-1:0][RSP_DATAW-1:0] rsp_data_in;
    wire [NUM_OUTPUTS-1:0]                rsp_ready_in;

    if (NUM_INPUTS > NUM_OUTPUTS) begin : g_rsp_select

        wire [NUM_OUTPUTS-1:0][LOG_NUM_REQS-1:0] rsp_sel_in;

        for (genvar i = 0; i < NUM_OUTPUTS; ++i) begin : g_rsp_data_in
            wire [ARB_TAG_WIDTH-1:0] bus_out_rsp_tag;
            wire [TAG_WIDTH-1:0]     rsp_tag_out;

            assign bus_out_rsp_tag = {
                bus_out_if_rsp_data_tag_uuid[i],
                bus_out_if_rsp_data_tag_value[i]
            };

            VX_bits_remove #(
                .N   (ARB_TAG_WIDTH),
                .S   (LOG_NUM_REQS),
                .POS (TAG_SEL_IDX)
            ) bits_remove (
                .data_in  (bus_out_rsp_tag),
                .sel_out  (rsp_sel_in[i]),
                .data_out (rsp_tag_out)
            );

            assign rsp_valid_in[i] = bus_out_if_rsp_valid[i];

            assign rsp_data_in[i] = {
                bus_out_if_rsp_data_data[i],
                rsp_tag_out
            };

            assign bus_out_if_rsp_ready[i] = rsp_ready_in[i];
        end

        VX_stream_switch #(
            .NUM_INPUTS  (NUM_OUTPUTS),
            .NUM_OUTPUTS (NUM_INPUTS),
            .DATAW       (RSP_DATAW),
            .OUT_BUF     (RSP_OUT_BUF)
        ) rsp_switch (
            .clk       (clk),
            .reset     (reset),
            .sel_in    (rsp_sel_in),
            .valid_in  (rsp_valid_in),
            .ready_in  (rsp_ready_in),
            .data_in   (rsp_data_in),
            .data_out  (rsp_data_out),
            .valid_out (rsp_valid_out),
            .ready_out (rsp_ready_out)
        );

    end else begin : g_rsp_arb

        for (genvar i = 0; i < NUM_OUTPUTS; ++i) begin : g_rsp_data_in
            assign rsp_valid_in[i] = bus_out_if_rsp_valid[i];

            assign rsp_data_in[i] = {
                bus_out_if_rsp_data_data[i],
                bus_out_if_rsp_data_tag_uuid[i],
                bus_out_if_rsp_data_tag_value[i]
            };

            assign bus_out_if_rsp_ready[i] = rsp_ready_in[i];
        end

        VX_stream_arb #(
            .NUM_INPUTS  (NUM_OUTPUTS),
            .NUM_OUTPUTS (NUM_INPUTS),
            .DATAW       (RSP_DATAW),
            .ARBITER     (ARBITER),
            .OUT_BUF     (RSP_OUT_BUF)
        ) rsp_arb (
            .clk       (clk),
            .reset     (reset),
            .valid_in  (rsp_valid_in),
            .ready_in  (rsp_ready_in),
            .data_in   (rsp_data_in),
            .data_out  (rsp_data_out),
            .valid_out (rsp_valid_out),
            .ready_out (rsp_ready_out),
            `UNUSED_PIN (sel_out)
        );

    end

    for (genvar i = 0; i < NUM_INPUTS; ++i) begin : g_output
        assign bus_in_if_rsp_valid[i] = rsp_valid_out[i];
        assign {
            bus_in_if_rsp_data_data[i],
            bus_in_if_rsp_data_tag_uuid[i],
            bus_in_if_rsp_data_tag_value[i]
        } = rsp_data_out[i];
        assign rsp_ready_out[i] = bus_in_if_rsp_ready[i];
    end

endmodule
