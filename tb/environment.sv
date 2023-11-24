class my_env extends uvm_env;
  `uvm_component_utils(my_env)
  
   write_agent w_agent;
   read_agent r_agent;
   virtual_sequencer vseqr;
   my_agent agent;
   my_scoreboard scoreboard;
   my_coverage  coverage;
  function new(string name="my_env", uvm_component parent);
    super.new(name ,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = my_agent::type_id::create("agent",this);
    w_agent=write_agent::type_id::create("w_agent",this);
    r_agent=read_agent::type_id::create("r_agent",this);
    scoreboard = my_scoreboard::type_id::create("scoreboard",this);
    vseqr= virtual_sequencer::type_id::create("vseqr",this);
    coverage = my_coverage::type_id::create("coverage" , this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    vseqr.w_sequencer = w_agent.w_sequencer;
    vseqr.r_sequencer = r_agent.r_sequencer;    
    agent.monitor.ap.connect(scoreboard.exp_port);
    w_agent.w_monitor.ap2.connect(scoreboard.exp_port);
    r_agent.r_monitor.ap1.connect(scoreboard.exp_port); 
    r_agent.r_monitor.ap1.connect(coverage.cov_export);
    w_agent.w_monitor.ap2.connect(coverage.cov_export);   
    agent.monitor.ap.connect(coverage.cov_export);

  endfunction
  
endclass
