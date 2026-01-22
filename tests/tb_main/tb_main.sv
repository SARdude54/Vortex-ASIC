`timescale 1ps/1ps


module tb_main;

    logic A;
    logic B;
    main UUT (
        .A(A),
        .B(B)
    );

    


    initial begin

        $dumpfile("wave.vcd");
        $dumpvars(0, tb_main);
    end


    initial begin
        A = 1;
        #1;
        assert (A == B) $display("PASS");
            else $error("FAIL");
        $finish;
    end

endmodule