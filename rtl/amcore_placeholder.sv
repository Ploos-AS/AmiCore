// AmiCore M0 placeholder module.
// M0 establishes the SystemVerilog source boundary only.
// Functional Amiga compatibility begins in later milestones.

module amcore_placeholder (
    input  logic clk,
    input  logic reset_n,
    output logic alive
);

    always_ff @(posedge clk) begin
        if (!reset_n)
            alive <= 1'b0;
        else
            alive <= 1'b1;
    end

endmodule
