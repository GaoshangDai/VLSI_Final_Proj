// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip ( reset, out_core1, out_core2, mem_in_core1, mem_in_core2, clk_core1, clk_core2,start_core1,start_core2);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input     clk_core1;
input     clk_core2;
input   start_core1, start_core2; 

input     [pr*bw-1:0] mem_in_core1;
input     [pr*bw-1:0] mem_in_core2;
input     reset;


output    [col*bw_psum-1:0] out_core1;
output    [col*bw_psum-1:0] out_core2;

wire      [bw_psum+3:0] sum_core1;
wire      [bw_psum+3:0] sum_core2;
wire [bw_psum+3:0] sum_out_core1;
wire [bw_psum+3:0] sum_out_core2;
wire [bw_psum+3:0] fifo_out_1;
wire [bw_psum+3:0] fifo_out_2;
wire fifo_ext_rd_core1, fifo_ext_rd_core2;
wire div_core1, div_core2;
wire empty_core1, empty_core2;
wire ready_core1, ready_core2;
assign ready_core1 = !empty_core2;
assign ready_core2 = !empty_core1;

assign sum_core1 = fifo_out_2;
assign sum_core2 = fifo_out_1;

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance1 (
      .clk(clk_core1), 
      .mem_in(mem_in_core1), 
      .start(start_core1),
      .out(out_core1),
      .sum_in(sum_core1),
	.sum_out(sum_out_core1),
	.fifo_ext_rd(fifo_ext_rd_core1),
	.fifo_in_ready(ready_core1),
	.div_o(div_core1)
      .reset(reset),
      .fifo_ext_rd_clk(clk_core2),

);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance2 (
      .clk(clk_core2), 
      .mem_in(mem_in_core2), 
      .start(start_core2),
      .out(out_core2),
      .sum_in(sum_core2),
	.sum_out(sum_out_core2),
	.fifo_ext_rd(fifo_ext_rd_core2),
	.fifo_in_ready(ready_core2),
	.div_o(div_core2)
      .reset(reset),
      .fifo_ext_rd_clk(clk_core1),
);


fifo_depth16 #(.bw(bw_psum+4)) fifo_depth16_inst_core1 (
        .reset(reset),
	.rd_clk(clk_core2),
	.wr_clk(clk_core1),
	.in(sum_out_core1),
	.out(fifo_out_1),
	.rd(div_core2),
	.wr(fifo_ext_rd_core1),
	.o_empty(empty_core1)
);


fifo_depth16 #(.bw(bw_psum+4)) fifo_depth16_inst_core2 (
        .reset(reset),
	.rd_clk(clk_core1),
	.wr_clk(clk_core2),
	.in(sum_out_core2),
	.out(fifo_out_2),
	.rd(div_core1),
	.wr(fifo_ext_rd_core2),
	.o_empty(empty_core2)
);
endmodule
