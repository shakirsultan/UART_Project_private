// This is linear queue / FIFO
// The queue length 8
// The data width is also 8 bits
module FIFO_Rx(
		output logic [31:0] 	Data_out,
		input logic 		parity_err, frame_err, R_en, clk, reset, fifo_wr,
		input logic [31:0]	Data_in,
		output logic 		fifo_threshold, Data_err, Empty, Full, 
					parity_out, frame_out,
		output logic [3:0] 	err_id
						); 
		
		logic [3:0] 	wptr, rptr; // pointers tracking the stack
		logic [33:0] 	memory [15:0]; // the stack is 8 bit wide and 8 locations in size
		logic 		err_found;
		logic [31:0]	reg_full;
		logic [3:0] 	temp;
		logic [3:0] 	count;

  //assign Empty = (count==0) ? ((wptr==rptr) ? 1:0) : 0;
 // assign full = ((wptr == 4'b111) & (rptr == 4'b000) ? 1 : 0 );  

  
// always @(posedge clk)
// 	begin
// 		temp <= 0;
// 			for(int i; i<16;i++)
// 				begin
// 					temp  = temp + reg_full[i];
// 				end

// 		count<=temp;

// 	end
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
					Empty = 1;
					Full = 0;
					fifo_threshold = 0;
					
				end
			else if(count == 13)
				begin
					fifo_threshold = 1;
					Full = 0;
					Empty = 0;
				end
			else if(count == 15)
				begin
					Full = 1;
					fifo_threshold = 0;
					Empty = 0;
				end 
			else
				begin
					Full = 0;
					fifo_threshold = 0;
					Empty = 0;
				end
		//#5		$display("Wr_ptr = %d, Rd_ptr = %d",wptr,rptr);
		//		$display("Temp = %d,Full = %d, Fifo_threshold = %d ",count,Full,fifo_threshold);
	end

  always @(posedge reset)
  	begin
			memory[0] <= 0; memory[1] <= 0; memory[2] <= 0; memory[3] <= 0;
        		memory[4] <= 0; memory[5] <= 0; memory[6] <= 0; memory[7] <= 0;
        		memory[8] <= 0; memory[9] <= 0; memory[10] <= 0; memory[11] <= 0;
    			memory[12] <= 0; memory[13] <= 0; memory[14] <= 0; memory[15] <= 0;
    			Data_out <= 0; wptr <= 0; rptr <= 0; err_found <= 0; //Full <= 0; 
			 Data_err <= 0; reg_full <= 0;//fifo_threshold <= 0;
			parity_out <= 0; frame_out <= 0;// count <= 0;  //Empty <= 1;
			err_id<=0;
     	 	
	end
    
  always @(posedge fifo_wr )//Writing data in FIFO
	begin
		if(!Full) 
			begin
      			
            		memory[wptr] <= {parity_err,frame_err,Data_in};
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
		if(Data_err == 1)
			begin
				Data_err<=0;
			end
			else 
			Data_err<=Data_err;

     		if (R_en & !Empty)
      			begin
				Data_out <= memory[rptr][31:0];
				frame_out <= memory[rptr][32];
				parity_out <= memory[rptr][33];
				reg_full[rptr] <= 0;
				
				

				if ( (Data_err==0)&& memory[rptr][32] || memory[rptr][33])//If there is a frame or parity error
          				begin        	 					
						Data_err <= 1;
						err_id <= rptr;//Address of fifo location where error has occured 
					end
				else
					begin
						Data_err <= 0;
						err_id <= 0;
					end
				
		 		rptr <= rptr+1;
			end
		
		else
			rptr <= rptr;


		
			
			
		
   	 end





  
   // initial 
   // begin
  //$dumpfile("dump.vcd");
 // $dumpvars;
  //#20000;
  //$finish;
	//end
endmodule