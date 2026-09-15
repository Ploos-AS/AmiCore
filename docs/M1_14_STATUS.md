# M1.14 — Bcc conditional branches

M1.14 extends the clean-room 68000 execution baseline with conditional branches driven by CCR N/Z/V/C.

Implemented conditions: HI, LS, CC/HS, CS/LO, NE, EQ, VC, VS, PL, MI, GE, LT, GT and LE.

Both 8-bit displacement and 16-bit extension-word forms are supported. A not-taken `.w` branch still consumes its extension word. Existing BRA and BSR paths remain separate.

Qualification is provided by `sim/tb_m1_14_bcc.sv` and `sim/tb_m1_14_bcc_flags.sv`, including taken/not-taken cases, extension-word handling and representative signed/overflow conditions.
