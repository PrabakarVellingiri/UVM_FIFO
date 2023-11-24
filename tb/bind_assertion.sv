module binding_module();
  bind  fifo  assertion  U_assert_ip (.clk(clk),.rst(rst),.full(full),.empty(empty),.D_in(D_in),.D_out(D_out),.wptr(wptr),.rptr(rptr)
  );
endmodule
