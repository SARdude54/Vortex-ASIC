`timescale 1ns / 1ps

`include "VX_define.vh"
`include "VX_mem_bus_if.vh"

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
    // VX_mem_bus_if #(
    //     .DATA_SIZE (`L1_LINE_SIZE),
    //     .TAG_WIDTH (L1_MEM_ARB_TAG_WIDTH)
    // ) socket_mem_bus_if[`L1_MEM_PORTS]();   
    `VX_MEM_BUS_IF_SIGNALS_N(tb_mem_bus_if, `L1_LINE_SIZE, L1_MEM_ARB_TAG_WIDTH, MEM_FLAGS_WIDTH, `MEM_ADDR_WIDTH, `L1_MEM_PORTS);

    // tie off memory
    for (genvar i = 0; i < `L1_MEM_PORTS; ++i) begin : g_mem_tieoff
        assign tb_mem_bus_if_req_ready[i]              = 1'b1;
        assign tb_mem_bus_if_rsp_valid[i]              = 1'b0;
        assign tb_mem_bus_if_rsp_data_data[i]          = '0;
        assign tb_mem_bus_if_rsp_data_tag_uuid[i]      = '0;
        assign tb_mem_bus_if_rsp_data_tag_value[i]     = '0;
    end


    // Instantiate Wrapper
    VX_top UUT (
        .clk(clk),
        .reset(reset),
        
        .dcr_bus_if_write_valid(write_valid),
        .dcr_bus_if_write_addr(write_addr),
        .dcr_bus_if_write_data(write_data),

        // .mem_bus_if(socket_mem_bus_if),
        `VX_MEM_BUS_IF_PASS_PORTS(mem_bus_if, tb_mem_bus_if),

        .busy(busy)
    );

    
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TB_VX_Top);
    end

    initial begin
        write_valid = 1'b0;
        write_addr  = '0;
        write_data  = '0;
    end

    initial begin
        // Vortex reset is usually active-high.
        reset = 1'b1;
        repeat (5) @(posedge clk);
        reset = 1'b0;

        repeat (20) @(posedge clk);
        $finish;
    end

endmodule

