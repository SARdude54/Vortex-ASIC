`ifndef VX_SCHED_CSR_FLAT_VH
`define VX_SCHED_CSR_FLAT_VH

`define VX_SCHED_CSR_IF_SIGNALS(prefix) \
    wire [PERF_CTR_BITS-1:0]                prefix``_cycles; \
    wire [`NUM_WARPS-1:0]                   prefix``_active_warps; \
    wire [`NUM_WARPS-1:0][`NUM_THREADS-1:0] prefix``_thread_masks; \
    wire                                    prefix``_alm_empty; \
    wire [NW_WIDTH-1:0]                     prefix``_alm_empty_wid; \
    wire                                    prefix``_unlock_warp; \
    wire [NW_WIDTH-1:0]                     prefix``_unlock_wid;

`define VX_SCHED_CSR_IF_PRODUCER_PORTS(prefix) \
    output wire [PERF_CTR_BITS-1:0]                 prefix``_cycles, \
    output wire [`NUM_WARPS-1:0]                    prefix``_active_warps, \
    output wire [`NUM_WARPS-1:0][`NUM_THREADS-1:0]  prefix``_thread_masks, \
    output  wire                                     prefix``_alm_empty, \
    input wire [NW_WIDTH-1:0]                      prefix``_alm_empty_wid, \
    input  wire                                     prefix``_unlock_warp, \
    input  wire [NW_WIDTH-1:0]                      prefix``_unlock_wid

`define VX_SCHED_CSR_IF_CONSUMER_PORTS(prefix) \
    input wire [PERF_CTR_BITS-1:0]                  prefix``_cycles, \
    input wire [`NUM_WARPS-1:0]                     prefix``_active_warps, \
    input wire [`NUM_WARPS-1:0][`NUM_THREADS-1:0]   prefix``_thread_masks, \
    input wire                                     prefix``_alm_empty, \
    output wire [NW_WIDTH-1:0]                       prefix``_alm_empty_wid, \
    output wire                                     prefix``_unlock_warp, \
    output wire [NW_WIDTH-1:0]                      prefix``_unlock_wid

`define VX_SCHED_CSR_IF_PASS_PORTS(prefix) \
    .prefix``_cycles(prefix``_cycles), \
    .prefix``_active_warps(prefix``_active_warps), \
    .prefix``_thread_masks(prefix``_thread_masks), \
    .prefix``_alm_empty_wid(prefix``_alm_empty_wid), \
    .prefix``_alm_empty(prefix``_alm_empty), \
    .prefix``_unlock_wid(prefix``_unlock_wid), \
    .prefix``_unlock_warp(prefix``_unlock_warp)

`endif