`include "core_struct.vh"
module ALU (
  input  CorePack::data_t a,
  input  CorePack::data_t b,
  input  CorePack::alu_op_enum  alu_op,
  output CorePack::data_t res
);

  import CorePack::*;

  always_comb begin
  //we use always_comb logic to implement combinational logic
    case(alu_op)
      ALU_ADD: res = a + b;
      ALU_SUB: res = a - b;
      ALU_AND: res = a & b;
      ALU_OR: res = a | b;
      ALU_XOR: res = a ^ b;
      ALU_SLT: res = ($signed(a) < $signed(b)) ? 64'b1 : 64'b0;   //set less than
      ALU_SLTU: res = (a < b) ? 64'b1 : 64'b0;  //set less than unsigned
      ALU_SLL: res = a << b[4:0];   //logical shift left
      ALU_SRL: res = a >> b[4:0];   //logical right shift
      ALU_SRA: res = $signed(a) >>> b[4:0];  //arithmetic right shift
      ALU_ADDW:   res = {{32{$signed(a[31:0] + b[31:0])[31]}}, $signed(a[31:0] + b[31:0])};
      ALU_SUBW:   res = {{32{$signed(a[31:0] - b[31:0])[31]}}, $signed(a[31:0] - b[31:0])};
      ALU_SLLW:   res = {{32{1'b0}}, (a[31:0] << b[4:0])};
      ALU_SRLW:   res = {{32{1'b0}}, (a[31:0] >> b[4:0])};
      ALU_SRAW:   res = {{32{$signed(a[31:0])[31]}}, ($signed(a[31:0]) >>> b[4:0])};
      //32bit version of operation
      ALU_DEFAULT: res = 64'b0;
      default: res = 64'b0;
    endcase
  end

endmodule
