`include "VX_define.vh"
`include "VX_dcr_bus_if.vh"

module VX_top import VX_gpu_pkg::*; #(
    parameter SOCKET_ID = 0,
    parameter `STRING INSTANCE_ID = ""
) (
    input wire                         clk,
    input wire                         reset,

    // flattened: VX_dcr_bus_if.slave         dcr_bus_if,
    `VX_DCR_BUS_CONSUMER_PORTS(dcr_bus_if, VX_DCR_ADDR_WIDTH, VX_DCR_DATA_WIDTH),

    // Pass in VX_mem_bus_if instead of instantiating here (easier for simulation)
    VX_mem_bus_if.master mem_bus_if[`L1_MEM_PORTS],

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
        .mem_bus_if(mem_bus_if),
        .busy(busy)
    );


    
endmodule
