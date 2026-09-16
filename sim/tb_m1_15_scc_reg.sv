`timescale 1ns/1ps
module tb_m1_15_scc_reg;
 logic condition_true; logic[31:0] dreg_in,dreg_out;
 amcore_scc_reg dut(.*);
 initial begin
  dreg_in=32'h12345678; condition_true=1'b1; #1;
  if(dreg_out!==32'h123456ff) $fatal(1,"Scc true mismatch: %h",dreg_out);
  condition_true=1'b0; #1;
  if(dreg_out!==32'h12345600) $fatal(1,"Scc false mismatch: %h",dreg_out);
  dreg_in=32'habcdef00; condition_true=1'b1; #1;
  if(dreg_out!==32'habcdefff) $fatal(1,"Scc preserve mismatch: %h",dreg_out);
  $display("PASS: M1.15 Scc Dn register semantics");
  $finish;
 end
endmodule
