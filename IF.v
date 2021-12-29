module IF (
    input clk,
    input reset_n,
//    input if_flush,
    input control_j,
    input hazard_detect,
    input [63:0] pc_j,
    input [31:0] ins_data,
    output [63:0] pipe_pc,
    output [63:0] ins_addr,
    output [31:0] pipe_data
);

reg [63:0] pc_out_reg;
reg [63:0] pc_in_reg;
reg [63:0] pipe_pc_reg;
reg [31:0] pipe_data_reg;

assign ins_addr = pc_out_reg;
assign pipe_pc = pipe_pc_reg;
assign pipe_data = pipe_data_reg;

always @(control_j or pc_out_reg or pc_j)
begin : MUX
    if (control_j == 1'b0)
        pc_in_reg = pc_out_reg + 64'd4;
    else
        pc_in_reg = pc_j;
end

always @(posedge clk or negedge reset_n)
begin : PC_REGISTER
    if (reset_n == 1'b0) begin
        pc_out_reg <= 64'd0;
//        pc_in_reg <= 64'd0;
        pipe_pc_reg <= 64'd0;
        pipe_data_reg <= 32'd0;
    end else if (hazard_detect == 1'b0) begin
        pc_out_reg <= pc_in_reg;
        pipe_pc_reg <= pc_out_reg;
        pipe_data_reg <= ins_data;
    end
end
endmodule

