// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module core (clk, sum_out, mem_in, out, inst, reset);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

output [bw_psum+3:0] sum_out;
wire [bw_psum+3:0] sum_out_temp1;
wire [bw_psum+3:0] sum_out_temp2;
output [bw_psum*col-1:0] out;
wire   [bw_psum*col-1:0] pmem_out;
input  [pr*bw-1:0] mem_in;
input  clk;
input  [19:0] inst; 
input  reset;

wire [bw_psum*col-1:0] sfp_in;
wire [bw_psum*col-1:0] sfp_out;
wire  [bw_psum+3:0] sum_in;

wire  [pr*bw-1:0] mac_in;
wire  [pr*bw-1:0] kmem_out;
wire  [pr*bw-1:0] qmem_out;
wire  [bw_psum*col-1:0] pmem_in;
wire  [bw_psum*col-1:0] fifo_out;
wire  [bw_psum*col-1:0] array_out;
wire  [col-1:0] fifo_wr;
wire  ofifo_rd;
wire [3:0] qkmem_add;
wire [3:0] pmem_add;

wire  qmem_rd;
wire  qmem_wr; 
wire  kmem_rd;
wire  kmem_wr; 
wire  pmem_rd;
wire  pmem_wr; 
wire [bw_psum+3:0] sum_q;

assign fifo_ext_rd = inst[19];
assign div = inst[18];
assign acc = inst[17];
assign ofifo_rd = inst[16];
assign qkmem_add = inst[15:12];
assign pmem_add = inst[11:8];

assign qmem_rd = inst[5];
assign qmem_wr = inst[4];
assign kmem_rd = inst[3];
assign kmem_wr = inst[2];
assign pmem_rd = inst[1];
assign pmem_wr = inst[0];

assign mac_in  = inst[6] ? kmem_out : qmem_out;
assign pmem_in = div ? sfp_out : fifo_out;
assign sfp_in = pmem_out;
assign out = pmem_out;
assign sum_in = 0;
assign sum_out_temp1 = {{(3){out[bw_psum*1-1:bw_psum*0]}},out[bw_psum*1-1:bw_psum*0]}
	+	{{(3){out[bw_psum*2-1:bw_psum*1]}},out[bw_psum*2-1:bw_psum*1]}
	+	{{(3){out[bw_psum*3-1:bw_psum*2]}},out[bw_psum*3-1:bw_psum*2]}
	+	{{(3){out[bw_psum*4-1:bw_psum*3]}},out[bw_psum*4-1:bw_psum*3]}
	+	{{(3){out[bw_psum*5-1:bw_psum*4]}},out[bw_psum*5-1:bw_psum*4]}
	+	{{(3){out[bw_psum*6-1:bw_psum*5]}},out[bw_psum*6-1:bw_psum*5]}
	+	{{(3){out[bw_psum*7-1:bw_psum*6]}},out[bw_psum*7-1:bw_psum*6]}
	+	{{(3){out[bw_psum*8-1:bw_psum*7]}},out[bw_psum*8-1:bw_psum*7]};
assign sum_out = fifo_ext_rd ? sum_out_temp2 : sum_out_temp1;

mac_array #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) mac_array_instance (
        .in(mac_in), 
        .clk(clk), 
        .reset(reset), 
        .inst(inst[7:6]),     
        .fifo_wr(fifo_wr),     
	.out(array_out)
);

ofifo #(.bw(bw_psum), .col(col))  ofifo_inst (
        .reset(reset),
        .clk(clk),
        .in(array_out),
        .wr(fifo_wr),
        .rd(ofifo_rd),
        .o_valid(fifo_valid),
        .out(fifo_out)
);


sram_w16 #(.sram_bit(pr*bw)) qmem_instance (
        .CLK(clk),
        .D(mem_in),
        .Q(qmem_out),
        .CEN(!(qmem_rd||qmem_wr)),
        .WEN(!qmem_wr), 
        .A(qkmem_add)
);

sram_w16 #(.sram_bit(pr*bw)) kmem_instance (
        .CLK(clk),
        .D(mem_in),
        .Q(kmem_out),
        .CEN(!(kmem_rd||kmem_wr)),
        .WEN(!kmem_wr), 
        .A(qkmem_add)
);

sram_w16 #(.sram_bit(col*bw_psum)) psum_mem_instance (
        .CLK(clk),
        .D(pmem_in),
        .Q(pmem_out),
        .CEN(!(pmem_rd||pmem_wr)),
        .WEN(!pmem_wr), 
        .A(pmem_add)
);

sfp_row #(.bw(bw), .bw_psum(bw_psum), .col(col)) sfp_row_instance (
	.clk(clk),
	.acc(acc),
	.div(div),
	.sum_in(sum_in),
	.sum_out(sum_out_temp2),
	.sfp_in(sfp_in),
	.sfp_out(sfp_out),
	.fifo_ext_rd(fifo_ext_rd),
	.sum_q(sum_q)
);


  //////////// For printing purpose ////////////
  always @(posedge clk) begin
      if(pmem_wr)
         $display("Memory write to PSUM mem add %x %x ", pmem_add, pmem_in); 
  end



endmodule
