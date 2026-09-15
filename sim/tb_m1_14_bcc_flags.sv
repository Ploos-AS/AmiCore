`timescale 1ns/1ps
module tb_m1_14_bcc_flags;
 logic clk=0,reset_n=0;logic[2:0]irq_level=0;logic[31:0]address;logic[15:0]data_out,data_in;logic read,write,ack;logic[31:0]d0,pc,a7;logic[15:0]sr;logic halted,exception;logic[7:0]exception_vector;integer cycles;
 amcore_68k_baseline dut(.*);always #5 clk=~clk;assign ack=read|write;
 always_comb begin case(address)
  0:data_in=0;2:data_in=16'h0200;4:data_in=0;6:data_in=16'h0100;
  // Force representative CCR combinations at checkpoints; branch execution itself remains end-to-end.
  32'h100:data_in=16'h6c02;32'h102:data_in=16'h7001; // GE taken when N==V
  32'h104:data_in=16'h6d02;32'h106:data_in=16'h7202; // LT taken when N!=V
  32'h108:data_in=16'h6e02;32'h10a:data_in=16'h7403; // GT taken when !Z && N==V
  32'h10c:data_in=16'h6f02;32'h10e:data_in=16'h7604; // LE taken when Z
  32'h110:data_in=16'h6902;32'h112:data_in=16'h7805; // VS taken
  32'h114:data_in=16'h6802;32'h116:data_in=16'h7a06; // VC taken
  32'h118:data_in=16'h6000;32'h11a:data_in=16'hfffc;
  default:data_in=16'h4e71;endcase end
 initial begin repeat(2)@(posedge clk);#1;reset_n=1;
  wait(pc==32'h100);#1;dut.sr[3:0]=4'b0000; // N=V=Z=C=0
  wait(pc==32'h104);#1;dut.sr[3:0]=4'b1000; // N=1,V=0
  wait(pc==32'h108);#1;dut.sr[3:0]=4'b0000;
  wait(pc==32'h10c);#1;dut.sr[3:0]=4'b0100; // Z=1
  wait(pc==32'h110);#1;dut.sr[3:0]=4'b0010; // V=1
  wait(pc==32'h114);#1;dut.sr[3:0]=4'b0000; // V=0
  cycles=0;while(pc!=32'h118&&cycles<300)begin @(posedge clk);#1;cycles=cycles+1;end
  if(cycles>=300)$fatal(1,"timeout signed Bcc qualification");
  if(dut.dreg[0]||dut.dreg[1]||dut.dreg[2]||dut.dreg[3]||dut.dreg[4]||dut.dreg[5])$fatal(1,"a taken Bcc failed");
  if(halted||exception)$fatal(1,"unexpected halt/exception");
  $display("PASS: M1.14 GE/LT/GT/LE/VS/VC conditions");$finish;end
endmodule
