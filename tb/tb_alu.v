`timescale 1ns/1ps

module tb_alu;
    reg [31:0] a;
    reg [31:0] b;
    reg [2:0] op;
    wire [31:0] result;
    wire zero;

    alu dut (
        .a(a),
        .b(b),
        .op(op),
        .result(result),
        .zero(zero)
    );


    task check(input [31:0] result_exp, input zero_exp);
        begin
            if (result !== result_exp || zero !== zero_exp)
                $display("FAIL t=%0t: exp result_exp=%b zero_exp=%b , got reuslt=%b zero=%b",
                        $time, result_exp, zero_exp, result, zero);

            else
                $display("PASS t=%0t", $time);
        end
    endtask


    initial begin
        // Initialize signals
        $dumpfile("alu.vcd");
        $dumpvars(0, tb_alu);
    end

    initial begin
        // Test addition
        a = 32'd5;
        b = 32'd2;
        op = 3'b010;

        #1;
        check (32'd7, 0);
        

        // Test subtraction
        #10;
        a = 32'd5;
        b = 32'd2;
        op = 3'b110;

        #1;
        check (8'd3, 0);

        // Test and
        #10;
        a = 32'd13;
        b = 32'd13;
        op = 3'b000;

        #1;
        check (32'd13, 0);


        // Test or
        #10;
        a = 32'b10001010;
        b = 32'b01011000;
        op = 3'b001;

        #1;
        check (32'b11011010, 0);

        // Test slt
        #10;
        a = 32'h80000000;
        b = 32'd1;
        op = 3'b111;
        #1;
        check(32'b1, 0);

        // Test slt
        #10;
        a = 32'h80000000;
        b = 32'd1;
        op = 3'b101;
        #1;
        check(32'b0, 1);


        // Test zero
        #10
        a = 32'd0;
        b = 32'd0;
        op = 3'b010;
        #1;
        check (32'd0, 1);


        #10
        a = 32'd5;
        b = 32'd5;
        op = 3'b110;
        #1;
        check (32'd0, 1);


        #10
        a = 32'd0;
        b = 32'd0;
        op = 3'b000;
        #1;
        check (32'd0, 1);

        #10
        a = 32'h80000000;
        b = 32'd1;
        op = 3'b111;
        #1;
        check (32'd1, 0);

        #10;
        $display("Test completed");
        $finish;

    end


endmodule

