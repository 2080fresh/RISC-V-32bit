`timescale 1ns / 1ns

module IF_tb;
    parameter RS1    = 5'b10000; 
    parameter RS2    = 5'b10001; 
    parameter RD     = 5'b10010; 
    parameter R_TYPE = 7'b0110011; 
    parameter I_TYPE = 7'b0010011;
    parameter JAL = 7'b1101111;
    parameter JALR = 7'b1100111;
    parameter B_TYPE = 7'b1100011;
    parameter LW = 7'b0000011;
    parameter SW = 7'b0100011;

    reg clk;
    reg reset_n;
    reg control_j;
    reg [31:0]pc_j;
    reg[31:0] ins_data;
    wire[31:0] pipe_data;
    wire[31:0] pipe_pc;
    wire[31:0] pipe_pc4;
    wire[31:0] ins_addr;

    IF tb_if(
        .clk(clk),
        .reset_n(reset_n),
        .control_j(control_j),
        .pc_j(pc_j),
        .ins_data(ins_data),
        .pipe_pc4(pipe_pc4),
        .pipe_pc(pipe_pc),
        .ins_addr(ins_addr),
        .pipe_data(pipe_data)
    );



    initial
    begin
        reset_n = 1'b1;
        clk = 1'b1;
        control_j = 1'b0;
        pc_j = 32'd0;
    end

    always #10 clk = ~clk;

    always @(ins_addr) 
    begin : INSTRUCTION_MEMORY
        case (ins_addr)
        32'd64 : ins_data = {000000000011,RS1,000,RD,I_TYPE}; //ADDI
        32'd68 : ins_data = {0000000,RS2,RS1,000,RD,R_TYPE}; //ADD 18,352,435
        32'd72 : ins_data = {0100000,RS2,RS1,000,RD,R_TYPE}; //SUB
        32'd76 : ins_data = {0000000,RS2,RS1,001,RD,R_TYPE}; //SLL
        32'd80 : ins_data = {0000000,RS2,RS1,010,RD,R_TYPE}; //SLT
        32'd84 : ins_data = {0000000,RS2,RS1,111,RD,R_TYPE}; //AMD
        32'd88 : ins_data = {0000000,RS2,RS1,110,RD,R_TYPE}; //OR
        32'd92 : ins_data = {000000000111,RS1,000,RD,I_TYPE}; //ADDI
        32'd96 : ins_data = {0,0000000011,1,00000000,RD,JAL}; //JAL
        32'd100 : ins_data = {000000000111,RS1,000,RD,JALR}; //JALR
        32'd104 : ins_data = {0000000,RS2,RS1,000,0000,0,B_TYPE}; //BEQ
        32'd108 : ins_data = {0000000,RS2,RS1,001,0000,0,B_TYPE}; //BNE
        32'd112 : ins_data = {0000000,RS2,RS1,010,RD,LW}; //LW
        32'd116 : ins_data = {0000000,RS2,RS1,010,00000,SW}; //SW

        default :ins_data = 32'd64;
        endcase
    end

    initial
    begin
        #0 reset_n = 1'b0;
        #10 reset_n = 1'b1;
        #110 reset_n = 1'b0;
        #20 reset_n = 1'b1;
        #40 pc_j = 32'd68;
        #20 control_j = 1'b1;
        #20 control_j = 1'b0;
    end


endmodule
