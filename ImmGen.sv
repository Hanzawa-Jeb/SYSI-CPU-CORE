module ImmGen (
    input [31:7] inst,
    //note that the indeces in the module should be from 31 to 7
    //please always keep the sorting of the index in mind.
    input CorePack::imm_op_enum immgen_op,
    //the type of the instruction determine the way the immediate is generated
    output CorePack::data_t imm
);

import CorePack::*;

always_comb begin
    case(immgen_op)
        IMM0: begin
            imm = 64'b0;
        end
        I_IMM: begin
            imm[10:5] = inst[30:25];
            imm[4:1] = inst[24:21];
            imm[0] = inst[20];
            imm[63:11] = {53{inst[31]}};
        end
        S_IMM: begin
            imm[10:5] = inst[30:25];
            imm[4:1] = inst[11:8];
            imm[0] = inst[7];
            imm[63:11] = {53{inst[31]}};
        end
        B_IMM: begin
            imm[11] = inst[7];
            imm[10:5] = inst[30:25];
            imm[4:1] = inst[11:8];
            imm[0] = 0'b0;
            imm[63:12] = {52{inst[31]}};
        end
        U_IMM: begin
            imm[11:0] = 12'b0;
            imm[19:12] = inst[19:12];
            imm[30:20] = inst[30:20];
            imm[31] = inst[31];
            imm[63:32] = {32{inst[31]}};
        end
        UJ_IMM: begin
            imm[19:12] = inst[19:12];
            imm[11] = inst[20];
            imm[10:5] = inst[30:25];
            imm[4:1] = inst[24:21];
            imm[0] = 0'b0;
            imm[63:20] = {44{inst[31]}};
        end
        IMM6: begin
            imm = 64'b0;
        end
        IMM7: begin
            imm = 64'b0;
        end
        default: begin
            imm = 64'b0;
        end
    endcase
end

//implement the function of the immediate generation function

endmodule