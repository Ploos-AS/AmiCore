`timescale 1ns/1ps
module tb_m1_12_stack_banking;
 logic clk=0,reset_n=0;logic[2:0]irq_level=0;logic[31:0]address;logic[15:0]data_out,data_in;logic read,write,ack;logic[31:0]d0,pc,a7;logic[15:0]sr;logic halted,exception;logic[7:0]exception_vector;logic[15:0]ram[0:511];integer cycles;
 amcore_68k_baseline dut(.*); always #5 clk=~clk; assign ack=read|write;
 always_comb begin
  data_in=16'h4e71;
  case(address)
   32'h0:data_in=16'h0000;32'h2:data_in=16'h0200;32'h4:data_in=16'h0000;32'h6:data_in=16'h0020;
   32'h20:data_in=16'h204f; // MOVEA.L A7,A0
   32'h22:data_in=16'h2018; // MOVE.L (A0)+,D0 -> A0=$204
   32'h24:data_in=16'h4e60; // MOVE A0,USP
   32'h26:data_in=16'h46fc;32'h28:data_in=16'h0000; // enter user mode
   32'h2a:data_in=16'h4e71;
   32'h64:data_in=16'h0000;32'h66:data_in=16'h0060; // level-1 autovector 25
   32'h60:data_in=16'h4e73; // RTE
   default:data_in=ram[address[10:1]];
  endcase
 end
 always_ff@(posedge clk)if(write&&ack)ram[address[10:1]]<=data_out;
 initial begin
  for(cycles=0;cycles<512;cycles=cycles+1)ram[cycles]=0;
  repeat(2)@(posedge clk); #1; reset_n=1;
  cycles=0;while(!((pc==32'h2a)&&!sr[13])&&cycles<300)begin @(posedge clk);#1;cycles=cycles+1;end
  if(cycles>=300)$fatal(1,"timeout entering user mode");
  if(a7!==32'h204||dut.usp!==32'h204||dut.ssp!==32'h200)$fatal(1,"bank setup A7=%h USP=%h SSP=%h",a7,dut.usp,dut.ssp);
  irq_level=1; @(posedge clk); #1; wait(exception); irq_level=0;
  cycles=0;while(!((pc==32'h2a)&&!sr[13]&&(a7==32'h204))&&cycles<300)begin @(posedge clk);#1;cycles=cycles+1;end
  if(cycles>=300)$fatal(1,"timeout returning to user mode");
  if(dut.usp!==32'h204||dut.ssp!==32'h200)$fatal(1,"bank restore USP=%h SSP=%h",dut.usp,dut.ssp);
  if(ram[16'h00fd]!==16'h0000||ram[16'h00fe]!==16'h0000||ram[16'h00ff]!==16'h002a)$fatal(1,"bad supervisor exception frame %h %h %h",ram[16'h00fd],ram[16'h00fe],ram[16'h00ff]);
  if(halted||exception)$fatal(1,"unexpected halt/exception after RTE");
  $display("PASS: M1.12 USP/SSP banking, user interrupt entry and RTE restore");$finish;
 end
endmodule
