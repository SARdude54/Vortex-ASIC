`ifndef VX_WRITEBACK_IF_FLAT_VH
`define VX_WRITEBACK_IF_FLAT_VH

`define VX_WRITEBACK_IF_SIGNALS(prefix, N) \
    logic [(N)-1:0] prefix``_valid; \
    writeback_t    prefix``_data [(N)-1:0];

`define VX_WRITEBACK_IF_PRODUCER_PORTS(prefix, N) \
    output logic [(N)-1:0]  prefix``_valid, \
    output writeback_t      prefix``_data [(N)-1:0]

`define VX_WRITEBACK_IF_CONSUMER_PORTS(prefix, N) \
    input logic [(N)-1:0]   prefix``_valid, \
    input writeback_t       prefix``_data [(N)-1:0]

`define VX_WRITEBACK_IF_PASS_PORTS(def_pref, pass_pref) \
    .def_pref``_valid(pass_pref``_valid), \
    .def_pref``_data(pass_pref``_data)

`define VX_WRITEBACK_IF_SLICE_VALID(prefix, i) \
    prefix``_valid[i]

`define VX_WRITEBACK_IF_SLICE_DATA(prefix, i) \
    prefix``_data[i]

`endif