module mips_top (
    input wire clk,
    input wire reset
);

    wire [31:0] Instr;
    wire [31:0] ReadData;
    wire [31:0] Pc;
    wire MemWrite;
    wire [31:0] WriteData;
    wire [31:0] ALUResult;


    mips mips_core(
        .clk(clk),
        .reset(reset),
        .Instr(Instr),
        .ReadData(ReadData),
        .Pc(Pc),
        .MemWrite(MemWrite),
        .WriteData(WriteData),
        .ALUResult(ALUResult)
    );

    instruction_memory instruction(
        .addr(Pc),
        .readdata(Instr)
    );

    data_memory data_memory (
        .clk(clk),
        .write_enable(MemWrite),
        .addr(ALUResult),
        .write_data(WriteData),
        .read_data(ReadData)
    );

endmodule