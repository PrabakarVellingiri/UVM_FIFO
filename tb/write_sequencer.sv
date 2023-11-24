class write_sequencer extends uvm_sequencer#(my_transaction);
  `uvm_component_utils(write_sequencer)
  
  function new(string name = "write_sequencer", uvm_component parent);
    super.new(name , parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    `uvm_info("write_sequencer","build_phase",UVM_LOW);
  endfunction
  
endclass 
