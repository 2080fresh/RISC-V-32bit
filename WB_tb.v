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

integer FID;
integer i=0;

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
    #10 ctrl_wb = 3'b000; pc4_wb = 32'sd3; mem_data = 32'sd2;
        alu_data = 32'sd1; rd_wb = 32'sd4;
        FID = $fopen("result.txt");
    #1  i = i+1;
        if((ctrl_wb[0] === op_write) && (write_data === alu_data))
            $fdisplay(FID, "testcase #%2d : success", i);
        else
	    $fdisplay(FID, "testcase #%2d : fail", i);
    #10 ctrl_wb = 3'b001;
    #1  i = i+1;
        if((ctrl_wb[0] === op_write) && (write_data === alu_data))
            $fdisplay(FID, "testcase #%2d : success", i);
        else
	    $fdisplay(FID, "testcase #%2d : fail", i);
    #10 ctrl_wb = 3'b010;
    #1  i = i+1;
        if((ctrl_wb[0] === op_write) && (write_data === mem_data))
            $fdisplay(FID, "testcase #%2d : success", i);
        else
	    $fdisplay(FID, "testcase #%2d : fail", i);
    #10 ctrl_wb = 3'b011;
    #1  i = i+1;
        if((ctrl_wb[0] === op_write) && (write_data === mem_data))
            $fdisplay(FID, "testcase #%2d : success", i);
        else
	    $fdisplay(FID, "testcase #%2d : fail", i);
    #10 ctrl_wb = 3'b100;
    #1  i = i+1;
        if((ctrl_wb[0] === op_write) && (write_data === pc4_wb))
            $fdisplay(FID, "testcase #%2d : success", i);
        else
	    $fdisplay(FID, "testcase #%2d : fail", i);
    #10 ctrl_wb = 3'b101;
    #1  i = i+1;
        if((ctrl_wb[0] === op_write) && (write_data === pc4_wb))
            $fdisplay(FID, "testcase #%2d : success", i);
        else
	    $fdisplay(FID, "testcase #%2d : fail", i);
    #10 ctrl_wb = 3'b110;
    #1  i = i+1;
        if((ctrl_wb[0] === op_write) && (write_data === pc4_wb))
            $fdisplay(FID, "testcase #%2d : success", i);
        else
	    $fdisplay(FID, "testcase #%2d : fail", i);
    #10 ctrl_wb = 3'b111;
    #1  i = i+1;
        if((ctrl_wb[0] === op_write) && (write_data === pc4_wb))
            $fdisplay(FID, "testcase #%2d : success", i);
        else
	    $fdisplay(FID, "testcase #%2d : fail", i);
    #10 $fclose("FID"); $stop;
end

endmodule
