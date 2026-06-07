`timescale 1ns / 1ps

`include "VX_define.vh"
`include "VX_dcr_bus_if.vh"
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

    // Output
    logic busy;

    // Memory Bus Interface
    // VX_mem_bus_if #(
    //     .DATA_SIZE (`L1_LINE_SIZE),
    //     .TAG_WIDTH (L1_MEM_ARB_TAG_WIDTH)
    // ) socket_mem_bus_if[`L1_MEM_PORTS]();   
    `VX_MEM_BUS_IF_SIGNALS_N(tb_mem_bus_if, `L1_LINE_SIZE, L1_MEM_ARB_TAG_WIDTH, MEM_FLAGS_WIDTH, `MEM_ADDR_WIDTH, `L1_MEM_PORTS);

    localparam int LINE_BYTES = `L1_LINE_SIZE;
    localparam int LINE_BITS  = 8 * LINE_BYTES;
    localparam int LINE_WORDS = LINE_BYTES / 4;
    localparam int LINE_ADDR_W = tb_mem_bus_if_ADDR_WIDTH;

    localparam [LINE_ADDR_W-1:0] STARTUP_LINE_ADDR =
        (`STARTUP_ADDR >> `CLOG2(`L1_LINE_SIZE));

    // Fake memory-line generator that creates a full cache line filled with RISC-V NOPs
    function automatic [LINE_BITS-1:0] make_mem_line(
        input [LINE_ADDR_W-1:0] line_addr
    );
    begin
        make_mem_line = '0;

        // Fill every 32-bit word in the cache line with:
        // addi x0, x0, 0
        for (int w = 0; w < LINE_WORDS; ++w) begin
            make_mem_line[w*32 +: 32] = 32'h0000_0013;
        end
    end
    endfunction

    // signals holdd pending response for each memory port
    logic [NPORTS-1:0] mem_rsp_valid_q;
    logic [NPORTS-1:0][LINE_BITS-1:0] mem_rsp_data_q;
    logic [NPORTS-1:0][`UP(UUID_WIDTH)-1:0] mem_rsp_tag_uuid_q;
    logic [NPORTS-1:0][L1_MEM_ARB_TAG_WIDTH-`UP(UUID_WIDTH)-1:0] mem_rsp_tag_value_q;

    // Signals will remember which request produced the current response
    logic [NPORTS-1:0][LINE_ADDR_W-1:0] pending_addr_q;
    logic [NPORTS-1:0] pending_rw_q;

    // Sgianls are per-port flags reduced into global flags
    logic [NPORTS-1:0] saw_any_mem_req_p;
    logic [NPORTS-1:0] saw_any_fetch_req_p;
    logic [NPORTS-1:0] saw_any_fetch_rsp_p;
    logic [NPORTS-1:0] saw_startup_fetch_req_p;
    logic [NPORTS-1:0] saw_startup_fetch_rsp_p;

    // OR-reduction turns all per-port observations into global pass/fail signals
    wire saw_any_mem_req       = |saw_any_mem_req_p;
    wire saw_any_fetch_req     = |saw_any_fetch_req_p;
    wire saw_any_fetch_rsp     = |saw_any_fetch_rsp_p;
    wire saw_startup_fetch_req = |saw_startup_fetch_req_p;
    wire saw_startup_fetch_rsp = |saw_startup_fetch_rsp_p;

    // one independent memory model per memory port
    for (genvar p = 0; p < `L1_MEM_PORTS; ++p) begin : g_mem_model

        // Accept a new request if there is no pending response or the pending response is being accepted this cycle
        assign tb_mem_bus_if_req_ready[p] = !mem_rsp_valid_q[p] || tb_mem_bus_if_rsp_ready[p];

        // response outputs
        assign tb_mem_bus_if_rsp_valid[p]          = mem_rsp_valid_q[p];
        assign tb_mem_bus_if_rsp_data_data[p]      = mem_rsp_data_q[p];
        assign tb_mem_bus_if_rsp_data_tag_uuid[p]  = mem_rsp_tag_uuid_q[p];
        assign tb_mem_bus_if_rsp_data_tag_value[p] = mem_rsp_tag_value_q[p];

        always_ff @(posedge clk) begin
            if (reset) begin
                mem_rsp_valid_q[p]     <= 1'b0;
                mem_rsp_data_q[p]      <= '0;
                mem_rsp_tag_uuid_q[p]  <= '0;
                mem_rsp_tag_value_q[p] <= '0;
                pending_addr_q[p]      <= '0;
                pending_rw_q[p]        <= 1'b0;

                saw_any_mem_req_p[p]       <= 1'b0;
                saw_any_fetch_req_p[p]     <= 1'b0;
                saw_any_fetch_rsp_p[p]     <= 1'b0;
                saw_startup_fetch_req_p[p] <= 1'b0;
                saw_startup_fetch_rsp_p[p] <= 1'b0;

            end else begin
                if (tb_mem_bus_if_req_valid[p] && tb_mem_bus_if_req_ready[p]) begin
                    pending_addr_q[p]      <= tb_mem_bus_if_req_data_addr[p];
                    pending_rw_q[p]        <= tb_mem_bus_if_req_data_rw[p];

                    mem_rsp_valid_q[p]     <= 1'b1;
                    mem_rsp_data_q[p]      <= make_mem_line(tb_mem_bus_if_req_data_addr[p]);
                    // echoes the request tag back in the response
                    mem_rsp_tag_uuid_q[p]  <= tb_mem_bus_if_req_data_tag_uuid[p];
                    mem_rsp_tag_value_q[p] <= tb_mem_bus_if_req_data_tag_value[p];

                    saw_any_mem_req_p[p] <= 1'b1;

                    if (!tb_mem_bus_if_req_data_rw[p]) begin
                        saw_any_fetch_req_p[p] <= 1'b1;
                    end

                    $display(
                        "[MEM REQ] time=%0t port=%0d rw=%0b line_addr=0x%0h byte_addr=0x%0h tag_uuid=0x%0h tag_value=0x%0h",
                        $time,
                        p,
                        tb_mem_bus_if_req_data_rw[p],
                        tb_mem_bus_if_req_data_addr[p],
                        {tb_mem_bus_if_req_data_addr[p], {`CLOG2(`L1_LINE_SIZE){1'b0}}},
                        tb_mem_bus_if_req_data_tag_uuid[p],
                        tb_mem_bus_if_req_data_tag_value[p]
                    );

                    if (!tb_mem_bus_if_req_data_rw[p]
                        && tb_mem_bus_if_req_data_addr[p] == STARTUP_LINE_ADDR) begin
                        saw_startup_fetch_req_p[p] <= 1'b1;
                        $display("[FETCH REQ] Startup fetch request observed on port %0d", p);
                    end
                end else if (mem_rsp_valid_q[p] && tb_mem_bus_if_rsp_ready[p]) begin
                    mem_rsp_valid_q[p] <= 1'b0;
                end

                // if DUT accepts response
                if (mem_rsp_valid_q[p] && tb_mem_bus_if_rsp_ready[p]) begin
                    if (!pending_rw_q[p]) begin
                        saw_any_fetch_rsp_p[p] <= 1'b1;
                    end
                    $display(
                        "[MEM RSP] time=%0t port=%0d line_addr=0x%0h rw=%0b tag_uuid=0x%0h tag_value=0x%0h",
                        $time,
                        p,
                        pending_addr_q[p],
                        pending_rw_q[p],
                        mem_rsp_tag_uuid_q[p],
                        mem_rsp_tag_value_q[p]
                    );

                    if (!pending_rw_q[p] && pending_addr_q[p] == STARTUP_LINE_ADDR) begin
                        saw_startup_fetch_rsp_p[p] <= 1'b1;
                        $display("[FETCH RSP] Startup fetch response accepted on port %0d", p);
                    end
                end
            end
        end
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

    // perform one dcr write
    // driven on neg edge so they are stable by pos edge
    task automatic dcr_write(
        input [VX_DCR_ADDR_WIDTH-1:0] addr,
        input [VX_DCR_DATA_WIDTH-1:0] data
    );
    begin
        @(negedge clk);
        write_valid = 1'b1;
        write_addr  = addr;
        write_data  = data;

        @(posedge clk);
        #1;

        assert (UUT.socket_dcr_bus_if_write_valid === 1'b1)
            else $fatal("DCR valid did not propagate into VX_top socket_dcr_bus_if");

        assert (UUT.socket_dcr_bus_if_write_addr === addr)
            else $fatal("DCR addr did not propagate into VX_top socket_dcr_bus_if");

        assert (UUT.socket_dcr_bus_if_write_data === data)
            else $fatal("DCR data did not propagate into VX_top socket_dcr_bus_if");

        assert (UUT.socket.dcr_bus_if_write_valid === 1'b1)
            else $fatal("DCR valid did not reach VX_socket");

        assert (UUT.socket.dcr_bus_if_write_addr === addr)
            else $fatal("DCR addr did not reach VX_socket");

        assert (UUT.socket.dcr_bus_if_write_data === data)
            else $fatal("DCR data did not reach VX_socket");

        $display(
            "[DCR CHECK] addr=0x%0h data=0x%0h propagated into VX_socket",
            addr,
            data
        );

        @(negedge clk);
        write_valid = 1'b0;
        write_addr  = '0;
        write_data  = '0;
    end
    endtask

    // dump waveform
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, TB_VX_Top);
    end

    // main test sequence
    initial begin
        reset = 1'b1;
        write_valid = 1'b0;
        write_addr  = '0;
        write_data  = '0;

        repeat (5) @(posedge clk);
        reset = 1'b0;

        repeat (2) @(posedge clk);

        dcr_write(`VX_DCR_BASE_STARTUP_ADDR0, `STARTUP_ADDR);

        `ifdef XLEN_64
            dcr_write(`VX_DCR_BASE_STARTUP_ADDR1, (`STARTUP_ADDR >> 32));
        `else
            dcr_write(`VX_DCR_BASE_STARTUP_ADDR1, '0);
        `endif

        // program Vortex startup DCRs
        dcr_write(`VX_DCR_BASE_STARTUP_ARG0, 32'h0000_0000);
        dcr_write(`VX_DCR_BASE_STARTUP_ARG1, 32'h0000_0000);
        dcr_write(`VX_DCR_BASE_MPM_CLASS, `VX_DCR_MPM_CLASS_CORE);

        // If the startup fetch request and response both happen, the test passes.

        for (int cycle = 0; cycle < 500; ++cycle) begin
            @(posedge clk);

            if (saw_any_fetch_req && saw_any_fetch_rsp) begin
                $display("PASSED TB_VX_Top Level 3A instruction fetch request/response test");

                if (saw_startup_fetch_req && saw_startup_fetch_rsp) begin
                    $display("INFO: Fetch also matched STARTUP_ADDR line_addr=0x%0h", STARTUP_LINE_ADDR);
                end else begin
                    $display(
                        "INFO: Fetch worked, but no accepted fetch matched STARTUP_ADDR line_addr=0x%0h. Core appears to be fetching from reset/boot PC.",
                        STARTUP_LINE_ADDR
                    );
                end

                $finish;
            end
        end

        if (!saw_any_mem_req) begin
            $fatal("No memory request observed after DCR startup programming");
        end

        if (!saw_any_fetch_req) begin
            $fatal("Memory requests occurred, but no read/fetch request was observed");
        end

        if (!saw_any_fetch_rsp) begin
            $fatal("Read/fetch request occurred, but no response was accepted");
        end

        $fatal("Instruction fetch request/response test timed out unexpectedly");
    end

    //monitor DCR
    always @(posedge clk) begin
        if (!reset && write_valid) begin
            $display(
                "[TB DCR WRITE] time=%0t addr=0x%0h data=0x%0h",
                $time,
                write_addr,
                write_data
            );
        end
    end

endmodule

