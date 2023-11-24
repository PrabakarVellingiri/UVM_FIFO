class my_coverage extends uvm_subscriber #(my_transaction);
  
  
  `uvm_component_utils(my_coverage)
  
  uvm_analysis_imp #(my_transaction,my_coverage) cov_export;
 
 // my_transaction seq;
  
  logic wr_en;
  logic rd_en;
  logic [7:0] D_in;
  logic [7:0] D_out;
  
  covergroup cg;
    W_R1:coverpoint wr_en {bins Write1 ={1};}
    W_R0:coverpoint wr_en {bins Write0 ={0};}
    R1:coverpoint rd_en {bins read1 ={1};}
    R0:coverpoint rd_en {bins  read0 ={0};}
    Input:coverpoint D_in {bins input_data ={[0:8]};}
    Output:coverpoint D_out {bins output_data ={[0:8]};}
    option.per_instance=1;
  endgroup
  
  function new(string name ="my_coverage", uvm_component parent);
    super.new(name,parent);
     cov_export=new("cov_export",this);
    cg=new();

  endfunction
    
  function void write (my_transaction t);
    `uvm_info("SUBSCRIBER","COVERAGE",UVM_LOW);
    wr_en = t.wr_en;
    rd_en = t.rd_en;
    D_in  = t.D_in;
    D_out = t.D_out;
    cg.sample();
   $display("coverage = %p", cg.get_coverage());
  endfunction

endclass
