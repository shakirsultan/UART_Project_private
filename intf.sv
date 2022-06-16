interface intf(input logic clk, input logic rst);
logic p_sel;
logic p_enable;
logic p_wr;
logic [31:0] pw_data;
logic [31:0] p_addr;
  logic [31:0] pr_data;
logic p_ready;
logic P_slv_err;
logic tx,rx,interupt_out;
  
endinterface :intf

