`ifndef VX_COMMIT_IF_FLAT_VH
`define VX_COMMIT_IF_FLAT_VH

`define VX_COMMIT_IF_SIGNALS(prefix, N) \
    logic [(N)-1:0] prefix``_valid; \
    commit_t        prefix``_data [(N)-1:0]; \
    logic [(N)-1:0] prefix``_ready;

`define VX_COMMIT_IF_PRODUCER_PORTS(prefix, N) \
    output logic [(N)-1:0]  prefix``_valid, \
    output commit_t         prefix``_data [(N)-1:0], \
    input  logic [(N)-1:0]  prefix``_ready

`define VX_COMMIT_IF_CONSUMER_PORTS(prefix, N) \
    input logic [(N)-1:0]   prefix``_valid, \
    input commit_t          prefix``_data [(N)-1:0], \
    output logic [(N)-1:0]  prefix``_ready

`define VX_COMMIT_IF_PASS_PORTS(def_pref, pass_pref) \
    .def_pref``_valid(pass_pref``_valid), \
    .def_pref``_data(pass_pref``_data), \
    .def_pref``_ready(pass_pref``_ready)

`define VX_COMMIT_IF_SLICE_VALID(prefix, i) \
    prefix``_valid[i];

`define VX_COMMIT_IF_SLICE_DATA(prefix, i) \
    prefix``_data[i];

`define VX_COMMIT_IF_SLICE_READY(prefix, i) \
    prefix``_ready[i];

`endif