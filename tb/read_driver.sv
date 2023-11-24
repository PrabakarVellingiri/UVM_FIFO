class read_driver extends uvm_driver #(my_transaction);
  `uvm_component_utils(read_driver);
  virtual fifo_inf vif;
 // uvm_analysis_port #(my_transaction) ap;
  
  function new(string name ="read_driver" , uvm_component parent);
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
    
     // `uvm_info("READ_DRIVER", $psprintf("AGENT recieved transaction %s", vif.convert2string()), UVM_LOW);
    end
  endtask
  
  task drive();
    @(posedge vif.clk) begin
      if(!req.wr_en && req.rd_en) begin
     // vif.wptr  <= req.wptr;
      vif.wr_en <= req.wr_en;
      vif.rd_en <= req.rd_en;
      //vif.rptr  <= req.rptr;
      vif.empty <= req.empty;
    end
    end
    
  endtask
    
endclass
