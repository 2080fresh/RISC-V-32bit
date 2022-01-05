module EX(
    input clk,
    input reset_n,
    input [4:0] rd_ex,
    input [7:0] ctrl_ex,
    input [63:0] r_data1,
    input [63:0] r_data2,
    input [63:0] extended,
    output [3:0] ctrl_mem,
    output [4:0] rd_mem,
    output [63:0] alu_result,
    output [63:0] write_data1
);

reg [3:0] ctrl_mem_reg;
reg [4:0] rd_mem_reg;
reg [63:0] alu_result_reg;
reg [63:0] write_data1_reg;

reg [63:0] result;
reg [63:0] mux_out;

assign ctrl_mem = ctrl_mem_reg;
assign rd_mem = rd_mem_reg;
assign alu_result = alu_result_reg;
assign write_data1 = write_data1_reg;

always @(posedge clk or negedge reset_n)
begin
    if (reset_n == 0) begin
        ctrl_mem_reg <= 4'd0;
        rd_mem_reg <= 5'd0;
        alu_result_reg <= 64'd0;
        write_data1_reg <= 64'd0;
    end else begin
        ctrl_mem_reg <= ctrl_ex[7:4];
        rd_mem_reg <= rd_ex;
        alu_result_reg <= result;
        write_data1_reg <= r_data2;
    end
end

always @ (*)
begin : MUX
    if (ctrl_ex[0] == 1) begin
        mux_out = extended;
    end else begin
        mux_out = r_data2;
    end
end

always @ (*)
begin : ALU
    if (ctrl_ex[3:1] == 3'b000) begin           // ADD
        result = r_data1 + mux_out;
    end else if (ctrl_ex[3:1] == 3'b001) begin  // SUB
        result = r_data1 - mux_out;
    end else if (ctrl_ex[3:1] == 3'b010) begin  // AND
        result = r_data1 & mux_out;
    end else if (ctrl_ex[3:1] == 3'b011) begin  // OR
        result = r_data1 | mux_out;
    end else if (ctrl_ex[3:1] == 3'b100) begin  // Shift left
        result = r_data1 << mux_out;
    end else if (ctrl_ex[3:1] == 3'b101) begin  // SLT
        result = (r_data1 < mux_out)? 64'd1 : 64'd0 ;
    end
end

endmodule
