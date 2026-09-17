`timescale 1ns/1ps
module tb_m1_20_cpu_indexed;
 logic clk=0,reset_n=0; logic[2:0] irq_level=0; logic[31:0] address; logic[15:0] data_out,data_in; logic read,write,ack; logic[31:0] d0,pc,a7; logic[15:0] sr; logic halted,exception; logic[7:0] exception_vector;
 logic[15:0] mem[0:511]; integer cycles; always #5 clk=~clk;
 amcore_68k_baseline dut(.*);
 always_comb begin ack=read||write; data_in=mem[address[9:1]]; end
 always_ff @(posedge clk) if(write) mem[address[9:1]]<=data_out;
 initial begin
  for(cycles=0;cycles<512;cycles=cycles+1) mem[cycles]=0;
  mem[0]=16'h0000; mem[1]=16'h0200; mem[2]=16'h0000; mem[3]=16'h0100;
  // MOVEQ #16,D0; LEA d8(A0,D0.L),A2 => 0x134 when A0=0x120,d8=4.
  mem[16'h080]=16'h7010;
  mem[16'h081]=16'h45F0; mem[16'h082]=16'h0804;
  // PEA d8(PC,D0.L): extension at 0x108, base 0x108, +16,+8 => 0x120.
  mem[16'h083]=16'h487B; mem[16'h084]=16'h0808;
  // JMP d8(PC,D0.L): extension at 0x10C, +16,+0x34 => 0x150.
  mem[16'h085]=16'h4EFB; mem[16'h086]=16'h0834;
  mem[16'h0A8]=16'h60FE; // 0x150 stable
  #20 reset_n=1;
  dut.areg[0]=32'h00000120;
  for(cycles=0;cycles<300;cycles=cycles+1) begin
   @(posedge clk); #1;
   if(pc==32'h150) begin
    if(dut.areg[2]!==32'h134) $fatal(1,"LEA indexed A2=%h",dut.areg[2]);
    if(a7!==32'h1FC) $fatal(1,"stack pointer=%h",a7);
    if(mem[16'h0FE]!==16'h0000 || mem[16'h0FF]!==16'h0120) $fatal(1,"PEA indexed stack=%h%h",mem[16'h0FE],mem[16'h0FF]);
    $display("PASS: M1.20 baseline CPU indexed LEA/PEA/JMP");
    $finish;
   end
  end
  $fatal(1,"timeout pc=%h a7=%h",pc,a7);
 end
endmodule
