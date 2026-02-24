`ifndef VX_ISSUE_SCHED_IF_FLAT_VH
`define VX_ISSUE_SCHED_IF_FLAT_VH 

`define VX_ISSUE_SCHED_IF_SIGNALS(prefix, N) \
    wire [(N)-1:0]                 prefix``_valid; \
    wire [(N)*ISSUE_WIS_W-1:0]     prefix``_wis;

`define VX_ISSUE_SCHED_IF_PRODUCER_PORTS(prefix, N) \
    output wire [(N)-1:0]              prefix``_valid, \
    output wire [(N)*ISSUE_WIS_W-1:0]  prefix``_wis

`define VX_ISSUE_SCHED_IF_CONSUMER_PORTS(prefix, N) \
    input wire [(N)-1:0]               prefix``_valid, \
    input wire [(N)*ISSUE_WIS_W-1:0]   prefix``_wis

`define VX_ISSUE_SCHED_IF_PASS_PORTS(prefix) \
    .prefix``_valid(prefix``_valid), \
    .prefix``_wis(prefix``_wis)

// macros to slice desired signal
`define VX_ISSUE_SCHED_IF_WIS_SLICE(prefix, i) \
    prefix``_wis[(i)*ISSUE_WIS_W +: ISSUE_WIS_W]

`define VX_ISSUE_SCHED_IF_VALID_BIT(prefix, i) \
    prefix``_valid[(i)]


`endif