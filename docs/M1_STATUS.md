# M1 Status

## Core infrastructure baseline

M1 establishes the board-independent contracts needed before integrating a CPU implementation or Amiga chipset blocks.

Implemented:

- 32-bit address / 16-bit data system-bus contract
- CPU integration boundary with 68000-style address/data/control signals
- shared memory-controller contract for chip RAM and ROM
- reset/alive deterministic simulation vector
- GitHub Actions compilation and simulation of the M1 baseline

Not yet implemented:

- 68000 instruction execution
- Amiga memory map
- chipset registers
- DMA/arbitration
- cycle-exact timing

The CPU boundary is intentionally independent of the eventual CPU implementation so that a compatible 68000/68020 core can be integrated later without redesigning the system-level interfaces.
