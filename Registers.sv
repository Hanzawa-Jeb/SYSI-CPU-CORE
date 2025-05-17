module Registers (
    input clk,
    //the parameters for the registers
    input rst,
    //reset the registers
    input logic [11:7] rd,
    //destination to write
    input logic [19:15] rsR1,
    //source to read
    input logic [24:20] rsR2,
    //source to read 2
    input logic [63:0] dataW,
    //address to write
    input we_reg,
    //write enable
    output logic [63:0] dataR1,
    //data 1
    output logic [63:0] dataR2
    //data 2
);

    integer i;

    logic [63:0] RegGroup [0:31];
    always_ff @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) begin
                RegGroup[i] <= 64'b0;
            end
        end else begin
            if (we_reg) begin
                RegGroup[rd] <= dataW;
            end
        end
    end

    assign dataR1 = (rsR1 == 5'b0) ? 64'b0 : RegGroup[rsR1];
    assign dataR2 = (rsR2 == 5'b0) ? 64'b0 : RegGroup[rsR2];

//implement the functions of the Register group
//waiting to be finished

endmodule