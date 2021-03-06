module rx(tick,rst,csr,in,parity_error,frame_error,fifo_wr,data_out);

input logic tick;
input logic rst;
input logic in;
input logic [31:0] csr;

logic [34:0] sr;
logic [31:0] d;
output logic parity_error;
output logic frame_error;
logic frame_error1;
logic frame_error2;
output logic fifo_wr;
output logic [31:0] data_out;

logic [3:0] count_data;
logic [5:0] count_fsm;
logic parity_bit;
logic rcvd_parity;
  enum logic [2:0] {idle=3'b000,start=3'b001,data=3'b010,parity=3'b011,stop1=3'b100,stop2=3'b101} state,next;

//assign data_out = sr[34:3];
assign data_out = d;

always_ff @(posedge tick or posedge rst)
	begin
		if(rst)
			begin
				state<=idle;
				
			end
				
		else
			state<= #1 next;
	end
	
	
	
always_comb
	begin
		case(state)
			idle:
				begin
					
					if(in)
						next=idle;
					else
						next=start;
					
				end
			start:
				begin
						next=data;
              					//parity_bit=0;
				end
			data:
				begin
					
					
					next=(count_data < csr[3:0])?data:((csr[5])?parity:stop1);
				end
			parity:
				begin
					next=stop1;
				end
			stop1:
				begin
					if(csr[4])
						next=stop2;
					else if(count_fsm<32)
						next=start;
					else
						next=idle;
				end
			stop2:
				begin
					if(count_fsm<32)
						next=start;
					else
						next=idle;
				end
		endcase
	end


always_ff @(posedge tick  or     posedge rst)
begin
	if(rst)
		begin
			count_data<=32'd1;
			count_fsm<=32'd0;
		end
	else
		begin
			case(state)
				idle:
					begin
						count_fsm<=32'd0;
						//sr<=32'd0;
						d=0;parity_error=0;
					end
				start:
					begin parity_bit <=0;parity_error=0;end
				data:
					begin
						count_data <= count_data + 4'b0001;
						count_fsm <= count_fsm + 6'b000001;
						parity_bit <= parity_bit ^ in ;
						//outreg[0]<= in;
						//outreg <= outreg<<1;
						parity_error=0;
						//outreg[count_fsm] = in;
						
					end
				parity:
					parity_error = (csr[6]) ?  (rcvd_parity ^ (~parity_bit)):(rcvd_parity ^ parity_bit);
				stop1:
					begin
						count_data<=32'd1;
					end
			endcase
		end
end


always_ff @(posedge tick )
	begin
		case(state)
			idle: sr=35'd0;
			data: 
			begin 
				sr={in,sr[33:0]}; sr=sr>>1;
				if(count_fsm==31) d=sr[33:2];
				else d=d;
			 end
		endcase
	end



always_comb 
	begin
		case(state)
			idle:
				begin
					frame_error=0;
					
					fifo_wr=0;
					//outreg[0]=in;
					
				end
			start:
				begin
					frame_error=0;
					//parity_error=0;
					fifo_wr=0;//parity_bit=0;
				end
			data:
				begin
					//outreg[count_fsm] = in;
					frame_error=0;
					//parity_error=0;
					//fifo_wr=0;
					//fifo_wr=(count_fsm==32)?1:0;
					 
					//data_out = (count_fsm>32)
					//outreg = outreg>>1;
				end
			parity:	begin
					rcvd_parity=in;
					//fifo_wr=1;
					//parity_error = rcvd_parity ^ parity_bit;
					
					//parity_error = ~((csr[6]) ? ~(rcvd_parity | parity_bit): (rcvd_parity | parity_bit));
				end
			stop1:begin	//frame_error = (in==0) ? 0 : 1; fifo_wr=0; parity_error=0;
					
					frame_error = (in) ? 0 : 1; 
					fifo_wr=(~csr[4]&(count_fsm>31))?1:0;
					
				end
			stop2:begin	frame_error1 = (in) ? 0 : 1;
 					frame_error=frame_error1|frame_error;
					fifo_wr=(count_fsm>31)?1:0;	end
				//frame_error = (in) ? 0 : 1;
		endcase
	end
endmodule