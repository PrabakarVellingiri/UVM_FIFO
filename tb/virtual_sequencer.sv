class virtual_sequencer extends uvm_sequencer#(my_transaction);
  `uvm_component_utils(virtual_sequencer)
  
  write_sequencer w_sequencer;
  read_sequencer r_sequencer;			
  
  function new(string name = "virtual_sequencer", uvm_component parent);
    super.new(name , parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    `uvm_info("virtual_sequencer","build_phase",UVM_LOW);
  endfunction
  
endclass 
