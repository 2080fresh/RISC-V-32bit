module MEM(
    input clk,
    input reset_n,
    input [4:0] ctrl_mem,
    input [31:0] rd_mem,
    input [31:0] pc4_mem,
    input [31:0] alu_result,
    input [31:0] write_data,
    input [31:0] read_data,     // Data memory output
    output [2:0] ctrl_wb,
    output [31:0] rd_wb,
    output [31:0] pc4_wb,
    output [31:0] mem_data,
    output [31:0] alu_data,
    output [31:0] address,      // Data memory input
    output [31:0] w_data        // Data memory input
);

reg [2:0] ctrl_wb_reg;
reg [31:0] rd_wb_reg;
reg [31:0] pc4_wb_reg;
reg signed [31:0] mem_data_reg;
reg signed [31:0] alu_data_reg;
reg [31:0] address_reg;
reg [31:0] w_data_reg;

//ctrl_mem[4] = memread
//ctrl_mem[3] = memwrite

always @(posedge clk or negedge reset_n)
begin : REGISTER
    if (reset_n == 1'b0) begin
        ctrl_wb_reg <= 3'd0;
        rd_wb_reg <= 32'd0;
        pc4_wb_reg <= 32'd0;
        mem_data_reg <= 32'sd0;
        alu_data_reg <= 32'sd0;
        address_reg <= 32'd0;
        w_data_reg <= 32'd0;
    end else begin
        ctrl_wb_reg <= ctrl_mem[2:0];
        rd_wb_reg <= rd_mem;
        pc4_wb_reg <= pc4_mem;
        mem_data_reg <= read_data;
        alu_data_reg <= alu_result;
        if (ctrl_mem[4] == 1) begin // (read) need modify here to
            address_reg <= alu_result;
            w_data_reg <= write_data;
        end 
        if (ctrl_mem[3] == 1) begin // (write)
            address_reg <= 
            w_data_reg <=  // here
    end
end

assign ctrl_wb = ctrl_wb_reg;
assign rd_wb = rd_wb_reg;
assign pc4_wb = pc4_wb_reg;
assign mem_data = mem_data_reg;
assign alu_data = alu_data_reg;
assign address = address_reg;            // Data memory input
assign w_data = w_data_reg;             // Data memory input

endmodule
