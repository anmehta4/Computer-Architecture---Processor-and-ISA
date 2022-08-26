/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (ALUOp, ALUresult, ALUSelA, ALUSelB, N, Z, P, CO, imm, PC, invB, 
		brFlag, isBr, PCSel, newPC, PC_2, read1Data, read2Data, err, signA, signB);

input[15:0] imm, PC, read1Data, read2Data;
input invB;
input [1:0] ALUSelA, ALUSelB;
input [3:0] ALUOp;
input [1:0] brFlag, PCSel;
input isBr;

output [15:0] ALUresult, newPC, PC_2;
output N, Z, P, CO, err, signA, signB;

wire [15:0] PC_2_I, PC_Br, PC_Br_temp, ALUsrcA, ALUtmpB, ALUsrcB;

assign ALUsrcA = (ALUSelA==2'b00) ? imm : 
		 (ALUSelA==2'b01) ? read1Data : read2Data;

assign ALUtmpB = (ALUSelB == 2'b00) ? 16'b0 :
		 (ALUSelB == 2'b01) ? imm :
		 (ALUSelB == 2'b10) ? read1Data : read2Data;
assign ALUsrcB = invB ? ~ALUtmpB : ALUtmpB;

assign signA = ALUsrcA[15];
assign signB = ALUsrcB[15];

alu_hier alu_hier1 (.Oper(ALUOp), .ALUsrcA(ALUsrcA), .ALUsrcB(ALUsrcB), 
		    .ALUresult(ALUresult), .N(N), .Z(Z), .P(P), .CO(CO)); 


cla_16b cla_PC_2   (.A(PC), .B(16'b10), .C_in(1'b0), .S(PC_2), .C_out(C_out), .err(err)); // PC + 2
cla_16b cla_PC_2_I (.A(PC_2), .B(imm), .C_in(1'b0), .S(PC_2_I), .C_out(C_out), .err(err));// PC + I

assign PC_Br_temp =   (brFlag == 2'b00 & Z)   ? PC_2_I : 
		      (brFlag == 2'b01 & ~Z)  ? PC_2_I :
                      (brFlag == 2'b10 & N)   ? PC_2_I :
		      (brFlag == 2'b11 & (Z|P)) ? PC_2_I : PC_2;

assign PC_Br = isBr? PC_Br_temp : PC_2;

assign newPC =  (PCSel == 2'b00) ? ALUresult :
	        (PCSel == 2'b01) ? PC_Br :
		(PCSel == 2'b10) ? PC_2 : PC_2_I;

assign err = (^ALUSelA == 1'bx | ^ALUSelB == 1'bx | ^ALUOp == 1'bx |
	      ^imm == 1'bx | ^PC == 1'bx);
			

// TODO: Your code here
   
endmodule
