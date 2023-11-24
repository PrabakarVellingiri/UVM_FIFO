class my_scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(my_scoreboard)
  virtual fifo_inf vif;
  uvm_analysis_imp#(my_transaction, my_scoreboard) exp_port;
  
  my_transaction s1[$];
   bit [7:0]mem[7:0];
   
  function new(string name, uvm_component parent);
    super.new(name, parent);
      if(!uvm_config_db#(virtual fifo_inf)::get(this,"","vif",vif))
      `uvm_error("Driver","No interface");

  endfunction
  
  function void build_phase(uvm_phase phase);
    exp_port = new("exp_port",this);
  endfunction
  
  function void write(my_transaction tr);
   // $display("SCB:: Pkt recived");
    s1.push_back(tr);
  endfunction
  
  task run_phase(uvm_phase phase);
	forever 
      begin
        my_transaction trans;
        wait(s1.size()>0);
        trans=s1.pop_front();
        if(trans.wr_en==1) 
          begin
            mem[trans.wptr]=trans.D_in;
              
          end
        else if(trans.rd_en==1) 
          begin 
            if(mem[trans.rptr]==trans.D_out) 
              begin
		`uvm_info("data transmission","SCOREBOARD Expected data",UVM_LOW)
                `uvm_info(get_type_name(),$sformatf("------ :: EXPECTED MATCH:: ------"),UVM_LOW)
                `uvm_info(get_type_name(),$sformatf("Data: %0h,mem[%0d]=%0h",trans.D_out,trans.rptr,mem[trans.rptr]),UVM_LOW)
              end
            else
              begin
                `uvm_info(get_type_name(),$sformatf("------ :: FAILED MATCH:: ------"),UVM_LOW)
                `uvm_info(get_type_name(),$sformatf("Data: %0h,mem[%0d]=%0h,mem[%0d]=%0h",trans.D_out,trans.rptr,mem[trans.rptr],trans.wptr,mem[trans.wptr]),UVM_LOW)
              end
        ///    j++;
          end
end
  endtask
  
endclass
