`ifndef VX_SCHED_IF_FLAT_PORTS_VH
`define VX_SCHED_IF_FlAT_PORTS_VH

`define VX_SCHEDULE_IF_SIGNALS(prefix) \
    logic  prefix``_valid; \
    schedule_t prefix``_data; \
    logic  prefix``_ready;

`define VX_SCHEDULE_IF_PRODUCER_PORTS(prefix) \
        output wire prefix``_valid, \
        output schedule_t prefix``_data, \
        input  wire prefix``_ready

`define VX_SCHEDULE_IF_CONSUMER_PORTS(prefix) \
        input wire prefix``_valid, \
        input schedule_t prefix``_data, \
        output  wire prefix``_ready

`define VX_SCHEDULE_IF_PASS_PORTS(prefix) \
        .prefix``_valid(prefix``_valid), \
        .prefix``_data(prefix``_data), \
        .prefix``_ready(prefix``_ready)

`endif