module WB(
    input [2:0] ctrl_wb,
    input [31:0] pc4_wb,
    input [31:0] mem_data,
    input [31:0] alu_data,
    input [31:0] rd_wb,
    output op_write,
    output [31:0] write_data,
    output [31:0] write_addr
);
reg signed [31:0] mux_out_reg;

assign op_write = ctrl_wb[2];
assign write_addr = rd_wb;
assign write_data = mux_out_reg;

always @(ctrl_wb or pc4_wb or mem_data or alu_data)
begin : MUX
    case(ctrl_wb[1:0])
        2'b00 : 
            mux_out_reg = alu_data;
        2'b01 : 
            mux_out_reg = mem_data;
        default : 
            mux_out_reg = pc4_wb;
    endcase
end
endmodule
