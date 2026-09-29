`timescale 1ns/1ps

module tb_register;
    reg clk;
    reg rst;
    reg write_enable;
    reg [4:0] rs;
    reg [4:0] rt;
    reg [4:0] rd;
    reg [31:0] write_data;
    wire [31:0] read_data1;
    wire [31:0] read_data2;

    register dut (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    reg [7:0] pass_n = 0;
    reg [7:0] fail_n = 0;
    reg [7:0] test_num = 0;

    task check(input [31:0] exp_read_data1, input [31:0] exp_read_data2);
        begin
            test_num = test_num + 1;
            if (read_data1 === exp_read_data1 && read_data2 === exp_read_data2) begin
                $display("PASS %0d at t=%0t", test_num, $time);
                pass_n = pass_n + 1;
            end
            else begin
                $display("FAIL %0d at t=%0t", test_num, $time);
                fail_n = fail_n + 1;
            end
        end
    endtask


    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        $dumpfile("register.vcd");
        $dumpvars(0, tb_register);
    end

    initial begin

        write_enable = 0;
        rs = 5'b0;
        rt = 5'b0;
        rd = 5'b0;
        write_data = 32'b0;
        rst = 1;
        @(posedge clk);
        #1;
        rst = 0;

        // Test case
        rs = 5'b10101;
        rt = 5'b10101;

        rst = 1;
        @(posedge clk);
        #1;
        rst = 0;
        check(32'b0, 32'b0);


        @(posedge clk);
        #1;
        rd = 5'b01001;
        write_data = 32'hDEADBEEF;
        write_enable = 1;
        @(posedge clk); #1;        // the write happens on this edge
        write_enable = 0; 
        rs = 5'b01001;                    // read port 1 address
        rt = 5'b01001;                    // read port 2 address
        #1;
        check(32'hDEADBEEF, 32'hDEADBEEF);


        @(posedge clk);
        #1;
        rd = 0;
        write_data = 32'hFFFFFFFF;
        write_enable = 1;
        @(posedge clk);
        #1;
        write_enable = 0;
        rs = 0; rt = 0;
        #1;
        check(0, 0);


        @(posedge clk);
        #1;
        rd = 5'b01001;
        write_data = 32'hFFFFFFFF;
        write_enable = 0;
        @(posedge clk);
        #1;
        rs = 5'b01001;         
        rt = 5'b01001;
        #1;
        check(32'hDEADBEEF, 32'hDEADBEEF);

        

        if (fail_n == 0)
            $display("ALL %0d PASSED", pass_n);
        else
            $display("%0d FAILED of %0d", fail_n, pass_n + fail_n);



        $finish;

    end

endmodule