/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input clk;
   input rst;

   output err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   
   wire f_err, d_err, x_err, m_err, w_err;
   wire [15:0] instr;
   wire [15:0] PC, PCval;
   dff ireg0 [15:0] (.d(PCval), .q(PC), .clk(clk), .rst(rst));

   fetch fetch0(.instr(instr), .readAddr(PC), .clk(clk), .rst(rst), .err(f_err));
   
   /*CONTROL SIGNALS*/
   wire [2:0] read1RegSel;
   wire [2:0] read2RegSel;
   wire [15:0] imm, read1Data, read2Data, writeData;

   wire extSel, isBr, isSet, memWrite, memRead, regWriteEn, memToReg, halt, invB;
   wire [1:0] immSel, brFlag, setFlag, ALUSelA, ALUSelB, finPC, writeDataSel;
   wire [2:0] writeRegSel; 
   wire [1:0] PCSel;
   wire [3:0] ALUOp;

   
   decode decode0(.clk(clk), .rst(rst), .instr(instr), 
 		.read1RegSel(read1RegSel), .read2RegSel(read2RegSel), .imm(imm),
		.extSel(extSel), .isBr(isBr), .isSet(isSet), .memWrite(memWrite),
		.memRead(memRead), .regWriteEn(regWriteEn), .immSel(immSel), 
		.brFlag(brFlag), .setFlag(setFlag), .ALUSelA(ALUSelA), .ALUSelB(ALUSelB), 
		.memToReg(memToReg), .finPC(finPC), .writeDataSel(writeDataSel),
	       	.writeRegSel(writeRegSel), .ALUOp(ALUOp), .PCSel(PCSel), .halt(halt),
		.read1Data(read1Data), .read2Data(read2Data), .writeData(writeData), .err(d_err), .invB(invB));

   
   /*ALU OUTPUTS*/
   wire Z, N, P, CO, signA, signB;
   wire [15:0] ALUresult, newPC, PC_2;
   execute execute0(.ALUOp(ALUOp), .ALUresult(ALUresult), .ALUSelA(ALUSelA), .ALUSelB(ALUSelB), .invB(invB),
			 .N(N), .Z(Z), .P(P), .CO(CO), .imm(imm), .PC(PC),  .brFlag(brFlag), .err(e_err), 
			 .isBr(isBr), .PCSel(PCSel), .newPC(newPC), .PC_2(PC_2), .read1Data(read1Data),
			.signA(signA), .signB(signB), .read2Data(read2Data));
   wire [15:0] memResult;
   memory memory0(.clk(clk), .rst(rst), .ALUresult(ALUresult), .memResult(memResult), .err(m_err),
		  .read2Data(read2Data), .memWrite(memWrite), .memRead(memRead), .halt(halt));

   
   wb wb0(.isSet(isSet), .setFlag(setFlag), .N(N), .Z(Z), .P(P), .CO(CO), .ALUresult(ALUresult), .memResult(memResult), 
	       .PC_2(PC_2), .memToReg(memToReg), .read2Data(read2Data), .writeDataSel(writeDataSel), .writeData(writeData),
	       .finPC(finPC), .newPC(newPC), .PC(PC), .PCval(PCval), .err(w_err), .signA(signA), .signB(signB));

  assign err = f_err | d_err | x_err | m_err | w_err;
   
   
endmodule // proc
// DUMMY LINE FOR REV CONTROL :0:
