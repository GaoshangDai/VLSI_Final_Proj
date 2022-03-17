// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_16in (out, a, b, clk);

parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16; // parallel factor: number of inputs = 64

output [bw_psum-1:0] out;
input  [pr*bw-1:0] a;
input  [pr*bw-1:0] b;
input  clk;


wire		[2*bw-1:0]	product0	;
wire		[2*bw-1:0]	product1	;
wire		[2*bw-1:0]	product2	;
wire		[2*bw-1:0]	product3	;
wire		[2*bw-1:0]	product4	;
wire		[2*bw-1:0]	product5	;
wire		[2*bw-1:0]	product6	;
wire		[2*bw-1:0]	product7	;
wire		[2*bw-1:0]	product8	;
wire	[2*bw-1:0]	product9	;
wire		[2*bw-1:0]	product10	;
wire		[2*bw-1:0]	product11	;
wire		[2*bw-1:0]	product12	;
wire		[2*bw-1:0]	product13	;
wire		[2*bw-1:0]	product14	;
wire		[2*bw-1:0]	product15	;

reg		[2*bw-1:0]      mid1_gate0	;
reg		[2*bw-1:0]      mid1_gate1	;
reg		[2*bw-1:0]      mid1_gate2	;
reg		[2*bw-1:0]      mid1_gate3	;
reg		[2*bw-1:0]      mid1_gate4	;
reg		[2*bw-1:0]      mid1_gate5	;
reg		[2*bw-1:0]      mid1_gate6	;
reg		[2*bw-1:0]      mid1_gate7	;
reg		[2*bw-1:0]      mid1_gate8	;
reg		[2*bw-1:0]      mid1_gate9	;
reg		[2*bw-1:0]      mid1_gate10	;
reg		[2*bw-1:0]      mid1_gate11	;
reg		[2*bw-1:0]      mid1_gate12	;
reg		[2*bw-1:0]      mid1_gate13	;
reg		[2*bw-1:0]      mid1_gate14	;
reg		[2*bw-1:0]      mid1_gate15	;



genvar i;


assign	product0	=	{{(bw){a[bw*	1	-1]}},	a[bw*	1	-1:bw*	0	]}	*	{{(bw){b[bw*	1	-1]}},	b[bw*	1	-1:	bw*	0	]};
assign	product1	=	{{(bw){a[bw*	2	-1]}},	a[bw*	2	-1:bw*	1	]}	*	{{(bw){b[bw*	2	-1]}},	b[bw*	2	-1:	bw*	1	]};
assign	product2	=	{{(bw){a[bw*	3	-1]}},	a[bw*	3	-1:bw*	2	]}	*	{{(bw){b[bw*	3	-1]}},	b[bw*	3	-1:	bw*	2	]};
assign	product3	=	{{(bw){a[bw*	4	-1]}},	a[bw*	4	-1:bw*	3	]}	*	{{(bw){b[bw*	4	-1]}},	b[bw*	4	-1:	bw*	3	]};
assign	product4	=	{{(bw){a[bw*	5	-1]}},	a[bw*	5	-1:bw*	4	]}	*	{{(bw){b[bw*	5	-1]}},	b[bw*	5	-1:	bw*	4	]};
assign	product5	=	{{(bw){a[bw*	6	-1]}},	a[bw*	6	-1:bw*	5	]}	*	{{(bw){b[bw*	6	-1]}},	b[bw*	6	-1:	bw*	5	]};
assign	product6	=	{{(bw){a[bw*	7	-1]}},	a[bw*	7	-1:bw*	6	]}	*	{{(bw){b[bw*	7	-1]}},	b[bw*	7	-1:	bw*	6	]};
assign	product7	=	{{(bw){a[bw*	8	-1]}},	a[bw*	8	-1:bw*	7	]}	*	{{(bw){b[bw*	8	-1]}},	b[bw*	8	-1:	bw*	7	]};
assign	product8	=	{{(bw){a[bw*	9	-1]}},	a[bw*	9	-1:bw*	8	]}	*	{{(bw){b[bw*	9	-1]}},	b[bw*	9	-1:	bw*	8	]};
assign	product9	=	{{(bw){a[bw*	10	-1]}},	a[bw*	10	-1:bw*	9	]}	*	{{(bw){b[bw*	10	-1]}},	b[bw*	10	-1:	bw*	9	]};
assign	product10	=	{{(bw){a[bw*	11	-1]}},	a[bw*	11	-1:bw*	10	]}	*	{{(bw){b[bw*	11	-1]}},	b[bw*	11	-1:	bw*	10	]};
assign	product11	=	{{(bw){a[bw*	12	-1]}},	a[bw*	12	-1:bw*	11	]}	*	{{(bw){b[bw*	12	-1]}},	b[bw*	12	-1:	bw*	11	]};
assign	product12	=	{{(bw){a[bw*	13	-1]}},	a[bw*	13	-1:bw*	12	]}	*	{{(bw){b[bw*	13	-1]}},	b[bw*	13	-1:	bw*	12	]};
assign	product13	=	{{(bw){a[bw*	14	-1]}},	a[bw*	14	-1:bw*	13	]}	*	{{(bw){b[bw*	14	-1]}},	b[bw*	14	-1:	bw*	13	]};
assign	product14	=	{{(bw){a[bw*	15	-1]}},	a[bw*	15	-1:bw*	14	]}	*	{{(bw){b[bw*	15	-1]}},	b[bw*	15	-1:	bw*	14	]};
assign	product15	=	{{(bw){a[bw*	16	-1]}},	a[bw*	16	-1:bw*	15	]}	*	{{(bw){b[bw*	16	-1]}},	b[bw*	16	-1:	bw*	15	]};


always @(posedge clk) begin
	mid1_gate0 <= product0;
	mid1_gate1 <= product1;
	mid1_gate2 <= product2;
	mid1_gate3 <= product3;
	mid1_gate4 <= product4;
	mid1_gate5 <= product5;
	mid1_gate6 <= product6;
	mid1_gate7 <= product7;
	mid1_gate8 <= product8;
	mid1_gate9 <= product9;
	mid1_gate10 <= product10;
	mid1_gate11 <= product11;
	mid1_gate12 <= product12;
	mid1_gate13 <= product13;
	mid1_gate14 <= product14;
	mid1_gate15 <= product15;
end



assign out = 
                {{(4){mid1_gate0[2*bw-1]}},mid1_gate0	}
	+	{{(4){mid1_gate1[2*bw-1]}},mid1_gate1	}
	+	{{(4){mid1_gate2[2*bw-1]}},mid1_gate2	}
	+	{{(4){mid1_gate3[2*bw-1]}},mid1_gate3	}
	+	{{(4){mid1_gate4[2*bw-1]}},mid1_gate4	}
	+	{{(4){mid1_gate5[2*bw-1]}},mid1_gate5	}
	+	{{(4){mid1_gate6[2*bw-1]}},mid1_gate6	}
	+	{{(4){mid1_gate7[2*bw-1]}},mid1_gate7	}
	+	{{(4){mid1_gate8[2*bw-1]}},mid1_gate8	}
	+	{{(4){mid1_gate9[2*bw-1]}},mid1_gate9	}
	+	{{(4){mid1_gate10[2*bw-1]}},mid1_gate10	}
	+	{{(4){mid1_gate11[2*bw-1]}},mid1_gate11	}
	+	{{(4){mid1_gate12[2*bw-1]}},mid1_gate12	}
	+	{{(4){mid1_gate13[2*bw-1]}},mid1_gate13	}
	+	{{(4){mid1_gate14[2*bw-1]}},mid1_gate14	}
	+	{{(4){mid1_gate15[2*bw-1]}},mid1_gate15	};



endmodule
