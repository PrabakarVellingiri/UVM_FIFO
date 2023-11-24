class write_monitor extends uvm_monitor;
  `uvm_component_utils(write_monitor)
  
  uvm_analysis_port #(my_transaction) ap2;
  virtual fifo_inf vif;
  my_transaction seq;
  
  function new(string name ="write_monitor",uvm_component parent);
    super.new(name,parent);
    ap2 = new("ap2",this);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //`uvm_info ("WRITE_MONITOR","BUILD_phase",UVM_LOW);
    if(!uvm_config_db#(virtual fifo_inf )::get(this,"","vif",vif)) begin
      `uvm_error("WRITE_MONITOR","NO INTERFACE");
    end
  endfunction
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    seq=my_transaction::type_id::create("seq");
    
   forever @(posedge vif.clk) begin
     if(vif.wr_en) begin
        seq.wr_en = vif.wr_en;
      //  seq.rptr  = vif.rptr;
        seq.wptr  = vif.wptr;
        seq.D_in  = vif.D_in;
        seq.full  = vif.full;
     //`uvm_info("WRITE_MONITOR","write operation",UVM_LOW);
     // uvm_report_info("monitor", $psprintf("Data in monitor: \nwr_rd= %0h \nfull= %0h  \nD_in= %0h",seq.wr_en,seq.full,seq.D_in),UVM_LOW);
      end
     
     ap2.write(seq);
   end
    
  endtask
  
endclass
