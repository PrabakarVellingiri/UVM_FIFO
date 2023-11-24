class read_agent extends uvm_agent ;
  `uvm_component_utils(read_agent)
  
  read_monitor r_monitor;
  read_driver r_driver;
  read_sequencer r_sequencer;
  
  function new(string name ="read_agent" , uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase (uvm_phase phase);
    super.build_phase(phase);
    r_driver= read_driver::type_id::create("r_driver",this);
    r_sequencer= read_sequencer::type_id::create("r_sequencer",this);
    r_monitor = read_monitor::type_id::create("r_monitor",this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    r_driver.seq_item_port.connect(r_sequencer.seq_item_export);
  endfunction
  
endclass
