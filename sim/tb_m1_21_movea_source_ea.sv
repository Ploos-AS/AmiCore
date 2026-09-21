`timescale 1ns/1ps
module tb_m1_21_movea_source_ea;
 logic clk=0,reset_n=0; logic[2:0] irq_level=0; logic[31:0] address; logic[15:0] data_out,data_in; logic read,write,ack; logic[31:0] d0,pc,a7; logic[15:0] sr; logic halted,exception; logic[7:0] exception_vector;
 logic[15:0] mem[0:511]; integer cycles; always #5 clk=~clk;
 amcore_68k_baseline dut(.*);
 always_comb begin ack=read||write; data_in=mem[address[9:1]]; end
 always_ff @(posedge clk) if(write) mem[address[9:1]]<=data_out;
 initial begin
  for(cycles=0;cycles<512;cycles=cycles+1) mem[cycles]=0;
  mem[0]=16'h0000; mem[1]=16'h03F0; mem[2]=16'h0000; mem[3]=16'h0100;
  mem[16'h080]=16'h2278; mem[16'h081]=16'h0200; // MOVEA.L $0200.W,A1
  mem[16'h082]=16'h2479; mem[16'h083]=16'h0000; mem[16'h084]=16'h0210; // abs.L,A2
  mem[16'h085]=16'h2668; mem[16'h086]=16'h0020; // d16(A0),A3
  mem[16'h087]=16'h2870; mem[16'h088]=16'h1804; // d8(A0,D1.L),A4
  mem[16'h089]=16'h2A7A; mem[16'h08A]=16'h00EC; // d16(PC),A5 -> 0x200
  mem[16'h08B]=16'h2C7B; mem[16'h08C]=16'h1874; // d8(PC,D1.L),A6 -> 0x200
  mem[16'h08D]=16'h60FE;
  mem[16'h100]=16'h1111; mem[16'h101]=16'h2222;
  mem[16'h0C8]=16'h1111; mem[16'h0C9]=16'h2222;
  mem[16'h108]=16'h3333; mem[16'h109]=16'h4444;
  mem[16'h120]=16'h5555; mem[16'h121]=16'h6666;
  mem[16'h114]=16'h7777; mem[16'h115]=16'h8888;
  #20 reset_n=1; @(posedge clk); #1; dut.areg[0]=32'h00000220; dut.dreg[1]=32'h00000004; dut.sr=16'h2715;
  for(cycles=0;cycles<300;cycles=cycles+1) begin @(posedge clk); #1;
   if(pc==32'h11A) begin
    if(dut.areg[1]!==32'h11112222) $fatal(1,"MOVEA abs.W A1=%h",dut.areg[1]);
    if(dut.areg[2]!==32'h33334444) $fatal(1,"MOVEA abs.L A2=%h",dut.areg[2]);
    if(dut.areg[3]!==32'h55556666) $fatal(1,"MOVEA d16 A3=%h",dut.areg[3]);
    if(dut.areg[4]!==32'h77778888) $fatal(1,"MOVEA indexed A4=%h",dut.areg[4]);
    if(dut.areg[5]!==32'h11112222) $fatal(1,"MOVEA PC d16 A5=%h",dut.areg[5]);
    if(dut.areg[6]!==32'h11112222) $fatal(1,"MOVEA PC indexed A6=%h",dut.areg[6]);
    if(sr!==16'h2715) $fatal(1,"MOVEA changed CCR/SR=%h",sr);
    $display("PASS: M1.21 MOVEA.L source EAs preserve CCR"); $finish;
   end
  end
  $fatal(1,"timeout pc=%h ir=%h state=%0d",pc,dut.ir,dut.state);
 end
endmodule
