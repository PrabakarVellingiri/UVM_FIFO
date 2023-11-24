class read_sequence extends uvm_sequence #(my_transaction);
  `uvm_object_utils(read_sequence)
  
  
  
  function new(string name="read_sequence");
    super.new(name);
  endfunction
  
  task body();
    repeat(8) 
     begin
       `uvm_do_with(req,{req.rd_en == 1; req.wr_en ==0;})
      end
   
  endtask
  
endclass


