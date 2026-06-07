`ifndef VX_MEM_BUS_IF_FLAT_VH
`define VX_MEM_BUS_IF_FLAT_VH

`define VX_MEM_BUS_IF_SIGNALS(prefix, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH) \
    localparam prefix``_ADDR_WIDTH = (MEM_ADDR_WIDTH) - `CLOG2(DATA_SIZE); \
    logic prefix``_req_valid; \
    logic prefix``_req_data_rw; \
    logic [prefix``_ADDR_WIDTH-1:0] prefix``_req_data_addr; \
    logic [(DATA_SIZE)*8-1:0] prefix``_req_data_data; \
    logic [(DATA_SIZE)-1:0] prefix``_req_data_byteen; \
    logic [(FLAGS_WIDTH)-1:0] prefix``_req_data_flags; \
    logic [`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_uuid; \
    logic [(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_value; \
    logic prefix``_req_ready; \
    logic prefix``_rsp_valid; \
    logic [(DATA_SIZE)*8-1:0] prefix``_rsp_data_data; \
    logic [`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_uuid; \
    logic [(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_value; \
    logic prefix``_rsp_ready

`define VX_MEM_BUS_IF_SIGNALS_N(prefix, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH, N) \
    localparam prefix``_ADDR_WIDTH = (MEM_ADDR_WIDTH) - `CLOG2(DATA_SIZE); \
    logic [(N)-1:0] prefix``_req_valid; \
    logic [(N)-1:0] prefix``_req_data_rw; \
    logic [(N)-1:0][prefix``_ADDR_WIDTH-1:0] prefix``_req_data_addr; \
    logic [(N)-1:0][(DATA_SIZE)*8-1:0] prefix``_req_data_data; \
    logic [(N)-1:0][(DATA_SIZE)-1:0] prefix``_req_data_byteen; \
    logic [(N)-1:0][(FLAGS_WIDTH)-1:0] prefix``_req_data_flags; \
    logic [(N)-1:0][`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_uuid; \
    logic [(N)-1:0][(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_value; \
    logic [(N)-1:0] prefix``_req_ready; \
    logic [(N)-1:0] prefix``_rsp_valid; \
    logic [(N)-1:0][(DATA_SIZE)*8-1:0] prefix``_rsp_data_data; \
    logic [(N)-1:0][`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_uuid; \
    logic [(N)-1:0][(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_value; \
    logic [(N)-1:0] prefix``_rsp_ready

// already computed address field width
`define VX_MEM_BUS_IF_SIGNALS_AW_N(prefix, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, ADDR_WIDTH, N) \
    logic [(N)-1:0] prefix``_req_valid; \
    logic [(N)-1:0] prefix``_req_data_rw; \
    logic [(N)-1:0][(ADDR_WIDTH)-1:0] prefix``_req_data_addr; \
    logic [(N)-1:0][(DATA_SIZE)*8-1:0] prefix``_req_data_data; \
    logic [(N)-1:0][(DATA_SIZE)-1:0] prefix``_req_data_byteen; \
    logic [(N)-1:0][(FLAGS_WIDTH)-1:0] prefix``_req_data_flags; \
    logic [(N)-1:0][`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_uuid; \
    logic [(N)-1:0][(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_value; \
    logic [(N)-1:0] prefix``_req_ready; \
    logic [(N)-1:0] prefix``_rsp_valid; \
    logic [(N)-1:0][(DATA_SIZE)*8-1:0] prefix``_rsp_data_data; \
    logic [(N)-1:0][`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_uuid; \
    logic [(N)-1:0][(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_value; \
    logic [(N)-1:0] prefix``_rsp_ready


`define VX_MEM_BUS_IF_PRODUCER_PORTS(prefix, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH) \
    output logic prefix``_req_valid, \
    output logic prefix``_req_data_rw, \
    output logic [(MEM_ADDR_WIDTH)-`CLOG2(DATA_SIZE)-1:0] prefix``_req_data_addr, \
    output logic [(DATA_SIZE)*8-1:0] prefix``_req_data_data, \
    output logic [(DATA_SIZE)-1:0] prefix``_req_data_byteen, \
    output logic [(FLAGS_WIDTH)-1:0] prefix``_req_data_flags, \
    output logic [`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_uuid, \
    output logic [(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_value, \
    input  logic prefix``_req_ready, \
    input  logic prefix``_rsp_valid, \
    input  logic [(DATA_SIZE)*8-1:0] prefix``_rsp_data_data, \
    input  logic [`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_uuid, \
    input  logic [(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_value, \
    output logic prefix``_rsp_ready


`define VX_MEM_BUS_IF_PRODUCER_PORTS_N(prefix, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH, N) \
    output logic [(N)-1:0] prefix``_req_valid, \
    output logic [(N)-1:0] prefix``_req_data_rw, \
    output logic [(N)-1:0][(MEM_ADDR_WIDTH)-`CLOG2(DATA_SIZE)-1:0] prefix``_req_data_addr, \
    output logic [(N)-1:0][(DATA_SIZE)*8-1:0] prefix``_req_data_data, \
    output logic [(N)-1:0][(DATA_SIZE)-1:0] prefix``_req_data_byteen, \
    output logic [(N)-1:0][(FLAGS_WIDTH)-1:0] prefix``_req_data_flags, \
    output logic [(N)-1:0][`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_uuid, \
    output logic [(N)-1:0][(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_value, \
    input  logic [(N)-1:0] prefix``_req_ready, \
    input  logic [(N)-1:0] prefix``_rsp_valid, \
    input  logic [(N)-1:0][(DATA_SIZE)*8-1:0] prefix``_rsp_data_data, \
    input  logic [(N)-1:0][`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_uuid, \
    input  logic [(N)-1:0][(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_value, \
    output logic [(N)-1:0] prefix``_rsp_ready

`define VX_MEM_BUS_IF_PRODUCER_PORTS_AW_N(prefix, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH, N) \
    output logic [(N)-1:0] prefix``_req_valid, \
    output logic [(N)-1:0] prefix``_req_data_rw, \
    output logic [(N)-1:0][(MEM_ADDR_WIDTH)-1:0] prefix``_req_data_addr, \
    output logic [(N)-1:0][(DATA_SIZE)*8-1:0] prefix``_req_data_data, \
    output logic [(N)-1:0][(DATA_SIZE)-1:0] prefix``_req_data_byteen, \
    output logic [(N)-1:0][(FLAGS_WIDTH)-1:0] prefix``_req_data_flags, \
    output logic [(N)-1:0][`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_uuid, \
    output logic [(N)-1:0][(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_value, \
    input  logic [(N)-1:0] prefix``_req_ready, \
    input  logic [(N)-1:0] prefix``_rsp_valid, \
    input  logic [(N)-1:0][(DATA_SIZE)*8-1:0] prefix``_rsp_data_data, \
    input  logic [(N)-1:0][`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_uuid, \
    input  logic [(N)-1:0][(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_value, \
    output logic [(N)-1:0] prefix``_rsp_ready


`define VX_MEM_BUS_IF_CONSUMER_PORTS(prefix, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH) \
    input  logic prefix``_req_valid, \
    input  logic prefix``_req_data_rw, \
    input  logic [(MEM_ADDR_WIDTH)-`CLOG2(DATA_SIZE)-1:0] prefix``_req_data_addr, \
    input  logic [(DATA_SIZE)*8-1:0] prefix``_req_data_data, \
    input  logic [(DATA_SIZE)-1:0] prefix``_req_data_byteen, \
    input  logic [(FLAGS_WIDTH)-1:0] prefix``_req_data_flags, \
    input  logic [`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_uuid, \
    input  logic [(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_value, \
    output logic prefix``_req_ready, \
    output logic prefix``_rsp_valid, \
    output logic [(DATA_SIZE)*8-1:0] prefix``_rsp_data_data, \
    output logic [`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_uuid, \
    output logic [(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_value, \
    input  logic prefix``_rsp_ready


`define VX_MEM_BUS_IF_CONSUMER_PORTS_N(prefix, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH, N) \
    input  logic [(N)-1:0] prefix``_req_valid, \
    input  logic [(N)-1:0] prefix``_req_data_rw, \
    input  logic [(N)-1:0][(MEM_ADDR_WIDTH)-`CLOG2(DATA_SIZE)-1:0] prefix``_req_data_addr, \
    input  logic [(N)-1:0][(DATA_SIZE)*8-1:0] prefix``_req_data_data, \
    input  logic [(N)-1:0][(DATA_SIZE)-1:0] prefix``_req_data_byteen, \
    input  logic [(N)-1:0][(FLAGS_WIDTH)-1:0] prefix``_req_data_flags, \
    input  logic [(N)-1:0][`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_uuid, \
    input  logic [(N)-1:0][(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_value, \
    output logic [(N)-1:0] prefix``_req_ready, \
    output logic [(N)-1:0] prefix``_rsp_valid, \
    output logic [(N)-1:0][(DATA_SIZE)*8-1:0] prefix``_rsp_data_data, \
    output logic [(N)-1:0][`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_uuid, \
    output logic [(N)-1:0][(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_value, \
    input  logic [(N)-1:0] prefix``_rsp_ready

`define VX_MEM_BUS_IF_CONSUMER_PORTS_AW_N(prefix, DATA_SIZE, TAG_WIDTH, FLAGS_WIDTH, MEM_ADDR_WIDTH, N) \
    input  logic [(N)-1:0] prefix``_req_valid, \
    input  logic [(N)-1:0] prefix``_req_data_rw, \
    input  logic [(N)-1:0][(MEM_ADDR_WIDTH)-1:0] prefix``_req_data_addr, \
    input  logic [(N)-1:0][(DATA_SIZE)*8-1:0] prefix``_req_data_data, \
    input  logic [(N)-1:0][(DATA_SIZE)-1:0] prefix``_req_data_byteen, \
    input  logic [(N)-1:0][(FLAGS_WIDTH)-1:0] prefix``_req_data_flags, \
    input  logic [(N)-1:0][`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_uuid, \
    input  logic [(N)-1:0][(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_req_data_tag_value, \
    output logic [(N)-1:0] prefix``_req_ready, \
    output logic [(N)-1:0] prefix``_rsp_valid, \
    output logic [(N)-1:0][(DATA_SIZE)*8-1:0] prefix``_rsp_data_data, \
    output logic [(N)-1:0][`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_uuid, \
    output logic [(N)-1:0][(TAG_WIDTH)-`UP(UUID_WIDTH)-1:0] prefix``_rsp_data_tag_value, \
    input  logic [(N)-1:0] prefix``_rsp_ready

`define VX_MEM_BUS_IF_PASS_PORTS(def_pref, pass_pref) \
    .``def_pref``_req_valid(pass_pref``_req_valid), \
    .``def_pref``_req_data_rw(pass_pref``_req_data_rw), \
    .``def_pref``_req_data_addr(pass_pref``_req_data_addr), \
    .``def_pref``_req_data_data(pass_pref``_req_data_data), \
    .``def_pref``_req_data_byteen(pass_pref``_req_data_byteen), \
    .``def_pref``_req_data_flags(pass_pref``_req_data_flags), \
    .``def_pref``_req_data_tag_uuid(pass_pref``_req_data_tag_uuid), \
    .``def_pref``_req_data_tag_value(pass_pref``_req_data_tag_value), \
    .``def_pref``_req_ready(pass_pref``_req_ready), \
    .``def_pref``_rsp_valid(pass_pref``_rsp_valid), \
    .``def_pref``_rsp_data_data(pass_pref``_rsp_data_data), \
    .``def_pref``_rsp_data_tag_uuid(pass_pref``_rsp_data_tag_uuid), \
    .``def_pref``_rsp_data_tag_value(pass_pref``_rsp_data_tag_value), \
    .``def_pref``_rsp_ready(pass_pref``_rsp_ready)

`define VX_MEM_BUS_IF_PASS_PORTS_I(def_pref, pass_pref, i) \
    .``def_pref``_req_valid(pass_pref``_req_valid[i]), \
    .``def_pref``_req_data_rw(pass_pref``_req_data_rw[i]), \
    .``def_pref``_req_data_addr(pass_pref``_req_data_addr[i]), \
    .``def_pref``_req_data_data(pass_pref``_req_data_data[i]), \
    .``def_pref``_req_data_byteen(pass_pref``_req_data_byteen[i]), \
    .``def_pref``_req_data_flags(pass_pref``_req_data_flags[i]), \
    .``def_pref``_req_data_tag_uuid(pass_pref``_req_data_tag_uuid[i]), \
    .``def_pref``_req_data_tag_value(pass_pref``_req_data_tag_value[i]), \
    .``def_pref``_req_ready(pass_pref``_req_ready[i]), \
    .``def_pref``_rsp_valid(pass_pref``_rsp_valid[i]), \
    .``def_pref``_rsp_data_data(pass_pref``_rsp_data_data[i]), \
    .``def_pref``_rsp_data_tag_uuid(pass_pref``_rsp_data_tag_uuid[i]), \
    .``def_pref``_rsp_data_tag_value(pass_pref``_rsp_data_tag_value[i]), \
    .``def_pref``_rsp_ready(pass_pref``_rsp_ready[i])

`define VX_MEM_BUS_IF_PASS_PORTS_SLICE(def_pref, pass_pref, base, N) \
    .``def_pref``_req_valid(pass_pref``_req_valid[(base) +: (N)]), \
    .``def_pref``_req_data_rw(pass_pref``_req_data_rw[(base) +: (N)]), \
    .``def_pref``_req_data_addr(pass_pref``_req_data_addr[(base) +: (N)]), \
    .``def_pref``_req_data_data(pass_pref``_req_data_data[(base) +: (N)]), \
    .``def_pref``_req_data_byteen(pass_pref``_req_data_byteen[(base) +: (N)]), \
    .``def_pref``_req_data_flags(pass_pref``_req_data_flags[(base) +: (N)]), \
    .``def_pref``_req_data_tag_uuid(pass_pref``_req_data_tag_uuid[(base) +: (N)]), \
    .``def_pref``_req_data_tag_value(pass_pref``_req_data_tag_value[(base) +: (N)]), \
    .``def_pref``_req_ready(pass_pref``_req_ready[(base) +: (N)]), \
    .``def_pref``_rsp_valid(pass_pref``_rsp_valid[(base) +: (N)]), \
    .``def_pref``_rsp_data_data(pass_pref``_rsp_data_data[(base) +: (N)]), \
    .``def_pref``_rsp_data_tag_uuid(pass_pref``_rsp_data_tag_uuid[(base) +: (N)]), \
    .``def_pref``_rsp_data_tag_value(pass_pref``_rsp_data_tag_value[(base) +: (N)]), \
    .``def_pref``_rsp_ready(pass_pref``_rsp_ready[(base) +: (N)])

// Slice helpers
`define VX_MEM_BUS_IF_SLICE_REQ_VALID(prefix, i) \
    prefix``_req_valid[i]

`define VX_MEM_BUS_IF_SLICE_REQ_DATA_RW(prefix, i) \
    prefix``_req_data_rw[i]

`define VX_MEM_BUS_IF_SLICE_REQ_DATA_ADDR(prefix, i) \
    prefix``_req_data_addr[i]

`define VX_MEM_BUS_IF_SLICE_REQ_DATA_DATA(prefix, i) \
    prefix``_req_data_data[i]

`define VX_MEM_BUS_IF_SLICE_REQ_DATA_BYTEEN(prefix, i) \
    prefix``_req_data_byteen[i]

`define VX_MEM_BUS_IF_SLICE_REQ_DATA_FLAGS(prefix, i) \
    prefix``_req_data_flags[i]

`define VX_MEM_BUS_IF_SLICE_REQ_DATA_TAG_UUID(prefix, i) \
    prefix``_req_data_tag_uuid[i]

`define VX_MEM_BUS_IF_SLICE_REQ_DATA_TAG_VALUE(prefix, i) \
    prefix``_req_data_tag_value[i]

`define VX_MEM_BUS_IF_SLICE_REQ_READY(prefix, i) \
    prefix``_req_ready[i]

`define VX_MEM_BUS_IF_SLICE_RSP_VALID(prefix, i) \
    prefix``_rsp_valid[i]

`define VX_MEM_BUS_IF_SLICE_RSP_DATA_DATA(prefix, i) \
    prefix``_rsp_data_data[i]

`define VX_MEM_BUS_IF_SLICE_RSP_DATA_TAG_UUID(prefix, i) \
    prefix``_rsp_data_tag_uuid[i]

`define VX_MEM_BUS_IF_SLICE_RSP_DATA_TAG_VALUE(prefix, i) \
    prefix``_rsp_data_tag_value[i]

`define VX_MEM_BUS_IF_SLICE_RSP_READY(prefix, i) \
    prefix``_rsp_ready[i]

`endif