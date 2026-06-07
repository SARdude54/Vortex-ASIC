`ifndef VX_GBAR_BUS_IF_FLAT_VH
`define VX_GBAR_BUS_IF_FLAT_VH

`include "VX_define.vh"

// Single flattened VX_gbar_bus_if signal bundle
`define VX_GBAR_BUS_IF_SIGNALS(prefix) \
    logic prefix``_req_valid; \
    logic [NB_WIDTH-1:0] prefix``_req_data_id; \
    logic [NC_WIDTH-1:0] prefix``_req_data_size_m1; \
    logic [NC_WIDTH-1:0] prefix``_req_data_core_id; \
    logic prefix``_req_ready; \
    logic prefix``_rsp_valid; \
    logic [NB_WIDTH-1:0] prefix``_rsp_data_id

// N flattened VX_gbar_bus_if signal bundles
`define VX_GBAR_BUS_IF_SIGNALS_N(prefix, N) \
    logic [(N)-1:0] prefix``_req_valid; \
    logic [(N)-1:0][NB_WIDTH-1:0] prefix``_req_data_id; \
    logic [(N)-1:0][NC_WIDTH-1:0] prefix``_req_data_size_m1; \
    logic [(N)-1:0][NC_WIDTH-1:0] prefix``_req_data_core_id; \
    logic [(N)-1:0] prefix``_req_ready; \
    logic [(N)-1:0] prefix``_rsp_valid; \
    logic [(N)-1:0][NB_WIDTH-1:0] prefix``_rsp_data_id

// Equivalent to VX_gbar_bus_if.master
`define VX_GBAR_BUS_IF_PRODUCER_PORTS(prefix) \
    output logic prefix``_req_valid, \
    output logic [NB_WIDTH-1:0] prefix``_req_data_id, \
    output logic [NC_WIDTH-1:0] prefix``_req_data_size_m1, \
    output logic [NC_WIDTH-1:0] prefix``_req_data_core_id, \
    input  logic prefix``_req_ready, \
    input  logic prefix``_rsp_valid, \
    input  logic [NB_WIDTH-1:0] prefix``_rsp_data_id

// N copies of VX_gbar_bus_if.master
`define VX_GBAR_BUS_IF_PRODUCER_PORTS_N(prefix, N) \
    output logic [(N)-1:0] prefix``_req_valid, \
    output logic [(N)-1:0][NB_WIDTH-1:0] prefix``_req_data_id, \
    output logic [(N)-1:0][NC_WIDTH-1:0] prefix``_req_data_size_m1, \
    output logic [(N)-1:0][NC_WIDTH-1:0] prefix``_req_data_core_id, \
    input  logic [(N)-1:0] prefix``_req_ready, \
    input  logic [(N)-1:0] prefix``_rsp_valid, \
    input  logic [(N)-1:0][NB_WIDTH-1:0] prefix``_rsp_data_id

// Equivalent to VX_gbar_bus_if.slave
`define VX_GBAR_BUS_IF_CONSUMER_PORTS(prefix) \
    input  logic prefix``_req_valid, \
    input  logic [NB_WIDTH-1:0] prefix``_req_data_id, \
    input  logic [NC_WIDTH-1:0] prefix``_req_data_size_m1, \
    input  logic [NC_WIDTH-1:0] prefix``_req_data_core_id, \
    output logic prefix``_req_ready, \
    output logic prefix``_rsp_valid, \
    output logic [NB_WIDTH-1:0] prefix``_rsp_data_id

// N copies of VX_gbar_bus_if.slave
`define VX_GBAR_BUS_IF_CONSUMER_PORTS_N(prefix, N) \
    input  logic [(N)-1:0] prefix``_req_valid, \
    input  logic [(N)-1:0][NB_WIDTH-1:0] prefix``_req_data_id, \
    input  logic [(N)-1:0][NC_WIDTH-1:0] prefix``_req_data_size_m1, \
    input  logic [(N)-1:0][NC_WIDTH-1:0] prefix``_req_data_core_id, \
    output logic [(N)-1:0] prefix``_req_ready, \
    output logic [(N)-1:0] prefix``_rsp_valid, \
    output logic [(N)-1:0][NB_WIDTH-1:0] prefix``_rsp_data_id

// Port pass-through for single flattened bundle
`define VX_GBAR_BUS_IF_PASS_PORTS(def_pref, pass_pref) \
    .``def_pref``_req_valid(pass_pref``_req_valid), \
    .``def_pref``_req_data_id(pass_pref``_req_data_id), \
    .``def_pref``_req_data_size_m1(pass_pref``_req_data_size_m1), \
    .``def_pref``_req_data_core_id(pass_pref``_req_data_core_id), \
    .``def_pref``_req_ready(pass_pref``_req_ready), \
    .``def_pref``_rsp_valid(pass_pref``_rsp_valid), \
    .``def_pref``_rsp_data_id(pass_pref``_rsp_data_id)

// Port pass-through for one element of an N-wide flattened bundle
`define VX_GBAR_BUS_IF_PASS_PORTS_I(def_pref, pass_pref, i) \
    .``def_pref``_req_valid(pass_pref``_req_valid[i]), \
    .``def_pref``_req_data_id(pass_pref``_req_data_id[i]), \
    .``def_pref``_req_data_size_m1(pass_pref``_req_data_size_m1[i]), \
    .``def_pref``_req_data_core_id(pass_pref``_req_data_core_id[i]), \
    .``def_pref``_req_ready(pass_pref``_req_ready[i]), \
    .``def_pref``_rsp_valid(pass_pref``_rsp_valid[i]), \
    .``def_pref``_rsp_data_id(pass_pref``_rsp_data_id[i])

// Port pass-through for a slice of an N-wide flattened bundle
`define VX_GBAR_BUS_IF_PASS_PORTS_SLICE(def_pref, pass_pref, base, N) \
    .``def_pref``_req_valid(pass_pref``_req_valid[(base) +: (N)]), \
    .``def_pref``_req_data_id(pass_pref``_req_data_id[(base) +: (N)]), \
    .``def_pref``_req_data_size_m1(pass_pref``_req_data_size_m1[(base) +: (N)]), \
    .``def_pref``_req_data_core_id(pass_pref``_req_data_core_id[(base) +: (N)]), \
    .``def_pref``_req_ready(pass_pref``_req_ready[(base) +: (N)]), \
    .``def_pref``_rsp_valid(pass_pref``_rsp_valid[(base) +: (N)]), \
    .``def_pref``_rsp_data_id(pass_pref``_rsp_data_id[(base) +: (N)])

// Assignment: dst is consumer/slave side, src is producer/master side
`define ASSIGN_VX_GBAR_BUS_IF(dst, src) \
    assign dst``_req_valid        = src``_req_valid; \
    assign dst``_req_data_id      = src``_req_data_id; \
    assign dst``_req_data_size_m1 = src``_req_data_size_m1; \
    assign dst``_req_data_core_id = src``_req_data_core_id; \
    assign src``_req_ready        = dst``_req_ready; \
    assign src``_rsp_valid        = dst``_rsp_valid; \
    assign src``_rsp_data_id      = dst``_rsp_data_id

// Assignment for one element of an N-wide flattened bundle
`define ASSIGN_VX_GBAR_BUS_IF_I(dst, dst_i, src, src_i) \
    assign dst``_req_valid[dst_i]        = src``_req_valid[src_i]; \
    assign dst``_req_data_id[dst_i]      = src``_req_data_id[src_i]; \
    assign dst``_req_data_size_m1[dst_i] = src``_req_data_size_m1[src_i]; \
    assign dst``_req_data_core_id[dst_i] = src``_req_data_core_id[src_i]; \
    assign src``_req_ready[src_i]        = dst``_req_ready[dst_i]; \
    assign src``_rsp_valid[src_i]        = dst``_rsp_valid[dst_i]; \
    assign src``_rsp_data_id[src_i]      = dst``_rsp_data_id[dst_i]

// Initialize a producer/master-side flattened gbar bus to idle
`define INIT_VX_GBAR_BUS_IF(prefix) \
    assign prefix``_req_valid        = 1'b0; \
    assign prefix``_req_data_id      = '0; \
    assign prefix``_req_data_size_m1 = '0; \
    assign prefix``_req_data_core_id = '0; \
    `UNUSED_VAR (prefix``_req_ready) \
    `UNUSED_VAR (prefix``_rsp_valid) \
    `UNUSED_VAR (prefix``_rsp_data_id)

// Initialize one producer/master-side element to idle
`define INIT_VX_GBAR_BUS_IF_I(prefix, i) \
    assign prefix``_req_valid[i]        = 1'b0; \
    assign prefix``_req_data_id[i]      = '0; \
    assign prefix``_req_data_size_m1[i] = '0; \
    assign prefix``_req_data_core_id[i] = '0; \
    `UNUSED_VAR (prefix``_req_ready[i]) \
    `UNUSED_VAR (prefix``_rsp_valid[i]) \
    `UNUSED_VAR (prefix``_rsp_data_id[i])

// Mark a consumer/slave-side flattened gbar bus as unused
`define UNUSED_VX_GBAR_BUS_IF(prefix) \
    `UNUSED_VAR (prefix``_req_valid) \
    `UNUSED_VAR (prefix``_req_data_id) \
    `UNUSED_VAR (prefix``_req_data_size_m1) \
    `UNUSED_VAR (prefix``_req_data_core_id) \
    assign prefix``_req_ready   = 1'b0; \
    assign prefix``_rsp_valid   = 1'b0; \
    assign prefix``_rsp_data_id = '0

// Mark one consumer/slave-side element as unused
`define UNUSED_VX_GBAR_BUS_IF_I(prefix, i) \
    `UNUSED_VAR (prefix``_req_valid[i]) \
    `UNUSED_VAR (prefix``_req_data_id[i]) \
    `UNUSED_VAR (prefix``_req_data_size_m1[i]) \
    `UNUSED_VAR (prefix``_req_data_core_id[i]) \
    assign prefix``_req_ready[i]   = 1'b0; \
    assign prefix``_rsp_valid[i]   = 1'b0; \
    assign prefix``_rsp_data_id[i] = '0

// Slice helpers
`define VX_GBAR_BUS_IF_SLICE_REQ_VALID(prefix, i) \
    prefix``_req_valid[i]

`define VX_GBAR_BUS_IF_SLICE_REQ_DATA_ID(prefix, i) \
    prefix``_req_data_id[i]

`define VX_GBAR_BUS_IF_SLICE_REQ_DATA_SIZE_M1(prefix, i) \
    prefix``_req_data_size_m1[i]

`define VX_GBAR_BUS_IF_SLICE_REQ_DATA_CORE_ID(prefix, i) \
    prefix``_req_data_core_id[i]

`define VX_GBAR_BUS_IF_SLICE_REQ_READY(prefix, i) \
    prefix``_req_ready[i]

`define VX_GBAR_BUS_IF_SLICE_RSP_VALID(prefix, i) \
    prefix``_rsp_valid[i]

`define VX_GBAR_BUS_IF_SLICE_RSP_DATA_ID(prefix, i) \
    prefix``_rsp_data_id[i]

`endif // VX_GBAR_BUS_IF_FLAT_VH

