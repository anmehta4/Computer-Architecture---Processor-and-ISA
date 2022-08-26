/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (clk, rst, ALUresult, memResult, read2Data, memWrite, memRead, halt, err);

input [15:0] ALUresult, read2Data;
input clk, rst, memRead, memWrite, halt;
output [15:0] memResult;
output err;

wire enable;
assign enable = (halt)? 1'b0 : memWrite|memRead;

assign err = (memRead == 1'bx | memWrite == 1'bx | halt == 1'bx);

memory2c memory2c(.clk(clk), .rst(rst), .addr(ALUresult), .data_out(memResult), 
                  .enable(enable), .wr(memWrite), .createdump(1'b1), .data_in(read2Data));
   
endmodule
