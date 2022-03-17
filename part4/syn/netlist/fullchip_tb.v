// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps

module fullchip_tb;

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 8;            // Q & K vector bit precision
parameter bw_psum = 2*bw+4;  // partial sum bit precision
parameter pr = 16;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped

integer qk_file ; // file handler
integer qk_scan_file ; // file handler

integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0

integer  Kcore1[col-1:0][pr-1:0];
integer  Kcore2[col-1:0][pr-1:0];
integer  Q[total_cycle-1:0][pr-1:0];
integer  resultcore1[total_cycle-1:0][col-1:0];
integer  resultcore2[total_cycle-1:0][col-1:0];
reg signed [bw_psum+3:0] sumcore1[total_cycle-1:0];
reg signed [bw_psum+3:0] sumcore2[total_cycle-1:0];
reg signed [bw_psum-1:0] sumcores[total_cycle-1:0];
reg signed [bw_psum-1:0] psumcore1[total_cycle-1:0][col-1:0];
reg signed [bw_psum-1:0] psumcore2[total_cycle-1:0][col-1:0];

integer i,j,k,t,p,q,s,u,m;

reg reset = 1;
reg clk = 0;
reg acc = 0;
reg div = 0;
reg wr_norm = 0;
reg fifo_ext_rd = 0;
reg [pr*bw-1:0] mem_in_core1;
reg [pr*bw-1:0] mem_in_core2;
reg ofifo_rd = 0;

wire [16:0] inst;
wire [col*bw_psum-1:0] out_core1;
wire [col*bw_psum-1:0] out_core2;
 
reg qmem_rd = 0;
reg qmem_wr = 0; 
reg kmem_rd = 0; 
reg kmem_wr = 0;
reg pmem_rd = 0; 
reg pmem_wr = 0; 
reg execute = 0;
reg load = 0;
reg [3:0] qkmem_add = 0;
reg [3:0] pmem_add = 0;

assign inst[16] = ofifo_rd;
assign inst[15:12] = qkmem_add;
assign inst[11:8]  = pmem_add;
assign inst[7] = execute;
assign inst[6] = load;
assign inst[5] = qmem_rd;
assign inst[4] = qmem_wr;
assign inst[3] = kmem_rd;
assign inst[2] = kmem_wr;
assign inst[1] = pmem_rd;
assign inst[0] = pmem_wr;

reg signed [bw_psum-1:0] temp5bcore1, temp5bcore2;
reg signed [bw_psum-1:0] temp5bcore1abs, temp5bcore2abs;
reg signed [bw_psum+3:0] temp_sum_core1, temp_sum_core2;
reg signed [bw_psum+3:0] psum_sign_extend;
reg signed [bw_psum*col-1:0] temp16bcore1, temp16bcore2;

reg [bw_psum*col-1:0] normalized_out_col_core1[total_cycle-1:0];
reg [bw_psum*col-1:0] normalized_out_col_core2[total_cycle-1:0];

reg [bw_psum*col-1:0] normalized_out_col_core11;
reg [bw_psum*col-1:0] normalized_out_col_core22;

reg signed [bw_psum-1:0] normalized_out_core1[total_cycle-1:0][col-1:0];
reg signed [bw_psum-1:0] normalized_out_core2[total_cycle-1:0][col-1:0];



fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
      .reset(reset),
      .clk_core1(clk_core1), 
      .clk_core2(clk_core2),
      .mem_in_core1(mem_in_core1),
      .mem_in_core2(mem_in_core2), 
      .inst(inst),
      .acc(acc),
      .div(div),
      .wr_norm(wr_norm),
      .rd_fifo(fifo_ext_rd),
      .out_core1(out_core1),
      .out_core2(out_core2)
);

initial begin 

  $dumpfile("fullchip_tb.vcd");
  $dumpvars(0,fullchip_tb);

///// Q data txt reading /////

$display("##### Q data txt reading #####");


  qk_file = $fopen("qdata.txt", "r");

  //// To get rid of first 3 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Q[q][j] = captured_data;
          //$display("%d\n", K[q][j]);
    end
  end
/////////////////////////////////


  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end


///// K data txt reading /////

$display("##### K data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end
  reset = 0;

  qk_file = $fopen("kdata_core0.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);

  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Kcore1[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end
  

  qk_file = $fopen("kdata_core1.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);

  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Kcore2[q][j] = captured_data;
          //$display("##### %d\n", K[q][j]);
    end
  end

/////////////////////////////////


/////////////// Estimated result printing /////////////////


$display("##### Estimated Multiplication Result #####");

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       resultcore1[t][q] = 0;
       normalized_out_core1[t][q] = 0;
       resultcore2[t][q] = 0;
       normalized_out_core2[t][q] = 0;
     end
     normalized_out_col_core1[t] = 0;
     normalized_out_col_core2[t] = 0;
     sumcore1[t] = 0;
     sumcore2[t] = 0;
     sumcores[t] = 0;
  end

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
           resultcore1[t][q] = resultcore1[t][q] + Q[t][k] * Kcore1[q][k];
           resultcore2[t][q] = resultcore2[t][q] + Q[t][k] * Kcore2[q][k];
         end

         temp5bcore1 = resultcore1[t][q];
         psumcore1[t][q] = temp5bcore1;
         temp16bcore1 = {temp16bcore1[139:0], temp5bcore1};
         temp5bcore1abs = (temp5bcore1[bw_psum-1])? ~temp5bcore1 + 1 : temp5bcore1;
         sumcore1[t] = sumcore1[t] + {4'b0, temp5bcore1abs};
         temp5bcore2 = resultcore2[t][q];
         psumcore2[t][q] = temp5bcore2;
         temp16bcore2 = {temp16bcore2[139:0], temp5bcore2};
         temp5bcore2abs = (temp5bcore2[bw_psum-1])? ~temp5bcore2 + 1 : temp5bcore2;
         sumcore2[t] = sumcore2[t] + {4'b0, temp5bcore2abs};
     end

     //$display("%d %d %d %d %d %d %d %d", result[t][0], result[t][1], result[t][2], result[t][3], result[t][4], result[t][5], result[t][6], result[t][7]);
     $display("prd @cycle%2d: core1 -> %40h, core2 -> %40h", t, temp16bcore1, temp16bcore2);
     $display("sum @cycle%2d: core1 -> %8h, core2 -> %8h", t, sumcore1[t], sumcore2[t]);
     $display("sum of two core @cycle%2d: %9h", t, sumcore1[t]+sumcore2[t]);
  end

//////////////////////////////////////////////

$display("##### Estimated Normalized Result #####");

   for (t=0; t<total_cycle; t=t+1) begin
      for (q=0; q<col; q=q+1) begin
         sumcores[t] = sumcore1[t][bw_psum+3:7] + sumcore2[t][bw_psum+3:7];
         resultcore1[t][q] = psumcore1[t][q]/sumcores[t];
         resultcore2[t][q] = psumcore2[t][q]/sumcores[t];
/*
	 $display("sumcore @cycle%2d:  %40h", t, sumcores[t]);
     	 $display("psumcore1 @cycle%2d: core1 -> %40h", t, psumcore1[t][q]);
	 $display("psumcore2 @cycle%2d: core2 -> %40h", t, psumcore2[t][q]);
*/
         normalized_out_core1[t][q] = resultcore1[t][q];
         normalized_out_core2[t][q] = resultcore2[t][q];

     	 $display("normcore1out @cycle%2d: core1 -> %40h", t, normalized_out_core1[t][q]);
	 $display("normcore2out @cycle%2d: core2 -> %40h", t, normalized_out_core2[t][q]);
/*
         normalized_out_col_core1[t] = {normalized_out_col_core1[t][139:0], normalized_out_col_core1[t][q]}; 
         normalized_out_col_core2[t] = {normalized_out_col_core2[t][139:0], normalized_out_col_core2[t][q]}; 

     	 $display("normcore1out @cycle%2d: core1 -> %40h", t, normalized_out_core1[t][q]);
	 $display("normcore2out @cycle%2d: core2 -> %40h", t, normalized_out_core2[t][q]);
*/
/*
	 normalized_out_col_core11 = {normalized_out_col_core11[139:0], normalized_out_col_core1[t][q]}; 
         normalized_out_col_core22 = {normalized_out_col_core22[139:0], normalized_out_col_core2[t][q]}; 
*/
         normalized_out_col_core1[t] = {normalized_out_col_core1[t][139:0], normalized_out_core1[t][q]}; 
         normalized_out_col_core2[t] = {normalized_out_col_core2[t][139:0], normalized_out_core2[t][q]}; 

      end
     
     $display("norm @cycle%2d: core1 -> %40h", t, normalized_out_col_core1[t]);
     $display("norm @cycle%2d: core2 -> %40h", t, normalized_out_col_core2[t]);

/*
     $display("norm @cycle%2d: core1 -> %40h", t, normalized_out_col_core11);
     $display("norm @cycle%2d: core2 -> %40h", t, normalized_out_col_core22);
*/

  end



///// Qmem writing  /////

$display("##### Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk = 1'b0;  
    qmem_wr = 1;  if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in_core1[1*bw-1:0*bw] = Q[q][0];
    mem_in_core2[1*bw-1:0*bw] = Q[q][0];
    mem_in_core1[2*bw-1:1*bw] = Q[q][1];
    mem_in_core2[2*bw-1:1*bw] = Q[q][1];
    mem_in_core1[3*bw-1:2*bw] = Q[q][2];
    mem_in_core2[3*bw-1:2*bw] = Q[q][2];
    mem_in_core1[4*bw-1:3*bw] = Q[q][3];
    mem_in_core2[4*bw-1:3*bw] = Q[q][3];
    mem_in_core1[5*bw-1:4*bw] = Q[q][4];
    mem_in_core2[5*bw-1:4*bw] = Q[q][4];
    mem_in_core1[6*bw-1:5*bw] = Q[q][5];
    mem_in_core2[6*bw-1:5*bw] = Q[q][5];
    mem_in_core1[7*bw-1:6*bw] = Q[q][6];
    mem_in_core2[7*bw-1:6*bw] = Q[q][6];
    mem_in_core1[8*bw-1:7*bw] = Q[q][7];
    mem_in_core2[8*bw-1:7*bw] = Q[q][7];
    mem_in_core1[9*bw-1:8*bw] = Q[q][8];
    mem_in_core2[9*bw-1:8*bw] = Q[q][8];
    mem_in_core1[10*bw-1:9*bw] = Q[q][9];
    mem_in_core2[10*bw-1:9*bw] = Q[q][9];
    mem_in_core1[11*bw-1:10*bw] = Q[q][10];
    mem_in_core2[11*bw-1:10*bw] = Q[q][10];
    mem_in_core1[12*bw-1:11*bw] = Q[q][11];
    mem_in_core2[12*bw-1:11*bw] = Q[q][11];
    mem_in_core1[13*bw-1:12*bw] = Q[q][12];
    mem_in_core2[13*bw-1:12*bw] = Q[q][12];
    mem_in_core1[14*bw-1:13*bw] = Q[q][13];
    mem_in_core2[14*bw-1:13*bw] = Q[q][13];
    mem_in_core1[15*bw-1:14*bw] = Q[q][14];
    mem_in_core2[15*bw-1:14*bw] = Q[q][14];
    mem_in_core1[16*bw-1:15*bw] = Q[q][15];
    mem_in_core2[16*bw-1:15*bw] = Q[q][15];

    #0.5 clk = 1'b1;  

  end


  #0.5 clk = 1'b0;  
  qmem_wr = 0; 
  qkmem_add = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////


///// Kmem writing  /////

$display("##### Kmem writing #####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk = 1'b0;  
    kmem_wr = 1; if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in_core1[1*bw-1:0*bw] = Kcore1[q][0];
    mem_in_core2[1*bw-1:0*bw] = Kcore2[q][0];
    mem_in_core1[2*bw-1:1*bw] = Kcore1[q][1];
    mem_in_core2[2*bw-1:1*bw] = Kcore2[q][1];
    mem_in_core1[3*bw-1:2*bw] = Kcore1[q][2];
    mem_in_core2[3*bw-1:2*bw] = Kcore2[q][2];
    mem_in_core1[4*bw-1:3*bw] = Kcore1[q][3];
    mem_in_core2[4*bw-1:3*bw] = Kcore2[q][3];
    mem_in_core1[5*bw-1:4*bw] = Kcore1[q][4];
    mem_in_core2[5*bw-1:4*bw] = Kcore2[q][4];
    mem_in_core1[6*bw-1:5*bw] = Kcore1[q][5];
    mem_in_core2[6*bw-1:5*bw] = Kcore2[q][5];
    mem_in_core1[7*bw-1:6*bw] = Kcore1[q][6];
    mem_in_core2[7*bw-1:6*bw] = Kcore2[q][6];
    mem_in_core1[8*bw-1:7*bw] = Kcore1[q][7];
    mem_in_core2[8*bw-1:7*bw] = Kcore2[q][7];
    mem_in_core1[9*bw-1:8*bw] = Kcore1[q][8];
    mem_in_core2[9*bw-1:8*bw] = Kcore2[q][8];
    mem_in_core1[10*bw-1:9*bw] = Kcore1[q][9];
    mem_in_core2[10*bw-1:9*bw] = Kcore2[q][9];
    mem_in_core1[11*bw-1:10*bw] = Kcore1[q][10];
    mem_in_core2[11*bw-1:10*bw] = Kcore2[q][10];
    mem_in_core1[12*bw-1:11*bw] = Kcore1[q][11];
    mem_in_core2[12*bw-1:11*bw] = Kcore2[q][11];
    mem_in_core1[13*bw-1:12*bw] = Kcore1[q][12];
    mem_in_core2[13*bw-1:12*bw] = Kcore2[q][12];
    mem_in_core1[14*bw-1:13*bw] = Kcore1[q][13];
    mem_in_core2[14*bw-1:13*bw] = Kcore2[q][13];
    mem_in_core1[15*bw-1:14*bw] = Kcore1[q][14];
    mem_in_core2[15*bw-1:14*bw] = Kcore2[q][14];
    mem_in_core1[16*bw-1:15*bw] = Kcore1[q][15];
    mem_in_core2[16*bw-1:15*bw] = Kcore2[q][15];

    #0.5 clk = 1'b1;  

  end

  #0.5 clk = 1'b0;  
  kmem_wr = 0;  
  qkmem_add = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////



  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;   
  end




/////  K data loading  /////
$display("##### K data loading to processor #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk = 1'b0;  
    load = 1; 
    if (q==1) kmem_rd = 1;
    if (q>1) begin
       qkmem_add = qkmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  kmem_rd = 0; qkmem_add = 0;
  #0.5 clk = 1'b1;  

  #0.5 clk = 1'b0;  
  load = 0; 
  #0.5 clk = 1'b1;  

///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end

///// execution  /////
$display("##### execute #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    execute = 1; 
    qmem_rd = 1;

    if (q>0) begin
       qkmem_add = qkmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  qmem_rd = 0; qkmem_add = 0; execute = 0;
  #0.5 clk = 1'b1;  


///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end




////////////// output fifo rd and wb to psum mem ///////////////////

$display("##### move ofifo to pmem #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    ofifo_rd = 1; 
    pmem_wr = 1; 

    if (q>0) begin
       pmem_add = pmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  pmem_wr = 0; pmem_add = 0; ofifo_rd = 0;
  #0.5 clk = 1'b1;  

///////////////////////////////////////////




  #10 $finish;


end

endmodule




