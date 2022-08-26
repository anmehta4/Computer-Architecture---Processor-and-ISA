/*
   CS/ECE 552 Spring '20
  
   Filename        : fetch.v
   Description     : This is the module for the overall fetch stage of the processor.
*/
module fetch (clk, rst, readAddr, instr, PC_2, err, err_mem, stall_mem);

input clk, rst;
input [15:0] readAddr;
output [15:0] instr, PC_2;
output err;
output err_mem;
output stall_mem;

wire err_PC_2;
// TODO: Your code here
//assign stall_mem = 1'b0;
//memory2c_align IF_memory2c(.clk(clk), .rst(rst), .addr(readAddr), .data_out(instr), 
//                     .enable(1'b1), .wr(1'b0), .createdump(1'b0), .data_in(), .err(err_mem));
wire Done, stall;
assign stall_mem = stall & ~Done;
mem_system IF_memory2c(.DataOut(instr), .Done(Done), .Stall(stall), .CacheHit(), .err(err_mem), .Addr(readAddr),
                  .DataIn(), .Rd(1'b1), .Wr(1'b0), .createdump(1'b0), .clk(clk), .rst(rst));
 
cla_16b cla_PC_2   (.A(readAddr), .B(16'b10), .C_in(1'b0), .S(PC_2), .C_out(), .err(err_PC_2)); // PC + 2   

assign err = (^readAddr == 1'bx) | err_PC_2;

endmodule
