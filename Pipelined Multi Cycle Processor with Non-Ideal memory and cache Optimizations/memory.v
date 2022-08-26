/*
   CS/ECE 552 Spring '20
  
   Filename        : memory.v
   Description     : This module contains all components in the Memory stage of the 
                     processor.
*/
module memory (clk, rst, ALUresult, memResult, read2Data, memWrite, memRead, halt, err, err_mem, stall_mem);

input [15:0] ALUresult, read2Data;
input clk, rst, memRead, memWrite, halt;
output [15:0] memResult;
output err;
output err_mem;
output stall_mem;

wire enable;
assign enable = (halt)? 1'b0 : memWrite|memRead;

assign err = (memRead == 1'bx | memWrite == 1'bx | halt == 1'bx);

//memory2c_align memory2c(.clk(clk), .rst(rst), .addr(ALUresult), .data_out(memResult), 
 //                 .enable(enable), .wr(memWrite), .createdump(1'b1), .data_in(read2Data), .err(err_mem));
wire Done, stall;
//assign stall_mem = ~Done;
assign stall_mem = stall & ~Done;
mem_system #(.memtype(1)) memory2c(.DataOut(memResult), .Done(Done), .Stall(stall), .CacheHit(), .err(err_mem), .Addr((memRead|memWrite) ? ALUresult: 16'h0), 
	   .DataIn(read2Data), .Rd(memRead), .Wr(memWrite), .createdump(1'b1), .clk(clk), .rst(rst));
 
endmodule
