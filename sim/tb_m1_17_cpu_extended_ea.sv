`timescale 1ns/1ps
module tb_m1_17_cpu_extended_ea;
 logic clk=0,reset_n=0;logic[2:0]irq_level=0;logic[31:0]address;logic[15:0]data_out,data_in;logic read,write,ack=1;logic[31:0]d0,pc,a7;logic[15:0]sr;logic halted,exception;logic[7:0]exception_vector;
 logic saw_pea_lo=0,saw_pea_hi=0,saw_a7_lo=0,saw_a7_hi=0;
 amcore_68k_baseline dut(.*); always #5 clk=~clk;
 always_comb begin case(address)
  0:data_in=16'h0000;2:data_in=16'h0200;4:data_in=16'h0000;6:data_in=16'h0100;
  32'h100:data_in=16'h45e8; // LEA $0010(A0),A2
  32'h102:data_in=16'h0010;
  32'h104:data_in=16'h47f8; // LEA $ff00.W,A3
  32'h106:data_in=16'hff00;
  32'h108:data_in=16'h49f9; // LEA $12345678.L,A4
  32'h10a:data_in=16'h1234;32'h10c:data_in=16'h5678;
  32'h10e:data_in=16'h4868; // PEA -$20(A0)
  32'h110:data_in=16'hffe0;
  32'h112:data_in=16'h4857; // PEA (A7), must push pre-decrement SP value
  32'h114:data_in=16'h60fe;
  default:data_in=16'h4e71; endcase end
 always @(negedge clk) begin
  if(write&&address==32'h1fe&&data_out==16'h0fe0)saw_pea_lo=1;
  if(write&&address==32'h1fc&&data_out==16'h0000)saw_pea_hi=1;
  if(write&&address==32'h1fa&&data_out==16'h01fc)saw_a7_lo=1;
  if(write&&address==32'h1f8&&data_out==16'h0000)saw_a7_hi=1;
 end
 initial begin
  repeat(2)@(posedge clk);reset_n=1;
  wait(pc==32'h100);#1;dut.areg[0]=32'h00001000;dut.sr[4:0]=5'b10101;
  fork begin repeat(400)@(posedge clk);$fatal(1,"timeout pc=%h a7=%h",pc,a7);end join_none
  wait(pc==32'h114&&a7==32'h000001f8);@(negedge clk);#1;
  if(dut.areg[2]!==32'h00001010)$fatal(1,"LEA d16 wrong %h",dut.areg[2]);
  if(dut.areg[3]!==32'hffffff00)$fatal(1,"LEA abs.W wrong %h",dut.areg[3]);
  if(dut.areg[4]!==32'h12345678)$fatal(1,"LEA abs.L wrong %h",dut.areg[4]);
  if(!saw_pea_lo||!saw_pea_hi)$fatal(1,"PEA d16 push missing");
  if(!saw_a7_lo||!saw_a7_hi)$fatal(1,"PEA (A7) did not push original SP");
  if(sr[4:0]!==5'b10101)$fatal(1,"LEA/PEA changed CCR %b",sr[4:0]);
  if(halted||exception)$fatal(1,"unexpected halt/exception");
  $display("PASS: M1.17 CPU extended LEA/PEA EAs");$finish;
 end
endmodule
