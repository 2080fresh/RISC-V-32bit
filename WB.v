module WB(
    input clk,
    input reset_n,
    input [1:0] ctrl_wb,
    input [63:0] mem_data,
    input [63:0] alu_data,
    input [4:0] rd_wb,
    output op_write,
    output [63:0] write_data,
    output [4:0] write_addr
);

reg op_write_reg;
reg [63:0] write_data_reg;
reg [4:0] write_addr_reg;
reg [63:0] mux_out_temp;

assign op_write = op_write_reg;
assign write_data = write_data_reg;
assign write_addr = write_addr_reg;

always @(posedge clk or negedge reset_n)
begin
    if (reset_n == 1'b0) begin
        op_write_reg <= 1'b0;
        write_data_reg <= 1'b0;
        write_addr_reg <= 1'b0;
    end else begin
        op_write_reg <= ctrl_wb[0];
        write_data_reg <= mux_out_temp;
        write_addr_reg <= rd_wb;
    end
end

always @(ctrl_wb or mem_data or alu_data)
begin : MUX
    if (ctrl_wb[1] == 1'b0)
        mux_out_temp = mem_data;
    else
        mux_out_temp = alu_data;
end
endmodule