`default_nettype none
module controller (
              input wire clk,
              input wire rst,
              input wire valid0,
	      input wire valid1,
	      input wire hit0,
	      input wire hit1,
	      input wire dirty0,
	      input wire dirty1,
	      input wire memRead,
	      input wire memWrite,
              input wire [3:0] busy,

	      output reg hit_ans,
              output reg enable0,
	      output reg enable1,
	      output reg way_sel,
	      output reg cache_rdy,
              output reg comp,
	      output reg rd,
	      output reg valid_in,
	      output reg wr,
	      output reg sel_data_cache,
              output reg write,
	      output reg soff,
	      output reg soff_mem,
	      output reg done,
	      output reg stag,
              output reg [1:0] offset_mem,
	      output reg [1:0] offset_cache
);

/****************************************************
 * State Machine
 ****************************************************/
localparam IDLE 	=	4'b0000;
localparam COMPARE 	=	4'b0001;
localparam AB0 		=	4'b0010;
localparam AB1 		=	4'b0011;
localparam AB2 		=	4'b0100;
localparam AB3		=	4'b0101;
localparam WR1C		=	4'b0110;
localparam WR2C		=	4'b0111;
localparam WB0		=	4'b1000;
localparam WB1		=	4'b1001;
localparam WB2		=	4'b1010;
localparam WB3		=	4'b1011;
localparam STALL	=	4'b1100;
localparam WRITE_MISS	=	4'b1101;
localparam DONE 	= 	4'b1110;

reg  [3:0] nxt_state;
wire [3:0] state;
reg write_check, hit_valid;
wire VW, VW_mux;


assign VW_mux = (memRead|memWrite & state==IDLE) ? ~VW : VW;
dff state_f [3:0](.d(nxt_state), .q(state), .clk(clk), .rst(rst));
dff victim_w (.d(VW_mux), .q(VW), .clk(clk), .rst(rst));

always @(state, valid0, valid1, hit0, hit1, memRead, memWrite, busy, dirty0, dirty1) begin
  /////////////////////////////////////////
  // Default all SM outputs & nxt_state //
  ///////////////////////////////////////
  comp = 1'b0;
  write = 1'b0;
  rd = 1'b0;
  wr = 1'b0;
  enable0 = 1'b0;
  enable1 = 1'b0;
  sel_data_cache = 1'b0;
  offset_mem = 2'b00;
  offset_cache = 2'b00;
  stag = 1'b0;
  soff = 1'b0;
  soff_mem = 1'b0;
  done = 1'b0;
  valid_in = 1'b0;
  cache_rdy = 1'b0;
  nxt_state = state;

  //state transition logic and output logic
  case (state)
    IDLE: begin //0
        hit_ans = 1'b1;
	write_check = memWrite;
        case(memRead | memWrite)
	   1'b1: begin 
	      nxt_state = COMPARE;
	    end
           1'b0: begin
	      nxt_state = IDLE;
	      cache_rdy = 1'b1;
	    end 
        endcase
     end
    COMPARE: begin //1
	comp = 1'b1;
	write = write_check;
	valid_in = write ? 1'b1 : 1'b0;
	enable0 = 1'b1;
	enable1 = 1'b1;
	hit_valid = (hit0 & valid0) | (hit1 & valid1);
	done = (hit_valid) ? 1'b1 : 1'b0;
	way_sel = (~hit_valid) ? ( (!valid0 & !valid1) ? 1'b0 : ((valid0&~valid1) ? 1'b1 : ((valid1&~valid0) ? 1'b0 : VW ))) : ( (hit1&valid1) ? 1'b1 : 1'b0);
	nxt_state = (hit_valid) ? IDLE : (((dirty0 & !way_sel) | (dirty1 & way_sel)) ? WB0: AB0);
    end	
    AB0: begin //2
        hit_ans = 1'b0;
	nxt_state = AB1;
	rd = 1'b1;
	wr = 1'b0;
	soff_mem = 1'b1;
	offset_mem = 2'b00;
     end
    AB1: begin //3
	nxt_state = AB2;
	rd = 1'b1;
	wr = 1'b0;
	soff_mem = 1'b1;
	offset_mem = 2'b01;
     end
    AB2: begin //4
	nxt_state = AB3;
	rd = 1'b1;
	wr = 1'b0;
	comp = 1'b0;
	valid_in = 1'b1;
	write = 1'b1;
	enable0 = way_sel ? 1'b0 : 1'b1;
	enable1 = way_sel ? 1'b1 : 1'b0;
	sel_data_cache = 1'b1;
        offset_cache = 2'b00;
	offset_mem = 2'b10;
	soff_mem = 1'b1;
	soff = 1'b1;
     end
    AB3: begin //5
	nxt_state = WR1C;
	rd = 1'b1;
	wr = 1'b0;
	comp = 1'b0;
	valid_in = 1'b1;
	write = 1'b1;
	enable0 = way_sel ? 1'b0 : 1'b1;
        enable1 = way_sel ? 1'b1 : 1'b0;
	sel_data_cache = 1'b1;
        offset_cache = 2'b01;
	offset_mem = 2'b11;
	soff_mem = 1'b1;
	soff = 1'b1;
     end
    WR1C: begin //6
	nxt_state = WR2C;
	comp = 1'b0;
	valid_in = 1'b1;
	write = 1'b1;
	enable0 = way_sel ? 1'b0 : 1'b1;
        enable1 = way_sel ? 1'b1 : 1'b0;
	sel_data_cache = 1'b1;
        offset_cache = 2'b10;
	soff = 1'b1;
     end
    WR2C: begin //7
	nxt_state = write_check ? WRITE_MISS : COMPARE;
	comp = 1'b0;
	valid_in = 1'b1;
	write = 1'b1;
	enable0 = way_sel ? 1'b0 : 1'b1;
        enable1 = way_sel ? 1'b1 : 1'b0;
	sel_data_cache = 1'b1;
        offset_cache = 2'b11;
	soff = 1'b1;
     end
    WRITE_MISS: begin
	nxt_state = COMPARE;
	comp = 1'b1;
	valid_in = 1'b1;
	write = 1'b1;
	enable0 = way_sel ? 1'b0 : 1'b1;
        enable1 = way_sel ? 1'b1 : 1'b0;
     end	
    WB0: begin //8
        hit_ans = 1'b0;
	nxt_state = WB1;
	rd = 1'b0;
	wr = 1'b1;
	comp = 1'b0;
	write = 1'b0;
	enable0 = way_sel ? 1'b0 : 1'b1;
        enable1 = way_sel ? 1'b1 : 1'b0;
        offset_cache = 2'b00;
	offset_mem = 2'b00;
	soff = 1'b1;
	soff_mem = 1'b1;
	stag = 1'b1;
     end
    WB1: begin //9
	nxt_state = WB2;
	rd = 1'b0;
	wr = 1'b1;
	comp = 1'b0;
	write = 1'b0;
	enable0 = way_sel ? 1'b0 : 1'b1;
        enable1 = way_sel ? 1'b1 : 1'b0;
        offset_cache = 2'b01;
	offset_mem = 2'b01;
	soff_mem = 1'b1;
	soff = 1'b1;
	stag = 1'b1;
     end
    WB2: begin //10
	nxt_state = WB3;
	rd = 1'b0;
	wr = 1'b1;
	comp = 1'b0;
	write = 1'b0;
	enable0 = way_sel ? 1'b0 : 1'b1;
        enable1 = way_sel ? 1'b1 : 1'b0;
        offset_cache = 2'b10;
	offset_mem = 2'b10;
	soff = 1'b1;
	soff_mem = 1'b1;
	stag = 1'b1;
     end
    WB3: begin //11
	nxt_state = STALL;
	rd = 1'b0;
	wr = 1'b1;
	comp = 1'b0;
	write = 1'b0;
	enable0 = way_sel ? 1'b0 : 1'b1;
        enable1 = way_sel ? 1'b1 : 1'b0;
        offset_cache = 2'b11;
	offset_mem = 2'b11;
	soff_mem = 1'b1;
	soff = 1'b1;
	stag = 1'b1;
     end
    STALL: begin //12
	nxt_state = busy[0] ? STALL : AB0;      
     end
  endcase
end

endmodule
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :0:
