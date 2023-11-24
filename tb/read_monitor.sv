class read_monitor extends uvm_monitor;
  `uvm_component_utils(read_monitor)
  
  uvm_analysis_port #(my_transaction) ap1;
  virtual fifo_inf vif;
  my_transaction seq;
  
  function new(string name ="read_monitor",uvm_component parent);
    super.new(name,parent);
    ap1 = new("ap1",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info ("READ_MONITOR","BUILD_phase",UVM_LOW);
    if(!uvm_config_db#(virtual fifo_inf )::get(this,"","vif",vif)) begin
      `uvm_error("READ_MONITOR","NO INTERFACE");
    end
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=my_transaction::type_id::create("seq");
    
   forever @(posedge vif.clk) begin
     if(vif.rd_en) begin
        seq.rd_en = vif.rd_en;
      //  seq.wptr  = vif.wptr;
        seq.rptr  = vif.rptr; 
        seq.empty = vif.empty;
        @(negedge vif.clk) 
        seq.D_out = vif.D_out;
           //  uvm_report_info("monitor", $psprintf("Data in monitor: \nrd_en= %0h \nfull= %0h  \nD_out= %0h",seq.rd_en,seq.empty,seq.D_out));
      // `uvm_info("READ_MONITOR","read operation",UVM_LOW);
      end
     ap1.write(seq);
   end
    
  endtask
  
endclass

class my_monitor extends uvm_monitor;
  `uvm_component_utils(my_monitor)
  
  uvm_analysis_port #(my_transaction) ap;
  virtual fifo_inf vif;
  my_transaction seq;
  
  function new(string name ="my_monitor",uvm_component parent);
    super.new(name,parent);
    ap = new("ap",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     `uvm_info ("MONITOR","BUILD_phase",UVM_LOW);
    if(!uvm_config_db#(virtual fifo_inf )::get(this,"","vif",vif)) begin
      `uvm_error("MONITOR","NO INTERFACE");
    end
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=my_transaction::type_id::create("seq");
    
   forever @(posedge vif.clk) begin
     if(vif.wr_en) begin
        seq.wptr  = vif.wptr;
       // seq.rptr  = vif.rptr;
        seq.wr_en = vif.wr_en;
        seq.full  = vif.full;
        seq.D_in  = vif.D_in;
       //`uvm_info("MONITOR","write operation",UVM_LOW);
      //  uvm_report_info("monitor", $psprintf("Data in monitor: \nwr_en= %0h \nfull= %0h  \nD_in= %0h",seq.wr_en,seq.full,seq.D_in));
      end
     else if(vif.rd_en) begin
        seq.rd_en = vif.rd_en;
        seq.rptr  = vif.rptr;
       // seq.wptr  = vif.wptr;
        seq.empty = vif.empty;
        @(negedge vif.clk)
        seq.D_out <= vif.D_out;
      //  uvm_report_info("monitor", $psprintf("Data in monitor: \nrd_en= %0h \nempty= %0h  \nD_out= %0h",seq.rd_en,seq.empty,seq.D_out));
       // `uvm_info("MONITOR","read operation",UVM_LOW);
      end
     ap.write(seq);
   end
    
  endtask
  
endclass
