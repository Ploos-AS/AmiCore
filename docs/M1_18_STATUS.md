# M1.18 — Authentic/Turbo CPU timing control

Status: **PASS**

## Scope

M1.18 establishes a board-independent CPU timing-control boundary for the two mandatory AmiCore operating modes:

- **Authentic** — profile-defined cadence intended to become the timing reference for the original machine.
- **Turbo** — deliberately accelerated CPU cadence.

The boundary uses a CPU enable pulse inside the common master-clock domain instead of generating a separate gated CPU clock. This keeps later chipset arbitration and DMA timing in one deterministic timing domain.

## Shared-bus rule

Turbo is not allowed to bypass chipset ownership of the shared bus. `bus_available` can stall CPU enable generation in both modes. This is the foundation for later Agnus DMA-slot and chip-bus contention modelling: Turbo may accelerate CPU-private work, but shared chip-bus accesses remain subject to machine arbitration.

## Implementation

`rtl/amcore_cpu_clock_control.sv` provides:

- profile parameters `AUTH_DIV` and `TURBO_DIV`;
- explicit `turbo_mode` selection;
- `authentic_mode` status;
- deterministic `cpu_enable` generation;
- shared-bus stall/resume behaviour;
- elaboration/simulation guards against invalid divider values.

The initial qualification profile uses `AUTH_DIV=4` and `TURBO_DIV=1` only to prove the timing boundary. These values are not claims about final A500 or A1200 master-clock ratios; machine-accurate values belong to the later machine profiles and must be derived from the selected FPGA master clock and original hardware timing.

## Automated qualification

`sim/tb_m1_18_cpu_clock_control.sv` checks:

1. Authentic cadence;
2. Turbo cadence;
3. mode-status reporting;
4. complete CPU stall while the shared bus is unavailable;
5. deterministic resume after bus ownership returns;
6. watchdog timeout protection.

GitHub Actions workflow `.github/workflows/m1_18.yml` runs the qualification with Icarus Verilog.

Workflow run **35266609895** on commit `b1db703bf1a569c266aa5a10971955c7372b299c` completed successfully. The general RTL workflow and the existing M1.14–M1.17 CPU regressions on the same head also completed successfully.

## Result

M1.18 is complete for the CPU timing-control boundary. It does not yet claim cycle-accurate A500 or A1200 timing. That accuracy will be established with the chipset, bus-arbitration and machine-profile work and compared against original hardware.

## Next

M1.19+ continues the remaining 68000 instruction and addressing-mode coverage required before meaningful OCS/A500 software qualification, while preserving the new Authentic/Turbo timing boundary.
