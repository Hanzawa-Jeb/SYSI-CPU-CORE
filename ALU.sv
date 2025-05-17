`include "core_struct.vh"
module ALU (
    input  CorePack::data_t a,
    input  CorePack::data_t b,
    input  CorePack::alu_op_enum  alu_op,
    output CorePack::data_t res
);
    import CorePack::*;
    
    // 声明中间变量用于32位操作
    logic [31:0] temp_addw;
    logic [31:0] temp_subw;
    logic [31:0] temp_sllw;
    logic [31:0] temp_srlw;
    logic [31:0] temp_sraw;

    always_comb begin
        // 预先计算所有32位结果
        temp_addw = a[31:0] + b[31:0];
        temp_subw = a[31:0] - b[31:0];
        temp_sllw = a[31:0] << b[4:0];
        temp_srlw = a[31:0] >> b[4:0];
        temp_sraw = $signed(a[31:0]) >>> b[4:0];

        case(alu_op)
            // 64位操作
            ALU_ADD:  res = a + b;
            ALU_SUB:  res = a - b;
            ALU_AND:  res = a & b;
            ALU_OR:   res = a | b;
            ALU_XOR:  res = a ^ b;
            ALU_SLT:  res = ($signed(a) < $signed(b)) ? 64'b1 : 64'b0;
            ALU_SLTU: res = (a < b) ? 64'b1 : 64'b0;
            ALU_SLL:  res = a << b[5:0];
            ALU_SRL:  res = a >> b[5:0];
            ALU_SRA:  res = $signed(a) >>> b[5:0];

            // 32位操作 - 使用预计算的结果
            ALU_ADDW: res = {{32{temp_addw[31]}}, temp_addw};
            ALU_SUBW: res = {{32{temp_subw[31]}}, temp_subw};
            ALU_SLLW: res = {{32{temp_sllw[31]}}, temp_sllw};
            ALU_SRLW: res = {32'b0, temp_srlw};
            ALU_SRAW: res = {{32{temp_sraw[31]}}, temp_sraw};

            default:  res = 64'b0;
        endcase
    end

endmodule
