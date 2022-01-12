module EX(
    input clk,
    input reset_n,
    input [31:0] rd_ex,
    input [8:0] ctrl_ex,
    input [31:0] r_data1,
    input [31:0] r_data2,
    input [31:0] extended,
    input [31:0] pc4_ex,
    output [4:0] ctrl_mem,
    output [31:0] rd_mem,
    output [31:0] alu_result,
    output [31:0] write_data1,
    output [31:0] pc4_mem
);

reg [4:0] ctrl_mem_reg;
reg [31:0] rd_mem_reg;
reg [31:0] pc4_mem_reg;
reg signed [31:0] alu_result_reg;
reg signed [31:0] write_data1_reg;

reg signed [31:0] result;
reg signed [31:0] mux_out;

always @(posedge clk or negedge reset_n)
begin
    if (reset_n == 1'd0) begin
        ctrl_mem_reg <= 5'd0;
        rd_mem_reg <= 5'd0;
        alu_result_reg <= 32'sd0;
        write_data1_reg <= 32'sd0;
        pc4_mem_reg <= 32'd0;
    end else begin
        ctrl_mem_reg <= ctrl_ex[8:4];
        rd_mem_reg <= rd_ex;
        alu_result_reg <= result;
        write_data1_reg <= r_data2;
        pc4_mem_reg <= pc4_ex;
    end
end

always @ (ctrl_ex[0] or extended or r_data2)
begin : MUX
    if (ctrl_ex[0] == 1'b1)
        mux_out = extended;
    else
        mux_out = r_data2;
end

always @ (ctrl_ex[3:1] or r_data1 or mux_out)
begin : ALU
    case (ctrl_ex[3:1])
        3'b000 :
            result = r_data1 + mux_out;                    // ADD
        3'b001 :
            result = r_data1 - mux_out;                    // SUB
        3'b010 :
            result = r_data1 & mux_out;                    // AND
        3'b011 :
            result = r_data1 | mux_out;                    // OR
        3'b100 :
            result = r_data1 << mux_out;                   // Shift left
        default :
            result = (r_data1 < mux_out)? 32'sd1 : 32'sd0 ;  // SLT (ctrl_ex[3:1] == 3'b101)
    endcase
end

assign ctrl_mem = ctrl_mem_reg;
assign rd_mem = rd_mem_reg;
assign alu_result = alu_result_reg;
assign write_data1 = write_data1_reg;
assign pc4_mem = pc4_mem_reg;

endmodule
