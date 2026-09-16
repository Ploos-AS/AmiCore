// AmiCore M1.15 — Scc Dn register-direct execution primitive.
// Writes only the low byte; upper 24 bits of Dn are preserved.
module amcore_scc_reg(
 input  logic       condition_true,
 input  logic[31:0] dreg_in,
 output logic[31:0] dreg_out
);
 always_comb begin
  dreg_out = {dreg_in[31:8], condition_true ? 8'hff : 8'h00};
 end
endmodule
