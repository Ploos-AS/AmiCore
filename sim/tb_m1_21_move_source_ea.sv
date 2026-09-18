`timescale 1ns/1ps
module tb_m1_21_move_source_ea;
 logic clk=0,reset_n=0; logic[2:0] irq_level=0; logic[31:0] address; logic[15:0] data_out,data_in; logic read,write,ack; logic[31:0] d0,pc,a7; logic[15:0] sr; logic halted,exception; logic[7:0] exception_vector;
 logic[15:0] mem[0:511]; integer cycles; always #5 clk=~clk;
 amcore_68k_baseline dut(.*);
 always_comb begin ack=read||write; data_in=mem[address[9:1]]; end
 always_ff @(posedge clk) if(write) mem[address[9:1]]<=data_out;
 initial begin
  for(cycles=0;cycles<512;cycles=cycles+1) mem[cycles]=0;
  mem[0]=16'h0000; mem[1]=16'h0200; mem[2]=16'h0000; mem[3]=16'h0100;
  // MOVE.L d16(A0),D1 ; extension +4 ; data at 0x124.
  mem[16'h080]=16'h2228; mem[16'h081]=16'h0004;
  // MOVE.L d8(A0,D1.W),D2 ; after first MOVE D1.W=0x5678, use negative displacement
  // is intentionally not used here: reset D1 via MOVEQ before indexed qualification.
  mem[16'h082]=16'h7204;
  // MOVE.L d8(A0,D1.L),D2 => A0 0x120 + 4 + 4 = 0x128.
  mem[16'h083]=16'h2430; mem[16'h084]=16'h1804;
  // MOVE.L d16(PC),D3: extension at 0x10C, +0x24 => 0x130.
  mem[16'h085]=16'h263A; mem[16'h086]=16'h0024;
  // MOVE.L d8(PC,D1.L),D4: extension at 0x110, +4 + 0x2C => 0x140.
  mem[16'h087]=16'h283B; mem[16'h088]=16'h182C;
  // MOVE.L $0180.W,D5; MOVE.L $00000190.L,D6.
  mem[16'h089]=16'h2A38; mem[16'h08A]=16'h0180;
  mem[16'h08B]=16'h2C39; mem[16'h08C]=16'h0000; mem[16'h08D]=16'h0190;
  // MOVE.L D1,d16(A0); MOVE.L D2,d8(A0,D1.L); absolute.W/L destinations.
  mem[16'h08E]=16'h2141; mem[16'h08F]=16'h0060;
  mem[16'h090]=16'h2182; mem[16'h091]=16'h1840;
  mem[16'h092]=16'h21C3; mem[16'h093]=16'h01A0;
  mem[16'h094]=16'h23C4; mem[16'h095]=16'h0000; mem[16'h096]=16'h01B0;
  mem[16'h097]=16'h60FE;
  mem[16'h0B0]=16'h1234; mem[16'h0B1]=16'h5678; // 0x160 source for first MOVE
  mem[16'h0B2]=16'h89AB; mem[16'h0B3]=16'hCDEF; // 0x164 indexed source
  mem[16'h098]=16'h0BAD; mem[16'h099]=16'hF00D; // 0x130
  mem[16'h0A0]=16'hCAFE; mem[16'h0A1]=16'hBABE; // 0x140
  mem[16'h0C0]=16'h1357; mem[16'h0C1]=16'h9BDF; // 0x180
  mem[16'h0C8]=16'h2468; mem[16'h0C9]=16'hACE0; // 0x190
  #20 reset_n=1; @(posedge clk); #1; dut.areg[0]=32'h00000120;
  for(cycles=0;cycles<350;cycles=cycles+1) begin
   @(posedge clk); #1;
   if(pc==32'h12E) begin
    if(dut.dreg[2]!==32'h89ABCDEF) $fatal(1,"indexed An MOVE D2=%h",dut.dreg[2]);
    if(dut.dreg[3]!==32'h0BADF00D) $fatal(1,"PC d16 MOVE D3=%h",dut.dreg[3]);
    if(dut.dreg[4]!==32'hCAFEBABE) $fatal(1,"PC indexed MOVE D4=%h",dut.dreg[4]);
    if(dut.dreg[5]!==32'h13579BDF) $fatal(1,"absolute.W MOVE D5=%h",dut.dreg[5]);
    if(dut.dreg[6]!==32'h2468ACE0) $fatal(1,"absolute.L MOVE D6=%h",dut.dreg[6]);
    if({mem[16'h0C0],mem[16'h0C1]}!==32'h00000004) $fatal(1,"d16 destination=%h",{mem[16'h0C0],mem[16'h0C1]});
    if({mem[16'h0B2],mem[16'h0B3]}!==32'h89ABCDEF) $fatal(1,"indexed destination=%h",{mem[16'h0B2],mem[16'h0B3]});
    if({mem[16'h0D0],mem[16'h0D1]}!==32'h0BADF00D) $fatal(1,"abs.W destination=%h",{mem[16'h0D0],mem[16'h0D1]});
    if({mem[16'h0D8],mem[16'h0D9]}!==32'hCAFEBABE) $fatal(1,"abs.L destination=%h",{mem[16'h0D8],mem[16'h0D9]});
    $display("PASS: M1.21 MOVE.L source displacement/indexed/PC-relative EAs");
    $finish;
   end
  end
  $fatal(1,"timeout pc=%h state=%0d ir=%h d1=%h d2=%h d3=%h d4=%h d5=%h d6=%h",pc,dut.state,dut.ir,dut.dreg[1],dut.dreg[2],dut.dreg[3],dut.dreg[4],dut.dreg[5],dut.dreg[6]);
 end
endmodule
