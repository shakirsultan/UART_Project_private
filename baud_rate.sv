module baud_rate_gen(
  input logic [31:0] csr,
  input logic clk,rst,
  output logic tick_tx, tick_rx);
  logic [19:0] counter;
  logic [10:0] counter2;
logic temp;
 
  
  always @ (posedge clk)
  begin
	if(rst)
	begin
		counter <= 0;
    		tick_tx <= 0;	
		tick_rx <= 0;
		counter2<= 0;
	end

	else 
	begin
   		 counter <= counter+1;
		

      		if (counter == (csr[26:7])-1)//csr[15:7] is tick rate
    		 	begin 
       			tick_tx <= 1;
 			counter<=0;
			counter2 <=0;
			temp <= 0;
                  $display("Value of csr is %d",(csr[26:7])-1);
			
     		 	end
      		  		
		
		else 
		begin
		
		 tick_tx <= 0;
		end
	end
  end

always@(posedge clk) begin

 counter2 <= counter2+1;
if( (counter2==(((csr[26:7])/2)-1)) && (temp==0))
		 	begin 
       			tick_rx <= 1;
 			counter2<=0;
			temp <= 1 ;
              $display("Value of csr is %d",((csr[26:7])/2));
			
     		 	end
else 
		begin
		 tick_rx <= 0;
end
end


  /*initial 
    begin
  $dumpfile("dump.vcd");
  $dumpvars;
  #20000;
  $finish;
	end*/
endmodule