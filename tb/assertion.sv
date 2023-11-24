module assertion (input clk,rst,full,empty,input [7:0] D_in,D_out,input [2:0] wptr,rptr);
   
   property reset_check;
     @(posedge clk) if (!rst)
      wptr==0;
      rptr==0;
      D_out==0;     
   endproperty
  

  
 // cover property (reset_check);
    check : assert property (reset_check)
      $display("assertion passed");
      else 
        $display("assertion failed");
     
 
endmodule


