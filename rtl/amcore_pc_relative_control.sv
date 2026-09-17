// AmiCore M1.19 — PC-relative control effective-address integration.
//
// This block captures the 68000 d16(PC) semantics used by LEA, PEA, JMP and
// JSR. pc_extension is the address of the extension word (the 68000 PC base
// for this addressing mode). The instruction decoder supplies whether the
// operation writes an address register, pushes the EA, jumps, or calls.
module amcore_pc_relative_control (
    input  logic [31:0] pc_extension,
    input  logic [15:0] displacement,
    input  logic        is_jsr,
    output logic [31:0] effective_address,
    output logic [31:0] return_address
);
    always_comb begin
        effective_address = pc_extension + {{16{displacement[15]}}, displacement};
        // d16(PC) has one extension word. For JSR the return address is the
        // instruction address + 4, i.e. two bytes after pc_extension.
        return_address = is_jsr ? (pc_extension + 32'd2) : 32'd0;
    end
endmodule
