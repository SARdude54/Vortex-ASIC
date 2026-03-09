`ifndef VX_BRANCH_CTL_IF_FLAT_VH

`define VX_BRANCH_CTL_IF_SIGNALS(prefix, N)  \
    wire [(N)-1:0]               prefix``_valid; \
    wire [(N)*NW_WIDTH-1:0] prefix``_wid; \
    wire [(N)-1:0]              prefix``_taken; \
    wire [(N)*PC_BITS-1:0]  prefix``_dest;

`define VX_BRANCH_CTL_IF_PRODUCER_PORTS(prefix, N)  \
    output wire [(N)-1:0]               prefix``_valid, \
    output wire [(N)*NW_WIDTH-1:0] prefix``_wid, \
    output wire [(N)-1:0]               prefix``_taken, \
    output wire [(N)*PC_BITS-1:0]  prefix``_dest

`define VX_BRANCH_CTL_IF_CONSUMER_PORTS(prefix, N)  \
    input wire [(N)-1:0]               prefix``_valid, \
    input wire [(N)*NW_WIDTH-1:0] prefix``_wid, \
    input wire [(N)-1:0]               prefix``_taken, \
    input wire [(N)*PC_BITS-1:0]  prefix``_dest

`define VX_BRANCH_CTL_IF_PASS_PORTS(prefix)  \
    .prefix``_valid(prefix``_valid), \
    .prefix``_wid(prefix``_wid), \
    .prefix``_taken(prefix``_taken), \
    .prefix``_dest(prefix``_dest)

// macro to slice desired signal
`define VX_BRANCH_CTL_IF_SLICE_VALID(prefix, i) \
    prefix``_valid[i]

`define VX_BRANCH_CTL_IF_SLICE_WID(prefix, i) \
    prefix``_wid[(i)*NW_WIDTH +: NW_WIDTH]

`define VX_BRANCH_CTL_IF_SLICE_TAKEN(prefix, i) \
    prefix``_taken[i]

`define VX_BRANCH_CTL_IF_SLICE_DEST(prefix, i) \
    prefix``_dest[(i)*PC_BITS +: PC_BITS]

`endif  


