`timescale 1ns / 1ps
module tb_ex;
localparam MODULE_DELAY = 0.1;
//clock
reg clk;
//input
reg reset_n;
reg [8:0] ctrl_ex;
reg [31:0] rd_ex;
reg [31:0] pc4_ex;
reg signed [31:0] r_data1;
reg signed [31:0] r_data2;
reg signed [31:0] extended;
//output
wire [4:0] ctrl_mem;
wire [31:0] rd_mem;
wire [31:0] pc4_mem;
wire signed [31:0] alu_result;
wire signed [31:0] write_data1;
// comparison factor
reg signed [31:0] com_factor;
// variable
integer FID;
integer t = 0;

EX EX_1(.clk(clk), .reset_n(reset_n), .rd_ex(rd_ex), .ctrl_ex(ctrl_ex),
        .r_data1(r_data1), .r_data2(r_data2), .extended(extended),
        .pc4_ex(pc4_ex), .ctrl_mem(ctrl_mem), .rd_mem(rd_mem),
        .alu_result(alu_result), .write_data1(write_data1), .pc4_mem(pc4_mem));

initial
begin : EX_TESTBENCH
    clk = 1'b0; reset_n = 1'b0;
    ctrl_ex = 9'b000000000;
    rd_ex = 32'd0; r_data1 = 32'sd0; r_data2 = 32'sd0;
    extended = 32'sd0; pc4_ex = 32'd0;
    #15 reset_n = 1'b1; FID = $fopen("result.txt");
    //Testcase #1
    #MODULE_DELAY;
    t = t + 1; ctrl_ex = 9'b111_110_000;
    rd_ex = 32'hFFFF_FFFF; pc4_ex = 32'hFFFF_FFFF;
    r_data1 = 32'sh0; r_data2 = 32'shFFFF_FFFF; extended = 32'sd0;
    com_factor = 32'shFFFF_FFFF;
    #(10 - MODULE_DELAY / 2);
    if(rd_mem !== rd_ex)
        $fdisplay(FID, "testcase #%d rd error", t);
    if(pc4_mem !== pc4_ex)
        $fdisplay(FID, "testcase #%d pc4 error", t);
    if(ctrl_mem !== ctrl_ex[8:4])
        $fdisplay(FID, "testcase #%d ctrl error", t);
    if(write_data1 !== r_data2)
        $fdisplay(FID, "testcase #%d writedata error", t);
    //Testcase #2
    #(MODULE_DELAY / 2);
    t = t+1; ctrl_ex = 9'b000_000_000;
    rd_ex = 32'h0; pc4_ex = 32'h0;
    r_data1 = 32'sh0; r_data2 = 32'sh0; extended = 32'sh0;
    com_factor = 32'sh0;
    #(10 - MODULE_DELAY / 2);
    if(rd_mem !== rd_ex)
        $fdisplay(FID, "testcase #%d rd error", t);
    if(pc4_mem !== pc4_ex)
        $fdisplay(FID, "testcase #%d pc4 error", t);
    if(ctrl_mem !== ctrl_ex[8:4])
        $fdisplay(FID, "testcase #%d ctrl error", t);
    if(write_data1 !== r_data2)
        $fdisplay(FID, "testcase #%d writedata error", t);
    //Testcase #3 ADD & r_data2
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_000_000;
    r_data1 = 32'sd1073741823; r_data2 = 32'sd1; extended = 32'sd0;
    com_factor = 32'sd1073741824;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #4 ADD & extended
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_000_001;
    r_data1 = - 32'sd70; r_data2 = 32'sd0; extended = 32'sd5;
    com_factor = -32'sd65;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #5 SUB & r_data2
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_000_010;
    r_data1 = 32'sd1073741824; r_data2 = 32'sd1; extended = 32'sd0;
    com_factor = 32'sd1073741823;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #6 SUB & extended
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_000_011;
    r_data1 = 32'sd81; r_data2 = 32'sd0; extended = 32'sd970;
    com_factor = -32'sd889;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #7 AND & r_data2
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_000_100;
    r_data1 = 32'shCCCC_CCCC; r_data2 = 32'shAAAA_AAAA; extended = 32'sh0;
    com_factor = 32'sh8888_8888;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #8 AND & extended
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_000_101;
    r_data1 = 32'sh3333_3333; r_data2 = 32'sh0; extended = 32'sh5555_5555;
    com_factor = 32'sh1111_1111;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #9 OR & r_data2
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_000_110;
    r_data1 = 32'shCCCC_CCCC; r_data2 = 32'shAAAA_AAAA; extended = 32'sh0;
    com_factor = 32'shEEEE_EEEE;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #10 OR & extended
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_000_111;
    r_data1 = 32'sh3333_3333; r_data2 = 32'sh0; extended = 32'sh5555_5555;
    com_factor = 32'sh7777_7777;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #11 Shift_left & r_data2
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_001_000;
    r_data1 = 32'shAAAA_AAAA; r_data2 = 32'sh1; extended = 32'sh0;
    com_factor = 32'sh5555_5554;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #12 Shift_left & extended
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_001_001;
    r_data1 = 32'sh5555_5555; r_data2 = 32'sh0; extended = 32'sh2;
    com_factor = 32'sh5555_5554;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #13 SLT & r_data2
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_001_010;
    r_data1 = 32'sd10; r_data2 = 32'sd80; extended = 32'sd0;
    com_factor = 32'sd1;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #14 SLT & r_data2
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_001_010;
    r_data1 = -32'sd10; r_data2 = -32'sd10; extended = 32'sd0;
    com_factor = 32'sd0;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #15 SLT & r_data2
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_001_010;
    r_data1 = 32'sd10; r_data2 = -32'sd105; extended = 32'sd0;
    com_factor = 32'sd0;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #16 SLT & extended
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_001_011;
    r_data1 = -32'sd87; r_data2 = 32'sd0; extended = 32'sd105;
    com_factor = 32'sd1;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #17 SLT & extended
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_001_011;
    r_data1 = 32'sd87; r_data2 = 32'sd0; extended = 32'sd87;
    com_factor = 32'sd0;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    //Testcase #18 SLT & extended
    #(MODULE_DELAY / 2);
    t = t + 1; ctrl_ex = 9'b000_001_011;
    r_data1 = -32'sd87; r_data2 = 32'sd0; extended = -32'sd287;
    com_factor = 32'sd0;
    #(10 - MODULE_DELAY / 2);
    if(com_factor !== alu_result)
        $fdisplay(FID, "testcase #%d\nout  : %d\nfact : %d", t, alu_result ,com_factor);
    #10
    $stop;
    $fclose("FID");
end

// clock period 10ns
always #5 clk = ~ clk;

endmodule
