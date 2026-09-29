module pc_register (
    input wire clk,
    input wire reset,
    input wire [31:0] pcnext,
    output reg [31:0] pc
);
    always @(posedge clk) begin
        if (reset) 
            pc <= 32'b0;
        else
            pc <= pcnext;
    end
endmodule