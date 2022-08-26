/*
   CS/ECE 552, Spring '22
   Homework #3, Problem #1
  
   This module creates a 16-bit register.  It has 1 write port, 2 read
   ports, 3 register select inputs, a write enable, a reset, and a clock
   input.  All register state changes occur on the rising edge of the
   clock. 
*/
module regFile (
                // Outputs
                read1Data, read2Data, err,
                // Inputs
                clk, rst, read1RegSel, read2RegSel, writeRegSel, writeData, writeEn
                );

   parameter REGWIDTH = 16;

   input        clk, rst;
   input [2:0]  read1RegSel;
   input [2:0]  read2RegSel;
   input [2:0]  writeRegSel;
   input [REGWIDTH - 1:0] writeData;
   input writeEn;

   output reg [REGWIDTH - 1:0] read1Data;
   output reg [REGWIDTH - 1:0] read2Data;
   output reg err;

   reg [REGWIDTH - 1:0] data_in [0:7];
   wire [REGWIDTH - 1:0] data_out [0:7];

   dff ireg0 [REGWIDTH - 1:0] (.d(data_in[0]), .q(data_out[0]), .clk(clk), .rst(rst));
   dff ireg1 [REGWIDTH - 1:0] (.d(data_in[1]), .q(data_out[1]), .clk(clk), .rst(rst));
   dff ireg2 [REGWIDTH - 1:0] (.d(data_in[2]), .q(data_out[2]), .clk(clk), .rst(rst));
   dff ireg3 [REGWIDTH - 1:0] (.d(data_in[3]), .q(data_out[3]), .clk(clk), .rst(rst));
   dff ireg4 [REGWIDTH - 1:0] (.d(data_in[4]), .q(data_out[4]), .clk(clk), .rst(rst));
   dff ireg5 [REGWIDTH - 1:0] (.d(data_in[5]), .q(data_out[5]), .clk(clk), .rst(rst));
   dff ireg6 [REGWIDTH - 1:0] (.d(data_in[6]), .q(data_out[6]), .clk(clk), .rst(rst));
   dff ireg7 [REGWIDTH - 1:0] (.d(data_in[7]), .q(data_out[7]), .clk(clk), .rst(rst));

   always @(*) begin
      case(read1RegSel)
      	3'b000: read1Data = data_out[0];
        3'b001: read1Data = data_out[1];
	3'b010: read1Data = data_out[2];
        3'b011: read1Data = data_out[3];
	3'b100: read1Data = data_out[4];
        3'b101: read1Data = data_out[5];
	3'b110: read1Data = data_out[6];
        3'b111: read1Data = data_out[7];
      endcase
  end
     
  always @(*) begin
      case(read2RegSel)
      	3'b000: read2Data = data_out[0];
        3'b001: read2Data = data_out[1];
	3'b010: read2Data = data_out[2];
        3'b011: read2Data = data_out[3];
	3'b100: read2Data = data_out[4];
        3'b101: read2Data = data_out[5];
	3'b110: read2Data = data_out[6];
        3'b111: read2Data = data_out[7];
      endcase
  end
  
  always @(*) begin
    case(rst) 
      1'b1: begin	    
      data_in[0] = 16'b0;
      data_in[1] = 16'b0;
      data_in[2] = 16'b0;
      data_in[3] = 16'b0;
      data_in[4] = 16'b0;
      data_in[5] = 16'b0;
      data_in[6] = 16'b0;
      data_in[7] = 16'b0;
      err = 1'b0;
      end
    endcase
  end
  
  always @(*) begin
    err = (^writeData === 1'bx | writeEn === 1'bx);// | ^writeData === 1'bz | writeEn === 1'bz)
      //err = 1'b1;
	case(writeRegSel)
	      	3'b000: data_in[0] = (writeEn & ~rst) ? writeData : data_in[0];
		3'b001: data_in[1] = (writeEn & ~rst) ? writeData : data_in[1];
		3'b010: data_in[2] = (writeEn & ~rst) ? writeData : data_in[2];
		3'b011: data_in[3] = (writeEn & ~rst) ? writeData : data_in[3];
		3'b100: data_in[4] = (writeEn & ~rst) ? writeData : data_in[4];
		3'b101: data_in[5] = (writeEn & ~rst) ? writeData : data_in[5];
		3'b110: data_in[6] = (writeEn & ~rst) ? writeData : data_in[6];
		3'b111: data_in[7] = (writeEn & ~rst) ? writeData : data_in[7];
        endcase
  end

endmodule
