`timescale 1ns/1ps

module tb_m1_10_ccr;
    logic [31:0] lhs;
    logic [3:0] quick;
    logic sub;
    logic [31:0] result;
    logic x,n,z,v,c;

    amcore_alu dut(.lhs(lhs), .quick(quick), .sub(sub), .result(result),
                   .flag_x(x), .flag_n(n), .flag_z(z), .flag_v(v), .flag_c(c));

    task check;
        input [31:0] a;
        input [3:0] q;
        input s;
        input [31:0] expected;
        input ex,en,ez,ev,ec;
        begin
            lhs=a; quick=q; sub=s; #1;
            if (result!==expected || x!==ex || n!==en || z!==ez || v!==ev || c!==ec) begin
                $display("FAIL: a=%h q=%0d sub=%b result=%h XNZVC=%b%b%b%b%b", a,q,s,result,x,n,z,v,c);
                $fatal(1);
            end
        end
    endtask

    initial begin
        // ADDQ.L #1,$7fffffff -> $80000000: N,V set.
        check(32'h7fffffff,4'd1,1'b0,32'h80000000, 0,1,0,1,0);
        // ADDQ.L #1,$ffffffff -> 0: Z,C,X set.
        check(32'hffffffff,4'd1,1'b0,32'h00000000, 1,0,1,0,1);
        // SUBQ.L #1,$80000000 -> $7fffffff: V set, no borrow.
        check(32'h80000000,4'd1,1'b1,32'h7fffffff, 0,0,0,1,0);
        // SUBQ.L #1,0 -> $ffffffff: N,C,X set (borrow).
        check(32'h00000000,4'd1,1'b1,32'hffffffff, 1,1,0,0,1);
        // Quick field value 0 is decoded as 8 by the CPU; ALU receives 8.
        check(32'h00000008,4'd8,1'b1,32'h00000000, 0,0,1,0,0);
        $display("PASS: M1.10 ADDQ.L/SUBQ.L XNZVC boundary vectors");
        $finish;
    end
endmodule
