// AmiCore M1.16 — clean-room JMP/JSR execution primitive.
// The effective address is supplied by the caller. JSR returns the address
// immediately following the instruction and requests a normal 68000 longword
// return-PC stack push (low word first in the AmiCore bus state machine).
module amcore_jump(
 input  logic        is_jsr,
 input  logic [31:0] effective_address,
 input  logic [31:0] next_pc,
 output logic [31:0] target_pc,
 output logic [31:0] return_pc,
 output logic        push_return
);
 always_comb begin
  target_pc = effective_address;
  return_pc = next_pc;
  push_return = is_jsr;
 end
endmodule
