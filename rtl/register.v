module register (
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire [4:0] rs,
    input wire [4:0] rt,
    input wire [4:0] rd,
    input wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    reg [31:0] mem [0:31];
    
    integer i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                mem[i] <= 0;
        end
        else if (write_enable)
            mem[rd] <= write_data;
    end
        
    assign read_data1 = (rs == 0) ? 32'b0 : mem[rs];
    assign read_data2 =  (rt == 0) ? 32'b0 : mem[rt];

endmodule