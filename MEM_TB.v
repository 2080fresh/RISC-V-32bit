`timescale 1ns / 1ps

module mem_tb;
//clock
reg clk;

//input
reg reset_n;
reg [4:0] ctrl_mem;
reg [31:0] rd_mem;
reg [31:0] pc4_mem;
reg [31:0] alu_result;
reg [31:0] write_data1;
reg [31:0] read_data;

//output
wire [2:0] ctrl_wb;
wire [31:0] rd_wb;
wire [31:0] pc4_wb;
wire [31:0] alu_data;
wire [1:0] mem_ctrl_input; // Data memory control input
wire [31:0] address;      // Data memory input
wire [31:0] w_data;        // Data memory input

MEM MEM_if(.clk(clk), .reset_n(reset_n), .ctrl_mem(ctrl_mem), 
               .rd_mem(rd_mem), .pc4_mem(pc4_mem), .alu_result(alu_result),
               .write_data1(write_data1), .read_data(read_data),
               .ctrl_wb(ctrl_wb), .rd_wb(rd_wb), .pc4_wb(pc4_wb),
               .mem_data(mem_data), .alu_data(alu_data),
               .mem_ctrl_input(mem_ctrl_input),
               .address(address), .w_data(w_data));

initial

endmodule
