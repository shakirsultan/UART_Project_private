module FIFO_Tx(
  output logic [31:0] Data_out,
  output logic full, empty,
  input logic [31:0] Data_in, csr_addr,
  input logic reset,
  input logic clk, Wr_en, Out_en); // Need to understand what is wn and rn are for
  
  logic [3:0] wptr, rptr; // pointers tracking the stack
  logic [31:0] memory [15:0]; // the stack is 8 bit wide and 8 locations in size
  logic [15:0]	reg_full;
  logic [4:0] 	temp;
  logic [4:0] 	count;
  logic count2;

 // assign full = ( (wptr == 4'b1111) ? 1 : 0 );
  //assign empty = (wptr ==rptr) ? 1 : 0;
  
// always @(posedge clk)
// 	begin
// 		temp <= 0;
// 			for(int i=0; i<16;i++)
// 				begin
// 					temp  = temp + reg_full[i];
// 				end

// 		count<=temp;

// 	end
integer i;
always_comb begin
  temp = '0; // fill 0
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
		//#5		$display("Wr_ptr = %d, Rd_ptr = %d",wptr,rptr);
		//		$display("Temp = %d,Full = %d, Fifo_threshold = %d ",count,Full,fifo_threshold);
	end





  always @(posedge reset)
  begin
  
        memory[0] <= 0; memory[1] <= 0; memory[2] <= 0; memory[3] <= 0;
        memory[4] <= 0; memory[5] <= 0; memory[6] <= 0; memory[7] <= 0;
	 memory[8] <= 0; memory[9] <= 0; memory[10] <= 0; memory[11] <= 0;
        memory[12] <= 0; memory[13] <= 0; memory[14] <= 0; memory[15] <= 0;
         wptr <= 0; rptr <= 0;reg_full <= 0; count2<= 1'b0;

      end
//always@(posedge clk && Wr_en)
	//begin
	//	Wr_en1 <= Wr_en;
	//end




always @(posedge clk) //Writing Data into FIFO after one clock
begin

  if(Wr_en && (count2==0) && (csr_addr == 32'd2))
	begin
		//temp_reg <= Data_in;
		count2 <= count2+1; // To wait for one cycle
	end


  else if (count2==1) //Take data from memory mapped CSR after one cycle
	begin

    		if(Wr_en) 
		begin
			if (!full)
     		 	begin
	
       				memory[wptr] <= Data_in;
				reg_full[wptr] <= 1;
      		  		wptr <= wptr + 1;
     		 	end
    			 else begin
    				 wptr <= wptr;
				 count2 <=0;
			end
		end
		else if (!Wr_en)
		begin
			
   			if (!full)
     		 	begin
	
       				memory[wptr] <= Data_in;
				reg_full[wptr] <= 1;
      		  		wptr <= wptr + 1;
				count2 <= 0;
     		 	end
    			else 
			begin
    				 wptr <= wptr;
				 count2<=0;

			end
		end
  	end
  

end



always @(posedge Out_en ) //Reading Data from FIFO using signal from Receiver
begin
	if (!empty)
      	begin
		Data_out <= memory[rptr];
		$display("Data_out is %d", memory[rptr]);
        	rptr <= rptr + 1;
        	reg_full[rptr] <= 0;
      	end

      	else
      	rptr<=rptr;
      	//rptr<= rptr;
end
endmodule