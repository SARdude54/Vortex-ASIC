`include "VX_define.vh"

module VX_top import VX_gpu_pkg::*; #(
    parameter SOCKET_ID = 0,
    parameter `STRING INSTANCE_ID = ""
) (
    input wire                         clk,
    input wire                         reset,

    // (Flattened) DCR interface Inputs
    input wire                         write_valid,
    input wire [VX_DCR_ADDR_WIDTH-1:0] write_addr,
    input wire [VX_DCR_DATA_WIDTH-1:0] write_data,

    // Pass in VX_mem_bus_if instead of instantiating here (easier for simulation)
    VX_mem_bus_if.master mem_bus_if[`L1_MEM_PORTS],

    output wire busy
);

    // Instatiate Interfaces
    VX_dcr_bus_if socket_dcr_bus_if();
    assign socket_dcr_bus_if.write_valid = write_valid;
    assign socket_dcr_bus_if.write_addr = write_addr;
    assign socket_dcr_bus_if.write_data = write_data;


    // Instantiate a Single a Socket
    VX_socket #(
        .SOCKET_ID(SOCKET_ID),
        .INSTANCE_ID(INSTANCE_ID)
    ) socket (
        .clk(clk),
        .reset(reset),
        .dcr_bus_if(socket_dcr_bus_if),
        .mem_bus_if(mem_bus_if),
        .busy(busy)
    );


    
endmodule
