class write_driver extends uvm_driver #(my_transaction);
  `uvm_component_utils(write_driver);
  virtual fifo_inf vif;
 // uvm_analysis_port #(my_transaction) ap;
  
  function new(string name ="write_driver" , uvm_component parent);
    super.new(name , parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual fifo_inf)::get(this,"","vif",vif))
      `uvm_error("Driver","No interface");
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
        drive();
      seq_item_port.item_done(req);
    
    //  `uvm_info("WRITE_DRIVER", $psprintf("AGENT recieved transaction %s", vif.convert2string()), UVM_LOW);
    end
  endtask
  
  virtual task drive();
    @(posedge vif.clk) begin
      if(req.wr_en && !req.rd_en) begin
      vif.wr_en <= req.wr_en;
      vif.D_in <= req.D_in;
     // vif.D_out <= req.D_out;
    end
    end
    
  endtask
    
endclass

class my_driver extends uvm_driver #(my_transaction);
  `uvm_component_utils(my_driver);
  virtual fifo_inf vif;
 // uvm_analysis_port #(my_transaction) ap;
  
  function new(string name ="mmy_driver" , uvm_component parent);
    super.new(name , parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual fifo_inf)::get(this,"","vif",vif))
      `uvm_error("Driver","No interface");
  endfunction
  
  task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
        drive();
      seq_item_port.item_done(req);
    
      //`uvm_info("DRIVER", $psprintf("AGENT recieved transaction %s", vif.convert2string()), UVM_LOW);
    end
  endtask
  
  virtual task drive();
    @(posedge vif.clk) begin
      if(!vif.rst) begin
        vif.D_out<=0;
      end
      else begin
     if(req.wr_en) begin
       vif.wr_en <= req.wr_en;
       // vif.full <= req.full;
      //vif.empty <= req.empty;
      vif.D_in <= req.D_in;
    end
        else if(req.rd_en) begin
     // vif.wptr <= req.wptr;
    //  vif.rptr <= req.rptr;
      vif.rd_en <= req.rd_en;
      vif.wr_en <= req.wr_en;
      //vif.full <= req.full;
      //vif.empty <= req.empty;
     // vif.D_out <= req.D_out;
    end
    end
    end
    
  endtask
    
endclass
