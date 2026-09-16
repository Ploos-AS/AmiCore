`timescale 1ns/1ps
module tb_m1_15_dbcc;
 logic condition_true; logic[31:0] dreg_in,pc_opcode; logic[15:0] displacement;
 logic[31:0] dreg_out,pc_out; logic branch_taken;
 amcore_dbcc dut(.*);
 task check(input logic cond,input logic[31:0] din,input logic[15:0] disp,input logic[31:0] dout,input logic[31:0] pout,input logic taken);
  begin condition_true=cond;dreg_in=din;pc_opcode=32'h00000100;displacement=disp;#1;
   if(dreg_out!==dout||pc_out!==pout||branch_taken!==taken)
    $fatal(1,"DBcc mismatch cond=%b din=%h disp=%h -> d=%h pc=%h take=%b",cond,din,disp,dreg_out,pc_out,branch_taken);
  end
 endtask
 initial begin
  // Condition true: no decrement, no branch, extension consumed.
  check(1,32'h12340005,16'h0010,32'h12340005,32'h00000104,0);
  // Condition false: decrement low word and branch while result != -1.
  check(0,32'h12340005,16'h0010,32'h12340004,32'h00000112,1);
  // Upper word is preserved and negative displacement is sign-extended.
  check(0,32'habcd0001,16'hfffc,32'habcd0000,32'h000000fe,1);
  // Counter expiration: 0 -> ffff, no branch.
  check(0,32'hbeef0000,16'h0010,32'hbeefffff,32'h00000104,0);
  // ffff wraps to fffe and therefore branches.
  check(0,32'hcafeffff,16'h0004,32'hcafefffe,32'h00000106,1);
  $display("PASS: M1.15 DBcc execution semantics");$finish;
 end
endmodule
