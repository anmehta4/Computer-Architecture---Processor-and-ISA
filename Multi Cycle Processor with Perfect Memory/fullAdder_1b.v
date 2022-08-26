/*
   CS/ECE 552 Spring '20
   Homework #1, Problem 2
    
   a 1-bit full adder
*/
module fullAdder_1b(A, B, C_in, S, C_out, err);
   input  A, B;
   input  C_in;
   output S;
   output C_out;
   output err;

   // intermediate wires
   wire   wire1, wire2, wire3, wire4, wire5, wire6, wire7, wire8;

   /*
    Creating a 1 bit Full Adder using nand gates. You are free
    to use any combination of the gates mentioned in the question.
    */
   nand2 inst1 (.in1(A),     .in2(B),     .out(wire1));     
   nand2 inst2 (.in1(wire1), .in2(A),     .out(wire2));
   nand2 inst3 (.in1(wire1), .in2(B),     .out(wire3));
   nand2 inst4 (.in1(wire2), .in2(wire3), .out(wire4));
   nand2 inst5 (.in1(wire4), .in2(C_in),  .out(wire5));
   nand2 inst6 (.in1(wire5), .in2(wire4), .out(wire6));
   nand2 inst7 (.in1(wire5), .in2(C_in),  .out(wire7));
   nand2 inst8 (.in1(wire6), .in2(wire7), .out(S));
   nand2 inst9 (.in1(wire1), .in2(wire5), .out(C_out));

   // currently no known error cases
   assign      err = 1'b0;

endmodule
