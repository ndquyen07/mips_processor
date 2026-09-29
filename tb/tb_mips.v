`timescale 1ns/1ps

module tb_mips;
    reg clk;
    reg reset;

    integer test_num = 0;
    integer pass_n   = 0;
    integer fail_n   = 0;

    mips dut (
        .clk(clk),
        .reset(reset)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    task check(input [31:0] got, input [31:0] exp);
        begin
            test_num = test_num + 1;
            if (got === exp) begin
                $display("PASS %0d  got=%h", test_num, got);
                pass_n = pass_n + 1;
            end
            else begin
                $display("FAIL %0d  got=%h  exp=%h", test_num, got, exp);
                fail_n = fail_n + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("../sim/mips.vcd");
        $dumpvars(0, tb_mips);
    end

    initial begin
        reset = 1;
        @(posedge clk);
        #1;
        reset = 0;

        repeat (5) @(posedge clk);
        #1;

        check(dut.register.mem[10], 32'd30);   // $t2 = 10 + 20
        check(dut.data_memory.mem[2],     32'd30);   // sw wrote it
        check(dut.Pc,                     32'd0);    // branch taken

        $display("%0d passed, %0d failed", pass_n, fail_n);
        $finish;
    end
endmodule