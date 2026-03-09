`ifndef VX_WARP_CTL_IF_FLAT_VH
`define VX_WARP_CTL_IF_FLAT_VH

`define VX_WARP_CTL_IF_SIGNALS(prefix) \
    wire                        prefix``_valid; \
    wire [NW_WIDTH-1:0]         prefix``_wid; \
    tmc_t                       prefix``_tmc; \
    wspawn_t                    prefix``_wspawn; \
    split_t                     prefix``_split; \
    join_t                      prefix``_sjoin; \
    barrier_t                   prefix``_barrier; \
    wire [NW_WIDTH-1:0]         prefix``_dvstack_wid; \
    wire [DV_STACK_SIZEW-1:0]   prefix``_dvstack_ptr;

`define VX_WARP_CTL_IF_PRODUCER_PORTS(prefix) \
    output wire                 prefix``_valid, \
    output wire [NW_WIDTH-1:0]  prefix``_wid, \
    output tmc_t                prefix``_tmc, \
    output wspawn_t             prefix``_wspawn, \
    output split_t              prefix``_split, \
    output join_t               prefix``_sjoin, \
    output barrier_t            prefix``_barrier, \
    output wire [NW_WIDTH-1:0]  prefix``_dvstack_wid, \
    input [DV_STACK_SIZEW-1:0]  prefix``_dvstack_ptr

`define VX_WARP_CTL_IF_CONSUMER_PORTS(prefix) \
    input wire                  prefix``_valid, \
    input wire [NW_WIDTH-1:0]   prefix``_wid, \
    input tmc_t                 prefix``_tmc, \
    input wspawn_t              prefix``_wspawn, \
    input split_t               prefix``_split, \
    input join_t                prefix``_sjoin, \
    input barrier_t             prefix``_barrier, \
    input wire [NW_WIDTH-1:0]   prefix``_dvstack_wid, \
    output [DV_STACK_SIZEW-1:0] prefix``_dvstack_ptr

`define VX_WARP_CTL_IF_PASS_PORTS(prefix) \
    .prefix``_valid(prefix``_valid), \
    .prefix``_wid(prefix``_wid), \
    .prefix``_tmc(prefix``_tmc), \
    .prefix``_wspawn(prefix``_wspawn), \
    .prefix``_split(prefix``_split), \
    .prefix``_sjoin(prefix``_sjoin), \
    .prefix``_barrier(prefix``_barrier), \
    .prefix``_dvstack_wid(prefix``_dvstack_wid), \
    .prefix``_dvstack_ptr(prefix``_dvstack_ptr)

`endif