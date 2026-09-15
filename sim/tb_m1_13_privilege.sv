`timescale 1ns/1ps
module tb_m1_13_privilege;
 logic clk=0,reset_n=0;logic[2:0]irq_level=0;logic[31:0]address;logic[15:0]data_out,data_in;logic read,write,ack;logic[31:0]d0,pc,a7;logic[15:0]sr;logic halted,exception;logic[7:0]exception_vector;logic[15:0]ram[0:511];integer cycles;
 amcore_68k_baseline dut(.*); always #5 clk=~clk; assign ack=read|write;
 always_comb begin
  data_in=16'h4e71;
  case(address)
   32'h0:data_in=16'h0000;32'h2:data_in=16'h0200;32'h4:data_in=16'h0000;32'h6:data_in=16'h0100;
   32'h20:data_in=16'h0000;32'h22:data_in=16'h0160; // vector 8 = $00000160
   32'h100:data_in=16'h204f; // MOVEA.L A7,A0
   32'h102:data_in=16'h2018; // MOVE.L (A0)+,D0 => A0=$204
   32'h104:data_in=16'h4e60; // MOVE A0,USP
   32'h106:data_in=16'h46fc;32'h108:data_in=16'h0000; // enter user mode
   32'h10a:data_in=16'h4e73; // privileged RTE in user mode => vector 8
   32'h10c:data_in=16'h60fe; // stable user-mode landing loop after handler skips offender
   32'h160:data_in=16'h4e73; // supervisor RTE
   default:data_in=ram[address[10:1]];
  endcase
 end
 always_ff@(posedge clk)if(write&&ack)ram[address[10:1]]<=data_out;
 initial begin
  for(cycles=0;cycles<512;cycles=cycles+1)ram[cycles]=0;
  repeat(2)@(posedge clk);#1;reset_n=1;
  cycles=0;while(!(exception&&exception_vector==8)&&cycles<300)begin @(posedge clk);#1;cycles=cycles+1;end
  if(cycles>=300)$fatal(1,"timeout waiting for privilege violation");
  if(dut.usp!==32'h204)$fatal(1,"USP not preserved: %h",dut.usp);
  cycles=0;while(!((pc==32'h160)&&sr[13])&&cycles<300)begin @(posedge clk);#1;cycles=cycles+1;end
  if(cycles>=300)$fatal(1,"timeout entering privilege handler");
  if(ram[16'h00fd]!==16'h0000||ram[16'h00fe]!==16'h0000||ram[16'h00ff]!==16'h010a)$fatal(1,"bad privilege frame %h %h %h",ram[16'h00fd],ram[16'h00fe],ram[16'h00ff]);
  // Minimal handler policy: skip the offending two-byte RTE before returning.
  ram[16'h00ff]=16'h010c;
  cycles=0;while(!((pc==32'h10c)&&!sr[13]&&(a7==32'h204))&&cycles<300)begin @(posedge clk);#1;cycles=cycles+1;end
  if(cycles>=300)$fatal(1,"timeout returning from privilege handler");
  if(dut.ssp!==32'h200)$fatal(1,"SSP not restored: %h",dut.ssp);
  if(halted)$fatal(1,"unexpected halt");
  $display("PASS: M1.13 user-mode RTE privilege violation, vector 8 frame and bank restore");$finish;
 end
endmodule
