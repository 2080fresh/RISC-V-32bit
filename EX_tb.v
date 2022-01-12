`timescale 1ns / 1ps

module tb_ex;
localparam module_delay = 0.1;
//clock
reg clk;

//input
reg reset_n;
reg [8:0] ctrl_ex;
reg [31:0] rd_ex;
reg [31:0] r_data1;
reg [31:0] r_data2;
reg [31:0] extended;
reg [31:0] pc4_ex;

//output
wire [4:0] ctrl_mem;
wire [31:0] rd_mem;
wire [31:0] alu_result;
wire [31:0] write_data1;
wire [31:0] pc4_mem;

// comparison factor
reg [31:0] alu_result_test;
wire [31:0] write_data1_test;

// variable
integer FID;
integer i;
integer error=0;

EX EX_1(.clk(clk), .reset_n(reset_n), .rd_ex(rd_ex), .ctrl_ex(ctrl_ex),
        .r_data1(r_data1), .r_data2(r_data2), .extended(extended),
        .pc4_ex(pc4_ex), .ctrl_mem(ctrl_mem), .rd_mem(rd_mem),
        .alu_result(alu_result), .write_data1(write_data1), .pc4_mem(pc4_mem));

initial begin
    clk = 1'b0; reset_n = 1'b0;
    ctrl_ex = 9'b000000000;
    rd_ex = 32'd0; r_data1 = 32'd0; r_data2 = 32'd0;
    extended = 32'd0; pc4_ex = 32'd0;
    #10 reset_n = 1'b1;
    #5  FID = $fopen("result.txt");
    for (i=0; i<512; i=i+1) begin                                       // clodk posedge    *output change
        #(module_delay/2);                                              // half delay       *compare old input and new output
        if ((pc4_ex!==pc4_mem) || (rd_ex!==rd_mem)
             || (ctrl_ex[8:4]!==ctrl_mem)
             || (alu_result_test !== alu_result)
             || (write_data1_test!==write_data1)) begin
            $fdisplay(FID, "testcase %d : error", ctrl_ex);
            error = error + 1;
        end
        #(module_delay/2) ctrl_ex = i;                                  // one delay        *input change
                          r_data1 = $urandom_range(0,4_000_000_000);
                          r_data2 = $urandom_range(0,4_000_000_000);
                          extended = $urandom_range(0,4_000_000_000);
                          rd_ex = $urandom_range(0,4_000_000_000);
                          pc4_ex = $urandom_range(0,4_000_000_000);
        #(10-module_delay);                                             // one clock period ended
    end
    #10 if (error>0)
            $fdisplay(FID, "%d errors were detected", error);
        else
            $fdisplay(FID, "all test case were success!");
        $fclose("FID"); $stop;
end

// clock period 10ns
always #5 clk = ~clk;

// comparison factor
always @ (ctrl_ex or r_data1 or write_data1_test)
begin : ALU
    case (ctrl_ex[3:1])
        3'b000 : alu_result_test = r_data1 + (ctrl_ex[0]? extended : r_data2);                    	// ADD
        3'b001 : alu_result_test = r_data1 - (ctrl_ex[0]? extended : r_data2);                    	// SUB
        3'b010 : alu_result_test = r_data1 & (ctrl_ex[0]? extended : r_data2);                    	// AND
        3'b011 : alu_result_test = r_data1 | (ctrl_ex[0]? extended : r_data2);                    	// OR
        3'b100 : alu_result_test = r_data1 << (ctrl_ex[0]? extended : r_data2);                   	// Shift left
        default : alu_result_test = (r_data1 < (ctrl_ex[0]? extended : r_data2))? 32'sd1 : 32'sd0 ;	// SLT (ctrl_ex[3:1] == 3'b101)
    endcase
end

assign write_data1_test = r_data2;

endmodule
