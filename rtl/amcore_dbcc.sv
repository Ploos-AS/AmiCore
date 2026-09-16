// AmiCore M1.15 — DBcc execution primitive.
// Implements the MC68000 DBcc register/branch rule independently of bus timing.
module amcore_dbcc(
 input  logic        condition_true,
 input  logic [31:0] dreg_in,
 input  logic [31:0] pc_opcode,
 input  logic [15:0] displacement,
 output logic [31:0] dreg_out,
 output logic [31:0] pc_out,
 output logic        branch_taken
);
 logic [15:0] decremented;
 always_comb begin
  dreg_out = dreg_in;
  pc_out = pc_opcode + 32'd4;
  branch_taken = 1'b0;
  decremented = dreg_in[15:0] - 16'd1;
  if (!condition_true) begin
   dreg_out = {dreg_in[31:16], decremented};
   if (decremented != 16'hffff) begin
    pc_out = pc_opcode + 32'd2 + {{16{displacement[15]}}, displacement};
    branch_taken = 1'b1;
   end
  end
 end
endmodule
