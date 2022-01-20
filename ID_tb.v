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
wire signed [31:0] r_data1;
wire signed [31:0] r_data2;
wire signed [31:0] extended;
wire [31:0] rd_ex;
wire op_write_top;

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
        .write_pc_reg_addr(write_pc_reg_addr),
        .op_write_top(op_write_top));

integer cnt;
reg [31:0] stored_data;
reg [31:0] stored_data1;
reg [31:0] stored_data2;
parameter [31:0] TEST_INS = {7'b0000000,5'd32,5'd28,3'b000,5'd16,7'b0110011};
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
    if ((ctrl_ex && pc4_ex && r_data1 && r_data2 &&
        extended && rd_ex) === 0)
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
         * <test> 7'b0000000,5'd28,5'd24,3'b000,5'd4,7'b0110011
         * [100]  ADD x4, x24, x28     
         *            ^rd ^rs1 ^rs2
         * - register initialization
         *   [100:103]: ADD instruction
         *   [28:31] 3954
         *   [32:35] 1542
         *   [16:19] add result
         *--------------------------------------*/
        R_TYPE_OP : begin
            $display("%t: R_TYPE instruction detected", $realtime);
            op_write = 1; 
            pipe_pc = 32'd100;
            pipe_pc4 = pipe_pc + 32'd4;
            pipe_data = TEST_INS;
            stored_data1 = 32'sd9;
            stored_data2 = 32'sd10;
            #1
            // data_reg access for initialization
            for (cnt = 0; cnt < 4; cnt = cnt + 1) begin
                data_reg[pipe_pc + 3 - cnt] = pipe_data[8 * cnt +: 8];
                data_reg[4 * load_pc_reg_addr1 + 3 - cnt] = stored_data1[8 * cnt +: 8];
                data_reg[4 * load_pc_reg_addr2 + 3 - cnt] = stored_data2[8 * cnt +: 8];
            end
            // read data from data_reg
            load_pc_reg_value1 = {data_reg[4 * load_pc_reg_addr1],
                                  data_reg[4 * load_pc_reg_addr1 + 1],
                                  data_reg[4 * load_pc_reg_addr1 + 2],
                                  data_reg[4 * load_pc_reg_addr1 + 3]};
            load_pc_reg_value2 = {data_reg[4 * load_pc_reg_addr2],
                                  data_reg[4 * load_pc_reg_addr2 + 1],
                                  data_reg[4 * load_pc_reg_addr2 + 2],
                                  data_reg[4 * load_pc_reg_addr2 + 3]};
            $display("%t: Behaviour done except data write", $realtime);
            #(CLOCK_PERIOD/2)
            $display("%t: Let's see ID output is correct", $realtime);

            $write("Expecting control_j\t%32d...", control_j);
            if (control_j === 1'b0)
                $display("Yes, %b is observed", control_j);
            else
                $error("No , %b is observed", control_j);

            $write("Expecting ctrl_ex 100000000...");
            if (ctrl_ex === 9'b100_00_0000)
                $display("Yes, %b is observed", ctrl_ex);
            else
                $error("No , %b is observed", ctrl_ex);

            $write("Expecting pc4_ex\t%32d...", pipe_pc4);
            if (pc4_ex === pipe_pc4)
                $display("Yes, %d is observed", pc4_ex);
            else
                $error("No , %d is observed", pc4_ex);

            $write("Expecting r_data1\t%32d...", 32'd9);
            if (r_data1 === 32'd9)
                $display("Yes, %d is observed", r_data1);
            else
                $error("No , %d is observed", r_data1);

            $write("Expecting r_data2\t%32d...", 32'd10);
            if (r_data2 === 32'd10)
                $display("Yes, %d is observed", r_data2);
            else
                $error("No , %d is observed", r_data2);

            $write("Expecting rd_ex\t%32d...", 32'd4); 
            if (rd_ex === 32'd4)
                $display("Yes, %d is observed", rd_ex);
            else
                $error("No , %d is observed", rd_ex);

            // write action right after clk
            write_addr = rd_ex;
            write_data = stored_data1 - stored_data2;
            // data_reg access
            #1
            for (cnt = 0 ; cnt < 4 ; cnt = cnt + 1)
                data_reg[4 * write_pc_reg_addr + 3 - cnt] = write_pc_reg_value[8 * cnt +: 8];
            $display("%t: We will display the regsters...", $realtime);
            for (cnt = 0 ; cnt < REG_SIZE ; cnt = cnt + 1) begin
                if (data_reg[cnt] !== 8'bx)
                    $display("%3d | %b", cnt, data_reg[cnt]);
            end
        end
        /*---------------------------------------
         * <ADDI test>
         * [400]  ADDI x12, x20, 7
         *             ^rd  ^rs1 ^offset
         * - register initialization
         *   [400:403]: addi instruction
         *   [20:23]  : 8
         *--------------------------------------*/
        ADDI_OP : begin
            $display("%t: ADDI instruction detected", $realtime);
            op_write = 1; 
            pipe_pc = 32'd400;
            pipe_pc4 = pipe_pc + 32'd4;
            /*---------------------------------------------
             * instruction = imm + rs1 + func3 + rd + op
             * {12'd7, 5'd20, 3'b000, 5'd12, 7'b0010011}
             *-------------------------------------------*/
            pipe_data = TEST_INS;
            stored_data = 32'd8;
            #1
            // data_reg access for initialization
            for (cnt = 0; cnt < 4; cnt = cnt + 1) begin
                data_reg[pipe_pc + 3 - cnt] = pipe_data[8 * cnt +: 8];
                data_reg[4 * load_pc_reg_addr1 + 3 - cnt] = stored_data[8 * cnt +: 8];
            end
            // read data from data_reg
            load_pc_reg_value1 = {data_reg[4 * load_pc_reg_addr1],
                                  data_reg[4 * load_pc_reg_addr1 + 1],
                                  data_reg[4 * load_pc_reg_addr1 + 2],
                                  data_reg[4 * load_pc_reg_addr1 + 3]};
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

            $write("Expecting r_data1 %32d...", 8);
            if (r_data1 === 32'd8)
                $display("Yes, %d is observed", r_data1);
            else
                $error("No , %d is observed", r_data1);

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
                data_reg[4 * write_pc_reg_addr + 3 - cnt] = write_pc_reg_value[8 * cnt +: 8];
            $display("%t: We will display the regsters...", $realtime);
            for (cnt = 0 ; cnt < REG_SIZE ; cnt = cnt + 1) begin
                if (data_reg[cnt] !== 8'bx)
                    $display("%3d | %b", cnt, data_reg[cnt]);
            end
        end
        /*---------------------------------------
         * <LD test>
         * [404]  LD x8, 64     (x20)
         *           ^rd ^offset ^rs1
         * - register initialization
         *   [404:407]: LD instruction
         *
         *   [80:83]  : 444
         *   [508:511]: 100
         *--------------------------------------*/
        LD_OP : begin
            $display("%t: LD instruction detected", $realtime);
            op_write = 1; 
            pipe_pc = 32'd404;
            pipe_pc4 = pipe_pc + 32'd4;
            /*---------------------------------------------
             * instruction = imm + rs1 + func3 + rd + op
             * {12'd64, 5'd20, 3'b010, 5'd8, 7'b0000011}
             *-------------------------------------------*/
            pipe_data = TEST_INS;
            stored_data = 32'd444;
            stored_data1 = 32'd100;
            #1
            // data_reg access for initialization
            for (cnt = 0; cnt < 4; cnt = cnt + 1) begin
                data_reg[4 * pipe_pc + 3 - cnt] = pipe_data[8 * cnt +: 8];
                data_reg[4 * load_pc_reg_addr1 + 3 - cnt] = stored_data[8 * cnt +: 8];
                data_reg[4 * 127 + 3 - cnt] = stored_data1[8 * cnt +: 8];
            end
            // read data from data_reg
            load_pc_reg_value1 = {data_reg[4 * load_pc_reg_addr1],
                                  data_reg[4 * load_pc_reg_addr1 + 1],
                                  data_reg[4 * load_pc_reg_addr1 + 2],
                                  data_reg[4 * load_pc_reg_addr1 + 3]};
            $display("%t: Behaviour done except data write", $realtime);
            #(CLOCK_PERIOD/2)
            $display("%t: Let's see ID output is correct", $realtime);
            $write("Expecting control_j 0...");
            if (control_j === 1'b0)
                $display("Yes, %b is observed", control_j);
            else
                $error("No , %b is observed", control_j);

            $write("Expecting ctrl_ex 101100001...");
            if (ctrl_ex === 9'b101_10_0001)
                $display("Yes, %b is observed", ctrl_ex);
            else
                $error("No , %b is observed", ctrl_ex);

            $write("Expecting pc4_ex %d...", pipe_pc4);
            if (pc4_ex === pipe_pc4)
                $display("Yes, %d is observed", pc4_ex);
            else
                $error("No , %d is observed", pc4_ex);

            $write("Expecting r_data1 %d...", 32'd444);
            if (r_data1 === 32'd444)
                $display("Yes, %d is observed", r_data1);
            else
                $error("No , %d is observed", r_data1);

            $write("Expecting extended %d...", 32'd64);
            if (extended === 32'd64)
                $display("Yes, %d is observed", extended);
            else
                $error("No , %d is observed", extended);

            $write("Expecting rd_ex %d...", 32'd8);
            if (rd_ex === 32'd8)
                $display("Yes, %d is observed", rd_ex);
            else
                $error("No , %d is observed", rd_ex);
            // write action right after clk
            write_addr = rd_ex;
            write_data = 32'd100;
            // data_reg access
            #1
            for (cnt = 0 ; cnt < 4 ; cnt = cnt + 1)
                data_reg[4 * write_pc_reg_addr + 3 - cnt] = write_pc_reg_value[8 * cnt +: 8];
            $display("%t: We will display the regsters...", $realtime);
            for (cnt = 0 ; cnt < REG_SIZE ; cnt = cnt + 1) begin
                if (data_reg[cnt] !== 8'bx)
                    $display("%3d | %b", cnt, data_reg[cnt]);
            end
        end
        /*---------------------------------------
         * <JALR test>
         * [300]  JALR x4, x12, 0
         *             ^rd ^rs1 ^offset
         * - register initialization
         *   [300:303]: jalr instruction
         *   [48:51]  : 500
         *--------------------------------------*/
        JALR_OP : begin
            $display("%t: JALR instruction detected", $realtime);
            op_write = 0; 
            pipe_pc = 32'd300;
            pipe_pc4 = pipe_pc + 32'd4;
            /*---------------------------------------------------------
             * instruction = imm + rs1 + func3 + rd + op
             * {12'd0, 5'd12, 3'b000, 5'd4, 7'1100111}
             *-------------------------------------------------------*/
            pipe_data = TEST_INS;
            stored_data = 32'd500;
            #1
            // data_reg access for initialization
            for (cnt = 0; cnt < 4; cnt = cnt + 1) begin
                data_reg[pipe_pc + 3 - cnt] = pipe_data[8 * cnt +: 8];
                data_reg[4 * load_pc_reg_addr1 + 3 - cnt] = stored_data[8 * cnt +: 8];
            end
            // read data from data_reg
            load_pc_reg_value1 = {data_reg[4 * load_pc_reg_addr1],
                                  data_reg[4 * load_pc_reg_addr1 + 1],
                                  data_reg[4 * load_pc_reg_addr1 + 2],
                                  data_reg[4 * load_pc_reg_addr1 + 3]};
            $display("%t: Behaviour done except data write", $realtime);
            #(CLOCK_PERIOD/2)
            $display("%t: Let's see ID output is correct", $realtime);

            $write("Expecting control_j\t%32d...", control_j);
            if (control_j === 1'b1)
                $display("Yes, %b is observed", control_j);
            else
                $error("No , %b is observed", control_j);

            $write("Expecting ctrl_ex 110000000...");
            if (ctrl_ex === 9'b110_00_0000)
                $display("Yes, %b is observed", ctrl_ex);
            else
                $error("No , %b is observed", ctrl_ex);

            $write("Expecting pc4_ex\t%32d...", pipe_pc4);
            if (pc4_ex === pipe_pc4)
                $display("Yes, %d is observed", pc4_ex);
            else
                $error("No , %d is observed", pc4_ex);

            $write("Expecting r_data1\t%32d...", 32'd500);
            if (r_data1 === 32'd500)
                $display("Yes, %d is observed", r_data1);
            else
                $error("No , %d is observed", r_data1);

            $write("Expecting extended\t%32d...", 32'd0);
            if (extended === 32'd0)
                $display("Yes, %d is observed", extended);
            else
                $error("No , %d is observed", extended);

            $write("Expecting rd_ex\t%32d...", 32'd4);
            if (rd_ex === 32'd4)
                $display("Yes, %d is observed", rd_ex);
            else
                $error("No , %d is observed", rd_ex);

            $write("Expecting pc_j\t%32d...", 32'd500);
            if (pc_j === 32'd500)
                $display("Yes, %d is observed", pc_j);
            else
                $error("No , %d is observed", pc_j);

            // write action right after clk
            write_addr = 32'd4;
            write_data = pipe_pc4;
            // data_reg access
            #1
            for (cnt = 0 ; cnt < 4 ; cnt = cnt + 1)
                data_reg[4 * write_pc_reg_addr + 3 - cnt] = write_pc_reg_value[8 * cnt +: 8];
            $display("%t: We will display the regsters...", $realtime);
            for (cnt = 0 ; cnt < REG_SIZE ; cnt = cnt + 1) begin
                if (data_reg[cnt] !== 8'bx)
                    $display("%3d | %b", cnt, data_reg[cnt]);
            end
        end
        /*---------------------------------------
         * <SD test>
         * [404]  SD x12, 20       (x8)
         *           ^rs2 ^offset   ^rs1
         * - register initialization
         *   [404:407]: SD instruction
         *   [48:51]  : 33
         *   [32:35]  : 72
         *--------------------------------------*/
        S_TYPE_OP : begin
            $display("%t: SD instruction detected", $realtime);
            op_write = 0; 
            pipe_pc = 32'd404;
            pipe_pc4 = pipe_pc + 32'd4;
            /*---------------------------------------------------------
             * instruction = imm + rs2 + rs1 + func3 + imm + op
             * {7'b0000000, 5'd12, 5'd8, 3'b010, 5'b10100, 7'b0100011}
             *-------------------------------------------------------*/
            pipe_data = TEST_INS;
            stored_data = 32'd72;
            stored_data1 = 32'd33;
            #1
            // data_reg access for initialization
            for (cnt = 0; cnt < 4; cnt = cnt + 1) begin
                data_reg[pipe_pc + 3 - cnt] = pipe_data[8 * cnt +: 8];
                data_reg[4 * load_pc_reg_addr2 + 3 - cnt] = stored_data1[8 * cnt +: 8];
                data_reg[4 * load_pc_reg_addr1 + 3 - cnt] = stored_data[8 * cnt +: 8];
            end
            // read data from data_reg
            load_pc_reg_value1 = {data_reg[4 * load_pc_reg_addr1],
                                  data_reg[4 * load_pc_reg_addr1 + 1],
                                  data_reg[4 * load_pc_reg_addr1 + 2],
                                  data_reg[4 * load_pc_reg_addr1 + 3]};
            load_pc_reg_value2 = {data_reg[4 * load_pc_reg_addr2],
                                  data_reg[4 * load_pc_reg_addr2 + 1],
                                  data_reg[4 * load_pc_reg_addr2 + 2],
                                  data_reg[4 * load_pc_reg_addr2 + 3]};
            $display("%t: Behaviour done except data write", $realtime);
            #(CLOCK_PERIOD/2)
            $display("%t: Let's see ID output is correct", $realtime);
            $write("Expecting control_j 0...");
            if (control_j === 1'b0)
                $display("Yes, %b is observed", control_j);
            else
                $error("No , %b is observed", control_j);

            $write("Expecting op_write_top 0...");
            if (op_write_top === 1'b0)
                $display("Yes, %b is observed", op_write_top);
            else
                $error("No , %b is observed", op_write_top);

            $write("Expecting ctrl_ex 000010001...");
            if (ctrl_ex === 9'b000_01_0001)
                $display("Yes, %b is observed", ctrl_ex);
            else
                $error("No , %b is observed", ctrl_ex);

            $write("Expecting pc4_ex %d...", pipe_pc4);
            if (pc4_ex === pipe_pc4)
                $display("Yes, %d is observed", pc4_ex);
            else
                $error("No , %d is observed", pc4_ex);

            $write("Expecting r_data1 %d...", 32'sd72);
            if (r_data1 === 32'sd72)
                $display("Yes, %d is observed", r_data1);
            else
                $error("No , %d is observed", r_data1);

            $write("Expecting r_data2 %d...", 32'sd33);
            if (r_data2 === 32'sd33)
                $display("Yes, %d is observed", r_data2);
            else
                $error("No , %d is observed", r_data2);

            $write("Expecting extended %d...", 32'sd20);
            if (extended === 32'sd20)
                $display("Yes, %d is observed", extended);
            else
                $error("No , %d is observed", extended);
            // store at MEM after several clk
            write_addr = r_data1 + 32'd20;
            write_data = r_data2;
            // data_reg access
            #1
            for (cnt = 0 ; cnt < 4 ; cnt = cnt + 1)
                data_reg[write_addr + 3 - cnt] = write_data[8 * cnt +: 8];
            $display("%t: We will display the regsters...", $realtime);
            for (cnt = 0 ; cnt < REG_SIZE ; cnt = cnt + 1) begin
                if (data_reg[cnt] !== 8'bx)
                    $display("%3d | %b", cnt, data_reg[cnt]);
            end
        end
        /*---------------------------------------
         * <BEQ test>
         * [408]  BEQ x12, x16  32
         *            ^rs1 ^rs2 ^offset
         * - register initialization (fail)
         *   [412:415]: BEQ instruction
         *   [48:51]  : 8
         *   [64:67]  : 9
         *
         * - register initialization (success)
         *   [412:415]: BEQ instruction
         *   [48:51]  : 11
         *   [64:67]  : 11
         *--------------------------------------*/
        BEQ_OP : begin
            $display("%t: BEQ instruction detected", $realtime);
            op_write = 0; 
            pipe_pc = 32'd408;
            pipe_pc4 = pipe_pc + 32'd4;
            /*-------------------------------------------------------------
             * instruction = imm + imm + rs2 + rs1 + func3 + imm + imm + op
             * {1'b0, 6'b000010, 5'd16, 5'd12, 3'b000, 4'b0000, 1'b0,
             *  7'b0100011}
             *-------------------------------------------------------------*/
            pipe_data = TEST_INS;
            stored_data = 32'd11;
            stored_data1 = 32'd11;
            #1
            // data_reg access for initialization
            for (cnt = 0; cnt < 4; cnt = cnt + 1) begin
                data_reg[pipe_pc + 3 - cnt] = pipe_data[8 * cnt +: 8];
                data_reg[4 * load_pc_reg_addr1 + 3 - cnt] = stored_data[8 * cnt +: 8];
                data_reg[4 * load_pc_reg_addr2 + 3 - cnt] = stored_data1[8 * cnt +: 8];
            end
            data_reg[load_pc_reg_addr1 + 7] = data_reg[load_pc_reg_addr1 + 7] + 8'd1;
            // read data from data_reg
            load_pc_reg_value1 = {data_reg[4 * load_pc_reg_addr1],
                                  data_reg[4 * load_pc_reg_addr1 + 1],
                                  data_reg[4 * load_pc_reg_addr1 + 2],
                                  data_reg[4 * load_pc_reg_addr1 + 3]};
            load_pc_reg_value2 = {data_reg[4 * load_pc_reg_addr2],
                                  data_reg[4 * load_pc_reg_addr2 + 1],
                                  data_reg[4 * load_pc_reg_addr2 + 2],
                                  data_reg[4 * load_pc_reg_addr2 + 3]};
            $display("%t: Behaviour done except data write", $realtime);
            #(CLOCK_PERIOD/2)
            $display("%t: Let's see ID output is correct", $realtime);
	    $write("Expecting control_j\t%b...", (r_data1 === r_data2));
            if (control_j === (r_data1 === r_data2))
                $display("Yes, %b is observed", control_j);
            else
                $error("No , %b is observed", control_j);

            $write("Expecting op_write_top 0...");
            if (op_write_top === 1'b0)
                $display("Yes, %b is observed", op_write_top);
            else
                $error("No , %b is observed", op_write_top);

            $write("Expecting pc_j\t%32d...", 32'd472);
            if (pc_j === 32'd472)
                $display("Yes, %d is observed", pc_j);
            else
                $error("No , %d is observed", pc_j);

            $write("Expecting ctrl_ex 000000000...");
            if (ctrl_ex === 9'b000_00_0000)
                $display("Yes, %b is observed", ctrl_ex);
            else
                $error("No , %b is observed", ctrl_ex);

            $write("Expecting pc4_ex\t%32d...", pipe_pc4);
            if (pc4_ex === pipe_pc4)
                $display("Yes, %d is observed", pc4_ex);
            else
                $error("No , %d is observed", pc4_ex);

            $display("r_data1 : %d | r_data2 : %d", r_data1, r_data2);

            $write("Expecting extended\t%32d...", 32'd32);
            if (extended === 32'd32)
                $display("Yes, %d is observed", extended);
            else
                $error("No , %d is observed", extended);
            // data_reg access
            #1
            for (cnt = 0 ; cnt < 4 ; cnt = cnt + 1)
                data_reg[4 * write_pc_reg_addr + 3 - cnt] = write_pc_reg_value[8 * cnt +: 8];
            $display("%t: We will display the regsters...", $realtime);
            for (cnt = 0 ; cnt < REG_SIZE ; cnt = cnt + 1) begin
                if (data_reg[cnt] !== 8'bx)
                    $display("%3d | %b", cnt, data_reg[cnt]);
            end
        end
        /*---------------------------------------
         * <JAL test>
         * [200]  JAL x4, 120
         *            ^rd ^offset  
         * - register initialization
         *   [200:203]: JAL instruction
         *--------------------------------------*/
        JAL_OP : begin
            $display("%t: JAL instruction detected", $realtime);
            op_write = 0; 
            pipe_pc = 32'd200;
            pipe_pc4 = pipe_pc + 32'd4;
            /*-------------------------------------------------------------
             * instruction = imm + imm + imm + imm + rd + op
             * {1'b0, 10'b0001111000, 1'b0, 8'b00000000, 5'd4, 7'b1101111}
             *-------------------------------------------------------------*/
            pipe_data = TEST_INS;
            #1
            // data_reg access for initialization
            for (cnt = 0; cnt < 4; cnt = cnt + 1) begin
                data_reg[pipe_pc + 3 - cnt] = pipe_data[8 * cnt +: 8];
            end
            // read data from data_reg
            $display("%t: Behaviour done except data write", $realtime);
            #(CLOCK_PERIOD/2)
            $display("%t: Let's see ID output is correct", $realtime);

            $write("Expecting control_j\t%32d...", control_j);
            if (control_j === 1'b1)
                $display("Yes, %b is observed", control_j);
            else
                $error("No , %b is observed", control_j);

            $write("Expecting ctrl_ex 110000000...");
            if (ctrl_ex === 9'b110_00_0000)
                $display("Yes, %b is observed", ctrl_ex);
            else
                $error("No , %b is observed", ctrl_ex);

            $write("Expecting pc4_ex\t%32d...", pipe_pc4);
            if (pc4_ex === pipe_pc4)
                $display("Yes, %d is observed", pc4_ex);
            else
                $error("No , %d is observed", pc4_ex);

            $write("Expecting extended\t%32d...", 32'd120);
            if (extended === 32'd120)
                $display("Yes, %d is observed", extended);
            else
                $error("No , %d is observed", extended);

            $write("Expecting rd_ex\t%32d...", 32'd4); //ra
            if (rd_ex === 32'd4)
                $display("Yes, %d is observed", rd_ex);
            else
                $error("No , %d is observed", rd_ex);

            $write("Expecting pc_j\t%32d...", 32'd440);
            if (pc_j === 32'd440)
                $display("Yes, %d is observed", pc_j);
            else
                $error("No , %d is observed", pc_j);

            // EX action right after clk
            write_addr = rd_ex;
            write_data = pipe_pc4;
            // data_reg access
            #1
            for (cnt = 0 ; cnt < 4 ; cnt = cnt + 1)
                data_reg[4 * write_pc_reg_addr + 3 - cnt] = write_pc_reg_value[8 * cnt +: 8];
            $display("%t: We will display the regsters...", $realtime);
            for (cnt = 0 ; cnt < REG_SIZE ; cnt = cnt + 1) begin
                if (data_reg[cnt] !== 8'bx)
                    $display("%3d | %b", cnt, data_reg[cnt]);
            end
        end       
    endcase
end
endmodule