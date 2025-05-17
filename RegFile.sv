`include "core_struct.vh"
module RegFile (
  input clk,
  input rst,
  input we,
  //parameter DATA_WIDTH = 64
  input CorePack::reg_ind_t  read_addr_1,
  input CorePack::reg_ind_t  read_addr_2,
  input CorePack::reg_ind_t  write_addr,
  //typedef logic [4:0] reg_ind_t
  //this is the index, indexing for 1-31
  input  CorePack::data_t write_data,
  output CorePack::data_t read_data_1,
  output CorePack::data_t read_data_2
  //typedef logic [DATA_WIDTH-1:0] data_t
);
  import CorePack::*;

  integer i;
  data_t register [1:31]; // x1 - x31, x0 keeps zero
  //each data cost 64 bit space

  always @(posedge clk) begin
  //the sequential block, used for resetting and more operations.
    if (rst) begin
    //reset
      for (i = 1; i < 32; i = i + 1) begin
        register[i] = 0;
        //reset all the registers
      end
    end 
    if (we) begin
    //write enable
      register[write_addr] = write_data;
    end
  end

  assign read_data_1 = register[read_addr_1];
  assign read_data_2 = register[read_addr_2];
  //directly give the output, just like the case in DRAM.sv

  // fill your code

endmodule
