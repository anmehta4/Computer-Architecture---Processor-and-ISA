/*
    CS/ECE 552 Spring '22
    Homework #2, Problem 2

    A multi-bit ALU module (defaults to 16-bit). It is designed to choose
    the correct operation to perform on 2 multi-bit numbers from rotate
    left, shift left, shift right arithmetic, shift right logical, add,
    or, xor, & and.  Upon doing this, it should output the multi-bit result
    of the operation, as well as drive the output signals Zero and Overflow
    (OFL).
*/
module alu (ALUsrcA, ALUsrcB, Oper, ALUresult, N, Z, P, CO);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 4;
       
    input  [OPERAND_WIDTH -1:0] ALUsrcA ; // Input operand A
    input  [OPERAND_WIDTH -1:0] ALUsrcB ; // Input operand B
    input  [NUM_OPERATIONS-1:0] Oper; // Operation type
  
    output [OPERAND_WIDTH -1:0] ALUresult;
    output N, Z, P, CO;


    wire [OPERAND_WIDTH -1:0] Out_Sum, A, B;
    wire Cin, Cout;

    assign A   =  ALUsrcA;
    assign B   = (Oper == 4'b0001) ? ~ALUsrcB : ALUsrcB;
    assign Cin = (Oper == 4'b0001) ? 1'b1 : 1'b0;
    cla_16b iCLA1(.A(A), .B(B), .C_in(Cin), .S(Out_Sum), .C_out(Cout), .err());

    wire [OPERAND_WIDTH -1:0] Out_Shift; 
    shifter_hier iSHIFT1 (.In(A), .ShAmt(B[3:0]), .Oper(Oper[1:0]), .Out(Out_Shift));
    
    wire [OPERAND_WIDTH -1:0] Out_Xor, Out_And; 
    assign Out_And = ALUsrcA & ALUsrcB;
    assign Out_Xor = ALUsrcA ^ ALUsrcB;

    wire [OPERAND_WIDTH -1:0] Out_Btr, Out_Slbi;
    assign Out_Btr = {ALUsrcA[0], ALUsrcA[1], ALUsrcA[2], ALUsrcA[3], ALUsrcA[4], ALUsrcA[5],
		     ALUsrcA[6], ALUsrcA[7], ALUsrcA[8], ALUsrcA[9], ALUsrcA[10], ALUsrcA[11],
		     ALUsrcA[12], ALUsrcA[13], ALUsrcA[14], ALUsrcA[15]};
    
    assign Out_Slbi = {ALUsrcA[7: 0], {8{1'b0}}} | ALUsrcB;

    // Assigning out based on opcode
    assign ALUresult =  (~Oper[3] & ~Oper[2] & ~Oper[1] & ~Oper[0]) ? Out_Sum :
 			(~Oper[3] & ~Oper[2] & ~Oper[1] &  Oper[0]) ? Out_Sum :
			(~Oper[3] & ~Oper[2] & Oper[1] & ~Oper[0]) ? Out_Xor :
			(~Oper[3] & ~Oper[2] & Oper[1] &  Oper[0]) ? Out_And : 
                        (~Oper[3] &  Oper[2]) ? Out_Shift :
                        (Oper[0]) ? Out_Slbi : Out_Btr;

    assign CO = Cout;
    assign N = ALUresult[15];
    assign Z = ~|ALUresult;
    assign P = ~N;

endmodule
