`include "core_struct.vh"
module Core (
    input clk,
    input rst,

    Mem_ift.Master imem_ift,
    //read request&read response
    //instruction memory interface
    Mem_ift.Master dmem_ift,
    //four channel, read & write
    //data memory interface
    output cosim_valid,
    output CorePack::CoreInfo cosim_core_info
);
    import CorePack::*;

    logic [63:0] pc;
    //the current pc 
    logic [63:0] pc_next;
    //the next pc
    logic [63:0] pc_plus_f;
    //pc plus four

    logic [63:0] write_data;
    logic [7:0] write_mask;
    logic [4:0] rs1;
    logic [4:0] rs2;

    logic [4:0] rd;

    logic [63:0] alw_zero = 64'b0;

    data_t ALUinput1;
    data_t ALUinput2;
    data_t alu_res;
    //set the wires for the ALU

    data_t imm;
    //set the wires for the ImmGen
    
    inst_t inst;
    logic [63:0] inst_64;
    wire we_reg;
    wire we_mem;
    wire re_mem;
    wire npc_sel;
    imm_op_enum immgen_op;
    alu_op_enum alu_op;
    cmp_op_enum cmp_op;//this is the bralu_op in the picture
    alu_asel_op_enum alu_asel;
    alu_bsel_op_enum alu_bsel;
    wb_sel_op_enum wb_sel;
    mem_op_enum mem_op;
    //set the wires from the controller

    wire br_taken;
    //the control signal for whether taking the branch

    logic [63:0] dataW;
    //the final output on the right
    logic [63:0] dataR1;
    logic [63:0] dataR2;
    //here are the signals that are connected to the Register group

    data_t dmem_rdata;
    logic [63:0] truncatedData;
    //get the return of the DRAM

    logic [63:0] read_data_1;
    logic [63:0] read_data_2;
    logic [63:0] wb_val;

    controller Controller(
        .inst(inst),
        .we_reg(we_reg),
        .we_mem(we_mem),
        .re_mem(re_mem),
        .npc_sel(npc_sel),
        .immgen_op(immgen_op),
        .alu_op(alu_op),
        .cmp_op(cmp_op),
        .alu_asel(alu_asel),
        .alu_bsel(alu_bsel),
        .wb_sel(wb_sel),
        .mem_op(mem_op)
        //connect all the wires from the controller
    );   

    Registers registers(
        .rst(rst),
        .rd(inst[11:7]),
        .rsR1(inst[19:15]),
        .rsR2(inst[24:20]),
        .dataW(dataW),
        .dataR1(dataR1),
        .dataR2(dataR2),
        .clk(clk),
        .we_reg(we_reg)
    );

    ALU alu(
        .a(ALUinput1),
        .b(ALUinput2),
        .alu_op(alu_op),
        .res(alu_res)
        //connect the ALU
    );

    ImmGen immgen(
        .inst(inst[31:7]),
        .immgen_op(immgen_op),
        .imm(imm)
        //connect the immgen module
    );

    Mux2To1_64 mux1(
        .I0(pc_plus_f),
        .I1(alu_res),
        .S(br_taken),
        .O(pc_next)
        //control the update of the PC
    );

    MuxA muxA(
        .PC(pc),
        .REG(dataR1),
        .S(alu_asel),
        .O(ALUinput1)
    );

    //these two multiplexers are for the ALU input

    MuxB muxB(
        .IMM(imm),
        .REG(dataR2),
        .S(alu_bsel),
        .O(ALUinput2)
    );

    Mux3To1_64 mux3(
        .PC(pc_plus_f),
        .ALU(alu_res),
        .MEM(truncatedData),
        .S(wb_sel),
        .O(dataW)
    );
    //connect the Mux4To1 altogether

    DataPkg datapkg(
        .mem_op(mem_op),
        .reg_data(dataR2),
        .dmem_waddr(alu_res),
        .dmem_wdata(write_data)
        //instantiate the datapackage module
    );

    MaskGen maskgen(
        .mem_op(mem_op),
        .dmem_waddr(alu_res),
        .dmem_wmask(write_mask)
        //instantiate the maskgen module
    );

    DataTrunc datatrunc(
        .dmem_rdata(dmem_rdata),
        .mem_op(mem_op),
        .dmem_raddr(alu_res),
        .read_data(truncatedData)
    );

    Cmp branch_cmp(
        .a(dataR1),
        .b(dataR2),
        .cmp_op(cmp_op),
        .cmp_res(br_taken)
    );

    always_ff @(posedge clk) begin
        if (rst) begin
            pc <= 64'b0;
        end else begin
            pc <= pc_next;
            //give the value of pc_next to pc
        end
        //the sequential block for the PC
    end

    always_comb begin
        pc_plus_f = pc + 64'h4;
        //always prepare the PC+4
    end

    always_comb begin
        //inst selection
        if (pc[2]) begin
            inst = inst_64[63:32]; //get the higher 32 bits
        end else begin
            inst = inst_64[31:0];  //get the lower 32 bits
        end
    end

    assign imem_ift.r_request_valid = 1'b1;
    //set the imem valid signal to always 1
    assign imem_ift.r_request_bits.raddr = {pc[63:3], 3'b0};
    //assign the pc to the read address
    assign inst_64 = imem_ift.r_reply_bits.rdata;
    //get the instruction with the length of 64 bits

    assign dmem_ift.r_request_valid = re_mem;
    //always set to 1 is OK?
    assign dmem_ift.r_request_bits.raddr = alu_res;

    assign dmem_ift.w_request_valid = we_mem;
    //always set to 1 is OK?not OK
    assign dmem_ift.w_request_bits.waddr = alu_res;
    assign dmem_ift.w_request_bits.wdata = write_data;
    //note that this part need to be completed
    assign dmem_ift.w_request_bits.wmask = write_mask;
    //this part also need to be completed
    //setting the port of the IMEM and DMEM

    assign dmem_rdata = dmem_ift.r_reply_bits.rdata;
    //get the return of the DMEM
    
    assign wb_val = dataW;

    assign read_data_1 = dataR1;
    assign read_data_2 = dataR2;

    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];

    assign cosim_valid = 1'b1;
    assign cosim_core_info.pc        = pc;
    //pc need to be connected
    assign cosim_core_info.inst      = {32'b0,inst};   
    //inst need to be connected
    assign cosim_core_info.rs1_id    = {59'b0, rs1};
    assign cosim_core_info.rs1_data  = read_data_1;
    assign cosim_core_info.rs2_id    = {59'b0, rs2};
    assign cosim_core_info.rs2_data  = read_data_2;
    assign cosim_core_info.alu       = alu_res;
    assign cosim_core_info.mem_addr  = dmem_ift.r_request_bits.raddr;
    assign cosim_core_info.mem_we    = {63'b0, dmem_ift.w_request_valid};
    assign cosim_core_info.mem_wdata = dmem_ift.w_request_bits.wdata;
    assign cosim_core_info.mem_rdata = dmem_ift.r_reply_bits.rdata;
    assign cosim_core_info.rd_we     = {63'b0, we_reg};
    //rd_we need to be connected
    assign cosim_core_info.rd_id     = {59'b0, rd}; 
    //rd_id need to be connected
    assign cosim_core_info.rd_data   = wb_val;
    //rd_data need to be connected
    assign cosim_core_info.br_taken  = {63'b0, br_taken};
    assign cosim_core_info.npc       = pc_next;

    assign rd = inst[11:7];


endmodule


module MultiFSM(
    input clk,
    input rst,
    Mem_ift.Master imem_ift,
    Mem_ift.Master dmem_ift,
    input we_mem,
    input re_mem,
    input CorePack::addr_t pc,
    input CorePack::addr_t alu_res,
    input CorePack::data_t data_package,
    input CorePack::mask_t mask_package,
    output stall
);
    import CorePack::*;

    // fill your code for bonus

endmodule
