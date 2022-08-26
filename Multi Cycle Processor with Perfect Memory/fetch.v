/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (clk, rst, readAddr, instr, PC_2, err);

input clk, rst;
input [15:0] readAddr;
output [15:0] instr, PC_2;
output err;

wire err_PC_2;
// TODO: Your code here
memory2c IF_memory2c(.clk(clk), .rst(rst), .addr(readAddr), .data_out(instr), 
                     .enable(1'b1), .wr(1'b0), .createdump(1'b0), .data_in());
 
cla_16b cla_PC_2   (.A(readAddr), .B(16'b10), .C_in(1'b0), .S(PC_2), .C_out(), .err(err_PC_2)); // PC + 2   

assign err = (^readAddr == 1'bx) | err_PC_2;

endmodule
