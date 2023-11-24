class my_test extends uvm_test;
  `uvm_component_utils(my_test)
  
  my_env env;
  
  
  function new(string name ="my_test" , uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=my_env::type_id::create("env",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    virtual_sequence v_seq;
    v_seq=virtual_sequence::type_id::create("v_seq");
    
    phase.raise_objection(this);
   /* v_seq.w_sequencer = env.w_agent.w_sequencer;
    v_seq.r_sequencer = env.r_agent.r_sequencer;*/
    v_seq.start (env.vseqr);
    phase.drop_objection(this);
    
  endtask
  
endclass

class parl_test extends uvm_test;
  `uvm_component_utils(parl_test) 
  my_env env;
  function new(string name ="my_test" , uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=my_env::type_id::create("env",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    write_sequence seq1;
    read_sequence seq2;
    seq1=write_sequence::type_id::create("seq1");
    seq2=read_sequence::type_id::create("seq2");

    phase.raise_objection(this);
    fork
      seq1.start(env.agent.sequencer);
      seq2.start(env.agent.sequencer);
    join
    phase.drop_objection(this);
  endtask
endclass

class random_test extends uvm_test;
  `uvm_component_utils(random_test)
  my_env env;
  
  function new(string name ="random_test" , uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env=my_env::type_id::create("env",this);
  endfunction
  
  task run_phase(uvm_phase phase);
    random_sequence seq;
    seq=random_sequence::type_id::create("seq");
    phase.raise_objection(this);
    seq.start(env.agent.sequencer);
    phase.drop_objection(this);
  endtask
  
endclass



