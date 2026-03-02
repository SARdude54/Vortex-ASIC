`ifndef VX_COMMIT_SCHED_IF_FLAT_VH
`define VX_COMMIT_SCHED_IF_FLAT 

`define VX_COMMIT_SCHED_IF_SIGNALS(prefix) \
    wire [`NUM_WARPS-1:0] prefix``_committed_warps;

`define VX_COMMIT_SCHED_IF_PRODUCER_PORTS(prefix) \
    output wire [`NUM_WARPS-1:0] prefix``_committed_warps

`define VX_COMMIT_SCHED_IF_CONSUMER_PORTS(prefix) \
    input wire [`NUM_WARPS-1:0] prefix``_committed_warps

`define VX_COMMIT_SCHED_IF_PASS_PORTS(prefix) \
    .prefix``_committed_warps(prefix``_committed_warps)

`endif