module WB(
<<<<<<< HEAD
    input [2:0] ctrl_wb,
    input [31:0] pc4_wb,
    input [31:0] mem_data,
    input [31:0] alu_data,
    input [4:0] rd_wb,
    output op_write,
    output [31:0] write_data,
    output [4:0] write_addr
);

reg signed [31:0] mux_out_reg;

assign op_write = ctrl_wb[0];
assign write_addr = rd_wb;
assign write_data = mux_out_reg;

always @(ctrl_wb or pc4_wb or mem_data or alu_data)
begin : MUX
    case(ctrl_wb[2:1])
        2'b00 : 
            mux_out_reg = alu_data;
        2'b01 : 
            mux_out_reg = mem_data;
        default : 
            mux_out_reg = pc4_wb;
    endcase
=======
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
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
end
endmodule