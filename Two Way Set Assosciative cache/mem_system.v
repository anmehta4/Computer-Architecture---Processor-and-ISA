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

     //CONTROLLER OUTPUTS
   wire enable0, enable1, rd, wr, comp, write, soff, soff_mem, stag, sel_data_cache, valid_in, cache_rdy, way_sel;
   wire [1:0] offset_cache, offset_mem;

   //CACHE OUTPUTS
   wire [4:0] tag_out0, tag_out1, tag_out;
   wire dirty0, dirty1, valid0, valid1, err_Cache0, err_Cache1;
   wire [15:0] DataOut0, DataOut1;
   wire CacheHit0, CacheHit1;

   //MEM OUTPUTS
   wire [15:0] mdata_out;
   wire stall_mem, err_Mem;
   wire [3:0] busy;

   assign DataOut = way_sel ? DataOut1 : DataOut0;
   assign Stall = ~cache_rdy;
   assign tag_out = way_sel ? tag_out1 : tag_out0;
   assign err = err_Mem | err_Cache0 | err_Cache1;

   /* data_mem = 1, inst_mem = 0 *
    * needed for cache parameter */
   parameter memtype = 0;
   cache #(0 + memtype) c0(// Outputs
                          .tag_out              (tag_out0),
                          .data_out             (DataOut0),
                          .hit                  (CacheHit0),
                          .dirty                (dirty0),
                          .valid                (valid0),
                          .err                  (err_Cache0),
                          // Inputs
                          .enable               (enable0),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (soff ? {offset_cache, 1'b0} : {Addr[2:0]}),
                          .data_in              (sel_data_cache ? mdata_out : DataIn),
                          .comp                 (comp),
                          .write                (write),
                          .valid_in             (valid_in));

   cache #(2 + memtype) c1(// Outputs
                          .tag_out              (tag_out1),
                          .data_out             (DataOut1),
                          .hit                  (CacheHit1),
                          .dirty                (dirty1),
                          .valid                (valid1),
                          .err                  (err_Cache1),
                          // Inputs
                          .enable               (enable1),
                          .clk                  (clk),
                          .rst                  (rst),
                          .createdump           (createdump),
                          .tag_in               (Addr[15:11]),
                          .index                (Addr[10:3]),
                          .offset               (soff ? {offset_cache, 1'b0} : {Addr[2:0]}),
                          .data_in              (sel_data_cache ? mdata_out : DataIn),
                          .comp                 (comp),
                          .write                (write),
                          .valid_in             (valid_in));

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
                     .data_in           (DataOut),
                     .wr                (wr),
                     .rd                (rd));

   controller controller(//Outputs
                         .enable0       (enable0),
			 .enable1	(enable1),
                         .comp          (comp),
                         .write         (write),
                         .rd            (rd),
                         .wr            (wr),
                         .soff          (soff),
                         .soff_mem      (soff_mem),
                         .valid_in      (valid_in),
                         .hit_ans       (CacheHit),
                         .done          (Done),
                         .stag          (stag),
                         .cache_rdy     (cache_rdy),
			 .way_sel	(way_sel),
                         .sel_data_cache(sel_data_cache),
                         .offset_mem    (offset_mem),
                         .offset_cache  (offset_cache),
                         // Inputs
                         .clk           (clk),
                         .rst           (rst),
                         .valid0        (valid0),
			 .valid1	(valid1),
                         .hit0          (CacheHit0),
			 .hit1		(CacheHit1),
                         .dirty0        (dirty0),
			 .dirty1	(dirty1),
                         .memRead       (Rd),
                         .memWrite      (Wr),
                         .busy          (busy));
 
   // your code here

   
endmodule // mem_system
`default_nettype wire
// DUMMY LINE FOR REV CONTROL :9:
