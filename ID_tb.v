`timescale 1ns / 10ps

module ID_tb;
parameter CLOCK_PERIOD = 10;
parameter REG_SIZE = 512;
parameter CTRL_ADDI = 12'b000_100_00_0001;
parameter CTRL_LD   = 12'b000_101_10_0001;
parameter CTRL_JALR = 12'b001_110_00_0000;
parameter CTRL_SD   = 12'b000_000_01_0001;
parameter CTRL_BEQ  = 12'b100_000_00_0000;
parameter CTRL_JAL  = 12'b010_110_00_0000;
parameter CTRL_ADD  = 12'b000_100_00_0000;
parameter CTRL_SUB  = 12'b000_100_00_0010;
parameter CTRL_SLL  = 12'b000_100_00_1000;
parameter CTRL_SLT  = 12'b000_100_00_1010;
parameter CTRL_AND  = 12'b000_100_00_0100;
parameter CTRL_OR   = 12'b000_100_00_0110;

// INPUT
reg clk = 1'b0;
reg reset_n = 1'b0;
reg op_write; //register
reg [31:0] pipe_pc4;
reg [31:0] pipe_pc;
reg [31:0] pipe_data; // instruction

reg [31:0] write_data;
reg [31:0] write_addr;
reg [31:0] load_pc_reg_value1;
reg [31:0] load_pc_reg_value2;   // load register value from tb

// OUTPUT
wire control_j;
wire [31:0] pc_j;
wire [8:0] ctrl_ex;
wire [31:0] pc4_ex;
wire [31:0] r_data1;
wire [31:0] r_data2;
wire signed [31:0] extended;
wire [31:0] rd_ex;

wire [31:0] load_pc_reg_addr1;   // load register address1 from tb
wire [31:0] load_pc_reg_addr2;   // load register address2 from tb
wire [31:0] write_pc_reg_value; // register value to write on tb
wire [31:0] write_pc_reg_addr;  // register addr to write on tb

// DATA REGISTER
reg [7:0] data_reg [0:REG_SIZE - 1];

ID ID0 (.clk(clk),               .reset_n(reset_n),
        .op_write(op_write),     .pipe_pc4(pipe_pc4),
        .pipe_pc(pipe_pc),       .pipe_data(pipe_data),
        .write_data(write_data), .write_addr(write_addr),
        .load_pc_reg_value1(load_pc_reg_value1),
        .load_pc_reg_value2(load_pc_reg_value2),
        .control_j(control_j),   .pc_j(pc_j),
        .ctrl_ex(ctrl_ex),       .pc4_ex(pc4_ex),
        .r_data1(r_data1),       .r_data2(r_data2),
        .extended(extended),     .rd_ex(rd_ex),
        .load_pc_reg_addr1(load_pc_reg_addr1),
        .load_pc_reg_addr2(load_pc_reg_addr2),
        .write_pc_reg_value(write_pc_reg_value),
        .write_pc_reg_addr(write_pc_reg_addr));

integer cnt;
reg [31:0] stored_data;
reg [31:0] stored_addr;
// instruction = imm + rs1 + func3 + rd + op
parameter [31:0] TEST_INS = {12'd7, 5'd20, 3'b000, 5'd12, 7'b0010011};
parameter [6:0] R_TYPE_OP  = 7'b0110011, // R_type
                ADDI_OP    = 7'b0010011, // I-type ADDI
                LD_OP      = 7'b0000011, // I-type LD
                JALR_OP    = 7'b1100111, // I-type JALR
                S_TYPE_OP  = 7'b0100011, // S-type SD
                BEQ_OP     = 7'b1100011, // SB-type BEQ,BNE,BLT,BGE
                JAL_OP     = 7'b1101111; // UJ-type JAL
// clock generator
always #(CLOCK_PERIOD / 2) clk = ~ clk;

initial
begin : TESTBENCH
    $timeformat(-9, 2, "ns", 8);
    $display("%t: Bench START, Initializing data register...", $realtime);
    // end of reset
    #CLOCK_PERIOD
    reset_n = 1;
    $write("Reset check...");
    if (control_j && pc_j && ctrl_ex && pc4_ex && r_data1 && r_data2 &&
        extended && rd_ex && load_pc_reg_addr1 && load_pc_reg_addr2 &&
        write_pc_reg_value && write_pc_reg_addr)
        $display("Success!");
    else
        $error("Failed!");
    // initialize data register
    for (cnt = 0 ; cnt < REG_SIZE ; cnt = cnt + 1) begin
        if (cnt < 4)
            data_reg[cnt] = 8'd0;
        else
            data_reg[cnt] = 8'dx;
    end
    #1
    case (TEST_INS[6:0])
        /*---------------------------------------
         * <ADDI test>
         * [400]  ADDI $12, $20, 7
         *
         * - register initialization
         *   [400:403]: addi instruction
         *   [20:23]  : 8
         *--------------------------------------*/
        ADDI_OP : begin
            $display("%t: ADDI instruction detected", $realtime);
            op_write = 1; 
            pipe_pc = 32'd400;
            pipe_pc4 = pipe_pc + 32'd4;
            pipe_data = TEST_INS;
            stored_data = 32'd8;
            #1
            // data_reg access for initialization
            for (cnt = 0; cnt < 4; cnt = cnt + 1) begin
                data_reg[pipe_pc + 3 - cnt] = pipe_data[8 * cnt +: 8];
                data_reg[load_pc_reg_addr1 + 3 - cnt] = stored_data[8 * cnt +: 8];
            end
            // read data from data_reg
            load_pc_reg_value1 = {data_reg[load_pc_reg_addr1],
                                  data_reg[load_pc_reg_addr1 + 1],
                                  data_reg[load_pc_reg_addr1 + 2],
                                  data_reg[load_pc_reg_addr1 + 3]};
            load_pc_reg_value2 = {data_reg[load_pc_reg_addr2],
                                  data_reg[load_pc_reg_addr2 + 1],
                                  data_reg[load_pc_reg_addr2 + 2],
                                  data_reg[load_pc_reg_addr2 + 3]};
            $display("%t: Behaviour done except data write", $realtime);
            #(CLOCK_PERIOD/2)
            $display("%t: Let's see ID output is correct", $realtime);
            if (control_j === 1'b0)
                $display("control_j is correct");
            else
                $error("control_j is wrong");

            $write("Expecting ctrl_ex 100000001...");
            if (ctrl_ex === 9'b100_00_0001)
                $display("Yes, %b is observed", ctrl_ex);
            else
                $error("No , %b is observed", ctrl_ex);

            $write("Expecting pc4_ex\t%32d...", pipe_pc4);
            if (pc4_ex === pipe_pc4)
                $display("Yes, %d is observed", pc4_ex);
            else
                $error("No , %d is observed", pc4_ex);

            $write("Expecting r_data1\t%32d...", 8);
            if (r_data1 === 32'd8)
                $display("Yes, %d is observed", r_data1);
            else
                $error("No , %d is observed", r_data1);

            $write("Expecting r_data2_ex\t%32d...", 32'd0);
            if (pc4_ex === 32'd0)
                $display("Yes, %d is observed", r_data2);
            else
                $error("No , %d is observed", r_data2);

            $write("Expecting extended\t%32d...", 32'd7);
            if (extended === 32'd7)
                $display("Yes, %d is observed", extended);
            else
                $error("No , %d is observed", extended);

            $write("Expecting rd_ex\t%32d...", 32'd12);
            if (rd_ex === 32'd12)
                $display("Yes, %d is observed", rd_ex);
            else
                $error("No , %d is observed", rd_ex);

            // write action right after clk
            write_addr = rd_ex;
            write_data = r_data1 + extended;
            // data_reg access
            #1
            for (cnt = 0 ; cnt < 4 ; cnt = cnt + 1)
                data_reg[write_pc_reg_addr + 3 - cnt] = write_pc_reg_value[8 * cnt +: 8];
            $display("%t: We will display the regsters...", $realtime);
            for (cnt = 0 ; cnt < REG_SIZE ; cnt = cnt + 1) begin
                if (data_reg[cnt] !== 8'bx)
                    $display("%3d | %b", cnt, data_reg[cnt]);
            end
        end
    endcase

end
endmodule
    

    


