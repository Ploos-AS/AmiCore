`timescale 1ns/1ps
module tb_m1_16_absolute;
 logic mode_long; logic[15:0] extension_hi,extension_lo; logic[31:0] effective_address; logic[2:0] instruction_bytes;
 amcore_jump_absolute dut(.*);
 task automatic check(input logic ml,input logic[15:0]hi,input logic[15:0]lo,input logic[31:0]ea,input logic[2:0]bytes);
  begin mode_long=ml;extension_hi=hi;extension_lo=lo;#1;
   if(effective_address!==ea)$fatal(1,"EA mismatch got=%h expected=%h",effective_address,ea);
   if(instruction_bytes!==bytes)$fatal(1,"length mismatch got=%0d expected=%0d",instruction_bytes,bytes);
  end
 endtask
 initial begin
  check(0,16'h1234,16'hdead,32'h00001234,3'd4);
  check(0,16'h8000,16'hbeef,32'hffff8000,3'd4);
  check(0,16'hfffc,16'h0000,32'hfffffffc,3'd4);
  check(1,16'h0012,16'h3456,32'h00123456,3'd6);
  check(1,16'hffff,16'h8000,32'hffff8000,3'd6);
  $display("PASS: M1.16 absolute JMP/JSR effective-address primitive");$finish;
 end
endmodule
