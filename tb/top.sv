`include "uvm_macros.svh"
//`include "fifo.sv"
//`include "assertion.sv"
//`include "bind_assertion.sv"
`include "interface.sv"
//import questa_uvm_pkg::*;
import uvm_pkg::*;
`include "package.sv"
import fifo_pkg::*;

module top;
  
  logic clk,rst;
  
  fifo_inf vif(clk,rst);
  
  fifo dut ( .clk(vif.clk), .rst(vif.rst), .wr_en(vif.wr_en),.rd_en(vif.rd_en),.full(vif.full),.empty(vif.empty), .data_in(vif.D_in), .data_out(vif.D_out),.wptr(vif.wptr),.rptr(vif.rptr));
  
  
  initial begin
   clk <= 0;
   forever #10 clk <= !clk;
  end
  
  initial begin
    rst = 0;
    #10 rst =1;
  end
  
  initial begin
    uvm_config_db#(virtual fifo_inf)::set(null,"*","vif",vif); 
    run_test("");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
   // #1000 $finish;
  end
  
endmodule
