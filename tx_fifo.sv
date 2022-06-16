module FIFO_Tx(
  output logic [31:0] Data_out,
  output logic full, empty,  reg_valid,
  input logic [31:0] Data_in, csr_addr,
  input logic reset,
  input logic clk, Wr_en, Tx_rd); // Need to understand what is wn and rn are for
  
  logic [3:0] wptr, rptr; // pointers tracking the stack
  logic [31:0] memory [15:0]; // the stack is 8 bit wide and 8 locations in size
  logic [15:0]	reg_full;
  logic [4:0] 	temp;
  logic [4:0] 	count;
  logic count2, reg_valid_flop,temp2,temp3,Wr_en_delayed,tx_addr_match;


integer i;
always_comb begin
  temp = '0; // fill 0s
  foreach(reg_full[i])
  begin
    temp += reg_full[i];
  end
  count = temp;
end

always_comb
	begin
			if(count==0)
				begin
					empty = 1;
					full = 0;
					
				end
			
			else if(count == 16)
				begin
					full = 1;
					empty = 0;
				end 
			else
				begin
					full = 0;
					empty = 0;
				end
			end





  always @(posedge reset)
  begin
  
        memory[0] <= 0; memory[1] <= 0; memory[2] <= 0; memory[3] <= 0;
        memory[4] <= 0; memory[5] <= 0; memory[6] <= 0; memory[7] <= 0;
	 memory[8] <= 0; memory[9] <= 0; memory[10] <= 0; memory[11] <= 0;
        memory[12] <= 0; memory[13] <= 0; memory[14] <= 0; memory[15] <= 0;
         wptr <= 0; rptr <= 0;reg_full <= 0; count2<= 1'b0; reg_valid_flop <= 0;
	temp3<=0;temp2<=0;Wr_en_delayed<=0;

      end
//always@(posedge clk && Wr_en)
	//begin
	//	Wr_en1 <= Wr_en;
	//end

always@(posedge clk)
begin
  reg_valid<= reg_valid_flop;
  Wr_en_delayed <= Wr_en;
end

always@(posedge clk  )
begin
if(csr_addr == 32'd2)
tx_addr_match<=1;
else
tx_addr_match<=0;

end


always @(posedge clk) //Writing Data into FIFO after one clock
begin


		if (Wr_en  && tx_addr_match && !full)
     		 begin
	
       			memory[wptr] <= Data_in;
			reg_full[wptr] <= 1;
      		  	wptr <= wptr + 1;
     		 end
    		 else 
    			 wptr <= wptr;
   


end
always @(negedge Tx_rd)
begin
reg_valid_flop<=0;
temp2<=0;
end

always @(posedge clk ) //Reading Data from FIFO using signal from Receiver
begin
	if(!empty && Tx_rd && !temp3 )
		temp3<=1;

	else if (temp3 && !empty && Tx_rd && !temp2)
      	begin
		Data_out <= memory[rptr];
		$display("Data_out is %d", memory[rptr]);
		reg_valid_flop <= 1;
        	rptr <= rptr + 1;
        	reg_full[rptr] <= 0;
		temp2<=1;
      	end

      	else
      	rptr<=rptr;
      	//rptr<= rptr;
end
endmodule