`ifndef VX_IBUFFER_IF_FLAT_VH
`define VX_IBUFFER_IF_FLAT_VH

`define VX_IBUFFER_IF_SIGNALS_N(prefix, N) \
    logic [(N)-1:0] prefix``_valid; \
    ibuffer_t       prefix``_data [(N)-1:0]; \
    logic [(N)-1:0] prefix``_ready

`define VX_IBUFFER_IF_SIGNALS(prefix) \
    logic       prefix``_valid; \
    ibuffer_t   prefix``_data; \
    logic       prefix``_ready

`define VX_IBUFFER_IF_PRODUCER_PORTS_N(prefix, N) \
    output logic [(N)-1:0]  prefix``_valid, \
    output ibuffer_t        prefix``_data [(N)-1:0], \
    input logic [(N)-1:0]   prefix``_ready

`define VX_IBUFFER_IF_PRODUCER_PORTS(prefix) \
    output logic        prefix``_valid, \
    output ibuffer_t    prefix``_data, \
    input logic         prefix``_ready

`define VX_IBUFFER_IF_CONSUMER_PORTS_N(prefix, N) \
    input logic [(N)-1:0]   prefix``_valid, \
    input ibuffer_t         prefix``_data [(N)-1:0], \
    output logic [(N)-1:0]  prefix``_ready

`define VX_IBUFFER_IF_CONSUMER_PORTS(prefix) \
    input logic     prefix``_valid, \
    input ibuffer_t prefix``_data, \
    output logic    prefix``_ready

`define VX_IBUFFER_IF_PASS_PORTS(def_pref, pass_pref) \
    .def_pref``_valid(pass_pref``_valid), \
    .def_pref``_data(pass_pref``_data), \
    .def_pref``_ready(pass_pref``_ready)

`define VX_IBUFFER_IF_PASS_PORTS_I(def_pref, pass_pref, i) \
    .def_pref``_valid(pass_pref``_valid[i]), \
    .def_pref``_data(pass_pref``_data[i]), \
    .def_pref``_ready(pass_pref``_ready[i])

`define VX_IBUFFER_IF_SLICE_VALID(prefix, i) \
    prefix``_valid[i]

`define VX_IBUFFER_IF_SLICE_DATA(prefix, i) \
    prefix``_data[i]

`define VX_IBUFFER_IF_SLICE_READY(prefix, i) \
    prefix``_ready[i]

`endif