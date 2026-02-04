`include "VX_define.vh"


module VX_top import VX_gpu_pkg::*; #(
    parameter SOCKET_ID = 0,
    parameter `STRING INSTANCE_ID = "",
    parameter int NPORTS = `L1_MEM_PORTS
) (
    input wire                         clk,
    input wire                         reset,

    // (Flattened) DCR interface Inputs
    input wire                         write_valid,
    input wire [VX_DCR_ADDR_WIDTH-1:0] write_addr,
    input wire [VX_DCR_DATA_WIDTH-1:0] write_data,

    // memory bus signals (flattened)
    input  logic [NPORTS-1:0]      mem_req_valid,
    input  vx_mem_req_data_t  mem_req_data [NPORTS],
    output logic [NPORTS-1:0]      mem_req_ready,

    input  logic [NPORTS-1:0]      mem_rsp_valid,
    input  vx_mem_rsp_data_t  mem_rsp_data [NPORTS],
    output logic [NPORTS-1:0]      mem_rsp_ready,

    // busy status
    output wire busy
);



    // Instantiate a Single a Socket
    VX_socket #(
         .SOCKET_ID   (SOCKET_ID),
         .INSTANCE_ID (INSTANCE_ID),
         .NPORTS      (NPORTS)
     ) socket (
         .clk            (clk),
         .reset          (reset),

         .dcr_write_valid(write_valid),
         .dcr_write_addr (write_addr),
         .dcr_write_data (write_data),

         .mem_req_valid  (mem_req_valid),
         .mem_req_data   (mem_req_data),
         .mem_req_ready  (mem_req_ready),

         .mem_rsp_valid  (mem_rsp_valid),
         .mem_rsp_data   (mem_rsp_data),
         .mem_rsp_ready  (mem_rsp_ready),

         .busy           (busy)
     );

    
endmodule
