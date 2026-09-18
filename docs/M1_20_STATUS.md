# M1.20 Status — Indexed control effective addresses

Status: **PASS**

M1.20 integrates brief-extension indexed 68000 control effective addresses into the baseline CPU.

## Qualified scope

- `d8(An,Xn)` and `d8(PC,Xn)` effective-address generation.
- Dn and An index selection from the 68000 brief extension word.
- Word index sign extension and full 32-bit long index.
- Signed 8-bit displacement.
- LEA and PEA indexed execution.
- JMP and JSR indexed target calculation.
- PC-relative base is the address of the extension word.
- Regression coverage for M1.14 through M1.19 remains intact.

68000 baseline semantics intentionally do not add 68020 index scaling.

## Qualification

GitHub Actions run **35290018598** passed the M1.20 indexed effective-address workflow after the CPU integration and test-vector corrections.

The qualification includes both the standalone effective-address primitive and execution through `amcore_68k_baseline`.

## Follow-on

M1.21 extends the data-transfer path so MOVE/MOVEA can use the broader effective-address machinery rather than limiting indexed/displacement addressing to control instructions.
