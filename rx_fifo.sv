module FIFO_Rx(
		output logic [31:0] 	Data_out,
		input logic 		R_en, clk, reset, fifo_wr,
		input logic [33:0]	Data_in,
		input logic 		csr_config,
		output logic 		fifo_threshold, Empty, Full, 
					parity_out, frame_out,
		output logic [3:0] 	err_id); 
		
		logic [3:0] 	wptr, rptr; // pointers tracking the stack
		logic [33:0] 	memory [15:0]; // the stack is 8 bit wide and 8 locations in size
		logic 		err_found;
		logic [31:0]	reg_full;
		logic [3:0] 	temp;
		logic [3:0] 	count;
		logic empty_flop;

  
integer i;
always_comb begin //Counts FIFO fill
  	temp = '0; // fill 0s
  	foreach(reg_full[i])
  		begin
   		 temp += reg_full[i];
  		end
  	count = temp;
end

always@(posedge clk)
	begin
	  Empty<=empty_flop;
	end

always_comb //Check whether fifo is empty,full or at threshold
	begin
			if(count==0)
				begin
					empty_flop = 1;
					Full = 0;
					fifo_threshold = 0;
					
				end
			else if(count == 13)
				begin
					fifo_threshold = 1;
					Full = 0;
					empty_flop = 0;
				end
			else if(count == 15)
				begin
					Full = 1;
					fifo_threshold = 0;
					empty_flop = 0;
				end 
			else
				begin
					Full = 0;
					fifo_threshold = 0;
					empty_flop = 0;
				end
			end

  always @(posedge reset)
  	begin
			memory[0] <= 0; memory[1] <= 0; memory[2] <= 0; memory[3] <= 0;
        		memory[4] <= 0; memory[5] <= 0; memory[6] <= 0; memory[7] <= 0;
        		memory[8] <= 0; memory[9] <= 0; memory[10] <= 0; memory[11] <= 0;
    			memory[12] <= 0; memory[13] <= 0; memory[14] <= 0; memory[15] <= 0;
    			Data_out <= 0; wptr <= 0; rptr <= 0; err_found <= 0; 
			reg_full <= 0; parity_out <= 0; frame_out <= 0;	err_id<=0;
     	 	
	end

always@(posedge csr_config)//flush fifo if this CSR is goes high.
	begin
			memory[0] <= 0; memory[1] <= 0; memory[2] <= 0; memory[3] <= 0;
        		memory[4] <= 0; memory[5] <= 0; memory[6] <= 0; memory[7] <= 0;
        		memory[8] <= 0; memory[9] <= 0; memory[10] <= 0; memory[11] <= 0;
    			memory[12] <= 0; memory[13] <= 0; memory[14] <= 0; memory[15] <= 0;
    			Data_out <= 0; wptr <= 0; rptr <= 0; err_found <= 0; 
			reg_full <= 0; parity_out <= 0; frame_out <= 0;	err_id<=0;


	end

    
  always @(posedge fifo_wr )//Writing data in FIFO
	begin
		if(!Full) 
			begin
      			
            		memory[wptr] <= Data_in;
					reg_full[wptr] <= 1;
					wptr <= wptr+1;
    	//#5      $display("The data is %d---Parity_err=%d----Frame_err=%d",Data_in, parity_err, frame_err);
		//$display("value at memory location %d is %d",wptr,memory[wptr]);
     			
        	
			end
		else
			wptr <= wptr;
  	end
    
  
  
  always @(posedge clk)//reading data
    	begin
		

     		if (R_en & !empty_flop)
      			begin
				Data_out <= memory[rptr][31:0];
				parity_out <= memory[rptr][32];
				frame_out <= memory[rptr][33];
				
				reg_full[rptr] <= 0;
				
				

				if (  memory[rptr][32] || memory[rptr][33])//If there is a frame or parity error
          				begin        	 					
				
						err_id <= rptr;//Address of fifo location where error has occured 
					end
				else
					begin
				
						err_id <= 0;
					end
				
		 		rptr <= rptr+1;
			end
		
		else
			rptr <= rptr;			
			
		
   	 end



endmodule