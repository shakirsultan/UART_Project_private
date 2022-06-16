module topp(
	input logic 		clk,rst,
	input logic 		p_sel,
  	input logic 		p_en,
  	input logic 		p_wr,
	input logic 	[31:0] 	p_addr,
 	input logic 	[31:0] 	pw_data,
  	output logic 		p_ready,
	output logic 	[31:0] 	pr_data,
 	output logic 		pslverr,
	output logic 		interupt_out,
	//outside
	output logic		tx,
	input	logic		rx);

logic [31:0]	w_data;
logic [31:0]	r_data;
logic [31:0]	addr;
logic ready,w_en,r_en,slverr;
logic interupt_in;
uart_top uart_inst(.clk(clk),.rst(rst),.w_en(w_en),.r_en(r_en),.w_data(w_data),.addr(addr),.tx(tx),.rx(rx),.ready(ready),.slverr(slverr),.r_data(r_data),.interupt(interupt_in));
apb_slave slv_inst (.p_sel(p_sel),.p_en(p_en),.p_wr(p_wr),.p_addr(p_addr),.pw_data(pw_data),.p_ready(p_ready),.pr_data(pr_data),.pslverr(pslverr),
.ready(ready),.r_data(r_data),.slverr(slverr),.w_en(w_en),.r_en(r_en),.w_data(w_data),.addr(addr));
assign interupt_out=interupt_in;
endmodule
