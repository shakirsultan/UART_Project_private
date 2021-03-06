module apb_slave(
	//master side
  	input logic 		pclk,
	input logic		prst,
	input logic 		p_sel,
  	input logic 		p_en,
  	input logic 		p_wr,
	input logic 	[31:0] 	p_addr,
 	input logic 	[31:0] 	pw_data,
  	output logic 		p_ready,
	output logic 	[31:0] 	pr_data,
 	output logic 		pslverr,
	
  	//uart side
	output logic 		clk,
	output logic		rst,
  	input logic 		ready,
  	input logic 	[31:0]	r_data,
	input logic 		slverr,
  	output logic 		w_en,
	output logic 		r_en,
	output logic 	[31:0]	w_data,
	output logic 	[31:0]  addr);
assign clk=pclk;
assign rst=prst;
always_comb
if(p_sel&&p_en)
begin
	p_ready=ready;
	addr=p_addr;
	pslverr=slverr;
	pr_data=r_data;
	w_data=pw_data;
	w_en=p_wr;
	r_en=~p_wr;
end
else
p_ready=0;
endmodule



