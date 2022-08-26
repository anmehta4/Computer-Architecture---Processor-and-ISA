/*
    CS/ECE 552 Spring '20
    Homework #1, Problem 2
    
    a 1-bit full adder testbench
*/
module fullAdder_tb();
   reg  A, B;
   reg  C_in;
   reg[1:0] Sum_golden; // extra bit for C_out golden
   wire S;
   wire C_out;
   wire        Clk;
   //2 dummy wires
   wire 	   rst;
   wire 	   err;

   clkrst my_clkrst( .clk(Clk), .rst(rst), .err(err));
   fullAdder_1b dut_inst (.A(A), .B(B), .C_in(C_in), .S(S), .C_out(C_out));

   initial begin
      A = 1'b0;
      B = 1'b0;
      C_in = 1'b0;
	  #3200 $finish;
   end

   always@(posedge Clk) begin
      A = $random;
      B = $random;
      C_in = $random;
   end

   always@(negedge Clk) begin
      Sum_golden = A+B+C_in;
      $display("A: %x, B: %x, Sum: %x, Golden Sum: %x, Carry out: %x, Golden Carry out: %x", A, B, S, Sum_golden[0], C_out, Sum_golden[1]);

      if (Sum_golden[0] !== S) $display ("ERRORCHECK Sum error");
      if (Sum_golden[1] !== C_out) $display ("ERRORCHECK CO error");
   end
endmodule
