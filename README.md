# AmiCore

Open FPGA core project for a clean-room, hardware-compatible Amiga implementation.

AmiCore is intended to scale from OCS/ECS systems toward an AGA/A1200-class implementation on affordable FPGAs. The project separates the compatibility core from board-specific wrappers so the same RTL can target multiple FPGA boards.

## M0 — Foundation

M0 establishes the repository structure, HDL language/tooling baseline, simulation smoke test, and architecture roadmap. No Amiga chipset compatibility is claimed yet.

## Goals

- clean-room, functionally compatible Amiga implementation
- SystemVerilog-first RTL
- deterministic simulation and automated CI
- scalable OCS/ECS/AGA architecture
- A1200-class target as the long-term reference
- board-independent core with separate FPGA targets
- open documentation and reproducible builds

## Non-goals

AmiCore does not copy proprietary HDL, netlists, gate-level implementations, or copyrighted ROM contents. Compatibility is developed from publicly available technical information and independently created tests.

## Repository

```text
rtl/          Core RTL
sim/          Simulation testbenches
boards/       FPGA board wrappers and constraints
scripts/      Development and verification helpers
docs/         Architecture and qualification documentation
.github/      CI workflows
```

## Status

**M0 — Foundation: in progress**

The first milestones will establish the bus, clock/reset, memory, CPU integration boundary, and simulation infrastructure before chipset implementation begins.
