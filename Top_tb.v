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
wire op_write_top;
wire [1:0] mem_ctrl_input;
wire [31:0] ins_addr;
wire [31:0] load_pc_reg_addr1;
wire [31:0] load_pc_reg_addr2;
wire [31:0] write_pc_reg_value;
wire [31:0] write_pc_reg_addr;
wire [31:0] address;
wire [31:0] w_data;

//etc
reg [7:0] Memory[0:Mem_size-1];
reg [7:0] predict[0:Mem_size-1];
integer i, FID;

Top Top_module(.clk(clk), .reset_n(reset_n), .ins_data(ins_data),
               .load_pc_reg_value1(load_pc_reg_value1),
               .load_pc_reg_value2(load_pc_reg_value2),
               .read_data(read_data), .op_write_top(op_write_top),
               .mem_ctrl_input(mem_ctrl_input), .ins_addr(ins_addr),
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
    $readmemh("predict.txt", predict);
/*--------------------------------------------------------------------------------


maybe....
just #1000000000000000000 and reset_n = 1'b1; here


--------------------------------------------------------------------------------*/
    #10 FID = $fopen("result.txt");
        for(i=0; i<Mem_size; i=i+1) begin
            if(Memory[i] !== predict[i])
                $fdisplay(FID, "Address %g error\nresult : %h\npredict value : %h",
                               i, Memory[i], predict[i]);
        end
    #10 $fdisplay(FID, "------------------------------------");
        $fdisplay(FID, "Address      data");
        for(i=0; i<Mem_size; i=i+4) begin
            $fdisplay(FID, "%d %h %h %h %h", i, Memory[i], Memory[i+1], Memory[i+2], Memory[i+3]);
        end
    #10 $fclose("FID"); $stop;
end

always #5 clk = ~clk;

always @(op_write_top or mem_ctrl_input or ins_addr
         or load_pc_reg_addr1 or load_pc_reg_addr2
         or write_pc_reg_value or write_pc_reg_addr
         or address or w_data)
begin : Memory_module
// IF module
    ins_data <= #Mem_delay {Memory[ins_addr],
                            Memory[ins_addr+1],
                            Memory[ins_addr+2],
                            Memory[ins_addr+3]};

// ID module
    load_pc_reg_value1 <= #Mem_delay {Memory[load_pc_reg_addr1],
                                      Memory[load_pc_reg_addr1+1],
                                      Memory[load_pc_reg_addr1+2],
                                      Memory[load_pc_reg_addr1+3]};
    load_pc_reg_value2 <= #Mem_delay {Memory[load_pc_reg_addr2],
                                      Memory[load_pc_reg_addr2+1],
                                      Memory[load_pc_reg_addr2+2],
                                      Memory[load_pc_reg_addr2+3]};
    if (op_write_top === 1'b1) begin
        {Memory[write_pc_reg_addr],
         Memory[write_pc_reg_addr+1],
         Memory[write_pc_reg_addr+2],
         Memory[write_pc_reg_addr+3]} <= #Mem_delay write_pc_reg_value;
    end

// MEM module
    // mem_ctrl_input[1] : read / mem_ctrl_input[0] : write
    if ((mem_ctrl_input[1] === 1'b1) && (mem_ctrl_input[0] === 1'b1)) begin
        $stop;
    end else if (mem_ctrl_input[1] === 1'b1) begin
        read_data <= #Mem_delay {Memory[address],
                                 Memory[address+1],
                                 Memory[address+2],
                                 Memory[address+3]};
    end else if(mem_ctrl_input[0] === 1'b1) begin
        {Memory[address],
         Memory[address+1],
         Memory[address+2],
         Memory[address+3]} <= #Mem_delay w_data;
    end
end

endmodule
