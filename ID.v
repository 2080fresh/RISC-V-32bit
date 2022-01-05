module ID(
    input clk,
    input reset_n,
    input op_write, //register
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
    output [4:0] rd_ex,
    output [1:0] ctrl_wb,
    output [1:0] ctrl_m,
    output [3:0] ctrl_ex
);

reg [63:0] extended_reg;
reg [63:0] 
reg [63:0] registers [0:31]; //register
reg [5:0] rs1_reg;
reg [5:0] rs2_reg;
reg [5:0] rd_reg;
reg [2:0] funct3_reg;
reg [6:0] funct7_reg;
reg [11:0] immediate_reg;
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

always @(*) // Seperate Instruction
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
            immediate_reg = pipe_data[31:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        LD_OP : begin
            immediate_reg = pipe_data[31:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        JALR_OP : begin
            immediate_reg = pipe_data[31:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        S_TYPE_OP : begin
            immediate_reg = {pipe_data[31:25], pipe_data[11:7]};
            rs2_reg = pipe_data[24:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        SB_TYPE_OP : begin
            immediate_reg = {pipe_data[7], pipe_data[30:25}, pipe_data[11:8]};
            rs2_reg = pipe_data[24:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
        end
        UJ_TYPE_OP : begin
            immediate_reg = {pipe_data[31], pipe_data[19:12], pipe_data[20], pipe_data[30:21]};
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
    endcase
end

// IMM-GEN
assign extended_reg = 64'sb{immediate_reg};

//Address adder( Shift left1, Add )
assign pc_j = pipe_pc + {extended_reg[62:0],1'b0};

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
                control_bit = 8'b11000110;
            else
                control_bit = 8'b00000000; // default condition
        end
        default :
            contrul_bit = 8'b00000000; // default condition
    endcase
end
endmodule

assign ctrl_wb = control_bit[7:6];
assign ctrl_m = control_bit[5:4];
assign ctrl_ex = control_bit[3:0];

always @(*)
begin : Registers
    if (reset_n == 0) begin
        registers[0:32] = 64d'0;
    end else if (pipe_data[6:0] == 


