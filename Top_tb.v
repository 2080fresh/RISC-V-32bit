`timescale 1ns / 1ps

module tb_top;
localparam module_delay = 0.1;
localparam Mem_delay = 1;
localparam Mem_size = 100000;
//clock
reg clk;

//input
reg reset_n;
reg [31:0] ins_data;
reg [31:0] load_pc_reg_value1;
reg [31:0] load_pc_reg_value2;
reg [31:0] read_data;

//output
wire write_ctrl_input;
wire [1:0] mem_ctrl_input;
wire [31:0] ins_addr;
wire [31:0] load_pc_reg_addr1;
wire [31:0] load_pc_reg_addr2;
wire [31:0] write_pc_reg_value;
wire [31:0] write_pc_reg_addr;
wire [31:0] address;
wire [31:0] w_data;

//etc
reg [31:0] Memory[0:Mem_size-1];
integer i, FID;

Top Top_module(.clk(clk), .reset_n(reset_n), .ins_data(ins_data),
               .load_pc_reg_value1(load_pc_reg_value1),
               .load_pc_reg_value2(load_pc_reg_value2),
               .read_data(read_data), .mem_ctrl_input(mem_ctrl_input),
               .ins_addr(ins_addr),
               .load_pc_reg_addr1(load_pc_reg_addr1),
               .load_pc_reg_addr2(load_pc_reg_addr2),
               .write_pc_reg_value(write_pc_reg_value),
               .write_pc_reg_addr(write_pc_reg_addr),
               .address(address), .w_data(w_data));

initial begin
    clk = 1'b0; reset_n = 1'b0;
    ins_data = 32'd0; read_data = 32'd0;
    load_pc_reg_value1 = 32'd0;
    load_pc_reg_value2 = 32'd0;
    $readmemh("memory.txt", Memory);
/*--------------------------------------------------------------------------------


maybe....
just #1000000000000000000 and reset_n = 1'b1; here


--------------------------------------------------------------------------------*/
    #10 FID = $fopen("result.txt");
        for(i=0; i<Mem_size; i=i+1) begin
            $fdisplay(FID, "%d %h", i, Memory[i]);
        end
    #10 $fclose("FID"); $stop;
end

always #5 clk = ~clk;

always @(write_ctrl_input or mem_ctrl_input or ins_addr
         or load_pc_reg_addr1 or load_pc_reg_addr2
         or write_pc_reg_value or write_pc_reg_addr
         or address or w_data)
begin : Memory_module
// IF module
    ins_data <= #Mem_delay Memory[ins_addr];

// ID module
    load_pc_reg_value1 <= #Mem_delay Memory[load_pc_reg_addr1];
    load_pc_reg_value2 <= #Mem_delay Memory[load_pc_reg_addr2];
    if (write_ctrl_input === 1'b1) begin
        Memory[write_pc_reg_addr] <= #Mem_delay write_pc_reg_value;
    end

// MEM module
    // mem_ctrl_input[1] : read / mem_ctrl_input[0] : write
    if ((mem_ctrl_input[1] === 1'b1) && (mem_ctrl_input[0] === 1'b1)) begin
        $stop;
    end else if (mem_ctrl_input[1] === 1'b1) begin
        read_data <= #Mem_delay Memory[address];
    end else if(mem_ctrl_input[0] === 1'b1) begin
        Memory[address] <= #Mem_delay w_data;
    end
end

endmodule
