module MEM(
    input clk,
    input reset_n,
    input [4:0] ctrl_mem,
    input [31:0] rd_mem,
    input [31:0] pc4_mem,
    input [31:0] alu_result,
    input [31:0] write_data1,
    input [31:0] read_data,       // Data memory output
    output [2:0] ctrl_wb,
    output [31:0] rd_wb,
    output [31:0] pc4_wb,
    output [31:0] mem_data,
    output [31:0] alu_data,
    output [1:0] mem_ctrl_input,  // Data memory input
    output [31:0] address,        // Data memory input
    output [31:0] w_data          // Data memory input
);

reg [2:0] ctrl_wb_reg;
reg [31:0] rd_wb_reg;
reg [31:0] pc4_wb_reg;
reg signed [31:0] mem_data_reg;
reg signed [31:0] alu_data_reg;

always @(posedge clk or negedge reset_n)
begin : PIPELINE_REGISTER
    if (reset_n == 1'b0) begin
        ctrl_wb_reg <= 3'd0;
        rd_wb_reg <= 32'd0;
        pc4_wb_reg <= 32'd0;
        mem_data_reg <= 32'sd0;
        alu_data_reg <= 32'sd0;
    end else begin
        ctrl_wb_reg <= ctrl_mem[4:2];
        rd_wb_reg <= rd_mem;
        pc4_wb_reg <= pc4_mem;
        mem_data_reg <= read_data;
        alu_data_reg <= alu_result;
    end
end

assign address = alu_result;           // Data memory input
assign w_data = write_data1;           // Data memory input
assign mem_ctrl_input = ctrl_mem[1:0]; // Data memoty input
assign ctrl_wb = ctrl_wb_reg;
assign rd_wb = rd_wb_reg;
assign pc4_wb = pc4_wb_reg;
assign mem_data = mem_data_reg;
assign alu_data = alu_data_reg;
endmodule
