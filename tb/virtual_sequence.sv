class virtual_sequence extends uvm_sequence;
  `uvm_object_utils(virtual_sequence)
  `uvm_declare_p_sequencer(virtual_sequencer)
  
  write_sequence w_seq;
  read_sequence r_seq;
  
 /* write_sequencer w_sequencer;
  read_sequencer r_sequencer;*/
  
  function new(string name="virtual_sequence");
    super.new(name);
  endfunction
  
  task pre_body(); 
    w_seq = write_sequence::type_id::create("w_seq");
    r_seq = read_sequence::type_id::create("r_seq");
  endtask
  
  task body();
    `uvm_info("virtual_sequence","build_phase",UVM_LOW);
   //fork
   w_seq.start(p_sequencer.w_sequencer);
   r_seq.start(p_sequencer.r_sequencer);
   //join
  endtask
  
endclass
