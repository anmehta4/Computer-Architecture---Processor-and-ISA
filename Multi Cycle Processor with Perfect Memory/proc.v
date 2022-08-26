`default_nettype none
/* $Author: sinclair $ */
/* $LastChangedDate: 2020-02-09 17:03:45 -0600 (Sun, 09 Feb 2020) $ */
/* $Rev: 46 $ */
module proc (/*AUTOARG*/
   // Outputs
   err, 
   // Inputs
   clk, rst
   );

   input wire clk;
   input wire rst;

   output wire err;

   // None of the above lines can be modified

   // OR all the err ouputs for every sub-module and assign it as this
   // err output
   
   // As desribed in the homeworks, use the err signal to trap corner
   // cases that you think are illegal in your statemachines
   wire f_err, d_err, e_err, m_err, w_err;
   wire [15:0] instr;
   wire [15:0] PC, PCval, PCstall;
   wire [2:0] read1RegSel;
   wire [2:0] read2RegSel;
   wire [15:0] imm, read1Data, read2Data, writeData;
   wire extSel, isBr, isSet, memWrite, memRead, regWriteEn, memToReg, halt, invB;
   wire [1:0] immSel, brFlag, setFlag, ALUSelA, ALUSelB, finPC, writeDataSel;
   wire [2:0] writeRegSel;
   wire [1:0] PCSel;
   wire [3:0] ALUOp;
   wire Z, N, P, CO, signA, signB;
   wire [15:0] ALUresult, newPC, PC_2, PC_2_I;
   wire [15:0] memResult;

   wire [47:0] 	ifid;
   wire [134:0] idex;
   wire [189:0] exmem;
   wire [206:0] memwb;
  
   wire [47:0]  d_ifid;
   wire [134:0] d_idex;
   wire [189:0] d_exmem;
   wire [206:0] d_memwb;

   wire [15:0] idex_read1Data, idex_read2Data;

   assign d_ifid = (ifid[47:45]==3'b011 | ifid[47:45]==3'b001 | ifid[47:43]==5'b10001 | 
	   	    idex[134:132]==3'b011 | idex[134:132]==3'b001) ? {16'h0800, PC, PC_2} :{instr, PC, PC_2};
   assign d_idex = {ifid, read1RegSel, read2RegSel, imm, extSel, isBr, isSet,
            		memWrite, memRead, immSel, brFlag, setFlag, ALUSelA, ALUSelB, memToReg,
            		finPC, writeDataSel, writeRegSel, ALUOp, PCSel, halt, read1Data,
            		read2Data, d_err, invB, regWriteEn};
   assign d_exmem = {{idex[134:35], {idex_read1Data, idex_read2Data}, idex[2:0]}, ALUresult, PC_2_I, PCval, signA, signB,
            		N, Z, P, CO, e_err}; 
   assign d_memwb = {memResult, m_err, exmem}; 

   wire rst_1;
   dff ireg0 [15:0] (.d(PCstall), .q(PC), .clk(clk), .rst(rst));
   dff rst_d (.d(rst), .q(rst_1), .clk(clk), .rst(1'b0));

   dff IF_ID [47:0] (.d(d_ifid), .q(ifid), .clk(clk), .rst(rst));
   dff ID_EX [134:0] (.d(d_idex), .q(idex), .clk(clk), .rst(rst_1));
   dff EX_MEM [189:0] (.d(d_exmem), .q(exmem), .clk(clk), .rst(rst));
   dff MEM_WB [206:0] (.d(d_memwb), .q(memwb), .clk(clk), .rst(rst));


   fetch fetch0(//Inputs
   		.clk(clk), .rst(rst), .readAddr(PC),
		//Outputs
		.instr(instr), .PC_2(PC_2), .err(f_err)); 
   
   decode decode0(
   		//Inputs
		.clk(clk), .rst(rst), .rst_1(rst_1), .instr(ifid[47:32]/*ifid_instr*/), .writeData(writeData), 
		.wb_regWriteEn(memwb[55]), .wb_writeRegSel(memwb[99:97]),

		//Outputs
 		.read1RegSel(read1RegSel), .read2RegSel(read2RegSel), .imm(imm),
		.extSel(extSel), .isBr(isBr), .isSet(isSet), .memWrite(memWrite),
		.memRead(memRead), .immSel(immSel), .brFlag(brFlag), .setFlag(setFlag), 
		.ALUSelA(ALUSelA), .ALUSelB(ALUSelB), .memToReg(memToReg), .finPC(finPC), 
		.writeDataSel(writeDataSel), .writeRegSel(writeRegSel), .ALUOp(ALUOp),
	       	.PCSel(PCSel), .halt(halt), .read1Data(read1Data), .read2Data(read2Data), 
		.err(d_err), .invB(invB), .regWriteEn(regWriteEn));

   execute execute0(
	   	//Inputs
		.imm(idex[80:65]), .PC(idex[118:103]), .PC_2(idex[102:87]), .read1Data(idex_read1Data), .read2Data(idex_read2Data), 
		.ALUOp(idex[41:38]), .ALUSelA(idex[53:52]), .ALUSelB(idex[51:50]), .brFlag(idex[57:56]), .PCSel(idex[37:36]),
		.isBr(idex[63]), .invB(idex[1]), .finPC(idex[48:47]), .isSet(idex[62]), .setFlag(idex[55:54]),
		//Outputs
		.ALUresult(ALUresult), .PC_2_I(PC_2_I), .PCval(PCval),
		.signA(signA), .signB(signB), .err(e_err),
	        .N(N), .Z(Z), .P(P), .CO(CO));

   memory memory0(
	   	//Inputs
		.clk(clk), .rst(rst), .ALUresult(exmem[54:39]), .read2Data(exmem[73:58]),
		.memRead(exmem[115]), .memWrite(exmem[116]), .halt(exmem[90]),
		//Outputs
		.memResult(memResult), .err(m_err));

   wb wb0(	//Inputs
		.ALUresult(memwb[54:39]), .memResult(memwb[206:191]), .read2Data(memwb[73:58]),
		.setFlag(memwb[110:109]), .writeDataSel(memwb[101:100]), .memToReg(memwb[104]),
		.signA(memwb[6]), .signB(memwb[5]), .isSet(memwb[117]), .PC_2(memwb[157:142]),
	  	.N(memwb[4]), .Z(memwb[3]), .P(memwb[2]), .CO(memwb[1]),
		//Outputs
		.writeData(writeData), .err(w_err));

    

   assign idex_read1Data = (exmem[55] &(exmem[99:97] == idex[86:84]) & (exmem[189:185]!=5'b10001))? exmem[54:39] : 
	                    (memwb[55] & (memwb[99:97] == idex[86:84])) ? writeData ://memwb[54:39] :
			     idex[34:19];

   assign idex_read2Data =  (exmem[55] &( exmem[99:97] == idex[83:81])) ? exmem[54:39] :
	   		    (memwb[55] & (memwb[99:97] == idex[83:81])) ? writeData :
			     idex[18:3];
   /* 
   assign PCstall = (ifid[47:45]==3'b011 | ifid[47:45]==3'b001 |
                     idex[134:132]==3'b011 | idex[134:132]==3'b001) ? PC :
		    (exmem[189:187]==3'b001 | exmem[189:187]==3'b011) ? PCval :  PC_2;//stallidex? PC : PC_2;
   */
   assign PCstall = (ifid[47:45] == 3'b011 | ifid[47:45]==3'b001 | ifid[47:43]==5'b10001) ? PC :
	   	    (idex[134:132]==3'b011 | idex[134:132]==3'b001) ? PCval : PC_2;
   assign err = 1'b0;//f_err | d_err | x_err | m_err | w_err;
   
endmodule // proc
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
