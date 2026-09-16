`timescale 1ns/1ps
module tb_m1_15_condition;
 logic[3:0]cc; logic n,z,v,c,take; logic[7:0]scc_value; integer flags,cond;
 amcore_condition dut(.*);
 function automatic logic expected(input logic[3:0]q,input logic nn,zz,vv,ccarry);begin
  case(q)
   0:expected=1;1:expected=0;2:expected=!ccarry&&!zz;3:expected=ccarry||zz;
   4:expected=!ccarry;5:expected=ccarry;6:expected=!zz;7:expected=zz;
   8:expected=!vv;9:expected=vv;10:expected=!nn;11:expected=nn;
   12:expected=(nn==vv);13:expected=(nn!=vv);14:expected=!zz&&(nn==vv);15:expected=zz||(nn!=vv);
  endcase
 end endfunction
 initial begin
  for(flags=0;flags<16;flags=flags+1)begin
   {n,z,v,c}=flags[3:0];
   for(cond=0;cond<16;cond=cond+1)begin
    cc=cond[3:0];#1;
    if(take!==expected(cc,n,z,v,c))$fatal(1,"cc=%h nzvc=%b%b%b%b take=%b",cc,n,z,v,c,take);
    if(scc_value!==(take?8'hff:8'h00))$fatal(1,"Scc value mismatch cc=%h",cc);
   end
  end
  $display("PASS: M1.15 all 16 condition codes across all NZVC combinations");
  $finish;
 end
endmodule
