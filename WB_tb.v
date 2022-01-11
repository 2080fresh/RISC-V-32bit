`timescale 1ns / 1ps

module tb_wb;
//clock
reg clk;

//input
reg [2:0] ctrl_wb;
reg [31:0] pc4_wb;
reg [31:0] mem_data;
reg [31:0] alu_data;
reg [31:0] rd_wb;

//output
wire op_write;
wire [31:0] write_data;
wire [31:0] write_addr;

WB WB_1(.ctrl_wb(ctrl_wb), .pc4_wb(pc4_wb), .mem_data(mem_data),
        .alu_data(alu_data), .rd_wb(rd_wb),
        .op_write(op_write), .write_data(write_data), .write_addr(write_addr));

initial
begin
    clk = 1'b0;
    ctrl_wb = 3'b000;
    pc4_wb = 32'd0;
    mem_data = 32'd0;
    alu_data = 32'd0;
    rd_wb = 32'd0;
end

always #5 clk = ~clk;

initial
begin
    #10 ctrl_wb = 3'b000; pc4_wb = 32'd1; mem_data = 32'd2;
        alu_data = 32'd3; rd_wb = 32'd4;
    #11 ctrl_wb = 3'b001;
    #11 ctrl_wb = 3'b010;
    #11 ctrl_wb = 3'b011;
    #11 ctrl_wb = 3'b100;
    #11 ctrl_wb = 3'b101;
    #11 ctrl_wb = 3'b110;
    #11 ctrl_wb = 3'b111;
end

endmodule
