module tx(
input  logic 	[31:0]	regdata,
input  logic 		tick,
input  logic 		rst,
input  logic 	[31:0] 	csr,
input  logic		fifo_empty,
output logic 		tx_done,
output logic 		out);

localparam 	idle	= 0,
  		start	= 1,
		data	= 2,
  		parity  = 3,
		stop1	= 4,
  		stop2   = 5;

logic [2:0] 	curr_st, n_st; 
logic [5:0] 	temp;
logic [3:0] 	count;
logic 		pbit,empty,count2;
logic [31:0] 	regd; 



//assign tx_done =(rst)?0:((curr_st==idle)?1:0);


always @(posedge tick)
begin

if (fifo_empty && count2 ==0)
	begin
	count2 <= 1;
	end
else if (fifo_empty && count2 ==1)
begin
empty <= 1;
end

else 
begin
empty <= 0;
count2 <= 0;
end
end




always @ (posedge tick or posedge rst)
begin
	if(rst)     
        	 curr_st<=idle;   
      	else      
      		curr_st<=n_st;
end

always_comb
begin
	case(curr_st) 
        idle :
	    	if(empty) n_st=idle;
	    	else
		n_st=start;
        start : 
		//if(fifo_empty) n_st=idle;
	    	//else
		 n_st=data;
	data : 
        begin
        	if (count<csr[3:0]-1) 
		begin
             	 	n_st=data; 
		end
            	else
              	begin
			if(csr[5]) 	
			begin
				n_st=parity;
			end
            		else 
			begin
				n_st=stop1;
			end
		end
	end
        parity:
	begin
		n_st=stop1;       
	end
        stop1 : 
	begin
		if(!csr[4])
              	begin
                	if(temp<32)
                  	begin       
                    		n_st=start;  
                  	end
                else
		begin                	
			n_st=idle;  
                    	
		end
		end
		else n_st=stop2;    
	end
	stop2:
	begin	       	
		if(temp<32)
                begin       
			n_st=start;  
                end
                else
                begin       
                    	n_st=idle; 
                end
	end    
	endcase      
end


always_comb
begin
	case(curr_st)
	idle: 
	begin
		pbit=0;
		tx_done=0;
		regd=regdata;
		out =(empty)?1:0;
	end
	start:
        begin
		tx_done=0;
		pbit=0;
	 	out=0;
        end
	data:
        begin
		out=regd[0]; 
		tx_done=0;   
		pbit=pbit^regd[0];                     
		regd=regd>>1; 
	end 
	parity:
		if(!csr[6]) out=pbit;
                else out=~pbit;
	stop1:	
	begin   
		if(!csr[4])
              	begin
                	if(temp<32)
                  	begin                
                    		tx_done= 0;
                  	end
               		else
			begin       
          			tx_done=1;       	
			end
		end 
		else tx_done=0;
 
		out=1;  
	end
	stop2:
	begin	         	
		if(temp<32)
                begin                  
                    	tx_done=0;
                end
                else
                begin         
                    	tx_done=1;
                end
		out=1;
	end    
	endcase
end

always@(posedge tick)
begin
	if(rst)
		begin
			count<=4'b0;
			temp<=5'b0;
		end
	else
		begin
			case(curr_st)
				idle:
					begin
						temp<=5'd1;count<=0;
					end
				data:
					begin
						count<=count + 1;
						temp<=temp + 1;
					end
				stop1:
					begin
						count<=4'd0;
					end
			endcase
			end
end
endmodule	  