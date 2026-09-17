`timescale 1ns/1ps
module tb_m1_17_cpu_lea_pea;
 logic clk=0,reset_n=0;logic[2:0]irq_level=0;logic[31:0]address;logic[15:0]data_out,data_in;logic read,write,ack=1;logic[31:0]d0,pc,a7;logic[15:0]sr;logic halted,exception;logic[7:0]exception_vector;
 logic saw_lo=0,saw_hi=0;
 amcore_68k_baseline dut(.*); always #5 clk=~clk;
 always_comb begin case(address)
  0:data_in=16'h0000;2:data_in=16'h0200;4:data_in=16'h0000;6:data_in=16'h0100;
  32'h100:data_in=16'h43d0; // LEA (A0),A1
  32'h102:data_in=16'h4851; // PEA (A1)
  32'h104:data_in=16'h60fe; // stable landing
  default:data_in=16'h4e71; endcase end
 always_ff @(posedge clk) begin
  if(write && address==32'h1fe && data_out==16'h1234) saw_lo<=1;
  if(write && address==32'h1fc && data_out==16'h0000) saw_hi<=1;
 end
 initial begin
  repeat(2) @(posedge clk);reset_n=1;
  wait(pc==32'h100);#1; dut.areg[0]=32'h00001234; dut.sr[4:0]=5'b10101;
  fork begin repeat(200) @(posedge clk);$fatal(1,"timeout pc=%h a7=%h",pc,a7);end join_none
  wait(pc==32'h104);#1;
  if(dut.areg[1]!==32'h00001234)$fatal(1,"LEA result wrong: %h",dut.areg[1]);
  if(!saw_lo||!saw_hi)$fatal(1,"PEA push missing lo=%b hi=%b",saw_lo,saw_hi);
  if(a7!==32'h000001fc)$fatal(1,"PEA A7 wrong: %h",a7);
  if(sr[4:0]!==5'b10101)$fatal(1,"LEA/PEA changed CCR: %b",sr[4:0]);
  if(halted||exception)$fatal(1,"unexpected halt/exception");
  $display("PASS: M1.17 CPU LEA/PEA (An) integration");$finish;
 end
endmodule
