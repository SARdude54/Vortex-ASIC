// flattens structs from VX_mem_bus_if

`ifndef VX_MEM_FLAT_PORTS_VH
`define VX_MEM_FLAT_PORTS_VH

`define VX_MEM_REQ_PORTS_IN(prefix, N, ADDR_W, DATA_SIZE, FLAGS_W, UUID_W, TAG_W) \
  input  logic                    prefix``_req_rw     [N], \
  input  logic [ADDR_W-1:0]        prefix``_req_addr   [N], \
  input  logic [DATA_SIZE*8-1:0]     prefix``_req_data   [N], \
  input  logic [DATA_SIZE-1:0]       prefix``_req_byteen [N], \
  input  logic [FLAGS_W-1:0]       prefix``_req_flags  [N], \
  input  logic [`UP(UUID_W)-1:0]   prefix``_req_tag_uuid  [N], \
  input  logic [TAG_W-`UP(UUID_W)-1:0] prefix``_req_tag_value [N],

`define VX_MEM_RSP_PORTS_OUT(prefix, N, DATA_SIZE, UUID_W, TAG_W) \
  output logic [DATA_SIZE*8-1:0]     prefix``_rsp_data   [N], \
  output logic [`UP(UUID_W)-1:0]   prefix``_rsp_tag_uuid  [N], \
  output logic [TAG_W-`UP(UUID_W)-1:0] prefix``_rsp_tag_value [N],

`endif
