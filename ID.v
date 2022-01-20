module ID(
    input clk,
    input reset_n,
    input op_write, //register
    input [31:0] pipe_pc,
    input [31:0] pipe_pc4,
    input [31:0] pipe_data, // instruction
    input [31:0] write_data,
    input [31:0] write_addr,
    input [31:0] load_pc_reg_value1,
    input [31:0] load_pc_reg_value2,   // load register value from tb
    output [31:0] load_pc_reg_addr1,   // load register address1 from tb
    output [31:0] load_pc_reg_addr2,   // load register address2 from tb
    output [31:0] write_pc_reg_value, // register value to write on tb
    output [31:0] write_pc_reg_addr,  // register addr to write on tb
    output control_j,
    output [31:0] pc_j,
    output [31:0] r_data1,
    output [31:0] r_data2,
    output [31:0] extended,
    output [31:0] rd_ex,
    output [8:0] ctrl_ex,
    output [31:0] pc4_ex,
    output op_write_top
);

reg signed [31:0] extended_reg;
reg [31:0] rs1_reg;
reg [31:0] rs2_reg;
reg [31:0] r_data1_reg;
reg [31:0] r_data2_reg;
reg [31:0] rd_reg;
reg [2:0] funct3_reg;
reg [6:0] funct7_reg;
reg signed [19:0] immediate_reg;
reg [31:0] load_pc_reg_addr1_reg;
reg [31:0] load_pc_reg_addr2_reg;
//reg [31:0] write_pc_reg_value_reg;
//reg [31:0] write_pc_reg_addr_reg;
reg [31:0] pc_j_reg;
reg [31:0] pc4_ex_reg;
reg [8:0] ctrl_ex_reg;
reg [31:0] rd_ex_reg;
reg [11:0] control_bit;

localparam [6:0] R_TYPE_OP  = 7'b0110011, // R_type
                 ADDI_OP    = 7'b0010011, // I-type ADDI
                 LD_OP      = 7'b0000011, // I-type LD
                 JALR_OP    = 7'b1100111, // I-type JALR
                 S_TYPE_OP  = 7'b0100011, // S-type SD
                 SB_TYPE_OP = 7'b1100011, // SB-type BEQ,BNE,BLT,BGE
                 UJ_TYPE_OP = 7'b1101111; // UJ-type JAL

always @(pipe_data) // Seperate Instruction
begin : SEPERTATE_INST
    case (pipe_data[6:0])
        R_TYPE_OP : begin
            funct7_reg = pipe_data[31:25];
            rs2_reg = pipe_data[24:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
            immediate_reg = 20'sd0;
        end
        ADDI_OP : begin
            immediate_reg = $signed(pipe_data[31:20]);
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
            funct7_reg = 7'd0;
            rs2_reg = 5'd0;
        end
        LD_OP : begin
            immediate_reg = $signed(pipe_data[31:20]);
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
            funct7_reg = 7'd0;
            rs2_reg = 5'd0;
        end
        JALR_OP : begin
            immediate_reg = $signed(pipe_data[31:22]);
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
            funct7_reg = 7'd0;
            rs2_reg = 5'd0;
        end
        S_TYPE_OP : begin
            immediate_reg = $signed({pipe_data[31:25], pipe_data[11:7]});
            rs2_reg = pipe_data[24:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            funct7_reg = 7'd0;
            rd_reg = 5'd0;
        end
        SB_TYPE_OP : begin
            immediate_reg = $signed({pipe_data[31], pipe_data[7], pipe_data[30:25], pipe_data[11:8]});
            rs2_reg = pipe_data[24:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            funct7_reg = 7'd0;
            rd_reg = 5'd0;
        end
        UJ_TYPE_OP : begin
            immediate_reg = $signed({pipe_data[31], pipe_data[19:12], pipe_data[20],
                                    pipe_data[30:21]});
            rd_reg = pipe_data[11:7];
            funct7_reg = 7'd0;
            rs2_reg = 5'd0;
            rs1_reg = 5'd0;
            funct3_reg = 3'd0;
        end
        default : begin
            immediate_reg = 20'sd0;
            funct7_reg = 7'd0;
            rs2_reg = 5'd0;
            rs1_reg = 5'd0;
            funct3_reg = 3'd0;
            rd_reg = 5'd0;
        end
    endcase
end
/*-----------------------------------------------------------
 * [control_bit]
 * [11]  : Goes to 'AND' when 'beq'
 * [10]  : MUX whether $rd will be $ra at 'jal'
 * [9]   : MUX whether 'rs+offset' selection and MUX for 'pc_j'
 * [8:6] : Control bit at WB [op_write, wb mux]
 * [5:4] : Control bit at MEM
 * [3:0] : Control bit at EX
 *
 * MemtoReg:[8:7], RegWrtie:[6],
 * MemRead:[5], MemWrite:[4]
 * ALUOp:[3:1], ALUSrc:[0] 
 *
 * ALUOp
 * 000 : ADD
 * 001 : SUB
 * 010 : AND
 * 011 : OR
 * 100 : SHIFT LEFT
 * 101 : SLT
 *
 * Only control_bit[8:0] will go through OUTPUT 'ctrl_ex'
 *---------------------------------------------------------*/
always @(pipe_data or funct3_reg or funct7_reg)
begin : CONTROL_GENERTATOR
    case (pipe_data[6:0])
        ADDI_OP :
            control_bit = 12'b000_100_00_0001;
        LD_OP :
            control_bit = 12'b000_101_10_0001;
        JALR_OP :
            control_bit = 12'b001_110_00_0000;
        S_TYPE_OP : // SD
            control_bit = 12'b000_000_01_0001;
        SB_TYPE_OP : // BEQ
            control_bit = 12'b100_000_00_0000;
        UJ_TYPE_OP : // JAL
            control_bit = 12'b010_110_00_0000;
        default : begin // R-type
            if (funct3_reg == 3'b000 && funct7_reg[5] == 1'b0) // add
                control_bit = 12'b000_100_00_0000;
            else if (funct3_reg == 3'b000 && funct7_reg[5] == 1'b1) //sub
                control_bit = 12'b000_100_00_0010;
            else if (funct3_reg == 3'b001) // SLL
                control_bit = 12'b000_100_00_1000;
            else if (funct3_reg == 3'b010) // SLT
                control_bit = 12'b000_100_00_1010;
            else if (funct3_reg == 3'b111) // AND
                control_bit = 12'b000_100_00_0100;
            else // OR
                control_bit = 12'b000_100_00_0110;
        end
    endcase
end

always @(control_bit or load_pc_reg_value1 or pipe_pc or extended_reg)
begin : PC_J_MUX
    if (control_bit[9] == 0) begin
        pc_j_reg = pipe_pc + {immediate_reg << 1}; //Address adder( Shift left1, Add )
    end else begin
        pc_j_reg = load_pc_reg_value1;
    end
end

always @(rs1_reg or rs2_reg or immediate_reg or write_addr or write_data or 
         load_pc_reg_value1 or load_pc_reg_value2 or control_bit[9])
begin : DATA_REGISTER
    if (control_bit[9] == 1'b1)
        load_pc_reg_addr1_reg = rs1_reg + immediate_reg;
    else
        load_pc_reg_addr1_reg = rs1_reg;
    load_pc_reg_addr2_reg = rs2_reg;
/*
    if (op_write == 1'b1) begin
        write_pc_reg_addr_reg = write_addr;
        write_pc_reg_value_reg = write_data;
    end else begin
        write_pc_reg_addr_reg = 32'd0;
        write_pc_reg_value_reg = 32'd0;
    end
*/
end

always @(negedge reset_n or posedge clk)
begin : PIPELINE_REGISTER
    if (reset_n == 1'b0) begin
        extended_reg <= 32'd0;
        r_data1_reg <= 32'd0;
        r_data2_reg <= 32'd0;
//        write_pc_reg_value_reg <= 32'd0;
//        write_pc_reg_addr_reg <= 32'd0;
        pc4_ex_reg <= 32'd0;
        ctrl_ex_reg <= 9'd0;
        rd_ex_reg <= 32'd0;
    end else begin
        ctrl_ex_reg <= control_bit[8:0];
        pc4_ex_reg <= pipe_pc4;
        r_data2_reg <= load_pc_reg_value2;
        extended_reg <= immediate_reg;
        r_data1_reg <= load_pc_reg_value1;
        if (control_bit[8:6] == 3'b000)
            rd_ex_reg <= 32'd4;
        else
            rd_ex_reg <= rd_reg;
    end
end

assign control_j = (((load_pc_reg_value1 == load_pc_reg_value2) &&
                    control_bit[11]) || control_bit[10] || control_bit[9]);
assign pc_j = pc_j_reg;
assign ctrl_ex = ctrl_ex_reg;
assign pc4_ex = pc4_ex_reg;
assign r_data1 = r_data1_reg;
assign r_data2 = r_data2_reg;
assign load_pc_reg_addr1 = load_pc_reg_addr1_reg;
assign load_pc_reg_addr2 = load_pc_reg_addr2_reg;
assign write_pc_reg_value = write_data;
assign write_pc_reg_addr = write_addr;
assign extended = extended_reg;
assign rd_ex = rd_ex_reg;
assign op_write_top = op_write;

endmodule