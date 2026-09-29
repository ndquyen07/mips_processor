module control_unit (
    input wire [5:0] Opcode,
    input wire [5:0] Funct,
    output wire MemtoReg,
    output wire MemWrite,
    output wire Branch,
    output wire ALUSrc,
    output wire RegDst,
    output wire RegWrite,
    output wire [2:0] ALUControl
    );
    
    wire [1:0] aluop;

    main_decoder inst1 (
        .Opcode(Opcode),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .Branch(Branch),    
        .ALUSrc(ALUSrc),
        .RegDst(RegDst),
        .RegWrite(RegWrite),
        .ALUOp(aluop)
    );

    alu_decoder inst2 (
        .Funct(Funct),
        .ALUOp(aluop),
        .ALUControl(ALUControl)
    );


endmodule


module main_decoder (
    input wire [5:0] Opcode,
    output reg MemtoReg,
    output reg MemWrite,
    output reg Branch,
    output reg ALUSrc,
    output reg RegDst,
    output reg RegWrite,
    output reg [1:0] ALUOp
);
    always @(*) begin
        case (Opcode)
            6'b000000: {RegWrite, RegDst, ALUSrc, Branch, MemWrite, MemtoReg, ALUOp} = 8'b11000010;
            6'b100011: {RegWrite, RegDst, ALUSrc, Branch, MemWrite, MemtoReg, ALUOp} = 8'b10100100;
            6'b101011: {RegWrite, RegDst, ALUSrc, Branch, MemWrite, MemtoReg, ALUOp} = 8'b00101000;
            6'b000100: {RegWrite, RegDst, ALUSrc, Branch, MemWrite, MemtoReg, ALUOp} = 8'b00010001;
            default: {RegWrite, RegDst, ALUSrc, Branch, MemWrite, MemtoReg, ALUOp} = 8'b00000000;
        endcase
    end

endmodule


module alu_decoder (
    input wire [5:0] Funct,
    input wire [1:0] ALUOp,
    output reg [2:0] ALUControl
);
    localparam ADD = 3'b010, SUB= 3'b110, AND = 3'b000, OR = 3'b001, SLT= 3'b111;
     
    always @(*) begin
        ALUControl = ADD;
        case (ALUOp)
            2'b00: ALUControl = ADD;
            2'b01: ALUControl = SUB;
            2'b10: begin
                case (Funct)
                    6'b100000: ALUControl = ADD;
                    6'b100010: ALUControl = SUB;
                    6'b100100: ALUControl = AND;
                    6'b100101: ALUControl = OR;
                    6'b101010: ALUControl = SLT;
                endcase
            end
        endcase
    end
    
endmodule

