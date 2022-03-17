// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module core (clk,start, mem_in, out, reset, fifo_ext_rd, sum_in, sum_out,fifo_in_ready,div_o);

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
input  clk,start, wr_norm;
// input  [16:0] inst; 
wire [19:0] inst;
reg div;
reg acc;
input  reset;
input  [bw_psum+3:0] sum_in;
wire [bw_psum*col-1:0] sfp_in;
wire [bw_psum*col-1:0] sfp_out;
wire  [bw_psum+3:0] sum_in;
input fifo_ext_rd;
input fifo_in_ready;
output reg div_o;
output reg fifo_ext_rd_reg;

wire div_q;//latched div signal

wire  [pr*bw-1:0] mac_in;
wire  [pr*bw-1:0] kmem_out;
wire  [pr*bw-1:0] qmem_out;
wire  [bw_psum*col-1:0] pmem_in;
wire  [bw_psum*col-1:0] fifo_out;
wire  [bw_psum*col-1:0] array_out;
wire  [bw_psum*col-1:0] ofifo_in;//
wire  [col-1:0] fifo_wr;
reg  ofifo_rd;

wire  [col-1:0] array_wr;//
wire  [col-1:0] norm_wr;

reg [3:0] qkmem_add;
reg [3:0] pmem_add;

reg  qmem_rd;
reg  qmem_wr; 
reg  kmem_rd;
reg  kmem_wr; 
reg  pmem_rd;
reg  pmem_wr; 
wire [bw_psum+3:0] sum_q;

reg execute;
reg load;
reg [4:0] cnt;
reg load_times;
reg wr_times;
reg [3:0] state;
//assign fifo_ext_rd = inst[19];
//assign div = inst[18];
//assign acc = inst[17];
//assign ofifo_rd = inst[16];
//assign qkmem_add = inst[15:12];
//assign pmem_add = inst[11:8];

//assign qmem_rd = inst[5];
//assign qmem_wr = inst[4];
//assign kmem_rd = inst[3];
//assign kmem_wr = inst[2];
//assign pmem_rd = inst[1];
//assign pmem_wr = inst[0];

parameter READY=4'b0000, Q_WR=4'b0001, K_WR=4'b0010, LOADING=4'b0011, EXECUTE=4'b0100, WR_TO_MEM=4'b0101, FETCH=4'b0110, NORM=4'b0111, LOAD=4'b1000, FIFO_SUM=4'b1001, WAIT=4'b1010;
parameter total_cycle= 16;

assign mac_in  = inst[6] ? kmem_out : qmem_out;
assign pmem_in =  fifo_out;
assign sfp_in = pmem_out;
assign ofifo_in = div_q ? sfp_out : array_out;//
assign fifo_wr = div_q ? norm_wr : array_wr;
assign out = pmem_out;
//assign sum_in = 0;
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
        .fifo_wr(array_wr),     
	.out(array_out)
);

ofifo #(.bw(bw_psum), .col(col))  ofifo_inst (
        .reset(reset),
        .clk(clk),
        .in(ofifo_in),
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
	.fifo_ext_rd(fifo_ext_rd_reg),
	.reset(reset),
        .norm_wr(norm_wr),
        .div_q(div_q)
);


  always @ (negedge clk) begin
    if (reset) begin
      div <= 0;
      acc <= 0;
      ofifo_rd <= 0;
      qmem_rd <= 0;
      qmem_wr <= 0; 
      kmem_rd <= 0; 
      kmem_wr <= 0;
      pmem_rd <= 0; 
      pmem_wr <= 0; 
      execute <= 0;
      load <= 0;
      qkmem_add <= 0;
      pmem_add <= 0;

      cnt <= 0;
      load_times <= 0;
      wr_times <= 0;
      state <= READY;
    end
    else begin
    case(state)
      
    READY:
	    if (start==1) begin
	      state <= Q_WR; 
            end
    Q_WR:
	    if (cnt == total_cycle) begin
	      qmem_wr <= 0;
	      qkmem_add <= 0;
	      state <= K_WR;
	      cnt <= 0;
	    end
	    else begin
	      if (cnt > 0) begin 
                qkmem_add <= qkmem_add + 1;
	      end
	      if (cnt == 0) begin
                qmem_wr <= 1;
              end
	      cnt <= cnt + 1;
            end
    K_WR:
	    if (cnt == col) begin
	      cnt <= 0;
	      state <= LOADING;
	      kmem_wr <= 0;
	      qkmem_add <= 0;
	    end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == 0) begin
                kmem_wr <= 1;
              end
	      else begin
	        qkmem_add <= qkmem_add + 1;
	      end
            end
    LOADING:
	    if (cnt == col+2) begin
	      load <= 0;
	      cnt <= 0;
	      state <= LOAD;
            end
	    else if (cnt == col+1) begin
	      kmem_rd <= 0;
	      qkmem_add <= 0;
	      cnt <= cnt + 1;
	    end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == 0) begin 
                load <= 1;
              end
	      else if (cnt == 1) begin
                kmem_rd <= 1;
              end
	      else begin
                qkmem_add <= qkmem_add + 1;
              end
	    end

    LOAD:
	    if (cnt == 9) begin
              if (load_times == 0) begin 
		state <= EXECUTE;
	        cnt <= 0;
	        load_times <= load_times + 1;
	      end
	      else begin
                load_times <= 0;
		state <= WR_TO_MEM;
		cnt <= 0;
	      end
	    end
	    else begin
              cnt <= cnt + 1;
            end
    EXECUTE:
	    if (cnt == total_cycle) begin
	      qmem_rd <= 0;
	      qkmem_add <= 0;
	      execute <= 0;
	      cnt <= 0;
	      state <= LOAD;
	    end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == 0) begin
	        execute <= 1;
		qmem_rd <= 1;
	      end
	      else begin
                qkmem_add <= qkmem_add + 1;
              end
	    end
    WR_TO_MEM:
	    if (cnt == total_cycle) begin
	      pmem_wr <= 0;
	      pmem_add <= 0;
	      ofifo_rd <= 0;
	      cnt <=0;
	      if (wr_times == 0) begin 
		state <= FETCH;
		wr_times <= wr_times + 1;
              end
	      else begin
		state <= READY;
		wr_times <= 0;
              end
	    end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == 0) begin
		ofifo_rd <= 1;
		pmem_wr <= 1;
              end
	      else begin 
                pmem_add <= pmem_add + 1;
              end
	    end
    FETCH:
	    if (cnt == total_cycle + 1) begin
	      acc <= 0;
	      cnt <= 0;
	      state <= FIFO_SUM;
	    end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == total_cycle) begin
	        pmem_rd <= 0;
	        pmem_add <= 0;
	      end
	      else begin
	        if (cnt == 0) begin 
                  pmem_rd <= 1;
                end
		else begin
	          pmem_add <= pmem_add + 1;
		  if (cnt == 1) begin
                    acc <= 1;
                  end
		end
	      end
            end
    FIFO_SUM:
	    if (cnt == total_cycle) begin
              fifo_ext_rd_reg <= 0;
              //fifo_ext_rd <= 0;
	      cnt <= 0;
	      state <= WAIT;
            end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == 0) begin
                fifo_ext_rd_reg <= 1;
              end
	    end
    WAIT:
	    if (fifo_in_ready) begin
              state <= NORM;
            end
    NORM:
	    if (cnt == total_cycle) begin
	      div <= 0;
	      div_o <= 0;
              cnt <= 0;
	      state <= WR_TO_MEM;
            end
	    else begin
	      cnt <= cnt + 1;
	      if (cnt == 0) begin
	        div <= 1;
		div_o <= 1;
              end
	    end
    endcase
    end
  end

  //////////// For printing purpose ////////////
  always @ (posedge clk) begin
      if(pmem_wr)
         $display("Memory write to PSUM mem add %x %x ", pmem_add, pmem_in); 
  end



endmodule
