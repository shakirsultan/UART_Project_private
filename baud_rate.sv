
module baud_rate_gen(
  input logic [31:0] csr,
  input logic clk,rst,
  output logic tick);
  logic [19:0] counter;
  
 
  
  always @ (posedge clk)
  begin
	if(rst)
	begin
		counter <= 0;
    		tick <= 0;
	end
	else 
	begin
   		 counter <= counter+1;

      if (counter == csr[26:7]-1)//csr[26:7] is tick rate
    		 begin 
       			 tick <= 1;
     		 end
      else if (counter == csr[26:7])
     		 begin
       			 tick <= 0;
       			 counter<=0;
     		 end
	end
  end
  //initial 
   // begin
  //$dumpfile("dump.vcd");
  //$dumpvars;
  //#20000;
  //$finish;
	//end
endmodule
    
        