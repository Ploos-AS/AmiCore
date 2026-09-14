`timescale 1ns/1ps

module tb_m1_interfaces;
    logic clk = 1'b0;
    logic reset_n = 1'b0;
    logic alive;

    amcore_placeholder dut (
        .clk(clk),
        .reset_n(reset_n),
        .alive(alive)
    );

    always #5 clk = ~clk;

    initial begin
        #12;
        if (alive !== 1'b0) $fatal(1, "alive must be low while reset is asserted");
        reset_n = 1'b1;
        #10;
        if (alive !== 1'b1) $fatal(1, "alive must assert after reset release");
        $display("PASS: M1 reset/alive deterministic vector");
        $finish;
    end
endmodule
