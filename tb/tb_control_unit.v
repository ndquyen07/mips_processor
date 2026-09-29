`timescale 1ns/1ps


module tb_control_unit;
    reg [5:0] Opcode;
    reg [5:0] Funct;
    wire MemtoReg;
    wire MemWrite;
    wire Branch;
    wire ALUSrc;
    wire RegDst;
    wire RegWrite;
    wire [2:0] ALUControl;

    wire [5:0] ctrl = {RegWrite, RegDst, ALUSrc, Branch, MemWrite, MemtoReg};

    control_unit dut (
        .Opcode(Opcode),
        .Funct(Funct),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .RegDst(RegDst),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl)
    );

    task check(input [5:0] ctrl_exp, input [2:0] alucontrol_exp);
        begin
            if (ctrl !== ctrl_exp || ALUControl !== alucontrol_exp)
                $display("FAIL t=%0t: exp ctrl_exp=%b alucontrol_exp=%b , got ctrl=%b alucontrol=%b",
                        $time, ctrl_exp, alucontrol_exp, ctrl, ALUControl);

            else
                $display("PASS t=%0t", $time);
        end
    endtask

    initial begin
        // Initialize signals
        $dumpfile("control_unit.vcd");
        $dumpvars(0, tb_control_unit);
    end


    initial begin
        // Test R-type (add)
        #5;
        Opcode = 6'b000000;
        Funct = 6'b100000;
        #1;
        check(6'b110000, 3'b010);
        
        // Test R-type (sub)
        #5;
        Opcode = 6'b000000;
        Funct = 6'b100010;
        #1;
        check(6'b110000, 3'b110);


        // Test R-type (and)
        #5;
        Opcode = 6'b000000;
        Funct = 6'b100100;
        #1;
        check(6'b110000, 3'b000);

        // Test R-type (or)
        #5;
        Opcode = 6'b000000;
        Funct = 6'b100101;
        #1;
        check(6'b110000, 3'b001);

        // Test R-type (slt)
        #5;
        Opcode = 6'b000000;
        Funct = 6'b101010;
        #1;
        check(6'b110000, 3'b111);

        
        // Test lw
        #5;
        Opcode = 6'b100011;
        Funct = 6'b101010;
        #1;
        check(6'b101001, 3'b010);

        // Test sw
        #5;
        Opcode = 6'b101011;
        Funct = 6'b101010;
        #1;
        check(6'b001010, 3'b010);

        // Test beq
        #5;
        Opcode = 6'b000100;
        Funct = 6'b101010;
        #1;
        check(6'b000100, 3'b110);

        // Test unknown
        #5;
        Opcode = 6'b111111;
        Funct = 6'b101010;
        #1;
        check(6'b000000, 3'b010);

        $display("Test completed");
        $finish;
    end

endmodule
