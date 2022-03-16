// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk, sum_out, mem_in, out, inst, reset);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

output [bw_psum+3:0] sum_out;
output [bw_psum*col-1:0] out;
input  clk; 
input  [pr*bw-1:0] mem_in; 
input  [19:0] inst; 
input  reset;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance (
      .reset(reset), 
      .clk(clk), 
      .mem_in(mem_in), 
      .inst(inst),
      .out(out),
      .sum_out(sum_out)
);

endmodule
