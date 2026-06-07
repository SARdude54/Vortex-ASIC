`ifndef VX_LSU_MEM_IF_FLAT_VH
`define VX_LSU_MEM_IF_FLAT_VH

`define VX_LSU_MEM_IF_SIGNALS(prefix, NUM_LANES, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH) \
    localparam prefix``_ADDR_WIDTH = (MEM_ADDR_WIDTH) - `CLOG2(DATA_SIZE); \
    logic prefix``_req_valid; \
    logic [(NUM_LANES)-1:0] prefix``_req_data_mask; \
    logic prefix``_req_data_rw; \
    logic [(NUM_LANES)-1:0][prefix``_ADDR_WIDTH-1:0] prefix``_req_data_addr; \
    logic [(NUM_LANES)-1:0][(DATA_SIZE)*8-1:0] prefix``_req_data_data; \
    logic [(NUM_LANES)-1:0][(DATA_SIZE)-1:0] prefix``_req_data_byteen; \
    logic [(NUM_LANES)-1:0][(FLAGS_WIDTH)-1:0] prefix``_req_data_flags; \
    logic [`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_uuid; \
    logic [(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_value; \
    logic prefix``_req_ready; \
    logic prefix``_rsp_valid; \
    logic [(NUM_LANES)-1:0] prefix``_rsp_data_mask; \
    logic [(NUM_LANES)-1:0][(DATA_SIZE)*8-1:0] prefix``_rsp_data_data; \
    logic [`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_uuid; \
    logic [(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_value; \
    logic prefix``_rsp_ready

`define VX_LSU_MEM_IF_PRODUCER_PORTS(prefix, NUM_LANES, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH) \
    output logic prefix``_req_valid, \
    output logic [(NUM_LANES)-1:0] prefix``_req_data_mask, \
    output logic prefix``_req_data_rw, \
    output logic [(NUM_LANES)-1:0][(MEM_ADDR_WIDTH)-`CLOG2(DATA_SIZE)-1:0] prefix``_req_data_addr, \
    output logic [(NUM_LANES)-1:0][(DATA_SIZE)*8-1:0] prefix``_req_data_data, \
    output logic [(NUM_LANES)-1:0][(DATA_SIZE)-1:0] prefix``_req_data_byteen, \
    output logic [(NUM_LANES)-1:0][(FLAGS_WIDTH)-1:0] prefix``_req_data_flags, \
    output logic [`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_uuid, \
    output logic [(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_value, \
    input  logic prefix``_req_ready, \
    input  logic prefix``_rsp_valid, \
    input  logic [(NUM_LANES)-1:0] prefix``_rsp_data_mask, \
    input  logic [(NUM_LANES)-1:0][(DATA_SIZE)*8-1:0] prefix``_rsp_data_data, \
    input  logic [`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_uuid, \
    input  logic [(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_value, \
    output logic prefix``_rsp_ready

`define VX_LSU_MEM_IF_CONSUMER_PORTS(prefix, NUM_LANES, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH) \
    input  logic prefix``_req_valid, \
    input  logic [(NUM_LANES)-1:0] prefix``_req_data_mask, \
    input  logic prefix``_req_data_rw, \
    input  logic [(NUM_LANES)-1:0][(MEM_ADDR_WIDTH)-`CLOG2(DATA_SIZE)-1:0] prefix``_req_data_addr, \
    input  logic [(NUM_LANES)-1:0][(DATA_SIZE)*8-1:0] prefix``_req_data_data, \
    input  logic [(NUM_LANES)-1:0][(DATA_SIZE)-1:0] prefix``_req_data_byteen, \
    input  logic [(NUM_LANES)-1:0][(FLAGS_WIDTH)-1:0] prefix``_req_data_flags, \
    input  logic [`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_uuid, \
    input  logic [(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_value, \
    output logic prefix``_req_ready, \
    output logic prefix``_rsp_valid, \
    output logic [(NUM_LANES)-1:0] prefix``_rsp_data_mask, \
    output logic [(NUM_LANES)-1:0][(DATA_SIZE)*8-1:0] prefix``_rsp_data_data, \
    output logic [`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_uuid, \
    output logic [(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_value, \
    input  logic prefix``_rsp_ready

`define VX_LSU_MEM_IF_PASS_PORTS(def_pref, pass_pref) \
    .``def_pref``_req_valid(pass_pref``_req_valid), \
    .``def_pref``_req_data_mask(pass_pref``_req_data_mask), \
    .``def_pref``_req_data_rw(pass_pref``_req_data_rw), \
    .``def_pref``_req_data_addr(pass_pref``_req_data_addr), \
    .``def_pref``_req_data_data(pass_pref``_req_data_data), \
    .``def_pref``_req_data_byteen(pass_pref``_req_data_byteen), \
    .``def_pref``_req_data_flags(pass_pref``_req_data_flags), \
    .``def_pref``_req_data_tag_uuid(pass_pref``_req_data_tag_uuid), \
    .``def_pref``_req_data_tag_value(pass_pref``_req_data_tag_value), \
    .``def_pref``_req_ready(pass_pref``_req_ready), \
    .``def_pref``_rsp_valid(pass_pref``_rsp_valid), \
    .``def_pref``_rsp_data_mask(pass_pref``_rsp_data_mask), \
    .``def_pref``_rsp_data_data(pass_pref``_rsp_data_data), \
    .``def_pref``_rsp_data_tag_uuid(pass_pref``_rsp_data_tag_uuid), \
    .``def_pref``_rsp_data_tag_value(pass_pref``_rsp_data_tag_value), \
    .``def_pref``_rsp_ready(pass_pref``_rsp_ready)

`endif