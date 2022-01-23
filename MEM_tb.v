`timescale 1ns / 1ns

module MEM_tb;
reg clk;
reg reset_n;
reg [4:0] ctrl_mem;
reg [31:0] rd_mem;
reg [31:0] pc4_mem;
reg [31:0] alu_result;
reg [31:0] write_data1;
reg [31:0] read_data;
wire[2:0] ctrl_wb;
wire[31:0] rd_wb;
wire[31:0] pc4_wb;
wire[31:0] mem_data;
wire[31:0] alu_data;
wire[1:0] mem_ctrl_input;
wire[31:0] address;
wire[31:0] w_data;   
integer FID;
integer i = 0;

MEM tb_mem(
    .clk(clk),
    .reset_n(reset_n),
    .ctrl_mem(ctrl_mem),
    .rd_mem(rd_mem),
    .pc4_mem(pc4_mem),
    .alu_result(alu_result),
    .write_data1(write_data1),
    .read_data(read_data),
    .ctrl_wb(ctrl_wb),
    .rd_wb(rd_wb),
    .pc4_wb(pc4_wb),
    .mem_data(mem_data),
    .alu_data(alu_data),
    .mem_ctrl_input(mem_ctrl_input),
    .address(address),
    .w_data(w_data)
);

always #10 clk = ~clk;

always @(address) 
begin : MEMORY
    case (mem_ctrl_input)
        2'b01 : read_data = 32'd2; //S_type
        2'b10 : read_data = 32'd320; //LD
        default : read_data = 32'd1;
    endcase
end

initial
begin
    reset_n = 1'b0;
    clk = 1'b1;
    pc4_mem = 32'd72;
    alu_result = 32'd40;
    write_data1 = 32'd32;
    rd_mem = 32'd12;
    FID = $fopen("MEM_result.txt");
    #21
    reset_n = 1'b1;
    ctrl_mem = 5'b01111;
    pc4_mem = 32'd56;
    alu_result = 32'd48;
    write_data1 = 32'd40;
    rd_mem = 32'd20;
    #1
    i = i + 1;
    if((ctrl_wb === 3'b000) && (pc4_wb === 32'd0) &&
       (mem_data === 32'd0) && (alu_data === 32'd0) &&
       (rd_wb === 32'd0) && (mem_ctrl_input === 2'b01))
        $fdisplay(FID, "testcase #%2d : success", i);
    else
        $fdisplay(FID, "testcase #%2d : fail", i);
    #20
    ctrl_mem = 5'b00101;
    pc4_mem = 32'd52;
    alu_result = 32'd44;
    write_data1 = 32'd0;
    rd_mem = 32'd16;
    #1
    i = i + 1;
    if((ctrl_wb === 3'b111) && (pc4_wb === 32'd56) &&
       (mem_data === 32'd2) && (alu_data === 32'd48) &&
       (rd_wb === 32'd20) && (mem_ctrl_input === 2'b00))
        $fdisplay(FID, "testcase #%2d : success", i);
    else
        $fdisplay(FID, "testcase #%2d : fail", i);
    #20
    ctrl_mem = 5'b10110;
    pc4_mem = 32'd48;
    alu_result = 32'd40;
    write_data1 = 32'd0;
    rd_mem = 32'd12;
    #1
    i = i + 1;
    if((ctrl_wb === 3'b101) && (pc4_wb === 32'd52) &&
       (mem_data === 32'd1) && (alu_data === 32'd44) &&
       (rd_wb === 32'd16) && (mem_ctrl_input === 2'b10))
        $fdisplay(FID, "testcase #%2d : success", i);
    else
        $fdisplay(FID, "testcase #%2d : fail", i);
    #20
    reset_n = 1'b0;
    pc4_mem = 32'd44;
    alu_result = 32'd36;
    write_data1 = 32'd28;
    rd_mem = 32'd8;
    #1
    i = i + 1;
    if((ctrl_wb === 3'd0) && (pc4_wb === 32'd0) &&
       (mem_data === 32'sd0) && (alu_data === 32'sd0) &&
       (rd_wb === 32'd0) && (mem_ctrl_input === 2'b10))
        $fdisplay(FID, "testcase #%2d : success", i);
    else
        $fdisplay(FID, "testcase #%2d : fail", i);
    #10
    reset_n = 1'b1;
    ctrl_mem = 5'b10110;
    #1
    i = i + 1;
    if((ctrl_wb === 3'b000) && (pc4_wb === 32'd0) &&
       (mem_data === 32'sd0) && (alu_data === 32'sd0) &&
       (rd_wb === 32'd0) && (mem_ctrl_input === 2'b10))
        $fdisplay(FID, "testcase #%2d : success", i);
    else
        $fdisplay(FID, "testcase #%2d : fail", i);
    #40
    $stop;
    $fclose("FID");
end
endmodule
