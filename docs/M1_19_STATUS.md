# M1.19 Qualification Status

Status: **PASS**

M1.19 adds the 68000 `d16(PC)` control effective-address baseline.

Qualified paths:

- reusable effective-address primitive
- LEA `d16(PC),An`
- PEA `d16(PC)`
- JMP `d16(PC)`
- JSR `d16(PC)`
- JSR return-address semantics
- execution through `amcore_68k_baseline`, including JSR/RTS and stack behaviour

The PC base is the address of the extension word, matching the 68000 `d16(PC)` addressing rule.

GitHub Actions qualification run: 35280891897 — PASS.
General RTL regression run: 35280891744 — PASS.

Next milestone: M1.20, indexed `d8(An,Xn)` and `d8(PC,Xn)` control effective-address baseline.
