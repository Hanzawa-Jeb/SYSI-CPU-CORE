`include"core_struct.vh"
module Cmp (
    input CorePack::data_t a,
    input CorePack::data_t b,
    input CorePack::cmp_op_enum cmp_op,
    //the opcode
    output cmp_res
);

    //it's easy to discover that the implementation here is based on the combinational logic.

    import CorePack::*;

    always_comb begin
        case(cmp_op)
            CMP_NO: cmp_res = 1'b0; //not the type of branch or jal
            CMP_EQ: cmp_res = (a == b) ? 1'b1 : 1'b0; //equal to 
            CMP_NE: cmp_res = (a == b) ? 1'b0 : 1'b1; //not equal to 
            CMP_LT: cmp_res = ($signed(a) < $signed(b)) ? 1'b1 : 1'b0; //lower than
            CMP_GE: cmp_res = ($signed(a) < $signed(b)) ? 1'b0 : 1'b1;
            CMP_LTU: cmp_res = (a < b) ? 1'b1 : 1'b0;
            CMP_GEU: cmp_res = (a < b) ? 1'b0 : 1'b1;
            //unsigned version
            CMP7: cmp_res = 1'b1;
            //JUMP STATE
            default: cmp_res = 1'b0;
        endcase
    end
    
endmodule