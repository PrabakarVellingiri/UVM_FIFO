interface fifo_inf(input logic clk , rst);
  logic wr_en;
  logic rd_en;
  logic full,empty;
  logic [7:0] D_in;
  logic [7:0] D_out;
  logic [2:0] wptr,rptr;
  
   function string convert2string();
     return $psprintf("d_in=%0h d_out=%0h wr_en=%0h rd_en=%0h ",D_in,D_out,wr_en,rd_en);
  endfunction

property reset_check;
@(posedge clk) 
(!rst) |-> (D_out==0 && wptr ==0 && rptr ==0);
endproperty

property empty_check;
@(posedge clk) 
disable iff(!rst)
 (wptr == rptr) |-> empty == 1;
endproperty 

property full_check;
@(posedge clk)
disable iff(!rst)
  (wptr == 3'b111 && rptr == 3'b000  |-> full == 1);
endproperty 

property rp_tr_check;
@(posedge clk)
disable iff(!rst && rd_en)
(wr_en==1 |=>$stable(rptr));
endproperty

property wr_tr_check;
@(posedge clk)
disable iff(!rst && wr_en)
(rd_en==1 |=> $stable(wptr));
endproperty


property em_rp_check;
@(posedge clk)
disable iff(!rst)
(empty ==1 |=> $stable(rptr));
endproperty

property clock_check;
realtime prev;
@(posedge clk)
(1,prev=$time) |=> ($time-prev==10ns);
endproperty

property d_cycle;
realtime ps_edg;
realtime ns_edg;
realtime ton, toff;
  @(posedge clk) (1,ps_edg = $time) |-> @(negedge (clk)) (1,ton = $time - ps_edg,ns_edg = $time) |-> @(posedge (clk)) (1,toff = $time - ns_edg)|-> (ton == toff);
 endproperty


reset : assert property (reset_check)
         $display("%0t reset assertion pass",$time);
        else
        $display("%0t reset assertion fail",$time);

ept : assert property (empty_check)
         $display("%0t empty assertion pass",$time);
        else
        $display("$0t empty assertion fail",$time);

ful : assert property (full_check)
         $display("%0t full assertion pass",$time);
        else
        $display("%0t full assertion fail",$time);
rp_tr : assert property (rp_tr_check)
         $display("%0t readpointer  assertion pass",$time);
        else
        $display("%0t readpointer  assertion fail",$time);

wp_tr : assert property (wr_tr_check)
         $display("%0t writepointer  assertion pass",$time);
        else
        $display("%0t writepointer   assertion fail",$time);
clk_check:assert property( clock_check)
          $display("%0t clock assertion passed",$time);
          else 
          $display("%0t clock assertion passed",$time);
dc_check:assert property( d_cycle)
          $display("%0t duty_cycle assertion passed",$time);
          else 
          $display("%0t duty_cycle assertion passed",$time);



endinterface 
