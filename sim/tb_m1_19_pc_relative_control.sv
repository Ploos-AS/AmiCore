`timescale 1ns/1ps

module tb_m1_19_pc_relative_control;
    logic [31:0] pc_extension;
    logic [15:0] displacement;
    logic is_jsr;
    logic [31:0] effective_address;
    logic [31:0] return_address;

    amcore_pc_relative_control dut (.*);

    task automatic check(
        input logic [31:0] t_pc,
        input logic [15:0] t_disp,
        input logic t_jsr,
        input logic [31:0] t_ea,
        input logic [31:0] t_ret
    );
        begin
            pc_extension = t_pc;
            displacement = t_disp;
            is_jsr = t_jsr;
            #1;
            if (effective_address !== t_ea || return_address !== t_ret)
                $fatal(1, "pc=%h disp=%h jsr=%b ea=%h ret=%h expected=%h/%h",
                       t_pc,t_disp,t_jsr,effective_address,return_address,t_ea,t_ret);
        end
    endtask

    initial begin
        // LEA/PEA/JMP all consume the same d16(PC) EA calculation.
        check(32'h00000102,16'h001e,1'b0,32'h00000120,32'h00000000);
        check(32'h00000120,16'hffe0,1'b0,32'h00000100,32'h00000000);
        // JSR additionally captures the address after its extension word.
        check(32'h00000202,16'h003e,1'b1,32'h00000240,32'h00000204);
        check(32'h01000000,16'h8000,1'b1,32'h00ff8000,32'h01000002);
        $display("PASS: M1.19 LEA/PEA/JMP/JSR d16(PC) control-EA semantics");
        $finish;
    end
endmodule
