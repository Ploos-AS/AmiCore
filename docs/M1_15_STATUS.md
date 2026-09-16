# M1.15 — DBcc and Scc condition-code execution

M1.15 extends the clean-room 68000 execution baseline with condition-code instruction execution beyond Bcc.

## Implemented

- Exhaustive 16-condition × 16-NZVC truth-table qualification.
- Shared standalone condition helper with Scc `$ff`/`$00` values.
- DBcc primitive qualification.
- Register-direct Scc primitive qualification.
- CPU decode/execution integration for `DBcc Dn,disp16`.
- CPU decode/execution integration for register-direct `Scc Dn`.
- DBcc decrements only the low 16 bits of Dn and preserves the upper word.
- DBcc branches on condition false while the decremented low word is not `$ffff`.
- Scc preserves the upper 24 bits of Dn.
- DBcc and Scc leave CCR unchanged.
- T/F condition encodings are supported for DBT/DBF and ST/SF semantics.

## Qualification

GitHub Actions qualification passed after CPU integration on `main` at commit `e5214a0c827e772139a5358b6ed9fc28bf7ec541`.

The existing RTL regression and M1.14 Bcc regression also remained green at that commit.

## Deferred

M1.15 does not add memory effective-address forms for Scc. Broader effective-address coverage remains part of later CPU expansion work.

## Next

M1.16 introduces JMP/JSR control flow and an initial effective-address baseline suitable for those instructions.
