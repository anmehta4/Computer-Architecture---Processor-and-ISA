/*
   CS/ECE 552 Spring '20
  
   Filename        : wb.v
   Description     : This is the module for the overall Write Back stage of the processor.
*/
module wb (isSet, setFlag, N, Z, P, CO, ALUresult, memResult, 
	   memToReg, read2Data, writeDataSel, writeData, 
	   signA, signB, err, PC_2);

input isSet, N, Z, P, CO, memToReg, signA, signB;
input [1:0] setFlag, writeDataSel;
input [15:0] ALUresult, memResult, read2Data, PC_2;
output [15:0] writeData;
output err;

wire [15:0] writeData_1;
wire [15:0] writeData_2_same, writeData_2_diff;

assign err = (isSet==1'bx | memToReg==1'bx | ^setFlag == 1'bx | ^writeDataSel == 1'bx);

assign writeData_1 = memToReg ? memResult : ALUresult;
assign writeData_2_same = isSet ?((setFlag == 2'b00 & Z)   ? 16'b1 : 
		      	     (setFlag == 2'b01 & N)   ? 16'b1 :
                             (setFlag == 2'b10 & (N|Z)) ? 16'b1 :
		             (setFlag == 2'b11 & CO)  ? 16'b1 : 16'b0) : 16'b0;

assign writeData_2_diff = isSet? ((setFlag == 2'b00) ? 16'b0 :
				  (setFlag == 2'b01) ? {15'b0, signA} :
				  (setFlag == 2'b10) ? {15'b0, signA} :
				  (setFlag == 2'b11 & CO) ? 16'b1: 16'b0) : 16'b0;

assign writeData_2 = (signA == signB) ? writeData_2_same : writeData_2_diff;

assign writeData = (writeDataSel == 2'b00) ? PC_2 :
		   (writeDataSel == 2'b01) ? writeData_1 :
		   (writeDataSel == 2'b10) ? writeData_2 : 16'b0;

endmodule
