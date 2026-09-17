`timescale 1ns/1ps
module tb_m1_20_indexed_ea;
 logic[2:0] mode; logic[31:0] address_register,pc_base,index_register; logic[15:0] extension_hi,extension_lo; logic[31:0] effective_address; logic[2:0] extension_bytes;
 amcore_ea dut(.*);
 task automatic check(input logic[2:0] m,input logic[31:0] base,input logic[31:0] pc,input logic[15:0] ext,input logic[31:0] idx,input logic[31:0] expected);
 begin mode=m;address_register=base;pc_base=pc;extension_hi=ext;extension_lo=0;index_register=idx;#1;
  if(effective_address!==expected||extension_bytes!==2)$fatal(1,"mode=%0d ea=%h expected=%h",m,effective_address,expected);
 end endtask
 initial begin
  // brief extension: bit 11 selects long (1) vs sign-extended word (0); low byte is d8.
  check(5,32'h1000,0,16'h0804,32'h00000020,32'h1024); // long index +32, d8 +4
  check(5,32'h1000,0,16'h00FC,32'h1234FFF0,32'h0FEC); // word index -16, d8 -4
  check(6,0,32'h2002,16'h0808,32'h00000100,32'h210A); // PC base + long index + d8
  check(6,0,32'h2002,16'h00F8,32'h0000FFF0,32'h1FEA); // PC base + word -16 + d8 -8
  $display("PASS: M1.20 indexed d8(An,Xn)/d8(PC,Xn) EA primitive"); $finish;
 end
endmodule
