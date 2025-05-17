`include "core_struct.vh"

//READ FROM THE REGISTERS
module DataPkg(
    input CorePack::mem_op_enum mem_op,
    //the operation code
    input CorePack::data_t reg_data,
    //the data to be written in
    input CorePack::addr_t dmem_waddr,
    //the address to write into
    output CorePack::data_t dmem_wdata
    //the data to be written
);
//mem_op_enum is the states for memory
//reg_data is the data to store
//addr_t is the write address
//dmem_wdata is the data to write
//mem_op there are types of the width of the data

  import CorePack::*;
  // Data package
  //only used to generate the data package

  always_comb begin
    dmem_wdata = 64'b0; // Default value
    case(mem_op)
    //in all the following cases that require offset, we use left shift to implement this.
      MEM_NO: begin
        dmem_wdata = 64'b0;
      end
      MEM_D: begin
        dmem_wdata = reg_data; // 64-bit write
      end
      MEM_W: begin
        // 32-bit write, shift based on address
        dmem_wdata = {32'b0, reg_data[31:0]} << {dmem_waddr[2:0], 3'b0};
      end
      MEM_H: begin
        // 16-bit write, shift based on address
        dmem_wdata = {48'b0, reg_data[15:0]} << {dmem_waddr[2:0], 3'b0};
      end
      MEM_B: begin
        // 8-bit write, shift based on address
        dmem_wdata = {56'b0, reg_data[7:0]} << {dmem_waddr[2:0], 3'b0};
      end
      MEM_UB: begin
        // Unsigned 8-bit write, same as MEM_B
        dmem_wdata = {56'b0, reg_data[7:0]} << {dmem_waddr[2:0], 3'b0};
      end
      MEM_UH: begin
        // Unsigned 16-bit
        dmem_wdata = {48'b0, reg_data[15:0]} << {dmem_waddr[2:0], 3'b0};
      end
      MEM_UW: begin
        // Unsigned 32-bit write, same as MEM_W
        dmem_wdata = {32'b0, reg_data[31:0]} << {dmem_waddr[2:0], 3'b0};
      end
      default: begin
        dmem_wdata = 64'b0;
      end
    endcase
  end

endmodule

