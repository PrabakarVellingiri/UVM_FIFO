class write_agent extends uvm_agent ;
  `uvm_component_utils(write_agent)
  
  write_monitor w_monitor;
  write_driver w_driver;
  write_sequencer w_sequencer;
  
  function new(string name ="write_agent" , uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    w_driver= write_driver::type_id::create("w_driver",this);
    w_sequencer= write_sequencer::type_id::create("w_sequencer",this);
    w_monitor = write_monitor::type_id::create("w_monitor",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    w_driver.seq_item_port.connect(w_sequencer.seq_item_export);
  endfunction
  
endclass

class my_agent extends uvm_agent ;
  `uvm_component_utils(my_agent)
  
  my_monitor monitor;
  my_driver driver;
  my_sequencer sequencer;
  
  function new(string name ="agent" , uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    driver= my_driver::type_id::create("driver",this);
    sequencer= my_sequencer::type_id::create("sequencer",this);
    monitor = my_monitor::type_id::create("monitor",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
  
endclass
