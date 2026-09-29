module instruction_memory (
    input wire [31:0] addr,
    output wire [31:0] readdata
);
    reg [31:0] RAM [0:63];

    initial begin
        $readmemh("program.hex", RAM);
    end

    assign readdata = RAM[addr[31:2]];
endmodule