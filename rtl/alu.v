module alu (
    input wire signed [31:0] a,
    input wire signed [31:0] b,
    input wire [2:0] op,
    output reg [31:0] result,
    output reg zero
);
    // op: 010 add, 110 sub, 000 and, 001 or, 111 slt
    always @(*) begin
        case (op)
            3'b000: result = a & b;
            3'b001: result = a | b;
            3'b010: result = a + b;
            3'b110: result = a - b;
            3'b111: result = (a < b) ? 32'd1 : 32'd0;
            3'b101: result = ($unsigned(a) < $unsigned(b)) ? 32'd1 : 32'd0;

            default: result = 32'bx;
        endcase

        zero = (result == 32'b0);
    end

endmodule