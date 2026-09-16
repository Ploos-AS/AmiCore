# M1.16 — JMP/JSR control-flow qualification

Status: **PASS**

M1.16 extends the clean-room 68000 execution baseline with qualified JMP/JSR control flow and a first reusable control-flow effective-address subset.

## Implemented

- `JMP (An)`
- `JSR (An)`
- `JMP xxx.W`
- `JSR xxx.W`
- `JMP xxx.L`
- `JSR xxx.L`
- Absolute-short address sign extension
- Correct JSR return PC for 2-, 4- and 6-byte instruction forms
- 32-bit return-PC stack push using the existing supervisor/user A7 path
- RTS round-trip qualification after JSR
- CCR is unchanged by JMP/JSR

## Qualification

GitHub Actions qualifies:

1. the standalone JMP/JSR execution primitive;
2. absolute `.W`/`.L` effective-address generation;
3. CPU `(An)` JMP/JSR plus RTS stack round-trip;
4. CPU absolute `.W`/`.L` JMP/JSR plus RTS stack round-trip;
5. the existing M1 regression workflows.

The final M1.16 CPU integration was qualified successfully on GitHub Actions at commit `bebf10fb18159946f5a14e905ffa1c44c25e6207`.

## Deferred

M1.16 intentionally does not attempt the complete 68000 effective-address matrix. PC-relative, displacement/indexed and other reusable EA forms remain future work. Address-error and bus-error behavior are also outside this milestone.

## Next

M1.17 introduces a reusable effective-address generation baseline around `LEA` and `PEA`, building on the control-flow EA work completed here.
