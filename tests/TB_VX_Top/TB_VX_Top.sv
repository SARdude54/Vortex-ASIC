`timescale 1ns / 1ps

`include "VX_define.vh"

module TB_VX_Top;
    import VX_gpu_pkg::*;

    logic clk;
    logic reset;

    // DCR Input Signals
    logic write_valid;
    logic [VX_DCR_ADDR_WIDTH-1:0] write_addr;
    logic [VX_DCR_DATA_WIDTH-1:0] write_data;

    // Output signal
    logic busy;

    // Memory Bus Interface
    VX_mem_bus_if #(
        .DATA_SIZE (`L1_LINE_SIZE),
        .TAG_WIDTH (L1_MEM_ARB_TAG_WIDTH)
    ) socket_mem_bus_if[`L1_MEM_PORTS]();   

    // Tie off memory signals for now
    for (genvar i = 0; i < `L1_MEM_PORTS; ++i) begin
        assign socket_mem_bus_if[i].req_ready = 1'b1;
        assign socket_mem_bus_if[i].rsp_valid = 1'b0;
        assign socket_mem_bus_if[i].rsp_data  = '0;
    end


    // Instantiate Wrapper
    VX_top UUT (
        .clk(clk),
        .reset(reset),
        
        .write_valid(write_valid),
        .write_addr(write_addr),
        .write_data(write_data),

        .mem_bus_if(socket_mem_bus_if),

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

