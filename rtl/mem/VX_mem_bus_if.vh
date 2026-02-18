// flattens signals and structs from VX_mem_bus_if

`ifndef VX_MEM_FLAT_PORTS_VH
`define VX_MEM_FLAT_PORTS_VH

// declare input and output signals from VX_mem_bus_if
`define VX_MEM_BUS_PORTS_IN(prefix, N, ADDR_W, DATA_SIZE, FLAGS_W, UUID_W, TAG_W) \
  input  logic                    prefix``_req_rw     [N], \
  input  logic [ADDR_W-1:0]        prefix``_req_addr   [N], \
  input  logic [DATA_SIZE*8-1:0]     prefix``_req_data   [N], \
  input  logic [DATA_SIZE-1:0]       prefix``_req_byteen [N], \
  input  logic [FLAGS_W-1:0]       prefix``_req_flags  [N], \
  input  logic [`UP(UUID_W)-1:0]   prefix``_req_tag_uuid  [N], \
  input  logic [TAG_W-`UP(UUID_W)-1:0] prefix``_req_tag_value [N], \
  output logic [N-1:0]      prefix`` [N], \
  output logic [DATA_SIZE*8-1:0]     prefix``_rsp_data   [N], \
  output logic [`UP(UUID_W)-1:0]   prefix``_rsp_tag_uuid  [N], \
  output logic [TAG_W-`UP(UUID_W)-1:0] prefix``_rsp_tag_value [N], \
  input  logic [N-1:0]      mem_rsp_valid, \
  output logic [N-1:0]      mem_rsp_ready

// declare the internal signals
`define VX_MEM_BUS_SIGNALS(prefix, N, ADDR_W, DATA_SIZE, FLAGS_W, UUID_W, TAG_W) \
  logic [N-1:0]                prefix``_req_valid; \
  logic [N-1:0]                prefix``_req_ready; \
  logic                        prefix``_req_rw     [N]; \
  logic [ADDR_W-1:0]           prefix``_req_addr   [N]; \
  logic [DATA_SIZE*8-1:0]      prefix``_req_data   [N]; \
  logic [DATA_SIZE-1:0]        prefix``_req_byteen [N]; \
  logic [FLAGS_W-1:0]          prefix``_req_flags  [N]; \
  logic [`UP(UUID_W)-1:0]      prefix``_req_tag_uuid  [N]; \
  logic [TAG_W-`UP(UUID_W)-1:0] prefix``_req_tag_value [N]; \
  logic [N-1:0]                prefix``_rsp_valid; \
  logic [N-1:0]                prefix``_rsp_ready; \
  logic [DATA_SIZE*8-1:0]      prefix``_rsp_data   [N]; \
  logic [`UP(UUID_W)-1:0]      prefix``_rsp_tag_uuid  [N]; \
  logic [TAG_W-`UP(UUID_W)-1:0] prefix``_rsp_tag_value [N];

// pass the signals into a module
`define VX_MEM_BUS_PASS_SIGNALS(prefix, N, ADDR_W, DATA_SIZE, FLAGS_W, UUID_W, TAG_W) \
  .prefix``_req_valid(prefix``_req_valid), \
  .prefix``_req_ready(prefix``_req_ready), \
  .prefix``_req_rw(prefix``_req_rw [N]), \
  .prefix``_req_addr(prefix``_req_addr[N]), \
  .prefix``_req_data(prefix``_req_data [N]), \
  .prefix``_req_byteen(prefix``_req_byteen[N]), \
  .prefix``_req_flags(prefix``_req_flags[N]), \
  .prefix``_req_tag_uuid(prefix``_req_tag_uuid[N]), \
  .prefix``_req_tag_value(prefix``_req_tag_value[N]), \
  .prefix``_rsp_valid(prefix``_rsp_valid), \
  .prefix``_rsp_ready(prefix``_rsp_ready), \
  .prefix``_rsp_data(prefix``_rsp_data[N]), \
  .prefix``_rsp_tag_uuid(prefix``_rsp_tag_uuid[N]), \
  .prefix``_rsp_tag_value(prefix``_rsp_tag_value[N])


// module header for producer
`define VX_MEM_BUS_FLAT_PRODUCER_PORTS(prefix, N, ADDR_W, DATA_SIZE, FLAGS_W, UUID_W, TAG_W) \
  input  logic [N-1:0]                 prefix``_req_valid, \
  input  logic                         prefix``_req_rw     [N], \
  input  logic [ADDR_W-1:0]            prefix``_req_addr   [N], \
  input  logic [DATA_SIZE*8-1:0]       prefix``_req_data   [N], \
  input  logic [DATA_SIZE-1:0]         prefix``_req_byteen [N], \
  input  logic [FLAGS_W-1:0]           prefix``_req_flags  [N], \
  input  logic [`UP(UUID_W)-1:0]       prefix``_req_tag_uuid  [N], \
  input  logic [TAG_W-`UP(UUID_W)-1:0] prefix``_req_tag_value [N], \
  output logic [N-1:0]                 prefix``_req_ready, \
  output logic [N-1:0]                 prefix``_rsp_valid, \
  output logic [DATA_SIZE*8-1:0]       prefix``_rsp_data   [N], \
  output logic [`UP(UUID_W)-1:0]       prefix``_rsp_tag_uuid  [N], \
  output logic [TAG_W-`UP(UUID_W)-1:0] prefix``_rsp_tag_value [N], \
  input  logic [N-1:0]                 prefix``_rsp_ready

// header module for consumer
`define VX_MEM_BUS_FLAT_CONSUMER_PORTS(prefix, N, ADDR_W, DATA_SIZE, FLAGS_W, UUID_W, TAG_W) \
  input  logic [N-1:0]                 prefix``_req_valid, \
  input  logic                         prefix``_req_rw     [N], \
  input  logic [ADDR_W-1:0]            prefix``_req_addr   [N], \
  input  logic [DATA_SIZE*8-1:0]       prefix``_req_data   [N], \
  input  logic [DATA_SIZE-1:0]         prefix``_req_byteen [N], \
  input  logic [FLAGS_W-1:0]           prefix``_req_flags  [N], \
  input  logic [`UP(UUID_W)-1:0]       prefix``_req_tag_uuid  [N], \
  input  logic [TAG_W-`UP(UUID_W)-1:0] prefix``_req_tag_value [N], \
  output logic [N-1:0]                 prefix``_req_ready, \
  output logic [N-1:0]                 prefix``_rsp_valid, \
  output logic [DATA_SIZE*8-1:0]       prefix``_rsp_data   [N], \
  output logic [`UP(UUID_W)-1:0]       prefix``_rsp_tag_uuid  [N], \
  output logic [TAG_W-`UP(UUID_W)-1:0] prefix``_rsp_tag_value [N], \
  input  logic [N-1:0]                 prefix``_rsp_ready

`endif

