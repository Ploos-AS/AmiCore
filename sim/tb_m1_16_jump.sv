`timescale 1ns/1ps
module tb_m1_16_jump;
 logic is_jsr; logic[31:0] effective_address,next_pc; logic[31:0] target_pc,return_pc; logic push_return;
 amcore_jump dut(.*);
 task automatic check(input logic jsr,input logic[31:0]ea,input logic[31:0]npc);
  begin is_jsr=jsr;effective_address=ea;next_pc=npc;#1;
   if(target_pc!==ea)$fatal(1,"target mismatch %h != %h",target_pc,ea);
   if(return_pc!==npc)$fatal(1,"return mismatch %h != %h",return_pc,npc);
   if(push_return!==jsr)$fatal(1,"push mismatch %b != %b",push_return,jsr);
  end
 endtask
 initial begin
  check(1'b0,32'h00012340,32'h00000102);
  check(1'b1,32'h00abcdef,32'h00000104);
  check(1'b1,32'h00000000,32'hffffffff);
  $display("PASS: M1.16 JMP/JSR execution primitive");$finish;
 end
endmodule
