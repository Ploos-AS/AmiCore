`timescale 1ns/1ps
module tb_m1_16_cpu_jump;
 logic clk=0,reset_n=0;logic[2:0]irq_level=0;logic[31:0]address;logic[15:0]data_out,data_in;logic read,write,ack=1;logic[31:0]d0,pc,a7;logic[15:0]sr;logic halted,exception;logic[7:0]exception_vector;
 logic saw_lo=0,saw_hi=0;
 amcore_68k_baseline dut(.*); always #5 clk=~clk;
 always_comb begin case(address)
  0:data_in=16'h0000;2:data_in=16'h0200;4:data_in=16'h0000;6:data_in=16'h0100;
  32'h100:data_in=16'h4ed0; // JMP (A0)
  32'h120:data_in=16'h4e91; // JSR (A1)
  32'h122:data_in=16'h60fe; // landing loop after RTS
  32'h140:data_in=16'h4e75; // RTS
  32'h1fc:data_in=16'h0000; // stacked return PC high
  32'h1fe:data_in=16'h0122; // stacked return PC low
  default:data_in=16'h4e71; endcase end
 always_ff @(posedge clk) begin
  if(write && address==32'h1fe && data_out==16'h0122) saw_lo<=1;
  if(write && address==32'h1fc && data_out==16'h0000) saw_hi<=1;
 end
 initial begin
  repeat(2) @(posedge clk);reset_n=1;
  wait(pc==32'h100);#1;dut.areg[0]=32'h120;dut.areg[1]=32'h140;
  fork begin repeat(300) @(posedge clk);$fatal(1,"timeout pc=%h a7=%h",pc,a7);end join_none
  wait(pc==32'h122);#1;
  if(!saw_lo||!saw_hi)$fatal(1,"JSR return PC stack push missing lo=%b hi=%b",saw_lo,saw_hi);
  if(a7!==32'h200)$fatal(1,"RTS did not restore A7: %h",a7);
  if(halted||exception)$fatal(1,"unexpected halt/exception");
  $display("PASS: M1.16 CPU JMP/JSR (An) and RTS round-trip");$finish;
 end
endmodule
