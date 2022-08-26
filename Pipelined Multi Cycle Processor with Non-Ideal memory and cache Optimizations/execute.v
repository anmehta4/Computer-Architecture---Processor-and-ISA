/*
   CS/ECE 552 Spring '20
  
   Filename        : execute.v
   Description     : This is the overall module for the execute stage of the processor.
*/
module execute (ALUOp, ALUresult, ALUSelA, ALUSelB, N, Z, P, CO, imm, PC, invB, PCval, finPC, isSet, 
		brFlag, isBr, PCSel, PC_2, PC_2_I, read1Data, read2Data, err, signA, signB, setFlag);

input[15:0] imm, PC, read1Data, read2Data, PC_2;
input invB;
input [1:0] ALUSelA, ALUSelB;
input [3:0] ALUOp;
input [1:0] brFlag, setFlag, PCSel, finPC;
input isBr, isSet;

output [15:0] ALUresult, PC_2_I, PCval;
output N, Z, P, CO, err, signA, signB;

wire [15:0] PC_Br, PC_Br_temp, ALUsrcA, ALUtmpB, ALUsrcB, newPC, ALUresult_1;

assign ALUsrcA = (ALUSelA==2'b00) ? imm : 
		 (ALUSelA==2'b01) ? read1Data : read2Data;

assign ALUtmpB = (ALUSelB == 2'b00) ? 16'b0 :
		 (ALUSelB == 2'b01) ? imm :
		 (ALUSelB == 2'b10) ? read1Data : read2Data;
assign ALUsrcB = invB ? ~ALUtmpB : ALUtmpB;

assign signA = ALUsrcA[15];
assign signB = ALUsrcB[15];

alu_hier alu_hier1 (.Oper(ALUOp), .ALUsrcA(ALUsrcA), .ALUsrcB(ALUsrcB), 
		    .ALUresult(ALUresult_1), .N(N), .Z(Z), .P(P), .CO(CO)); 

wire [15:0] writeData_2;
wire [15:0] writeData_2_same, writeData_2_diff;

assign writeData_2_same = isSet ?((setFlag == 2'b00 & Z)   ? 16'b1 :
                             (setFlag == 2'b01 & N)   ? 16'b1 :
                             (setFlag == 2'b10 & (N|Z)) ? 16'b1 :
                             (setFlag == 2'b11 & CO)  ? 16'b1 : 16'b0) : 16'b0;

assign writeData_2_diff = isSet? ((setFlag == 2'b00) ? 16'b0 :
                                  (setFlag == 2'b01) ? {15'b0, signA} :
                                  (setFlag == 2'b10) ? {15'b0, signA} :
                                  (setFlag == 2'b11 & CO) ? 16'b1: 16'b0) : 16'b0;

assign writeData_2 = (signA == signB) ? writeData_2_same : writeData_2_diff;

assign ALUresult = isSet ? writeData_2 : ALUresult_1;

cla_16b cla_PC_2_I (.A(PC_2), .B(imm), .C_in(1'b0), .S(PC_2_I), .C_out(C_out), .err(err));// PC + I

assign PC_Br_temp =   (brFlag == 2'b00 & Z)   ? PC_2_I : 
		      (brFlag == 2'b01 & ~Z)  ? PC_2_I :
                      (brFlag == 2'b10 & N)   ? PC_2_I :
		      (brFlag == 2'b11 & (Z|P)) ? PC_2_I : PC_2;

assign PC_Br = isBr? PC_Br_temp : PC_2;

assign newPC =  (PCSel == 2'b00) ? ALUresult :
                (PCSel == 2'b01) ? PC_Br :
                (PCSel == 2'b10) ? PC_2 : PC_2_I;

assign PCval = (finPC == 2'b00) ? newPC :
               (finPC == 2'b01) ? 16'h0002 :
               (finPC == 2'b10) ? PC: 16'b0;

assign err = (^ALUSelA == 1'bx | ^ALUSelB == 1'bx | ^ALUOp == 1'bx |
	      ^imm == 1'bx | ^PC == 1'bx);
			

// TODO: Your code here
   
endmodule
