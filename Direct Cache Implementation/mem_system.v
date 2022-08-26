/* $Author: karu $ */
/* $LastChangedDate: 2009-04-24 09:28:13 -0500 (Fri, 24 Apr 2009) $ */
/* $Rev: 77 $ */

`default_nettype none
module mem_system(/*AUTOARG*/
   // Outputs
   DataOut, Done, Stall, CacheHit, err,
   // Inputs
   Addr, DataIn, Rd, Wr, createdump, clk, rst
   );
   
   input wire [15:0] Addr;
   input wire [15:0] DataIn;
   input wire        Rd;
   input wire        Wr;
   input wire        createdump;
   input wire        clk;
   input wire        rst;
   
   output wire [15:0] DataOut;
   output wire        Done;
   output wire        Stall;
   output wire        CacheHit;
   output wire        err;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */

   //CONTROLLER OUTPUTS
   wire enable, rd, wr, comp, write, soff, soff_mem, stag, sel_data_cache, valid_in, cache_rdy;
   wire [1:0] offset_cache, offset_mem;

   //CACHE OUTPUTS
   wire [4:0] tag_out;
   wire dirty, valid, err_Cache;
   wire cache_hit;

   //MEM OUTPUTS
   wire [15:0] mdata_out;
   wire stall_mem, err_Mem;
   wire [3:0] busy;

   assign Stall = ~cache_rdy;
   assign err = err_Mem | err_Cache;

   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out),		//TBD
                          .data_out             (DataOut),	//ModuleOut
                          .hit                  (cache_hit),	//ModuleOut
                          .dirty                (dirty),	//intermediate
                          .valid                (valid),	//intermediate
                          .err                  (err_Cache),	//intermediate
                          // Inputs
                          .enable               (enable),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (soff ? {offset_cache, 1'b0} : {Addr[2:0]}), //from controller
                          .data_in              (sel_data_cache ? mdata_out : DataIn), 		
                          .comp                 (comp),		//from controller
                          .write                (write),	//from controller
                          .valid_in             (valid_in));	//from controller

   four_bank_mem mem(// Outputs
                     .data_out          (mdata_out),
                     .stall             (stall_mem),
                     .busy              (busy),
                     .err               (err_Mem),
                     // Inputs
                     .clk               (clk),
                     .rst               (rst),
                     .createdump        (createdump),
                     .addr              ({(stag ? tag_out : Addr[15:11]), 
		     			  Addr[10:3], 
					  (soff_mem ? {offset_mem,1'b0} : {Addr[2:1],1'b0})}),
                     .data_in           (DataOut),		//Either from cache or actual DataIn
                     .wr                (wr),			//from controller
                     .rd                (rd));			//from controller

   controller controller(//Outputs
   			 .enable	(enable),
			 .comp		(comp),
			 .write		(write),
			 .rd		(rd),
			 .wr		(wr),
			 .soff		(soff),
			 .soff_mem	(soff_mem),
			 .valid_in	(valid_in),
			 .hit_ans	(CacheHit),
			 .done		(Done),
			 .stag		(stag),
			 .cache_rdy	(cache_rdy),
			 .sel_data_cache(sel_data_cache),
			 .offset_mem	(offset_mem),
			 .offset_cache	(offset_cache),
   			 // Inputs
			 .clk		(clk),
			 .rst		(rst),
			 .valid		(valid),
			 .hit		(cache_hit),
			 .dirty		(dirty),
			 .memRead	(Rd),
			 .memWrite	(Wr),
			 .busy		(busy));
				
   
   // your code here

   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
