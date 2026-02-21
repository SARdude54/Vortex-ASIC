`ifndef VX_FETCH_IF_FLAT_VH
`define VX_FETCH_IF_FLAT_VH

`define VX_FETCH_IF_SIGNALS(prefix) \
    logic  prefix``_valid; \
    fetch_t prefix``_data; \
    logic  prefix``_ready; \
`ifndef L1_ENABLE \
    logic [`NUM_WARPS-1:0] prefix``_ibuf_pop; \
`endif \

`define VX_FETCH_IF_PRODUCER_SIGNALS(prefix) \
    output logic prefix``_valid, \
    output fetch_t prefix``_data, \
    input  logic prefix``_ready \
    `ifndef L1_ENABLE \
        , input logic prefix``_ibuf_pop \
    `endif

`define VX_FETCH_IF_CONSUMER_SIGNALS(prefix) \
    input logic prefix``_valid, \
    input fetch_t prefix``_data, \
    output logic prefix``_ready \
    `ifndef L1_ENABLE \
        , output prefix``_ibuf_pop \
    `endif

`define VX_FETCH_IF_PASS_PORTS(prefix) \
    .prefix``_valid(prefix``_valid), \
    .prefix``_data(prefix``_data), \
    .prefix``_ready(prefix``_ready) \
    `ifndef L1_ENABLE \
        , .prefix``_ibuf_pop(prefix``_ibuf_pop), \
    `endif

`endif