`timescale 1ns/1ps
module tb_m1_14_bcc;
 logic clk=0,reset_n=0;logic[2:0]irq_level=0;logic[31:0]address;logic[15:0]data_out,data_in;logic read,write,ack;logic[31:0]d0,pc,a7;logic[15:0]sr;logic halted,exception;logic[7:0]exception_vector;integer cycles;
 amcore_68k_baseline dut(.*);always #5 clk=~clk;assign ack=read|write;
 always_comb begin case(address)
  32'h0:data_in=16'h0000;32'h2:data_in=16'h0200;32'h4:data_in=16'h0000;32'h6:data_in=16'h0100;
  // Z=1: BEQ taken, BNE not taken.
  32'h100:data_in=16'h7000; 32'h102:data_in=16'h6702; 32'h104:data_in=16'h7201; 32'h106:data_in=16'h6602; 32'h108:data_in=16'h7402;
  // N=1: BMI taken, BPL not taken.
  32'h10a:data_in=16'h70ff; 32'h10c:data_in=16'h6b02; 32'h10e:data_in=16'h7603; 32'h110:data_in=16'h6a02; 32'h112:data_in=16'h7804;
  // C=1 from 0xffffffff + 1: BCS taken, BCC not taken.
  32'h114:data_in=16'h70ff; 32'h116:data_in=16'h5280; 32'h118:data_in=16'h6502; 32'h11a:data_in=16'h7a05; 32'h11c:data_in=16'h6402; 32'h11e:data_in=16'h7c06;
  // Z=1: BGT.w not taken must consume extension; BLE.w taken skips $12c.
  32'h120:data_in=16'h7000; 32'h122:data_in=16'h6e00; 32'h124:data_in=16'h0004; 32'h126:data_in=16'h7e07; 32'h128:data_in=16'h6f00; 32'h12a:data_in=16'h0002; 32'h12c:data_in=16'h7009; 32'h12e:data_in=16'h6000; 32'h130:data_in=16'hfffc;
  default:data_in=16'h4e71;endcase end
 initial begin repeat(2)@(posedge clk);#1;reset_n=1;cycles=0;while(pc!=32'h12e&&cycles<400)begin @(posedge clk);#1;cycles=cycles+1;end
  if(cycles>=400)$fatal(1,"timeout in Bcc qualification");
  if(dut.dreg[1]!==0)$fatal(1,"BEQ failed: skipped D1 write executed");
  if(dut.dreg[2]!==32'h2)$fatal(1,"BNE not-taken failed");
  if(dut.dreg[3]!==0)$fatal(1,"BMI failed: skipped D3 write executed");
  if(dut.dreg[4]!==32'h4)$fatal(1,"BPL not-taken failed");
  if(dut.dreg[5]!==0)$fatal(1,"BCS failed: skipped D5 write executed");
  if(dut.dreg[6]!==32'h6)$fatal(1,"BCC not-taken failed");
  if(dut.dreg[7]!==32'h7)$fatal(1,"BGT.w not-taken did not consume extension correctly");
  if(d0!==0)$fatal(1,"BLE.w taken failed: D0=%h",d0);
  if(halted||exception)$fatal(1,"unexpected halt/exception");
  $display("PASS: M1.14 Bcc.s/Bcc.w taken/not-taken CCR qualification");$finish;end
endmodule
