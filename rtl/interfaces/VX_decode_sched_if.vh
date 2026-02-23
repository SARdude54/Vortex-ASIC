`ifndef VX_DECODE_SCHED_IF_FLAT_VH
`define VX_DECODE_SCHED_IF_FLAT_VH

`define VX_DECODE_SCHED_IF_SIGNALS(prefix) \
    wire                prefix``_valid; \
    wire                prefix``_unlock; \
    wire [NW_WIDTH-1:0] prefix``_wid; \

`define VX_DECODE_SCHED_IF_PRODUCER_PORTS(prefix) \
    output wire                 prefix``_valid, \
    output wire                 prefix``_unlock, \
    output wire [NW_WIDTH-1:0]  prefix``_wid \

`define VX_DECODE_SCHED_IF_CONSUMER_PORTS(prefix) \
    input wire                  prefix``_valid, \
    input wire                  prefix``_unlock, \
    input wire [NW_WIDTH-1:0]   prefix``_wid \

`define VX_DECODE_SCHED_IF_PASS_PORTS(prefix) \
    .prefix``_valid(prefix``_valid), \
    .prefix``_unlock(prefix``_unlock), \
    .prefix``_wid(prefix``_wid)

`endif