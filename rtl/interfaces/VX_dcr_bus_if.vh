// flattens signals and structs from VX_dcr_bus_if




`ifndef VX_DCR_BUS_FLAT_PORTS_VH
`define VX_DCR_BUS_FlAT_PORTS_VH


`define VX_DCR_BUS_SIGNALS(prefix, DCR_ADDR_WIDTH, DCR_DATA_WIDTH) \
   wire                      prefix``_write_valid; \
   wire [DCR_ADDR_WIDTH-1:0] prefix``_write_addr; \
   wire [DCR_DATA_WIDTH-1:0] prefix``_write_data;


`define VX_DCR_BUS_PRODUCER_PORTS(prefix, DCR_ADDR_WIDTH, DCR_DATA_WIDTH) \
   output wire                      prefix``_write_valid, \
   output wire [DCR_ADDR_WIDTH-1:0] prefix``_write_addr, \
   output wire [DCR_DATA_WIDTH-1:0] prefix``_write_data


`define VX_DCR_BUS_CONSUMER_PORTS(signal_pref, DCR_ADDR_WIDTH, DCR_DATA_WIDTH) \
   input wire                      signal_pref``_write_valid, \
   input wire [DCR_ADDR_WIDTH-1:0] signal_pref``_write_addr, \
   input wire [DCR_DATA_WIDTH-1:0] signal_pref``_write_data


`define VX_DCR_BUS_PASS_PORTS(signal_pref, pass_prefix) \
   .signal_pref``_write_valid(pass_prefix``_write_valid), \
   .signal_pref``_write_addr(pass_prefix``_write_addr), \
   .signal_pref``_write_data(pass_prefix``_write_data)


`endif









