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
`include "VX_lsu_mem_if.vh"

module VX_lmem_switch import VX_gpu_pkg::*; #(
    parameter GLOBAL_OUT_BUF = 0,
    parameter LOCAL_OUT_BUF = 0,
    parameter RSP_OUT_BUF = 0,
    parameter `STRING ARBITER = "R"
) (
    input wire              clk,
    input wire              reset,
    // VX_lsu_mem_if.slave     lsu_in_if,
    `VX_LSU_MEM_IF_CONSUMER_PORTS(lsu_in_if, `NUM_LSU_LANES, LSU_WORD_SIZE, LSU_TAG_WIDTH, MEM_FLAGS_WIDTH, `MEM_ADDR_WIDTH),
    // VX_lsu_mem_if.master    global_out_if,
    `VX_LSU_MEM_IF_PRODUCER_PORTS(global_out_if, `NUM_LSU_LANES, LSU_WORD_SIZE, LSU_TAG_WIDTH, MEM_FLAGS_WIDTH, `MEM_ADDR_WIDTH),
    // VX_lsu_mem_if.master    local_out_if
    `VX_LSU_MEM_IF_PRODUCER_PORTS(local_out_if, `NUM_LSU_LANES, LSU_WORD_SIZE, LSU_TAG_WIDTH, MEM_FLAGS_WIDTH, `MEM_ADDR_WIDTH)
);
    localparam REQ_DATAW = `NUM_LSU_LANES + 1 + `NUM_LSU_LANES * (LSU_WORD_SIZE + LSU_ADDR_WIDTH + MEM_FLAGS_WIDTH + LSU_WORD_SIZE * 8) + LSU_TAG_WIDTH;
    localparam RSP_DATAW = `NUM_LSU_LANES + `NUM_LSU_LANES * (LSU_WORD_SIZE * 8) + LSU_TAG_WIDTH;

    wire [`NUM_LSU_LANES-1:0] is_addr_local_mask;
    wire req_global_ready;
    wire req_local_ready;

    for (genvar i = 0; i < `NUM_LSU_LANES; ++i) begin : g_is_addr_local_mask
        assign is_addr_local_mask[i] = lsu_in_if_req_data_flags[i][MEM_REQ_FLAG_LOCAL];
    end

    wire is_addr_global = | (lsu_in_if_req_data_mask & ~is_addr_local_mask);
    wire is_addr_local  = | (lsu_in_if_req_data_mask & is_addr_local_mask);

    assign lsu_in_if_req_ready = (req_global_ready && is_addr_global)
                              || (req_local_ready && is_addr_local);

    wire [LSU_TAG_WIDTH-1:0] lsu_in_req_tag;

    assign lsu_in_req_tag = {
        lsu_in_if_req_data_tag_uuid,
        lsu_in_if_req_data_tag_value
    };

    wire [REQ_DATAW-1:0] global_req_data_out;
    wire [REQ_DATAW-1:0] local_req_data_out;

    VX_elastic_buffer #(
        .DATAW   (REQ_DATAW),
        .SIZE    (`TO_OUT_BUF_SIZE(GLOBAL_OUT_BUF)),
        .OUT_REG (`TO_OUT_BUF_REG(GLOBAL_OUT_BUF))
    ) req_global_buf (
        .clk       (clk),
        .reset     (reset),
        .valid_in  (lsu_in_if_req_valid && is_addr_global),
        .data_in   ({
            lsu_in_if_req_data_mask & ~is_addr_local_mask,
            lsu_in_if_req_data_rw,
            lsu_in_if_req_data_addr,
            lsu_in_if_req_data_data,
            lsu_in_if_req_data_byteen,
            lsu_in_if_req_data_flags,
            lsu_in_req_tag
        }),
        .ready_in  (req_global_ready),
        .valid_out (global_out_if_req_valid),
        .data_out  (global_req_data_out),
        .ready_out (global_out_if_req_ready)
    );

    assign {
        global_out_if_req_data_mask,
        global_out_if_req_data_rw,
        global_out_if_req_data_addr,
        global_out_if_req_data_data,
        global_out_if_req_data_byteen,
        global_out_if_req_data_flags,
        global_out_if_req_data_tag_uuid,
        global_out_if_req_data_tag_value
    } = global_req_data_out;

    VX_elastic_buffer #(
        .DATAW   (REQ_DATAW),
        .SIZE    (`TO_OUT_BUF_SIZE(LOCAL_OUT_BUF)),
        .OUT_REG (`TO_OUT_BUF_REG(LOCAL_OUT_BUF))
    ) req_local_buf (
        .clk       (clk),
        .reset     (reset),
        .valid_in  (lsu_in_if_req_valid && is_addr_local),
        .data_in   ({
            lsu_in_if_req_data_mask & is_addr_local_mask,
            lsu_in_if_req_data_rw,
            lsu_in_if_req_data_addr,
            lsu_in_if_req_data_data,
            lsu_in_if_req_data_byteen,
            lsu_in_if_req_data_flags,
            lsu_in_req_tag
        }),
        .ready_in  (req_local_ready),
        .valid_out (local_out_if_req_valid),
        .data_out  (local_req_data_out),
        .ready_out (local_out_if_req_ready)
    );

    assign {
        local_out_if_req_data_mask,
        local_out_if_req_data_rw,
        local_out_if_req_data_addr,
        local_out_if_req_data_data,
        local_out_if_req_data_byteen,
        local_out_if_req_data_flags,
        local_out_if_req_data_tag_uuid,
        local_out_if_req_data_tag_value
    } = local_req_data_out;

    wire [RSP_DATAW-1:0] global_rsp_data_in;
    wire [RSP_DATAW-1:0] local_rsp_data_in;
    wire [RSP_DATAW-1:0] lsu_rsp_data_out;

    assign global_rsp_data_in = {
        global_out_if_rsp_data_mask,
        global_out_if_rsp_data_data,
        global_out_if_rsp_data_tag_uuid,
        global_out_if_rsp_data_tag_value
    };

    assign local_rsp_data_in = {
        local_out_if_rsp_data_mask,
        local_out_if_rsp_data_data,
        local_out_if_rsp_data_tag_uuid,
        local_out_if_rsp_data_tag_value
    };

    VX_stream_arb #(
        .NUM_INPUTS (2),
        .DATAW      (RSP_DATAW),
        .ARBITER    (ARBITER),
        .OUT_BUF    (RSP_OUT_BUF)
    ) rsp_arb (
        .clk       (clk),
        .reset     (reset),
        .valid_in  ({
            local_out_if_rsp_valid,
            global_out_if_rsp_valid
        }),
        .ready_in  ({
            local_out_if_rsp_ready,
            global_out_if_rsp_ready
        }),
        .data_in   ({
            local_rsp_data_in,
            global_rsp_data_in
        }),
        .data_out  (lsu_rsp_data_out),
        .valid_out (lsu_in_if_rsp_valid),
        .ready_out (lsu_in_if_rsp_ready),
        `UNUSED_PIN (sel_out)
    );

    assign {
        lsu_in_if_rsp_data_mask,
        lsu_in_if_rsp_data_data,
        lsu_in_if_rsp_data_tag_uuid,
        lsu_in_if_rsp_data_tag_value
    } = lsu_rsp_data_out;

endmodule
