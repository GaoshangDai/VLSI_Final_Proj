// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (inst, reset, acc, div, wr_norm, rd_fifo, out_core1, out_core2, mem_in_core1, mem_in_core2, clk_core1, clk_core2);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input     clk_core1;
input     clk_core2;
input     [16:0] inst;
input     [pr*bw-1:0] mem_in_core1;
input     [pr*bw-1:0] mem_in_core2;
input     reset, acc, div, wr_norm;
input     rd_fifo;

output    [col*bw_psum-1:0] out_core1;
output    [col*bw_psum-1:0] out_core2;

wire      [bw_psum+3:0] sum_core1;
wire      [bw_psum+3:0] sum_core2;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance1 (
      .clk(clk_core1), 
      .mem_in(mem_in_core1), 
      .out(out_core1),
      .inst(inst),
      .reset(reset),
      .fifo_ext_rd_clk(clk_core2),
      .acc(acc),
      .div(div),
      .wr_norm(wr_norm),
      .sum_in(sum_core2),
      .sum_out(sum_core1),
      .fifo_ext_rd(rd_fifo)
);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance2 (
      .clk(clk_core2), 
      .mem_in(mem_in_core2), 
      .out(out_core2),
      .inst(inst),
      .reset(reset),
      .fifo_ext_rd_clk(clk_core1),
      .acc(acc),
      .div(div),
      .wr_norm(wr_norm),
      .sum_in(sum_core1),
      .sum_out(sum_core2),
      .fifo_ext_rd(rd_fifo)
);

endmodule
