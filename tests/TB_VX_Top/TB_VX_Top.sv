`timescale 1ns / 1ps

`include "VX_define.vh"
`include "VX_mem_bus_if.vh"


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
    logic [NPORTS-1:0]       mem_req_ready;
    logic mem_req_rw [NPORTS-1:0];      
    logic mem_req_addr [NPORTS-1:0];   
    logic mem_req_data [NPORTS-1:0];   
    logic mem_req_byteen [NPORTS-1:0]; 
    logic mem_req_flags [NPORTS-1:0];  
    logic mem_req_tag_uuid [NPORTS-1:0];  
    logic mem_req_tag_value [NPORTS-1:0];

    logic [NPORTS-1:0]       mem_rsp_valid;
    logic [NPORTS-1:0]       mem_rsp_ready;

    logic mem_rsp_data [NPORTS-1:0];
    logic mem_rsp_tag_uuid [NPORTS-1:0];
    logic mem_rsp_tag_value [NPORTS-1:0];

    // Output
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
    VX_top #(
        .SOCKET_ID(0),
        .INSTANCE_ID(""),
        .NPORTS(NPORTS)
    ) UUT (
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

    task automatic dcr_write(
    input [VX_DCR_ADDR_WIDTH-1:0] addr,
    input [VX_DCR_DATA_WIDTH-1:0] data
    );
    begin
        @(posedge clk);
        write_valid <= 1'b1;
        write_addr  <= addr;
        write_data  <= data;

        @(posedge clk);
        write_valid <= 1'b0;
        write_addr  <= '0;
        write_data  <= '0;
    end
    endtask

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

    always @(posedge clk) begin
        if (!reset && write_valid) begin
            #1;

            assert (UUT.socket_dcr_bus_if_write_valid === write_valid)
                else $fatal("DCR valid did not propagate into VX_top socket_dcr_bus_if");

            assert (UUT.socket_dcr_bus_if_write_addr === write_addr)
                else $fatal("DCR addr did not propagate into VX_top socket_dcr_bus_if");

            assert (UUT.socket_dcr_bus_if_write_data === write_data)
                else $fatal("DCR data did not propagate into VX_top socket_dcr_bus_if");

            $display(
                "[DCR CHECK] VX_top socket_dcr_bus_if matched addr=0x%0h data=0x%0h",
                UUT.socket_dcr_bus_if_write_addr,
                UUT.socket_dcr_bus_if_write_data
            );
        end
    end

endmodule

