/*
   CS/ECE 552 Spring '20
  
   Filename        : decode.v
   Description     : This is the module for the overall decode stage of the processor.
*/
module decode (clk, rst, rst_1, instr, immSel, extSel, ALUOp, wb_regWriteEn,
	       read1RegSel, read2RegSel, writeRegSel, imm, isBr, brFlag,
	       PCSel, memToReg, memRead, memWrite, ALUSelA, ALUSelB,	
	       isSet, setFlag, finPC, writeDataSel, regWriteEn, halt,
	       read1Data, read2Data, writeData, err, invB, wb_writeRegSel);

input clk, rst, rst_1;
input [15:0] instr, writeData;
input wb_regWriteEn;
input [2:0] wb_writeRegSel;

output [2:0] read1RegSel;
output [2:0] read2RegSel;
output [15:0] imm, read1Data, read2Data;

output extSel, isBr, isSet, memWrite, memRead, regWriteEn, memToReg, halt, err, invB;
output [1:0] immSel, brFlag, setFlag, ALUSelA, ALUSelB, finPC, writeDataSel;
output [2:0] writeRegSel; 
output [1:0] PCSel;
output [3:0] ALUOp;

wire regFile_err;
wire [1:0] writeRegSelMux;
wire [4:0] op;
wire [1:0] func;
assign op = {instr[15], instr[14], instr[13], instr[12], instr[11]};
assign func = {instr[1], instr[0]};

assign isBr =  (~op[4] & op[3] & op[2]);
assign isSet =  (op[4] & op[3] & op[2]);
assign brFlag = {op[1], op[0]};
assign setFlag = {op[1], op[0]};

assign ALUOp = (op == 5'b11111) ? 4'b0000 :				//Set CO						(1)
               (op == 5'b11001) ? 4'b1000 :				//BTR							(1)
               (op == 5'b11010) ? {2'b01, func}:			//Barrel Shifter with 1 and then remaining bits is func (4)
               (op == 5'b11011) ? {2'b00, func}:		  	//CLA and ALU with 0 and then remaining bits as func	(4)
               (op == 5'b10010) ? 4'b1001 :				//SLBI RS<< 8 | I					(1)
               (op == 5'b11000) ? 4'b0000 : 				//Add Rs with 0						(1)
               (~op[4] & ~op[3] & op[2]) ? 4'b0000 :			//Rs + I						(4)
               (op[4] & ~op[3] & op[2]) ? {2'b01, op[1:0]} : 		//Barrel Shifter 					(4)      		  
               (~op[4] & op[3] & ~op[2]) ? {2'b00, op[1:0]} :		//CLA and ALU						(4)	  						 (1)
               (op[3] & op[2]) ? 4'b0001 :  	 	  		//Branch or set (except CO) condition so subtract with 0(7)
               (op[4] & ~op[3]& ~op[2]) ? 4'b0000 : 4'b0000;		//ST and LD						(3)
               
                   
assign writeRegSelMux = (op == 5'b11000 | op == 5'b10010 | op == 5'b10011) ? 2'b00:
			((~op[4] & op[3] & ~op[2])|(op[4] & ~op[3] & op[2]) | (op==5'b10001)) ? 2'b01 :
                        (op[4] & op[3]) ? 2'b10 :
                        (~op[4] & ~op[3] & op[2] & op[1]) ? 2'b11 : 2'b00;

assign PCSel = (~op[4] & op[3] & op[2]) ? 2'b01 : //Branch Instruction Output
               (~op[4] & ~op[3] & op[2] & op[0]) ? 2'b00 : // RS + I
	       (~op[4] & ~op[3] & op[2] & ~op[0]) ? 2'b11: 2'b10; // PC+2+I else PC + 2
                
assign finPC = (op == 5'b00000) ? 2'b10 : //NOP so hold PC
	       (op == 5'b00011) ? 2'b01 : 2'b00; // PC <- EPC else take the PCSel Output
                	

assign ALUSelA = (op == 5'b01001 | op==5'b11000) ? 2'b00 : // Rt for sub rt - rs so 2 
		 (op == 5'b11011 & func == 2'b01) ? 2'b10 : 2'b01; // 0:Imm for I - Rs and Rs<-I+0 in LBI else always 1:Reg

assign invB = (op==5'b01011 | (op==5'b11011 & func==2'b11)) ? 1'b1 : 1'b0;

assign ALUSelB = (op == 5'b01001 | (op==5'b11011 & func==2'b01)) ? 2'b10 : //RS
                 ((op[4] & ~op[3])| (~op[4] & op[3] & ~op[2]) | (~op[4] & ~op[3] & op[2] & op[0])) ? 2'b01 : //Immediate
		 ((~op[4] & op[3] & op[2]) | (op==5'b11000)) ? 2'b00 : 2'b11; //0 for set and Rs<-I else Rt

assign memRead = (op == 5'b10001) ? 1'b1 : 1'b0; //Only for LD

assign memWrite = (op == 5'b10000 | op == 5'b10011) ? 1'b1 : 1'b0; // Only for 2 st instructions
  
assign memToReg = (op == 5'b10001) ? 1'b1 : 1'b0; //Only for Load else ALU result

assign writeDataSel = (op[4] & op[3] & op[2]) ? 2'b10 : //Set output for writing to Rd
		      (~op[4] & ~op[3] & op[2] & op[1]) ? 2'b00 : 2'b01; //output from memToRegMux  

//If function is store or branch or J/JR or HALT or NOP then regWrite is 0
assign regWriteEn =  ((op==5'b10000)|(op==5'b00000)|(op==5'b00001) | (~op[4] & op[3] & op[2])
		     | (~op[4] & ~op[3] & op[2] & ~op[1])) ? 1'b0 : 1'b1;     
               
assign immSel = (~op[4] & ~op[3] & op[2] & ~op[0]) ? 2'b10 :
                ((~op[4] & ~op[3] & op[2]) | (~op[4] & op[3] & op[2]) | (op==5'b10010) | (op==5'b11000)) ? 2'b01 : 2'b00;

//If xor or and with I or if SLBI then zero extend else sign extend
assign extSel = ((~op[4] & op[3] & ~op[2] & op[1]) | (op == 5'b10010)) ? 1'b0 : 1'b1;

assign halt = (op==5'b00000) & ~rst_1; //If opcode is a Halt assert halt signal

assign read1RegSel = instr[10:8];
assign read2RegSel = instr[7:5];
assign writeRegSel = writeRegSelMux == 2'b01 ? read2RegSel :
		     writeRegSelMux == 2'b10 ? {instr[4:2]} :
		     writeRegSelMux == 2'b11 ? 3'b111 : read1RegSel ;

assign imm = (immSel == 2'b00) ? ( extSel ? {{11{instr[4]}}, instr[4:0]} : 
                                {{11{1'b0}}, instr[4:0]}) :
	     (immSel == 2'b01) ? ( extSel ? {{8{instr[7]}}, instr[7:0]} :
				{{8{1'b0}}, instr[7:0]}) :
 	     (immSel == 2'b10) ? ( extSel ? {{5{instr[10]}}, instr[10:0]} :
                                {{5{1'b0}}, instr[10:0]}) : 0;

assign err = (^ALUOp == 1'bx | ^instr == 1'bx);

regFile_bypass regFile0(.read1Data(read1Data), .read2Data(read2Data), .clk(clk), .rst(rst),
               	      .read1RegSel(read1RegSel), .read2RegSel(read2RegSel), .err(regFile_err),
		      .writeRegSel(wb_writeRegSel), .writeData(writeData), .writeEn(wb_regWriteEn));
                               

endmodule
