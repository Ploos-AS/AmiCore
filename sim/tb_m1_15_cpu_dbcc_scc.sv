`timescale 1ns/1ps
module tb_m1_15_cpu_dbcc_scc;
 logic clk=0,reset_n=0; logic[2:0]irq_level=0; logic[31:0]address;logic[15:0]data_out,data_in;logic read,write,ack=1;logic[31:0]d0,pc,a7;logic[15:0]sr;logic halted,exception;logic[7:0]exception_vector;
 amcore_68k_baseline dut(.*); always #5 clk=~clk;
 always_comb begin case(address)
  0:data_in=16'h0000;2:data_in=16'h0200;4:data_in=16'h0000;6:data_in=16'h0100;
  32'h100:data_in=16'h7001;       // MOVEQ #1,D0
  32'h102:data_in=16'h51c8;       // DBF D0,+2
  32'h104:data_in=16'h0002;
  32'h106:data_in=16'h7209;       // skipped first DBF iteration
  32'h108:data_in=16'h57c1;       // SEQ D1 (Z=0 => 00)
  32'h10a:data_in=16'h7000;       // MOVEQ #0,D0, Z=1
  32'h10c:data_in=16'h57c1;       // SEQ D1 => FF
  32'h10e:data_in=16'h60fe;       // stable loop
  default:data_in=16'h4e71; endcase end
 initial begin
  repeat(2) @(posedge clk); reset_n=1;
  fork begin repeat(300) @(posedge clk); $fatal(1,"timeout pc=%h d0=%h d1=%h",pc,d0,dut.dreg[1]);end join_none
  wait(pc==32'h0000010e); #1;
  if(d0!==32'h00000000) $fatal(1,"D0 mismatch %h",d0);
  if(dut.dreg[1][7:0]!==8'hff) $fatal(1,"Scc mismatch D1=%h",dut.dreg[1]);
  if(halted||exception) $fatal(1,"unexpected halt/exception");
  $display("PASS: M1.15 CPU DBcc/Scc execution"); $finish;
 end
endmodule
