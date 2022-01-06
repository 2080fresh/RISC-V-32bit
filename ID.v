module ID(
    input clk,
    input reset_n,
    input op_write, //register
<<<<<<< HEAD
    input [31:0] pipe_pc,
    input [31:0] pipe_data, // instruction
    input [31:0] write_data,
    input [4:0] write_addr,
    input [31:0] load_pc_reg_value1,
    input [31:0] load_pc_reg_value2,   // load register value from tb
    output [31:0] load_pc_reg_addr,   // load register address from tb
    output [31:0] write_pc_reg_value, // write register value on tb
    output control_j,
    output [31:0] pc_j,
    output [31:0] r_data1,
    output [31:0] r_data2,
    output [31:0] extended,
=======
    //input hazard_ctrl_mem,
    input [63:0] pipe_pc,
    input [31:0] pipe_data, // instruction
    input [63:0] write_data,
    input [4:0] write_addr,
    //output hazard_detect,
    output control_j,
    output [63:0] pc_j,
    output [63:0] r_data1,
    output [63:0] r_data2,
    output [63:0] extended,
    //output [4:0] rs1,
    //output [4:0] rs2,
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
    output [4:0] rd_ex,
    output [1:0] ctrl_wb,
    output [1:0] ctrl_m,
    output [3:0] ctrl_ex
);

<<<<<<< HEAD
reg signed [31:0] extended_reg;
//reg [31:0] registers [0:31]; //register
reg [5:0] rs1_reg;
reg [5:0] rs2_reg;
reg [31:0] r_data1_reg;
reg [31:0] r_data2_reg;
reg [5:0] rd_reg;
reg [2:0] funct3_reg;
reg [6:0] funct7_reg;
reg signed [11:0] immediate_reg;
reg [31:0] load_pc_reg_addr_reg;   // load register address from tb
reg [31:0] write_pc_reg_value_reg; // write register value on tb
=======
reg [63:0] extended_reg;
reg [63:0] 
reg [63:0] registers [0:31]; //register
reg [5:0] rs1_reg;
reg [5:0] rs2_reg;
reg [5:0] rd_reg;
reg [2:0] funct3_reg;
reg [6:0] funct7_reg;
reg [11:0] immediate_reg;
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
reg bits;

/*---------------------------------------------------------------
 * MemtoReg(WB), RegWrtie(WB), MemRead(MEM), MemWrite(MEM), ALUOp(3)
 *
 * ALUOp
 * 000 : ADD
 * 001 : SUB
 * 010 : AND
 * 011 : OR
 * 100 : SHIFT LEFT
 * 101 : SLT
 * 
 *-------------------------------------------------------------*/

localparam [6:0] R_TYPE_OP  = 7'b0110011, // R_type
                 ADDI_OP    = 7'b0010011, // I-type ADDI
                 LD_OP      = 7'b0000011, // I-type LD
                 JALR_OP    = 7'b1100111, // I-type JALR
                 S_TYPE_OP  = 7'b0100011, // S-type SD
                 SB_TYPE_OP = 7'b1100011, // SB-type BEQ,BNE,BLT,BGE
                 UJ_TYPE_OP = 7'b1101111; // UJ-type JAL

<<<<<<< HEAD
always @(pipe_data) // Seperate Instruction
=======
always @(*) // Seperate Instruction
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
begin : SEPERTATE_INST
    case (pipe_data[6:0])
        R_TYPE_OP : begin
            funct7_reg = pipe_data[31:25];
            rs2_reg = pipe_data[24:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        ADDI_OP : begin
<<<<<<< HEAD
            immediate_reg = $signed(pipe_data[31:20]);
=======
            immediate_reg = pipe_data[31:20];
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        LD_OP : begin
<<<<<<< HEAD
            immediate_reg = $signed(pipe_data[31:20]);
=======
            immediate_reg = pipe_data[31:20];
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        JALR_OP : begin
<<<<<<< HEAD
            immediate_reg = $signed(pipe_data[31:20]);
=======
            immediate_reg = pipe_data[31:20];
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        S_TYPE_OP : begin
<<<<<<< HEAD
            immediate_reg = $signed({pipe_data[31:25], pipe_data[11:7]});
=======
            immediate_reg = {pipe_data[31:25], pipe_data[11:7]};
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
            rs2_reg = pipe_data[24:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        SB_TYPE_OP : begin
<<<<<<< HEAD
            immediate_reg = $signed({pipe_data[7], pipe_data[30:25], pipe_data[11:8]});
=======
            immediate_reg = {pipe_data[7], pipe_data[30:25}, pipe_data[11:8]};
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
            rs2_reg = pipe_data[24:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
        end
        UJ_TYPE_OP : begin
<<<<<<< HEAD
            immediate_reg = $signed({pipe_data[31], pipe_data[19:12], pipe_data[20],
                             pipe_data[30:21]});
=======
            immediate_reg = {pipe_data[31], pipe_data[19:12], pipe_data[20], pipe_data[30:21]};
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
    endcase
end

<<<<<<< HEAD
always @(immediate_reg)
begin : IMM_GEN
    extended_reg = immediate_reg;
end

//Address adder( Shift left1, Add )
assign pc_j = pipe_pc + {extended_reg[31:0],1'b0};
assign extended = extended_reg;
=======
// IMM-GEN
assign extended_reg = 64'sb{immediate_reg};

//Address adder( Shift left1, Add )
assign pc_j = pipe_pc + {extended_reg[62:0],1'b0};
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e

/*---------------------------------------------------------------
 * MemtoReg, RegWrtie, MemRead, MemWrite, ALUOp(3)
 *
 * ALUOp
 * 000 : ADD
 * 001 : SUB
 * 010 : AND
 * 011 : OR
 * 100 : SHIFT LEFT
 * 101 : SLT
 * 
 *-------------------------------------------------------------*/

reg [7:0] control_bit;

always @(pipe_data)
begin : CONTROL_GENERTATOR
    case (pipe_data[6:0])
        ADDI_OP :
            control_bit = 8'b01000001;
        LD_OP :
            control_bit = 8'b11100001;
        JALR_OP :
            control_bit = 8'b01000000;
        S_TYPE_OP :
            control_bit = 8'b00010001;
        SB_TYPE_OP :
            control_bit = 8'b00000000;
        UJ_TYPE_OP :
            control_bit = 8'b01000000;
        R_TYPE_OP : begin
<<<<<<< HEAD
            if (funct3_reg == 3'b000 && funct7_reg[5] == 1'b0) // add
                control_bit = 8'b11000000;
            else if (funct3_reg == 3'b000 && funct7_reg[5] == 1'b1) //sub
                control_bit = 8'b11000010;
            else if (funct3_reg == 3'b001) // SLL
                control_bit = 8'b11001000;
            else if (funct3_reg == 3'b010) // SLT
                control_bit = 8'b11001010;
            else if (funct3_reg == 3'b111) // AND
                control_bit = 8'b11000100;
            else if (funct3_reg == 3'b110) // OR
=======
            if (funct3 == 3'b000 && funct7[5] == 1'b0) // add
                control_bit = 8'b11000000;
            else if (funct3 == 3'b000 && funct7[5] == 1'b1) //sub
                control_bit = 8'b11000010;
            else if (funct3 == 3'b001) // SLL
                control_bit = 8'b11001000;
            else if (funct3 == 3'b010) // SLT
                control_bit = 8'b11001010;
            else if (funct3 == 3'b111) // AND
                control_bit = 8'b11000100;
            else if (funct3 == 3'b110) // OR
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
                control_bit = 8'b11000110;
            else
                control_bit = 8'b00000000; // default condition
        end
        default :
<<<<<<< HEAD
            control_bit = 8'b00000000; // default condition
=======
            contrul_bit = 8'b00000000; // default condition
>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
    endcase
end

assign ctrl_wb = control_bit[7:6];
assign ctrl_m = control_bit[5:4];
assign ctrl_ex = control_bit[3:0];

<<<<<<< HEAD
always @(negedge reset_n or posedge clk)
begin : REGISTERS
    if (reset_n == 1'b0) begin
        //all regs reset
    end else begin
        if (op_write == 1'b1) begin
            write_pc_reg_value_reg <= write_data;
            load_pc_reg_addr_reg <= write_addr;
            //registers[write_addr] <= write_data;
        end else begin
            r_data1_reg <= load_pc_reg_value1;
            r_data2_reg <= load_pc_reg_value2;
        end
    end
end

assign write_pc_reg_value = write_pc_reg_value_reg;
assign load_pc_reg_addr = load_pc_reg_addr_reg;
=======
always @(posedge clk)
begin : Registers
    if (reset_n == 0) begin
        registers[0:32] = 64d'0;
    end else if (op_write == 1'b1) begin
        registers[write_addr] <= write_data;
    end else begin
        r_data1_reg <= regsiters[rs1];
        r_data2_reg <= registers[rs2];
    end
end

>>>>>>> 707534bc7954012b2d497c0c1a67843afd9d564e
assign r_data1 = r_data1_reg;
assign r_data2 = r_data2_reg;

endmodule
