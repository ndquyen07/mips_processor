module mips (
    input wire clk,
    input wire reset,
    input wire [31:0] Instr,
    input wire [31:0] ReadData,
    output wire [31:0] Pc,
    output wire MemWrite,
    output wire [31:0] WriteData,
    output wire [31:0] ALUResult
);
    wire [31:0] PcNext;
    wire [31:0] PcPlus4;
    wire [31:0] PcBranch;
    wire [31:0] SignImm;
    wire [31:0] SignImmSh;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] Result;
    wire [4:0] WriteReg;
    wire MemtoReg;
    wire Branch;
    wire [2:0] ALUControl;
    wire ALUSrc;
    wire RegDst;
    wire RegWrite;
    wire PCSrc;
    wire Zero;

    //==============================//

    mux2 pcsrc (
        .a(PcPlus4),
        .b(PcBranch),
        .sel(PCSrc),
        .y(PcNext)
    );

    pc_register pc_register (
        .clk(clk),
        .reset(reset),
        .pcnext(PcNext),
        .pc(Pc)
    );


    adder pcplus4adder (
        .a(Pc),
        .b(32'd4),
        .y(PcPlus4)
    );



    //==============================//

    control_unit control_unit (
        .Opcode(Instr[31:26]),
        .Funct(Instr[5:0]),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .Branch(Branch),
        .ALUSrc(ALUSrc),
        .RegDst(RegDst),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl)
    );


    register register (
        .clk(clk),
        .reset(reset),
        .write_enable(RegWrite),
        .rs(Instr[25:21]),
        .rt(Instr[20:16]),
        .rd(WriteReg),
        .write_data(Result),
        .read_data1(SrcA),
        .read_data2(WriteData)
    );


    sign_extend sign_extend (
        .in(Instr[15:0]),
        .out(SignImm)
    );



    mux2 #(5) regdst (
        .a(Instr[20:16]),
        .b(Instr[15:11]),
        .sel(RegDst),
        .y(WriteReg)
    );

    //==============================//
    
    mux2 alusrc (
        .a(WriteData),
        .b(SignImm),
        .sel(ALUSrc),
        .y(SrcB)
    );


    alu alu (
        .a(SrcA),
        .b(SrcB),
        .op(ALUControl),
        .result(ALUResult),
        .zero(Zero)
    );

    assign PCSrc = Branch && Zero;

    assign SignImmSh = SignImm << 2;

    adder pcbranchadder (
        .a(SignImmSh),
        .b(PcPlus4),
        .y(PcBranch)
    );


    //==============================//


    mux2 memtoreg (
        .a(ALUResult),
        .b(ReadData),
        .sel(MemtoReg),
        .y(Result)
    );

endmodule