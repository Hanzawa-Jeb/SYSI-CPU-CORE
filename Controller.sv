`include "core_struct.vh"
module controller (
    input CorePack::inst_t inst,
    //logic [31:0]
    output we_reg,
    //already connected, used in the register write
    output we_mem,
    //write enable of the 
    output re_mem,
    //no matter what the output is , it is always set to 1
    output npc_sel,
    //used to select pc
    output CorePack::imm_op_enum immgen_op,
    //operation code for the immgen
    output CorePack::alu_op_enum alu_op,
    //op code for the alu
    output CorePack::cmp_op_enum cmp_op,
    //compare op, not connected yet
    output CorePack::alu_asel_op_enum alu_asel,
    //select the muxA
    output CorePack::alu_bsel_op_enum alu_bsel,
    //select the muxB
    output CorePack::wb_sel_op_enum wb_sel,
    //select the final data to write back
    output CorePack::mem_op_enum mem_op
    //used for the modules like DataPkg, MaskGen and DataTrunc
    // output ControllerPack::ControllerSignals ctrl_signals
);

    import CorePack::*;
    // import ControllerPack::*;
    
    //variable declarance

    opcode_t opcode = inst[6:0];
    funct7_t funct7 = inst[31:25];
    funct3_t funct3 = inst[14:12];

    wire inst_load = (opcode == LOAD_OPCODE);
    wire inst_imm = (opcode == IMM_OPCODE);
    wire inst_auipc = (opcode == AUIPC_OPCODE);
    wire inst_immw = (opcode == IMMW_OPCODE);
    wire inst_store = (opcode == STORE_OPCODE);
    wire inst_reg = (opcode == REG_OPCODE);
    wire inst_lui = (opcode == LUI_OPCODE);
    wire inst_regw = (opcode == REGW_OPCODE);
    wire inst_branch = (opcode == BRANCH_OPCODE);
    wire inst_jalr = (opcode == JALR_OPCODE);
    wire inst_jal = (opcode == JAL_OPCODE);
    //assign the instruction wires

    assign we_reg = inst_load | inst_imm | inst_auipc | inst_immw | inst_reg | inst_lui | inst_regw | inst_jal | inst_jalr;
    //wite enable signal of registers
    assign we_mem = inst_store;
    //only the store operation needs to write the memory
    assign re_mem = 1'b1;
    //always accept the input, useless in some sense 
    assign npc_sel = 1'b1;
    //useless signal

    always_comb begin
        // Default values
        immgen_op = I_IMM;  // I-type immediate by default
        alu_op = ALU_ADD;   // ADD by default
        cmp_op = CMP_NO;    // No comparison by default
        alu_asel = ASEL_REG; // Register input by default
        alu_bsel = BSEL_IMM; // Immediate input by default
        wb_sel = WB_SEL_ALU; // ALU result by default
        mem_op = MEM_NO;     // No memory operation by default

        case(opcode)
            LOAD_OPCODE: begin
                // Load operations
                immgen_op = I_IMM;
                alu_op = ALU_ADD;
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_IMM;
                wb_sel = WB_SEL_MEM;
                case(funct3)
                    LB_FUNCT3:  mem_op = MEM_B;
                    LH_FUNCT3:  mem_op = MEM_H;
                    LW_FUNCT3:  mem_op = MEM_W;
                    LD_FUNCT3:  mem_op = MEM_D;
                    LBU_FUNCT3: mem_op = MEM_UB;
                    LHU_FUNCT3: mem_op = MEM_UH;
                    LWU_FUNCT3: mem_op = MEM_UW;
                    default:    mem_op = MEM_NO;
                endcase
            end

            STORE_OPCODE: begin
                // Store operations
                immgen_op = S_IMM;
                alu_op = ALU_ADD;
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_IMM;
                wb_sel = WB_SEL0;
                case(funct3)
                    SB_FUNCT3: mem_op = MEM_B;
                    SH_FUNCT3: mem_op = MEM_H;
                    SW_FUNCT3: mem_op = MEM_W;
                    SD_FUNCT3: mem_op = MEM_D;
                    default:   mem_op = MEM_NO;
                endcase
            end

            IMM_OPCODE: begin
                // Immediate arithmetic operations
                immgen_op = I_IMM;
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_IMM;
                wb_sel = WB_SEL_ALU;
                case(funct3)
                    ADD_FUNCT3:  alu_op = ALU_ADD;
                    XOR_FUNCT3:  alu_op = ALU_XOR;
                    OR_FUNCT3:   alu_op = ALU_OR;
                    AND_FUNCT3:  alu_op = ALU_AND;
                    SLL_FUNCT3:  alu_op = ALU_SLL;
                    SRL_FUNCT3:  alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    SLT_FUNCT3:  alu_op = ALU_SLT;
                    SLTU_FUNCT3: alu_op = ALU_SLTU;
                    default:     alu_op = ALU_ADD;
                endcase
            end

            REG_OPCODE: begin
                // Register arithmetic operations
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_REG;
                wb_sel = WB_SEL_ALU;
                case(funct3)
                    ADD_FUNCT3:  alu_op = (funct7[5]) ? ALU_SUB : ALU_ADD;
                    XOR_FUNCT3:  alu_op = ALU_XOR;
                    OR_FUNCT3:   alu_op = ALU_OR;
                    AND_FUNCT3:  alu_op = ALU_AND;
                    SLL_FUNCT3:  alu_op = ALU_SLL;
                    SRL_FUNCT3:  alu_op = (funct7[5]) ? ALU_SRA : ALU_SRL;
                    SLT_FUNCT3:  alu_op = ALU_SLT;
                    SLTU_FUNCT3: alu_op = ALU_SLTU;
                    default:     alu_op = ALU_ADD;
                endcase
            end

            BRANCH_OPCODE: begin
                // Branch operations
                immgen_op = B_IMM;
                alu_op = ALU_ADD;
                alu_asel = ASEL_PC;
                alu_bsel = BSEL_IMM;
                wb_sel = WB_SEL0;
                case(funct3)
                    BEQ_FUNCT3:  cmp_op = CMP_EQ;
                    BNE_FUNCT3:  cmp_op = CMP_NE;
                    BLT_FUNCT3:  cmp_op = CMP_LT;
                    BGE_FUNCT3:  cmp_op = CMP_GE;
                    BLTU_FUNCT3: cmp_op = CMP_LTU;
                    BGEU_FUNCT3: cmp_op = CMP_GEU;
                    default:     cmp_op = CMP_NO;
                endcase
            end

            JAL_OPCODE: begin
                // JAL
                immgen_op = U_IMM;
                alu_op = ALU_ADD;
                alu_asel = ASEL_PC;
                alu_bsel = BSEL_IMM;
                wb_sel = WB_SEL_PC;
                cmp_op = CMP7;
            end

            JALR_OPCODE: begin
                // JALR
                immgen_op = I_IMM;
                alu_op = ALU_ADD;
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_IMM;
                wb_sel = WB_SEL_PC;
                cmp_op = CMP7;
            end

            LUI_OPCODE: begin
                // LUI
                immgen_op = U_IMM;
                alu_op = ALU_ADD;
                alu_asel = ASEL0;
                alu_bsel = BSEL_IMM;
                wb_sel = WB_SEL_ALU;
            end

            AUIPC_OPCODE: begin
                // AUIPC
                immgen_op = U_IMM;
                alu_op = ALU_ADD;
                alu_asel = ASEL_PC;
                alu_bsel = BSEL_IMM;
                wb_sel = WB_SEL_ALU;
            end

            default: begin
                // Default/Invalid instruction
                immgen_op = I_IMM;
                alu_op = ALU_ADD;
                cmp_op = CMP_NO;
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_IMM;
                wb_sel = WB_SEL0;
                mem_op = MEM_NO;
            end
        endcase
    end


endmodule

