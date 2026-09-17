# M1.17 — LEA/PEA effective-address baseline

Status: **PASS**

## Scope

M1.17 extends the clean-room 68000 execution baseline with LEA and PEA control effective-address generation for:

- `(An)`
- `d16(An)`
- `xxx.W`
- `xxx.L`

The implementation sign-extends 16-bit displacement and absolute-short operands and preserves CCR state because LEA and PEA do not modify the condition codes.

PEA uses the existing 32-bit stack-write sequence and explicitly qualifies `PEA (A7)` so the value pushed is the original A7 effective address before stack predecrement.

## Automated qualification

GitHub Actions workflow `.github/workflows/m1_17.yml` qualifies:

1. the standalone effective-address generator;
2. the LEA/PEA execution primitive;
3. CPU integration for `(An)`;
4. CPU integration for `d16(An)`, `xxx.W` and `xxx.L`;
5. CCR preservation;
6. stack behaviour including `PEA (A7)`.

The extended CPU integration landed in commit `78978d6412acd7b9d91a55bbf802a64a65ca8350`, its qualification test in `06de743907f6039001fe692846b70aad41a888f3`, and the workflow update in `955d6fe964c00cdf58ab3df0eeafa601fc46327f`.

Workflow run 35265719678 passed on commit `955d6fe964c00cdf58ab3df0eeafa601fc46327f`. Subsequent M1.17 runs also passed after documentation/roadmap changes, including run 35266164034.

## Result

M1.17 is complete for its declared control-EA subset. Indexed and PC-relative effective-address forms remain future CPU-coverage work and are not implied by this milestone.

## Next

M1.18 defines the CPU clock/timing control boundary needed to keep **Authentic** machine timing separate from deliberate **Turbo** acceleration.
