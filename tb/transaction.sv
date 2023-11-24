class my_transaction extends uvm_sequence_item;
  rand bit [7:0] D_in;
  rand bit wr_en;
  rand bit rd_en;
  bit [7:0] D_out;
  bit full,empty;
  bit [2:0] wptr,rptr;

 `uvm_object_utils_begin(my_transaction)
    `uvm_field_int(D_in,UVM_ALL_ON)
    `uvm_field_int(wr_en,UVM_ALL_ON)
    `uvm_field_int(rd_en,UVM_ALL_ON)
    `uvm_field_int(full,UVM_ALL_ON)
    `uvm_field_int(empty,UVM_ALL_ON) 
    `uvm_field_int(D_out,UVM_ALL_ON)
    `uvm_field_int(wptr,UVM_ALL_ON)
    `uvm_field_int(rptr,UVM_ALL_ON)
  `uvm_object_utils_end

  
  function  new(string name="my_transaction");
    super.new(name);
  endfunction
  
   
endclass
