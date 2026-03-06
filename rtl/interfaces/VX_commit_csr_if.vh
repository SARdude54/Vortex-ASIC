`ifndef VX_COMMIT_CSR_IF_FLAT_VH
`define VX_COMMIT_CSR_IF_FLAT_VH

`define VX_COMMIT_CSR_IF_SIGNALS(prefix) \
    wire [PERF_CTR_BITS-1:0] prefix``_instret 

`define VX_COMMIT_CSR_IF_PRODUCER_PORTS(prefix) \
    output [PERF_CTR_BITS-1:0] prefix``_instret

`define VX_COMMIT_CSR_IF_CONSUMER_PORTS(prefix) \
    input [PERF_CTR_BITS-1:0] prefix``_instret

`define VX_COMMIT_CSR_IF_PASS_PORTS(prefix) \
    .prefix``_instret(prefix``_instret)
    
`endif