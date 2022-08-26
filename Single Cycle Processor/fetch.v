/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (instr, readAddr, clk, rst, err);

input [15:0] readAddr;
input clk, rst;
output [15:0] instr;
output err;

assign err = (^readAddr == 1'bx);

// TODO: Your code here
memory2c IF_memory2c(.clk(clk), .rst(rst), .addr(readAddr), .data_out(instr), 
                     .enable(1'b1), .wr(1'b0), .createdump(1'b0), .data_in());
 
   
endmodule
