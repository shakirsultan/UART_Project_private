`include "intf.sv"

class transaction;
bit [31:0] data;
bit [31:0] addr;
bit is_write;
logic [31:0] tx_reg;
  
function new();
this.data=0;
this.addr=0;
this.is_write=1;
endfunction

function void display(string name);
$display("- %s",name);
$display("- data  = %0d",data);
$display("- addr  = %0d",addr);
$display("- is_write  = %0d",is_write);
$display("- tx_reg = %0d" ,tx_reg);
endfunction
endclass


class generator;
int repeat_count;
event drv_done;
transaction trans,trans2;
mailbox gen2drv;
mailbox gen2scb;
mailbox gen2mon;
  function new(mailbox gen2drv,mailbox gen2scb,mailbox gen2mon,int repeat_count);
	this.gen2drv=gen2drv;
	this.gen2scb=gen2scb;
	this.gen2mon=gen2mon;
	this.repeat_count=repeat_count;
endfunction	
 
  task run();

repeat(repeat_count) begin
trans=new();
trans.data=32'h00000378;
trans.addr=32'd0;
trans.is_write=1;
trans.display("[Generator] starting..");
gen2drv.put(trans);
gen2scb.put(trans);
gen2mon.put(trans);
#10;
trans2=new();
trans2.data=32'h00000378;
trans2.addr=32'd2;
trans2.is_write=1;
trans2.display("[Generator]");
gen2drv.put(trans2);
gen2scb.put(trans2);
end
@(drv_done);
$display("event trigered in [GENERATOR]..");
endtask
endclass


class driver;
int repeat_count;
virtual intf rinf;
//event drv_done;
mailbox gen2drv;
function new(mailbox gen2drv,int repeat_count,virtual intf rinf);
this.gen2drv=gen2drv;
this.repeat_count=repeat_count;
this.rinf=rinf;
endfunction
task run();
$display("[DRVIVE] starting..");
forever begin
transaction trans;
gen2drv.get(trans);
trans.display("[DRIVE]");
rinf.p_sel<=1;
rinf.p_enable<=1;
rinf.p_wr=trans.is_write;
rinf.p_addr=trans.addr;
rinf.pw_data=trans.data;
@(posedge rinf.clk);
while(!rinf.p_ready)
	begin
		$display("waiting for ready in [DRIVER]");
      @(posedge rinf.clk);	
	end
//->drv_done;
end
endtask
endclass


class monitor;
virtual intf rinf;
mailbox mon2scb;
mailbox gen2mon;
logic [31:0] conf;
  logic [19:0] count;
  logic tick;
  int repeat_count;
  bit [31:0] data;
  bit [31:0] addr;
  bit is_write;
function new(mailbox gen2mon,mailbox mon2scb,int repeat_count,virtual intf rinf);
this.gen2mon=gen2mon;
this.mon2scb=mon2scb;
this.repeat_count=repeat_count;
this.rinf=rinf;
endfunction
  
  
task run();
$display("[MONITOR] starting..");

forever begin 
int i=0;
int j=0;
  transaction trans = new();
  transaction trans2=new();
#10 gen2mon.get(trans2);//for configuration register
conf=trans2.data;
  //while(1)
    	
  @(posedge rinf.clk)
  begin
    	count=count+1;
    if(count== (conf[26:7])-1)
      	begin
          tick=1;
        end
    else
      tick=0;
  end
       // end
  
//@(posedge vif.tick)
for(i=0;i<32/(conf[3:0]);i++)
begin
wait(rinf.tx==0);//start
while(j<conf[3:0])
	begin
		
		trans.tx_reg[i]=rinf.tx;//d0
		j++;
		@(posedge tick);
	end
  if(conf[5]) @(posedge tick); //pairty state
  if(conf[4])begin @(posedge tick); @(posedge tick); end//stop1 stop2 states
	else @(posedge tick); //stop1 state
end

  for(;i<32;i++)
begin	
	wait(rinf.tx==0);//start
	trans.tx_reg[i]=rinf.tx;
  @(posedge tick);
end
	
  j=conf[3:0]-(32 % conf[3:0]); 
	if(j!=0)
		begin
	for(i=0;i<j;i++)
		begin
			@(posedge tick);
		end
          if(conf[5]) @(posedge tick); //pairty state
          if(conf[4])begin @(posedge tick); @(posedge tick); end//stop1 stop2 states
	else @(posedge tick); //stop1 state
end

mon2scb.put(trans);
trans.display("[MONITOR] starting..");
end
endtask



	

endclass
  
class scoreboard;
int repeat_count;
event drv_done;
mailbox mon2scb;
mailbox gen2scb;
mailbox gen2mon;
  bit [31:0] data,data1;
  bit [31:0] addr,addr1;
  bit is_write,is_write1;
//logic [31:0] memory;
  function  new(mailbox gen2scb, mailbox mon2scb, int repeat_count);
	this.gen2scb=new;

	//this.gen2scb=gen2scb;

	this.gen2mon=new;
	//this.gen2mon=gen2mon;
	//for(i=0;i<32;i++)
	//memory[i]=32'b0;
endfunction
task run();
transaction trans,trans1;
trans=new();
trans1=new();
mon2scb.get(trans);
trans.display("[SCOREBOARD] starting..");

gen2scb.get(trans1);
if(trans1.tx_reg==trans.data)
$display("test passed..");
else 
$display("test failed..");
endtask
endclass
  
  
class environment;
generator gen;
driver drv;
monitor mon;
scoreboard scb;
mailbox gen2drv, mon2scb, gen2scb, gen2mon;
virtual intf rinf;
int repeat_count;
event drv_done;
function new(virtual intf rinf,int repeat_count);
this.rinf = rinf;
this.repeat_count = repeat_count;
this.gen2drv=new();
this.mon2scb=new();
this.gen2scb=new();
this.gen2mon=new();
  this.gen=new( gen2drv,gen2scb,gen2mon,repeat_count);
this.drv=new( gen2drv,repeat_count, rinf);
this.mon=new( gen2mon, mon2scb, repeat_count, rinf);
this.scb = new(gen2scb,  mon2scb, repeat_count);
this.gen.drv_done=drv_done;
this.scb.drv_done=drv_done;
endfunction

  task run();
fork
	gen.run();
	drv.run();
	mon.run();
	scb.run();
join
endtask
endclass
  
  



  class test;
  	int repeat_count;
 	virtual intf rinf;
 	//initial begin
	environment env;
  
  function new(int repeat_count,virtual intf rinf);
    
    	this.repeat_count=repeat_count;
    	this.rinf = rinf;
    	env=new(rinf,repeat_count);
    
  	endfunction
 
 task run();
	fork
    env.run();
    join_none
    
  endtask
  endclass    

 module tb_top();  
    
  logic clk;
  logic rst;
  int repeat_count;
  intf rinf(.clk(clk),.rst(rst));
  test test_dut;
  topp dut  (.clk(clk),.rst(rst),.p_sel(rinf.p_sel),.p_en(rinf.p_enable),
	    .p_wr(rinf.p_wr),.pw_data(rinf.pw_data),.p_addr(rinf.p_addr),
	    .pr_data(rinf.pr_data),.p_ready(rinf.p_ready),.interupt_out(rinf.interupt_out),
 	    .pslverr(rinf.P_slv_err),.tx(rinf.tx), .rx(rinf.rx));
  
  
  
  always #5 clk=~clk;
  initial begin
   
   repeat_count = 1;
    clk=0;
    rst=1;    
    #10 rst=0;
  
    test_dut = new(repeat_count,rinf);
    //dut.env.rinf = rinf;
    test_dut.run();
  	
  end


endmodule