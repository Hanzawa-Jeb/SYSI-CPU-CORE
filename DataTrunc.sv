`include "core_struct.vh"

//READ FROM THE MEMORY
module DataTrunc (
    input CorePack::data_t dmem_rdata,
    //the data in the MEMORY
    input CorePack::mem_op_enum mem_op,
    //memory operation
    input CorePack::addr_t dmem_raddr,
    //reading address
    output CorePack::data_t read_data
);

  import CorePack::*;
  // Data trunction
  //truncate the data needed to be read
  always_comb begin
    case(mem_op)
      MEM_NO: begin
        read_data = 64'b0;
        //NO OPERATION, directly output
      end
      MEM_D: begin
        read_data = dmem_rdata;
        //SIGNED double word, 64-bit
      end
      MEM_W: begin
        read_data = {{32{dmem_rdata[{dmem_raddr[2:0], 3'b0} + 31]}}, dmem_rdata[{dmem_raddr[2:0], 3'b0} +: 32]};
        //SIGNED word, 32-bit
      end
      MEM_H: begin
        read_data = {{48{dmem_rdata[{dmem_raddr[2:0], 3'b0} + 15]}}, dmem_rdata[{dmem_raddr[2:0], 3'b0} +: 16]};
        //SIGNED half-word, 16-bit
      end
      MEM_B: begin
        read_data = {{56{dmem_rdata[{dmem_raddr[2:0], 3'b0} + 7]}}, dmem_rdata[{dmem_raddr[2:0], 3'b0} +: 8]};
        //SIGNED byte, 8-bit
      end
      MEM_UB: begin
        read_data = {56'b0, dmem_rdata[{dmem_raddr[2:0], 3'b0} +: 8]};
        //UNSIGNED byte, 8-bit
      end
      MEM_UH: begin
        read_data = {48'b0, dmem_rdata[{dmem_raddr[2:0], 3'b0} +: 16]};
        //UNSIGNED half-word, 16-bit
      end
      MEM_UW: begin
        read_data = {32'b0, dmem_rdata[{dmem_raddr[2:0], 3'b0} +: 32]};
        //UNSIGNED word, 32-bit
      end
      default: begin
        read_data = 64'b0;
      end
    endcase
  end

endmodule

