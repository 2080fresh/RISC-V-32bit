module ID (
    input clk,
    input reset_n,
    input op_write,
    input hazard_ctrl_mem,
    input [4:0] rd_in,
    input [63:0] pipe_pc,
    input [31:0] pipe_data,
    input [63:0] write_data,
    input [4:0] write_addr,
    output control_j;
    output hazard_detect,
    output [63:0] branched_pc,
    output [63:0] r_data1,
    output [63:0] r_data2,
    output [63:0] extended,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd_out,
    output [1:0] ctrl_wb,
    output [2:0] ctrl_m,
    output [3:0] ctel_ex
);

reg [63:0] reg_extended;
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

localparam [6:0] ADDI_OP    = 7'b0010011,
                 LD_OP      = 7'b0000011,
                 JALR_OP    = 7'b1100111,
                 S_TYPE_OP  = 7'b0100011,
                 SB_TYPE_OP = 7'b1100011,
                 UJ_TYPE_OP = 7'b1101111;


always @(*)
begin : IMMEDIATE_GENERATOR
    case (pipe_data[6:0])
        S_TYPE_OP : begin
            reg_extended = 64'sb{pipe_data[31:25], pipe_data[11:7]};
        end
        SB_TYPE_OP : begin
            reg_extended = 64'sb{pipe_data[7], pipe_data[30:25}, pipe_data[11:8],
                             1'b0};
        end
        UJ_TYPE_OP : begin
            reg_extended = 64'sb{pipe_data[31], pipe_data[19:12], pipe_data[20],
                             pipe_data[30:21], 1'b0};
        end
        // containing I-type plus alpha (my edit later)
        default : begin
            reg_extended = 64'sb{pipe_data[31:20]);
        end
    endcase
end

//Address adder
assign branched_pc = reg_extended + pipe_pc;
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
always @(*)
begin : CONTROL_GENERTATOR
    case (pipe_data[6:0])
        ADDI_OP :
            control_bit = 7'b0100000;
        LD_OP :
            control_bit = 7'b1110000;
        JALR_OP :
            control_bit = 7'b0100000;
        //To be continued...
    endcase
end
endmodule

