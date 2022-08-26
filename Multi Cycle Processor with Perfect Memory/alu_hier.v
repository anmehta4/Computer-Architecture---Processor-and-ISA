/*
    CS/ECE 552 Spring '22
    Homework #2, Problem 2

    A wrapper for a multi-bit ALU module combined with clkrst.
*/
module alu_hier (ALUsrcA, ALUsrcB, Oper, ALUresult, N, Z, P, CO);

    parameter OPERAND_WIDTH = 16;    
    parameter NUM_OPERATIONS = 4;
       
    input  [OPERAND_WIDTH -1:0] ALUsrcA ; // Input operand A
    input  [OPERAND_WIDTH -1:0] ALUsrcB ; // Input operand B
    input  [NUM_OPERATIONS-1:0] Oper; // Operation type
  
    output [OPERAND_WIDTH -1:0] ALUresult;
    output N, Z, P, CO;

    // clkrst signals
    wire clk;
    wire rst;
    wire err;

    assign err = 1'b0;

    alu #(.OPERAND_WIDTH(OPERAND_WIDTH),
          .NUM_OPERATIONS(NUM_OPERATIONS)) 
        DUT (// Outputs
             .ALUsrcA(ALUsrcA),
             .ALUsrcB(ALUsrcB), 
             .Oper(Oper),
             // Inputs
             .ALUresult(ALUresult), 
             .N(N), 
             .Z(Z), 
             .P(P), 
             .CO(CO));
   
    clkrst c0(// Outputs
              .clk                       (clk),
              .rst                       (rst),
              // Inputs
              .err                       (err)
              );

endmodule // alu_hier
