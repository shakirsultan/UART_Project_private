module csr(clk,rst,r_en,w_en,addr,w_data,parity_error,frame_error,threshold,err_id,rx_fifo_out,config_reg,tx_fifo_in,r_data,slverr);
input logic clk , rst;
input logic r_en;
input logic w_en;
input logic [31:0] addr;
input logic [31:0] w_data;
input logic parity_error;
input logic frame_error;
input logic threshold;
input logic [3:0] err_id;
input logic [31:0] rx_fifo_out;

output logic [31:0] r_data;
output logic [31:0] config_reg;
output logic [31:0] tx_fifo_in;
output logic slverr;
//output logic frame;

logic [31:0] csr_mem [3:0];
always_ff @(posedge clk)
begin
	if(rst)
		begin
			csr_mem[0]=32'd0; //configuration
			csr_mem[1]=32'd0; //errors
			csr_mem[2]=32'd0; //tx_reg
			csr_mem[3]=32'd0; //rx_reg
			//err_id=0;
		end
	else if(w_en)
		begin
			csr_mem[addr]=w_data;
			//csr_mem[3]=rx_fifo_out;
		end
	else if(frame_error || parity_error || threshold)
			begin csr_mem[1]={{25'b0},{err_id},{threshold},{frame_error},{parity_error}};
				
			end
slverr=frame_error||parity_error;
	//else
	 if(r_en)
			csr_mem[addr] = rx_fifo_out;	
end


//uart side
assign tx_fifo_in = csr_mem[2];
assign config_reg = csr_mem[0];
assign r_data = csr_mem[3];

endmodule
