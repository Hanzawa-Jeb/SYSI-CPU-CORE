`include "core_struct.vh"

//READ FROM THE REGISTERS
module MaskGen(
    input CorePack::mem_op_enum mem_op,
    //opcode for the memory operation
    input CorePack::addr_t dmem_waddr,
    //write address of the content
    output CorePack::mask_t dmem_wmask
    //the mask generated
);

  import CorePack::*;
  
  always_comb begin
    case(mem_op)
      MEM_NO: begin
        //no operation
        dmem_wmask = 8'b0;
      end
      MEM_D: begin
        //double word, 64-bit, all bytes enabled
        dmem_wmask = 8'b11111111;
      end
      MEM_W: begin
        //word, 32-bit, enable 4 bytes
        dmem_wmask = (8'b00001111 << dmem_waddr[2:0]);
      end
      MEM_H: begin
        //half-word, 16-bit, enable 2 bytes
        dmem_wmask = (8'b00000011 << dmem_waddr[2:0]);
      end
      MEM_B: begin
        //one-byte, 8-bit, enable 1 byte
        dmem_wmask = (8'b00000001 << dmem_waddr[2:0]);
      end
      MEM_UB: begin
        //one-byte unsigned
        dmem_wmask = (8'b00000001 << dmem_waddr[2:0]);
      end
      MEM_UH: begin
        //half-word unsigned
        dmem_wmask = (8'b00000011 << dmem_waddr[2:0]);
      end
      MEM_UW: begin
        //word unsigned
        dmem_wmask = (8'b00001111 << dmem_waddr[2:0]);
      end
      default: begin
        dmem_wmask = 8'b0;
      end
    endcase
  end

endmodule