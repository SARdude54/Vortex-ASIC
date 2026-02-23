`ifndef VX_DECODE_IF_FLAT_VH
`define VX_DECODE_IF_FLAT_VH

`define VX_DECODE_IF_SIGNALS(prefix) \
    logic  prefix``_valid; \
    decode_t prefix``_data; \
    logic  prefix``_ready; \
`ifndef L1_ENABLE \
    wire [`NUM_WARPS-1:0] prefix``_ibuf_pop; \
`endif \

`define VX_DECODE_IF_PRODUCER_PORTS(prefix) \
    output logic prefix``_valid, \
    output decode_t prefix``_data, \
    input  logic prefix``_ready \
    `ifndef L1_ENABLE \
        , input wire prefix``_ibuf_pop \
    `endif

`define VX_DECODE_IF_CONSUMER_PORTS(prefix) \
    input logic prefix``_valid, \
    input decode_t prefix``_data, \
    output logic prefix``_ready \
    `ifndef L1_ENABLE \
        , output wire prefix``_ibuf_pop \
    `endif

`define VX_DECODE_IF_PASS_PORTS(def_pref, sig_pref) \
    .def_pref``_valid(sig_pref``_valid), \
    .def_pref``_data(sig_pref``_data), \
    .def_pref``_ready(sig_pref``_ready) \
    `ifndef L1_ENABLE \
        , .def_pref``_ibuf_pop(sig_pref) \
    `endif

`endif