assign sum_out = 
                {{(3){out[bw_psum*1-1:bw_psum*0]}},out[bw_psum*1-1:bw_psum*0]}
	+	{{(3){out[bw_psum*2-1:bw_psum*1]}},out[bw_psum*2-1:bw_psum*1]}
	+	{{(3){out[bw_psum*3-1:bw_psum*2]}},out[bw_psum*3-1:bw_psum*2]}
	+	{{(3){out[bw_psum*4-1:bw_psum*3]}},out[bw_psum*4-1:bw_psum*3]}
	+	{{(3){out[bw_psum*5-1:bw_psum*4]}},out[bw_psum*5-1:bw_psum*4]}
	+	{{(3){out[bw_psum*6-1:bw_psum*5]}},out[bw_psum*6-1:bw_psum*5]}
	+	{{(3){out[bw_psum*7-1:bw_psum*6]}},out[bw_psum*7-1:bw_psum*6]}
	+	{{(3){out[bw_psum*8-1:bw_psum*7]}},out[bw_psum*8-1:bw_psum*7]};
