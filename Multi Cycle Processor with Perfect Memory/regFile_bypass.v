/*
   CS/ECE 552, Spring '22
   Homework #3, Problem #2
  
   This module creates a wrapper around the 8x16b register file, to do
   do the bypassing logic for RF bypassing.
*/
module regFile_bypass (
                       // Outputs
                       read1Data, read2Data, err,
                       // Inputs
                       clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                       );
   input        clk, rst;
   input [2:0]  read1RegSel;
   input [2:0]  read2RegSel;
   input [2:0]  writeRegSel;
   input [15:0] writeData;
   input        writeEn;

   output reg [15:0] read1Data;
   output reg [15:0] read2Data;
   output        err;

   wire [15:0] data1;
   wire [15:0] data2;
   wire read1cond, read2cond;

   regFile iregFile0 (  // Outputs
                	.read1Data(data1), .read2Data(data2), .err(err),
                	// Inputs
                	.clk(clk), .rst(rst), .read1RegSel(read1RegSel), .read2RegSel(read2RegSel), 
			.writeRegSel(writeRegSel), .writeData(writeData), .writeEn(writeEn)
   );

   and iAND1 (read1cond, (read1RegSel == writeRegSel), writeEn);
   and iAND2 (read2cond, (read2RegSel == writeRegSel), writeEn);
  
   always @ (*) begin
        case(read1cond)
	     1'b1: read1Data = writeData;
	     1'b0: read1Data =  data1;
	endcase
   end
   always @ (*) begin
	case(read2cond)
	     1'b1: read2Data = writeData;
	     1'b0: read2Data = data2;
	endcase
   end
   
endmodule
