module ID(
    input clk,
    input reset_n,
    input op_write, //register
    input [31:0] pipe_pc,
    input [31:0] pipe_data, // instruction
    input [31:0] write_data,
    input [31:0] write_addr,
    input [31:0] load_pc_reg_value1,
    input [31:0] load_pc_reg_value2,   // load register value from tb
    output [31:0] load_pc_reg_addr,   // load register address from tb
    output [31:0] write_pc_reg_value, // write register value on tb
    output control_j,
    output [31:0] pc_j,
    output [31:0] r_data1,
    output [31:0] r_data2,
    output [31:0] extended,
    output [31:0] rd_ex,
    output [8:0] ctrl_ex
);

reg signed [31:0] extended_reg;
reg [31:0] rs1_reg;
reg [31:0] rs2_reg;
reg [31:0] r_data1_reg;
reg [31:0] r_data2_reg;
reg [5:0] rd_reg; //Where does it used?
reg [2:0] funct3_reg;
reg [6:0] funct7_reg;
reg signed [11:0] immediate_reg;
reg [31:0] load_pc_reg_addr_reg;   // load register address from tb
reg [31:0] write_pc_reg_value_reg; // write register value on tb
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

always @(pipe_data) // Seperate Instruction
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
            immediate_reg = $signed(pipe_data[31:20]);
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        LD_OP : begin
            immediate_reg = $signed(pipe_data[31:20]);
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        JALR_OP : begin
            immediate_reg = $signed(pipe_data[31:20]);
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        S_TYPE_OP : begin
            immediate_reg = $signed({pipe_data[31:25], pipe_data[11:7]});
            rs2_reg = pipe_data[24:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
        SB_TYPE_OP : begin
            immediate_reg = $signed({pipe_data[7], pipe_data[30:25], pipe_data[11:8]});
            rs2_reg = pipe_data[24:20];
            rs1_reg = pipe_data[19:15];
            funct3_reg = pipe_data[14:12];
        end
        UJ_TYPE_OP : begin
            immediate_reg = $signed({pipe_data[31], pipe_data[19:12], pipe_data[20],
                                    pipe_data[30:21]});
            funct3_reg = pipe_data[14:12];
            rd_reg = pipe_data[11:7];
        end
    endcase
end

always @(immediate_reg)
begin : IMM_GEN
    extended_reg = immediate_reg;
end

//Address adder( Shift left1, Add )
assign pc_j = pipe_pc + {extended_reg[31:0],1'b0};
assign extended = extended_reg;



/*-----------------------------------------------------------
 * control_bit
 * [11]  : Goes to 'AND'
 * [10]  : MUX for 'pc_j'
 * [9]   : MUX whether 'rs+offset' selection
 * [8:6] : Control bit at WB [op_write, wb mux]
 * [5:4] : Control bit at MEM
 * [3:0] : Control bit at EX
 *
 * Only control_bit[8:0] will go through OUTPUT 'ctrl_ex'
 *---------------------------------------------------------*/
reg [11:0] control_bit;

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
always @(pipe_data)
begin : CONTROL_GENERTATOR
    case (pipe_data[6:0])
        ADDI_OP :
            control_bit = 12'b0x0_100_00_0001;
        LD_OP :
            control_bit = 12'b0x0_101_10_0001;
        JALR_OP :
            control_bit = 12'b1x1_110_00_0000;
        S_TYPE_OP : // SD
            control_bit = 12'b0x0_000_01_0001;
        SB_TYPE_OP : // BEQ
            control_bit = 12'b1x0_000_00_0000;
        UJ_TYPE_OP : // JAL
            control_bit = 12'b1x0_110_00_0000;
        R_TYPE_OP : begin
            if (funct3_reg == 3'b000 && funct7_reg[5] == 1'b0) // add
                control_bit = 12'b0x0_100_00_0000;
            else if (funct3_reg == 3'b000 && funct7_reg[5] == 1'b1) //sub
                control_bit = 12'b0x0_100_00_0010;
            else if (funct3_reg == 3'b001) // SLL
                control_bit = 12'b0x0_100_00_1000;
            else if (funct3_reg == 3'b010) // SLT
                control_bit = 12'b0x0_100_00_1010;
            else if (funct3_reg == 3'b111) // AND
                control_bit = 12'b0x0_100_00_0100;
            else if (funct3_reg == 3'b110) // OR
                control_bit = 12'b0x0_100_00_0110;
            else
                control_bit = 12'b111_111_11_1111; // default condition
        end
        default :
            control_bit = 12'b111_111_11_1111; // default condition
    endcase
end

assign ctrl_ex = control_bit[8:0];

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
assign r_data1 = r_data1_reg;
assign r_data2 = r_data2_reg;

endmodule
