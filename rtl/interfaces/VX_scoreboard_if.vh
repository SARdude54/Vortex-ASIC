`ifndef VX_SCOREBOARD_IF_FLAT_VH
`define VX_SCOREBOARD_IF_FLAT_VH

`define VX_SCOREBOARD_IF_SIGNALS(prefix) \
    logic       prefix``_valid; \
    scoreboard_t   prefix``_data; \
    logic       prefix``_ready

`define VX_SCOREBOARD_IF_PRODUCER_PORTS(prefix) \
    output logic        prefix``_valid, \
    output scoreboard_t    prefix``_data, \
    input logic         prefix``_ready

`define VX_SCOREBOARD_IF_CONSUMER_PORTS(prefix) \
    input logic     prefix``_valid, \
    input scoreboard_t prefix``_data, \
    output logic    prefix``_ready

`define VX_SCOREBOARD_IF_PASS_PORTS(def_pref, pass_pref) \
    .def_pref``_valid(pass_pref``_valid), \
    .def_pref``_data(pass_pref``_data), \
    .def_pref``_ready(pass_pref``_ready)

`endif