/*-----------------------------------------------------------------------------
 *
 *  Copyright (c) 2021 by Won Hyeok Kim, Jae Uk Park, Chang Yeon Woo,
 *  Hyeon Woo Lee All rights reserved.
 *
 *  File name  : Top.v
 *  Written by : Won Hyeok Kim
 *               Jae Uk Park
 *               Chang Yeon Woo,
 *               Hyeon Woo Lee
 *               Undergraduate
 *               School of Electrical Engineering
 *               Sungkyunkwan University
 *  Written on : January 18, 2022
 *  Version    : 1.0
 *  Design     : RISC-V top module by 'IF','ID','EX','MEM','WB' module
 *               association.
 *
 *  Target testbench: "Top_tb.v" is target testbench code for "Top.v".
 *
 *---------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------
 *
 *  MODULE : Top
 *
 *  I/O wire
 *      - INPUT
 *      clk : System clock. Default clock period is 10ns.
 *      reset_n : Reset signal asynchronous with clk.
 *      ins_data : instruction memory, 32-bits output
 *      load_pc_reg_value1 : ID_register, 32-bits output
 *      load_pc_reg_value2 : ID_register, 32-bits output
 *      read_data : Data memory, 32-bits output
 *      - OUTPUT
 *      op_write_top : ID_register control bit
 *      mem_ctrl_input : Data memory 2-bits input
 *      ins_addr : instruction memory 32-bits input
 *      load_pc_reg_addr1 : ID_register 32-bits input
 *      load_pc_reg_addr2 : ID_register 32-bits input
 *      write_pc_reg_value : ID_register 32-bits input
 *      write_pc_reg_addr : ID_register 32-bits input
 *      address : Data memory 32-bits address input
 *      w_data : Data memory 32-bits data input
 *
 *---------------------------------------------------------------------------*/
module Top(
    input clk,
    input reset_n,
    input [31:0] ins_data,
    input [31:0] load_pc_reg_value1,
    input [31:0] load_pc_reg_value2,
    input [31:0] read_data,
    output op_write_top,
    output [1:0] mem_ctrl_input,
    output [31:0] ins_addr,
    output [31:0] load_pc_reg_addr1,
    output [31:0] load_pc_reg_addr2,
    output [31:0] write_pc_reg_value,
    output [31:0] write_pc_reg_addr,
    output [31:0] address,
    output [31:0] w_data
);
                                        // in       out
                                        //--------------
wire control_j;                         // IF       ID
wire op_write;                          // ID       WB
wire [2:0] ctrl_wb;                     // WB       MEM
wire [4:0] ctrl_mem;                    // MEM      EX
wire [8:0] ctrl_ex;                     // EX       ID
wire [31:0] pc_j;                       // IF       ID
wire [31:0] pipe_pc4;                   // ID       IF
wire [31:0] pipe_pc;                    // ID       IF
wire [31:0] pipe_data;                  // ID       IF
wire [31:0] write_data;                 // ID       WB
wire [31:0] write_addr;                 // ID       WB
wire [31:0] r_data1;                    // EX       ID
wire [31:0] r_data2;                    // EX       ID
wire [31:0] extended;                   // EX       ID
wire [31:0] rd_ex;                      // EX       ID
wire [31:0] pc4_ex;                     // EX       ID
wire [31:0] rd_mem;                     // MEM      EX
wire [31:0] alu_result;                 // MEM      EX
wire [31:0] write_data1;                // MEM      EX
wire [31:0] pc4_mem;                    // MEM      EX
wire [31:0] rd_wb;                      // WB       MEM
wire [31:0] pc4_wb;                     // WB       MEM
wire [31:0] mem_data;                   // WB       MEM
wire [31:0] alu_data;                   // WB       MEM

    
IF IF_module(.clk(clk), .reset_n(reset_n), .control_j(control_j),
             .pc_j(pc_j), .ins_data(ins_data),
             .pipe_pc4(pipe_pc4), .pipe_pc(pipe_pc),
             .ins_addr(ins_addr), .pipe_data(pipe_data));
             
ID ID_module(.clk(clk), .reset_n(reset_n), .op_write(op_write),
             .pipe_pc(pipe_pc), .pipe_pc4(pipe_pc4), .pipe_data(pipe_data),
             .write_data(write_data), .write_addr(write_addr),
             .load_pc_reg_value1(load_pc_reg_value1),
             .load_pc_reg_value2(load_pc_reg_value2),
             .load_pc_reg_addr1(load_pc_reg_addr1),
             .load_pc_reg_addr2(load_pc_reg_addr2),
             .write_pc_reg_value(write_pc_reg_value),
             .write_pc_reg_addr(write_pc_reg_addr),
             .control_j(control_j), .pc_j(pc_j), .r_data1(r_data1),
             .r_data2(r_data2), .extended(extended),
             .rd_ex(rd_ex), .ctrl_ex(ctrl_ex), .pc4_ex(pc4_ex),
             .op_write_top(op_write_top));
             
EX EX_module(.clk(clk), .reset_n(reset_n), .rd_ex(rd_ex),
             .ctrl_ex(ctrl_ex), .r_data1(r_data1), .r_data2(r_data2),
             .extended(extended), .pc4_ex(pc4_ex),
             .ctrl_mem(ctrl_mem), .rd_mem(rd_mem), .alu_result(alu_result),
             .write_data1(write_data1), .pc4_mem(pc4_mem));
             
MEM MEM_module(.clk(clk), .reset_n(reset_n), .ctrl_mem(ctrl_mem), 
               .rd_mem(rd_mem), .pc4_mem(pc4_mem), .alu_result(alu_result),
               .write_data1(write_data1), .read_data(read_data),
               .ctrl_wb(ctrl_wb), .rd_wb(rd_wb), .pc4_wb(pc4_wb),
               .mem_data(mem_data), .alu_data(alu_data),
               .mem_ctrl_input(mem_ctrl_input),
               .address(address), .w_data(w_data));
               
WB WB_module(.ctrl_wb(ctrl_wb), .pc4_wb(pc4_wb), .mem_data(mem_data),
             .alu_data(alu_data), .rd_wb(rd_wb), .op_write(op_write),
             .write_data(write_data), .write_addr(write_addr));
             
endmodule
