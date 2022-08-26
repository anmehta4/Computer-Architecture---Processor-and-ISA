/*
    CS/ECE 552 Spring '22
    Homework #2, Problem 1
    
    A barrel shifter module.  It is designed to shift a number via rotate
    left, shift left, shift right arithmetic, or shift right logical based
    on the 'Oper' value that is passed in.  It uses these
    shifts to shift the value any number of bits.
 */
module shifter (In, ShAmt, Oper, Out);

    // declare constant for size of inputs, outputs, and # bits to shift
    parameter OPERAND_WIDTH = 16;
    parameter SHAMT_WIDTH   =  4;
    parameter NUM_OPERATIONS = 2;

    input  [OPERAND_WIDTH -1:0] In   ; // Input operand
    input  [SHAMT_WIDTH   -1:0] ShAmt; // Amount to shift/rotate
    input  [NUM_OPERATIONS-1:0] Oper ; // Operation type
    output [OPERAND_WIDTH -1:0] Out  ; // Result of shift/rotate

    wire [OPERAND_WIDTH - 1:0] stg1;
    wire [OPERAND_WIDTH - 1:0] stg2;
    wire [OPERAND_WIDTH - 1:0] stg3;

    assign stg1 = ShAmt[0]? ((Oper == 2'b00) ? {In[OPERAND_WIDTH - 1 - 1: 0], In[OPERAND_WIDTH - 1: OPERAND_WIDTH - 1]} :
		  	     (Oper == 2'b01) ? {In[OPERAND_WIDTH - 1 - 1: 0], {1{1'b0}}} :
		  	     (Oper == 2'b10) ? {In[0], In[OPERAND_WIDTH - 1: 1]} :
		  	     (Oper == 2'b11) ? {{1{1'b0}}, In[OPERAND_WIDTH - 1: 1]}: In) : In; 

    assign stg2 = ShAmt[1]? ((Oper == 2'b00) ? {stg1[OPERAND_WIDTH - 1 - 2: 0], stg1[OPERAND_WIDTH - 1: OPERAND_WIDTH - 2]} :
		    	     (Oper == 2'b01) ? {stg1[OPERAND_WIDTH - 1 - 2: 0], {2{1'b0}}} :
		  	     (Oper == 2'b10) ? {stg1[1:0], stg1[OPERAND_WIDTH - 1: 2]} :
		  	     (Oper == 2'b11) ? {{2{1'b0}}, stg1[OPERAND_WIDTH - 1: 2]}: stg1) : stg1;

    assign stg3 = ShAmt[2]? ((Oper == 2'b00) ? {stg2[OPERAND_WIDTH - 1 - 4: 0], stg2[OPERAND_WIDTH - 1: OPERAND_WIDTH - 4]} :
		  	     (Oper == 2'b01) ? {stg2[OPERAND_WIDTH - 1 - 4: 0], {4{1'b0}}} :
		  	     (Oper == 2'b10) ? {stg2[3:0], stg2[OPERAND_WIDTH - 1: 4]} :
		  	     (Oper == 2'b11) ? {{4{1'b0}}, stg2[OPERAND_WIDTH - 1: 4]}: stg2) : stg2; 

    assign Out  = ShAmt[3]? ((Oper == 2'b00) ? {stg3[OPERAND_WIDTH - 1 - 8: 0], stg3[OPERAND_WIDTH - 1: OPERAND_WIDTH - 8]} :
		             (Oper == 2'b01) ? {stg3[OPERAND_WIDTH - 1 - 8: 0], {8{1'b0}}} :
		             (Oper == 2'b10) ? {stg3[7:0], stg3[OPERAND_WIDTH - 1: 8]} :
		             (Oper == 2'b11) ? {{8{1'b0}}, stg3[OPERAND_WIDTH - 1: 8]}: stg3) : stg3;

endmodule
