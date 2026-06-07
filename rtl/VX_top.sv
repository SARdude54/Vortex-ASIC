`include "VX_define.vh"
`include "VX_mem_bus_if.vh"

`include "VX_dcr_bus_if.vh"
`include "VX_mem_bus_if.vh"

module VX_top import VX_gpu_pkg::*; #(
    parameter SOCKET_ID = 0,
    parameter `STRING INSTANCE_ID = "",
    parameter int NPORTS = `L1_MEM_PORTS
) (
    input wire                         clk,
    input wire                         reset,

    // flattened: VX_dcr_bus_if.slave         dcr_bus_if,
    `VX_DCR_BUS_CONSUMER_PORTS(dcr_bus_if, VX_DCR_ADDR_WIDTH, VX_DCR_DATA_WIDTH),

    // Pass in VX_mem_bus_if instead of instantiating here (easier for simulation)
    
    // Flatten: VX_mem_bus_if.master mem_bus_if[`L1_MEM_PORTS],
    `VX_MEM_BUS_IF_PRODUCER_PORTS_N(mem_bus_if, `L1_LINE_SIZE, L1_MEM_ARB_TAG_WIDTH, MEM_FLAGS_WIDTH, `MEM_ADDR_WIDTH, `L1_MEM_PORTS),

    // busy status
    output wire busy
);

    // Instatiate Interfaces
    // flattened: VX_dcr_bus_if socket_dcr_bus_if();
    `VX_DCR_BUS_SIGNALS(socket_dcr_bus_if, VX_DCR_ADDR_WIDTH, VX_DCR_DATA_WIDTH)


    assign socket_dcr_bus_if_write_valid = dcr_bus_if_write_valid;
    assign socket_dcr_bus_if_write_addr = dcr_bus_if_write_addr;
    assign socket_dcr_bus_if_write_data = dcr_bus_if_write_data;


    // Instantiate a Single a Socket
    VX_socket #(
        .SOCKET_ID(SOCKET_ID),
        .INSTANCE_ID(INSTANCE_ID)
    ) socket (
        .clk(clk),
        .reset(reset),
        // flatten: .dcr_bus_if(socket_dcr_bus_if),
        `VX_DCR_BUS_PASS_PORTS(dcr_bus_if, socket_dcr_bus_if),
        // flatten: .mem_bus_if(mem_bus_if),
        `VX_MEM_BUS_IF_PASS_PORTS(mem_bus_if, mem_bus_if),
        .busy(busy)
    );

    
endmodule


