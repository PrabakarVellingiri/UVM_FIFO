class write_sequence extends uvm_sequence #(my_transaction);
  `uvm_object_utils(write_sequence)
  
  function new(string name="write_sequence");
    super.new(name);
  endfunction
  
  task body();
    repeat(8) 
     begin
       `uvm_do_with(req,{req.wr_en == 1; req.rd_en ==0;})
      end
   
  endtask
  
endclass


class random_sequence extends uvm_sequence #(my_transaction);
  `uvm_object_utils(random_sequence)
  
  
  constraint wr {solve req.wr_en before req.rd_en;}
  function new(string name="random_sequence");
    super.new(name);
  endfunction
  
  task body();
   my_transaction req;
   req=my_transaction::type_id::create("req");
    repeat(7) 
      begin
    start_item(req);
        req.randomize() with {wr_en dist {1:=10, 0:=10};};
        //req.print();
    finish_item(req);
      end
/*    `uvm_create(req);
    assert(req.randomize());
    `uvm_send(req);*/
  endtask
  
endclass
