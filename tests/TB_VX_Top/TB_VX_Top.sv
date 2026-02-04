`timescale 1ns / 1ps

`include "VX_define.vh"


module TB_VX_Top;
    import VX_gpu_pkg::*;

    localparam int NPORTS = `L1_MEM_PORTS;

    logic clk;
    logic reset;

    // DCR Input Signals
    logic write_valid;
    logic [VX_DCR_ADDR_WIDTH-1:0] write_addr;
    logic [VX_DCR_DATA_WIDTH-1:0] write_data;

    // Flattened memory bus signals
    logic [NPORTS-1:0]       mem_req_valid;
    vx_mem_req_data_t        mem_req_data [NPORTS];
    logic [NPORTS-1:0]       mem_req_ready;

    logic [NPORTS-1:0]       mem_rsp_valid;
    vx_mem_rsp_data_t        mem_rsp_data [NPORTS];
    logic [NPORTS-1:0]       mem_rsp_ready;

    // Output
    logic busy;


    // Instantiate Wrapper
    VX_top #(
        .SOCKET_ID(0),
        .INSTANCE_ID(""),
        .NPORTS(NPORTS)
    ) UUT (
        .clk(clk),
        .reset(reset),
        
        .write_valid(write_valid),
        .write_addr(write_addr),
        .write_data(write_data),

        .mem_req_valid(mem_req_valid),
        .mem_req_data (mem_req_data),
        .mem_req_ready(mem_req_ready),

        .mem_rsp_valid(mem_rsp_valid),
        .mem_rsp_data (mem_rsp_data),
        .mem_rsp_ready(mem_rsp_ready),

        .busy(busy)
    );

    
    initial clk = 0;
    always #5 clk = ~clk;


    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TB_VX_Top);
    end

    initial begin
        write_valid = 0;
        write_data = '0;
        write_addr = '0;
    end

    
    initial begin
        reset = 0;

        #20 reset = 1;
        @(posedge clk);

        
        #50;
        $finish;
    end

endmodule

