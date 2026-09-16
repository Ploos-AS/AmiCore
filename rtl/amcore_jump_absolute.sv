// AmiCore M1.16 — absolute effective-address resolver for JMP/JSR.
// mode=0: xxx.W, sign-extended 16-bit absolute address.
// mode=1: xxx.L, full 32-bit absolute address.
module amcore_jump_absolute(
 input  logic        mode_long,
 input  logic [15:0] extension_hi,
 input  logic [15:0] extension_lo,
 output logic [31:0] effective_address,
 output logic [2:0]  instruction_bytes
);
 always_comb begin
  if (mode_long) begin
   effective_address = {extension_hi, extension_lo};
   instruction_bytes = 3'd6;
  end else begin
   effective_address = {{16{extension_hi[15]}}, extension_hi};
   instruction_bytes = 3'd4;
  end
 end
endmodule
