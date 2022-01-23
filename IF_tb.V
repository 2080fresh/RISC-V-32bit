`timescale 1ns / 1ns
module IF_tb;
parameter INS_MEM_SIZE = 40;
parameter INS_START    = 64;
parameter CLK_CYCLE    = 4;
parameter ZERO         = 0;
//clock
reg clk;
//input
reg reset_n;
reg control_j;
reg [31:0]pc_j;
reg [31:0] ins_data;
//output
wire [31:0] pipe_data;
wire [31:0] pipe_pc;
wire [31:0] pipe_pc4;
wire [31:0] ins_addr;
//instruction_memory
reg [31:0] ins_mem_tmp1[INS_MEM_SIZE - 1:0];
reg [7:0] ins_mem[INS_MEM_SIZE*4-1:0];
//variable
integer FID;
integer i=0;

genvar gi, gj;

IF tb_if(.clk(clk), .reset_n(reset_n), .control_j(control_j), .pc_j(pc_j),
         .ins_data(ins_data), .pipe_pc4(pipe_pc4), .pipe_pc(pipe_pc),
         .ins_addr(ins_addr), .pipe_data(pipe_data));

always #10 clk = ~ clk;

generate
    for (gi = 0; gi < INS_MEM_SIZE; gi = gi+1) begin : TMP_TO_MEM_1
        for (gj = 0; gj < 4; gj = gj+1) begin :SET_MEM
            always @ (negedge reset_n) 
                ins_mem[gi*4+gj] = ins_mem_tmp1[gi][gj*8+:8];
        end
    end
endgenerate

generate
    for (gi = 0; gi < 4; gi=gi+1) begin : ASSIGN_INSTRUCTION_
        always @ (ins_addr)
            ins_data[gi*8+:8] = ins_mem[ins_addr-INS_START+gi];
    end
endgenerate

initial
begin
    FID = $fopen("IF_result.txt");
    $readmemh("INS_MEM.txt", ins_mem_tmp1);
    reset_n = 1'b0;
    clk = 1'b1;
    control_j = 1'b0;
    pc_j = 32'd112;

    #21 reset_n = 1'b1;
    #1  i = i + 1; 
        if((ins_addr === INS_START) &&
        (pipe_pc4 === ZERO) &&
        (pipe_pc === ZERO) &&
        (pipe_data === ZERO))
            $fdisplay(FID, "testcase #%2d - initial setup: success", i);
        else
            $fdisplay(FID, "testcase #%2d - initial setup: fail", i);
    #20  i = i + 1;
        if((ins_addr === INS_START + CLK_CYCLE*1) &&
           (pipe_pc4 === INS_START + CLK_CYCLE*1) &&
           (pipe_pc === INS_START) &&
           (pipe_data === {ins_mem[pipe_pc-INS_START+3],
                           ins_mem[pipe_pc-INS_START+2],
                           ins_mem[pipe_pc-INS_START+1],
                           ins_mem[pipe_pc-INS_START+0]}))
            $fdisplay(FID, "testcase #%2d - processing by clk: success", i);
        else
            $fdisplay(FID, "testcase #%2d - processing by clk: fail", i);
    #20  i = i + 1;
        if((ins_addr === INS_START + CLK_CYCLE*2) &&
        (pipe_pc4 === INS_START + CLK_CYCLE*2) &&
        (pipe_pc === INS_START + CLK_CYCLE*1) &&
        (pipe_data === {ins_mem[pipe_pc-INS_START+3],
                        ins_mem[pipe_pc-INS_START+2],
                        ins_mem[pipe_pc-INS_START+1],
                        ins_mem[pipe_pc-INS_START+0]}))
            $fdisplay(FID, "testcase #%2d - processing by clk: success", i);
        else
            $fdisplay(FID, "testcase #%2d - processing by clk: fail", i);
    #17 control_j = 1'b1;
    #3   i = i + 1;
        if((ins_addr === pc_j) &&
        (pipe_pc4 === INS_START + CLK_CYCLE*3) &&
        (pipe_pc === INS_START + CLK_CYCLE*2) &&
        (pipe_data === ZERO))
            $fdisplay(FID, "testcase #%2d - processing by j: success", i);
        else
            $fdisplay(FID, "testcase #%2d - processing by j: fail", i);
    #17 control_j = 1'b0;
    #3  i = i + 1;
        if((ins_addr ===(pc_j + CLK_CYCLE*1)) &&
           (pipe_pc4 === (pc_j + CLK_CYCLE*1)) &&
           (pipe_pc === pc_j) &&
           (pipe_data === {ins_mem[pipe_pc-INS_START+3],
                           ins_mem[pipe_pc-INS_START+2],
                           ins_mem[pipe_pc-INS_START+1],
                           ins_mem[pipe_pc-INS_START+0]}))
            $fdisplay(FID, "testcase #%2d - processing by clk: success", i);
        else
            $fdisplay(FID, "testcase #%2d - processing by clk: fail", i);
    #20  i = i + 1;
        if((ins_addr === (pc_j + CLK_CYCLE*2)) &&
           (pipe_pc4 === (pc_j + CLK_CYCLE*2)) &&
           (pipe_pc === (pc_j + CLK_CYCLE*1)) &&
           (pipe_data === {ins_mem[pipe_pc-INS_START+3],
                           ins_mem[pipe_pc-INS_START+2],
                           ins_mem[pipe_pc-INS_START+1],
                           ins_mem[pipe_pc-INS_START+0]}))
            $fdisplay(FID, "testcase #%2d - processing by clk: success", i);
        else
            $fdisplay(FID, "testcase #%2d - processing by clk: fail", i);
    #20 reset_n = 1'b0;
    #1  i = i + 1;
        if((ins_addr === INS_START) &&(pipe_pc4 === ZERO) &&
           (pipe_pc === ZERO) && (pipe_data === ZERO))
                $fdisplay(FID, "testcase #%2d - processing by reset: success", i);
            else
                $fdisplay(FID, "testcase #%2d - processing by reset: fail", i);
    #16 reset_n = 1'b1;
    #2  i = i + 1;
        if((ins_addr === INS_START + CLK_CYCLE*1) &&
           (pipe_pc4 === INS_START + CLK_CYCLE*1) &&
           (pipe_pc === INS_START) &&
           (pipe_data === {ins_mem[pipe_pc-INS_START+3],
                           ins_mem[pipe_pc-INS_START+2],
                           ins_mem[pipe_pc-INS_START+1],
                           ins_mem[pipe_pc-INS_START+0]}))
            $fdisplay(FID, "testcase #%2d - processing by clk: success", i);
        else
            $fdisplay(FID, "testcase #%2d - processing by clk: fail", i);
    #20 $fclose("FID"); $stop;
end
endmodule
