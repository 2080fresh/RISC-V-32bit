`timescale 1ns / 1ns

module IF_tb;
    reg clk;
    reg reset_n;
    reg control_j;
    reg [31:0]pc_j;
    reg [31:0] ins_data;
    wire [31:0] pipe_data;
    wire [31:0] pipe_pc;
    wire [31:0] pipe_pc4;
    wire [31:0] ins_addr;

    integer FID;
    integer i=0;

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

    always #10 clk = ~clk;

    initial
    begin
        reset_n = 1'b0;
        clk = 1'b1;
        control_j = 1'b0;
        ins_data = $urandom;
        pc_j = 32'd102;
        FID = $fopen("IF_result.txt");

        #21 reset_n = 1'b1;
        #1  i = i + 1; 
            if((ins_addr === 32'd64) &&
            (pipe_pc4 === 32'd0) &&
            (pipe_pc === 32'd0) &&
            (pipe_data === 32'd0))
                $fdisplay(FID, "testcase #%2d - initial setup: success", i);
            else
                $fdisplay(FID, "testcase #%2d - initial setup: fail", i);
        #20  i = i + 1;
            if((ins_addr === 32'd68) &&
            (pipe_pc4 === 32'd68) &&
            (pipe_pc === 32'd64) &&
            (pipe_data === ins_data))
                $fdisplay(FID, "testcase #%2d - processing by clk: success", i);
            else
                $fdisplay(FID, "testcase #%2d - processing by clk: fail", i);
        #20  i = i + 1;
            if((ins_addr === 32'd72) &&
            (pipe_pc4 === 32'd72) &&
            (pipe_pc === 32'd68) &&
            (pipe_data === ins_data))
                $fdisplay(FID, "testcase #%2d - processing by clk: success", i);
            else
                $fdisplay(FID, "testcase #%2d - processing by clk: fail", i);
        #17 control_j = 1'b1;
        #3   i = i + 1;
            if((ins_addr === pc_j) &&
            (pipe_pc4 === 32'd76) &&
            (pipe_pc === 32'd72) &&
            (pipe_data === 32'd0))
                $fdisplay(FID, "testcase #%2d - processing by j: success", i);
            else
                $fdisplay(FID, "testcase #%2d - processing by j: fail", i);
        #17 control_j = 1'b0;
        #3  i = i + 1;
            if((ins_addr ===(pc_j + 32'd4)) &&
            (pipe_pc4 === (pc_j + 32'd4)) &&
            (pipe_pc === pc_j) &&
            (pipe_data === ins_data))
                $fdisplay(FID, "testcase #%2d - processing by clk: success", i);
            else
                $fdisplay(FID, "testcase #%2d - processing by clk: fail", i);
        #20  i = i + 1;
            if((ins_addr === (pc_j + 32'd8)) &&
            (pipe_pc4 === (pc_j + 32'd8)) &&
            (pipe_pc === (pc_j + 32'd4)) &&
            (pipe_data === ins_data))
                $fdisplay(FID, "testcase #%2d - processing by clk: success", i);
            else
                $fdisplay(FID, "testcase #%2d - processing by clk: fail", i);
        #20 reset_n = 1'b0;
        #1  i = i + 1;
            if((ins_addr === 32'd64) &&
            (pipe_pc4 === 32'd0) &&
            (pipe_pc === 32'd0) &&
            (pipe_data === 32'd0))
                $fdisplay(FID, "testcase #%2d - processing by reset: success", i);
            else
                $fdisplay(FID, "testcase #%2d - processing by reset: fail", i);
        #16 reset_n = 1'b1;
        #2  i = i + 1;
            if((ins_addr === 32'd68) &&
            (pipe_pc4 === 32'd68) &&
            (pipe_pc === 32'd64) &&
            (pipe_data === ins_data))
                $fdisplay(FID, "testcase #%2d - processing by clk: success", i);
            else
                $fdisplay(FID, "testcase #%2d - processing by clk: fail", i);
        #20 $fclose("FID"); $stop;
    end
endmodule
