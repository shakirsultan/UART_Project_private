module uart_top(
input logic 		clk,
input logic 		rst,
input logic 		w_en,
input logic		r_en,
input logic 	[31:0] 	w_data,
input logic 	[31:0]	addr,
//input logic 		in,
output logic 	[31:0] 	r_data,
output logic 		tx,
input logic		rx,
output logic 		ready,slverr,interupt);

logic 		[31:0] 	tx_fifo_in;
logic 		[31:0]	data,data_outrx,Data_out;
logic 			tick;
logic 		[31:0]	config_reg;
logic			fifo_empty,parity_out,frame_out,fifo_threshold;
logic 		[3:0]	err_id;
logic 			tx_done,parity_error,frame_error,fifo_wr;
logic rf_full;

FIFO_Tx  tf_inst  (.Data_out(data),.csr_addr(addr), .full(full), .empty(fifo_empty), .Data_in(tx_fifo_in), .clk(clk), .reset(rst), .Wr_en(w_en), .Out_en(tx_done));
//FIFO_Tx  tf_inst  (.Data_out(data), .full(full), .empty(fifo_empty), .Data_in(tx_fifo_in), .clk(clk), .Wr_en(w_en), .Out_en(tx_done));
tx  tx_inst  (.regdata(data), .tick(tick),.rst(rst),.csr(config_reg),.fifo_empty(fifo_empty),.tx_done(tx_done),.out(tx));
baud_rate_gen   b_inst  (.csr(config_reg),.clk(clk),.rst(rst),.tick(tick));
csr  csr_inst  (.slverr(slverr),.clk(clk),.rst(rst),.r_en(r_en),.w_en(w_en),.addr(addr),.w_data(w_data),.parity_error(parity_out),.frame_error(frame_out),.threshold(fifo_threshold),.rx_fifo_out(Data_out),.err_id(err_id),.config_reg(config_reg),.tx_fifo_in(tx_fifo_in),.r_data(r_data));

FIFO_Rx rf_inst(.Data_out(Data_out),.parity_err(parity_error), .frame_err(frame_error), .R_en(r_en), .clk(clk), .reset(rst), .fifo_wr(fifo_wr),
.Data_in(data_outrx),.fifo_threshold(fifo_threshold),  .Empty(rf_empty), .Full(rf_full), .parity_out(parity_out), .frame_out(frame_out),.err_id(err_id));

rx rx_inst(.tick(tick),.rst(rst),.csr(config_reg),.in(rx),.parity_error(parity_error),.frame_error(frame_error),.fifo_wr(fifo_wr),.data_out(data_outrx));
//assign ready=(~rf_empty)&(((~w_en)&(r_en))|((~full)&(w_en)&(~r_en)));
//ready = E' (w' rd + F' w rd')
//assign ready = ((~rf_empty)&(full)&(~w_en)&(r_en)) |(((~full)&(w_en)) & ((~rf_empty) |((rf_empty)&(r_en))));
assign ready =(full && rf_empty)?0:1;
assign interupt=fifo_threshold || rf_full;
endmodule
