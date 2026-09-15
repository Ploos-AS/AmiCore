// AmiCore M1.10 — clean-room 68000 arithmetic/CCR helper.
// Implements 32-bit ADDQ/SUBQ flag semantics for X, N, Z, V and C.

module amcore_alu (
    input  logic [31:0] lhs,
    input  logic [3:0]  quick,
    input  logic        sub,
    output logic [31:0] result,
    output logic        flag_x,
    output logic        flag_n,
    output logic        flag_z,
    output logic        flag_v,
    output logic        flag_c
);
    logic [32:0] wide;
    logic [31:0] rhs;

    always_comb begin
        rhs = {28'd0, quick};
        if (sub) begin
            result = lhs - rhs;
            wide = {1'b0, lhs} - {1'b0, rhs};
            // 68000 C/X for subtraction indicate borrow.
            flag_c = (lhs < rhs);
            flag_x = flag_c;
            flag_v = (lhs[31] ^ rhs[31]) & (lhs[31] ^ result[31]);
        end else begin
            wide = {1'b0, lhs} + {1'b0, rhs};
            result = wide[31:0];
            flag_c = wide[32];
            flag_x = wide[32];
            flag_v = ~(lhs[31] ^ rhs[31]) & (lhs[31] ^ result[31]);
        end
        flag_n = result[31];
        flag_z = (result == 32'd0);
    end
endmodule
