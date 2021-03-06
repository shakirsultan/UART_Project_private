module tbench;
logic 	[31:0]	pw_data;
logic 	[31:0]	pr_data;
logic 		p_wr,p_sel,p_en;
logic 		rst;
logic 	[31:0]	p_addr;
logic in;
//logic 	[31:0] 	csr;

logic 		tx;
logic 		clk;
logic interupt_out;
initial begin
clk=0; 
forever #5 clk= ~ clk;
end

//uart_top uart_inst(.clk(clk),.w_en(w_en),.w_data(data_in),.rst(rst),.tx(out),.addr(addr),.r_en(r_en),.rx(rx),.ready(ready));
topp top_inst(.pclk(clk),.prst(rst),.p_sel(p_sel),.p_en(p_en),.p_wr(p_wr),.p_addr(p_addr),.pw_data(pw_data),.p_ready(p_ready),.pr_data(pr_data),.pslverr(pslverr),
	.tx(tx),.rx(tx),.interupt_out(interupt_out));
initial begin
		p_wr=0; p_sel=0;in=1;
		p_en=1;
  		rst=1;
	#10;	rst=1;	 p_sel=1;
	#20;	rst=0;	
	p_wr=1;pw_data=32'h0000_0778; p_addr=32'h0;
	//#5;	p_wr=0;
	//Wr_en=0;Out_en = 0;
	//	reset = 0;
	//#5	reset = 1;
   	//#5 	reset = 0;
		//p_wr=1;
	 // #1      pw_data = $urandom%30; p_addr=32'h2;
	
	//#20 pw_data = $urandom%30; p_addr=32'h2;
	//Out_en =1;
	//#1  p_wr = 0;

	#10; 	p_wr=1;pw_data=32'h3a3a_3a3a; p_addr=32'h2;
	#10;	pw_data=32'hf6f6_f6f6; p_addr=32'h2;
	#1;	 p_en=0;	
	#14000;	p_en=1;p_wr=0;	p_addr=32'd3;
	
	//#10	p_wr=0;
	/*#55;	p_wr=0;
		//pw_data=32'h0014_5a78;
    		//csr = 32'h0000135;
		//csr1= 32'h0000135;
      	
      		//csr = 32'h0000035;
		in=0;//start
	#20;
	
	in=1;//d0//////
	#20;
	in=0;//d1
	#20;
	in=1;//d2
	#20;
	in=0;//d3//////
	#20;
	in=0;//d4
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;

	in=0;//start
	#20;
	
	in=0;//d0
	#20;
	in=0;//d1
	#20;
	in=0;//d2/////////
	#20;
	in=1;//d3
	#20;
	in=0;//d4
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;

	in=0;//start
	#20;
	
	in=1;//d0
	#20;
	in=0;//d1///////
	#20;
	in=0;//d2
	#20;
	in=0;//d3
	#20;
	in=0;//d4
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;

	in=0;//start
	#20;
	
	in=0;//d0
	#20;
	in=1;//d1////////////
	#20;
	in=0;//d2
	#20;
	in=1;//d3
	#20;
	in=0;//d4//////////
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;

	in=0;//start
	#20;
	
	in=0;//d0
	#20;
	in=0;//d1
	#20;
	in=0;//d2
	#20;
	in=0;//d3
	#20;
	in=1;//d4////////
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;

	in=0;//start
	#20;
	
	in=0;//d0
	#20;
	in=1;//d1
	#20;
	in=0;//d2/////////
	#20;
	in=0;//d3
	#20;
	in=0;//d4
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;

	in=0;//start
	#20;
	
	in=0;//d0
	#20;
	in=0;//d1
	#20;
	in=1;//d2////////
	#20;
	in=0;//d3
	#20;
	in=1;//d4
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;
	//#1000;
	//in=1;*/

	end
endmodule
/*
module tbench;
  logic tick;
  logic rst;
  logic in;
  logic [31:0] csr;
  
  logic [31:0] out_reg;
  logic parity_error;
	logic frame_error;
	logic fifo_wr;

  logic fsm_error;
  //testbench signals
  //logic [8:0] i;
  rx dut(tick,rst,csr,in,parity_error,frame_error,fifo_wr,out_reg);
  always #10 tick = ~tick;
  initial begin
   	// $monitor("tick=%d,rst=%d,in=%d,outreg=%d,parity_error=%d,frame_error=%d",tick , rst, in, outreg, parity_error, frame_error);
    	tick=1;
    	rst=1;
    	csr=32'h00000025; //data with frame size 8
    	#20;
    	rst=0;
    	#20;
  
    	in=0;//start
	#20;
	
	in=1;//d0//////
	#20;
	in=0;//d1
	#20;
	in=1;//d2
	#20;
	in=0;//d3//////
	#20;
	in=0;//d4
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;

	in=0;//start
	#20;
	
	in=0;//d0
	#20;
	in=0;//d1
	#20;
	in=0;//d2/////////
	#20;
	in=1;//d3
	#20;
	in=0;//d4
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;

	in=0;//start
	#20;
	
	in=1;//d0
	#20;
	in=0;//d1///////
	#20;
	in=0;//d2
	#20;
	in=0;//d3
	#20;
	in=0;//d4
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;

	in=0;//start
	#20;
	
	in=0;//d0
	#20;
	in=1;//d1////////////
	#20;
	in=0;//d2
	#20;
	in=1;//d3
	#20;
	in=0;//d4//////////
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;

	in=0;//start
	#20;
	
	in=0;//d0
	#20;
	in=0;//d1
	#20;
	in=0;//d2
	#20;
	in=0;//d3
	#20;
	in=1;//d4////////
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;

	in=0;//start
	#20;
	
	in=0;//d0
	#20;
	in=1;//d1
	#20;
	in=0;//d2/////////
	#20;
	in=0;//d3
	#20;
	in=0;//d4
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;

	in=0;//start
	#20;
	
	in=0;//d0
	#20;
	in=0;//d1
	#20;
	in=1;//d2////////
	#20;
	in=0;//d3
	#20;
	in=1;//d4
	#20;

	in=0;//parity
	#20;
	in=1;//stop
	#20;
	//#1000;
	//in=1;

 
   // csr=32'h00000025; //data with frame size 5
	
   
  end
endmodule*/