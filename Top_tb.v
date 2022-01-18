`timescale 1ns / 10ps

module Top_tb;
parameter MODULE_DELAY = 0.1;
parameter MEM_DELAY = 1;
parameter MEM_SIZE = 512;
parameter CLK_PERIOD = 10;
//clock
reg clk = 1'b0;

//input
reg reset_n = 1'b0;
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
reg [7:0] memory[0:MEM_SIZE-1];
reg [7:0] predict[0:MEM_SIZE-1];
integer i, FID, cnt;

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

always #(CLK_PERIOD / 2) clk = ~ clk;

initial begin
    ins_data = 32'd0; read_data = 32'd0;
    load_pc_reg_value1 = 32'd0;
    load_pc_reg_value2 = 32'd0;
    $readmemh("memory.txt", memory);
    $readmemh("predict.txt", predict);

    #3
    reset_n = 1'b1;
    #1000

    #CLK_PERIOD
    FID = $fopen("result.txt");
    for(i=0; i<MEM_SIZE; i = i + 1) begin
        if(memory[i] !== predict[i]) begin
        $fdisplay(FID, "Address %g error\nresult : %h\npredict value : %h",
                  i, memory[i], predict[i]);
        end
    end
    #CLK_PERIOD
    $fdisplay(FID, "------------------------------------");
    $fdisplay(FID, "Address      data");
    for(i = 0; i < MEM_SIZE; i = i + 4) begin
        $fdisplay(FID, "%d %h %h %h %h", i, memory[i], memory[i+1], memory[i+2], memory[i+3]);
    end
    #CLK_PERIOD


    $display("%t: We will display the regsters...", $realtime);
    for (cnt = 0 ; cnt < MEM_SIZE ; cnt = cnt + 1) begin
        if (memory[cnt] !== 8'bx)
            $display("%3d | %b", cnt, memory[cnt]);
    end
    $stop;
    $fclose("FID");
end



always @(op_write_top or mem_ctrl_input or ins_addr
         or load_pc_reg_addr1 or load_pc_reg_addr2
         or write_pc_reg_value or write_pc_reg_addr
         or address or w_data)
begin : Memory_module
// IF module
    ins_data <= #MEM_DELAY {memory[ins_addr+3],
                            memory[ins_addr+2],
                            memory[ins_addr+1],
                            memory[ins_addr]};

// ID module
    load_pc_reg_value1 <= #MEM_DELAY {memory[load_pc_reg_addr1+3],
                                      memory[load_pc_reg_addr1+2],
                                      memory[load_pc_reg_addr1+1],
                                      memory[load_pc_reg_addr1]};
    load_pc_reg_value2 <= #MEM_DELAY {memory[load_pc_reg_addr2+3],
                                      memory[load_pc_reg_addr2+2],
                                      memory[load_pc_reg_addr2+1],
                                      memory[load_pc_reg_addr2]};
    if (op_write_top === 1'b1) begin
        memory[write_pc_reg_addr + 3] <= write_pc_reg_value[31:24];
        memory[write_pc_reg_addr + 2] <= write_pc_reg_value[23:16];
        memory[write_pc_reg_addr + 1] <= write_pc_reg_value[15:8];
        memory[write_pc_reg_addr] <= write_pc_reg_value[7:0];
    end

// MEM module
    // mem_ctrl_input[1] : read / mem_ctrl_input[0] : write
    if ((mem_ctrl_input[1] === 1'b1) && (mem_ctrl_input[0] === 1'b1)) begin
        $stop;
    end else if (mem_ctrl_input[1] === 1'b1) begin
        read_data <= #MEM_DELAY {memory[address+3],
                                 memory[address+2],
                                 memory[address+1],
                                 memory[address]};
    end else if(mem_ctrl_input[0] === 1'b1) begin
        #MEM_DELAY
        for (cnt = 0 ; cnt < 4 ; cnt = cnt + 1)
            memory[address + 3 - cnt] <= w_data[8 * cnt +: 8];
    end
end

endmodule
