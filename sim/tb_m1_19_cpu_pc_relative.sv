`timescale 1ns/1ps
module tb_m1_19_cpu_pc_relative;
 logic clk=0,reset_n=0; logic[2:0] irq_level=0; logic[31:0] address; logic[15:0] data_out,data_in; logic read,write,ack; logic[31:0] d0,pc,a7; logic[15:0] sr; logic halted,exception; logic[7:0] exception_vector;
 logic[15:0] mem[0:511]; integer cycles; always #5 clk=~clk;
 amcore_68k_baseline dut(.*);
 always_comb begin ack=read||write; data_in=mem[address[9:1]]; end
 always_ff @(posedge clk) if(write) mem[address[9:1]]<=data_out;
 initial begin
  for(cycles=0;cycles<512;cycles=cycles+1) mem[cycles]=0;
  mem[0]=16'h0000; mem[1]=16'h0200; mem[2]=16'h0000; mem[3]=16'h0100;
  // LEA 30(PC),A2: extension word is at 0x102, target 0x120.
  mem[16'h080]=16'h45FA; mem[16'h081]=16'h001E;
  // PEA 26(PC): extension at 0x106, target 0x120.
  mem[16'h082]=16'h487A; mem[16'h083]=16'h001A;
  // JSR 54(PC): extension at 0x10A, target 0x140; return 0x10C.
  mem[16'h084]=16'h4EBA; mem[16'h085]=16'h0036;
  // JMP 82(PC): extension at 0x10E, target 0x160.
  mem[16'h086]=16'h4EFA; mem[16'h087]=16'h0052;
  mem[16'h0A0]=16'h4E75; // RTS at 0x140
  mem[16'h0B0]=16'h60FE; // stable BRA.s -2 at 0x160
  #20 reset_n=1;
  for(cycles=0;cycles<300;cycles=cycles+1) begin
   @(posedge clk); #1;
   if(pc==32'h160) begin
    if(dut.areg[2]!==32'h120) $fatal(1,"LEA d16(PC) A2=%h",dut.areg[2]);
    if(a7!==32'h1FC) $fatal(1,"stack pointer=%h",a7);
    if(mem[16'h0FE]!==16'h0000 || mem[16'h0FF]!==16'h0120) $fatal(1,"PEA stack value=%h%h",mem[16'h0FE],mem[16'h0FF]);
    $display("PASS: M1.19 baseline CPU LEA/PEA/JMP/JSR d16(PC)");
    $finish;
   end
  end
  $fatal(1,"timeout pc=%h a7=%h",pc,a7);
 end
endmodule
