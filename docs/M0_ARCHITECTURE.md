# AmiCore M0 Architecture

## Purpose

AmiCore is an open FPGA implementation project targeting functional compatibility with classic Amiga systems, with the A1200/AGA as the long-term reference platform.

## Design principles

1. Keep the Amiga-compatible core independent of any particular FPGA board.
2. Keep CPU, chipset, memory, storage, and peripheral interfaces as explicit modules.
3. Prefer deterministic RTL and reproducible simulation over board-specific shortcuts.
4. Develop compatibility from public technical documentation and independently authored tests.
5. Keep proprietary ROM contents and proprietary HDL/netlists outside the repository.

## Initial logical layers

```text
+--------------------------------------------------+
|                 Board Wrapper                    |
| HDMI | Audio | SDRAM | Input | Storage | Clocks |
+-------------------------+------------------------+
                          |
+-------------------------v------------------------+
|                 AmiCore Top                      |
|                                                  |
|  CPU ---- Bus ---- Memory / ROM                  |
|             |                                    |
|       +-----+-----+                              |
|       |           |                              |
|   Chipset       CIA/Peripheral                   |
|   OCS/ECS/AGA   interfaces                       |
|       |                                           |
|   Video / Audio / DMA / Floppy / Serial          |
+--------------------------------------------------+
```

## M0 contracts

The first implementation phase will define:

- system clock and reset
- CPU/bus transaction abstraction
- address and data widths
- memory response semantics
- interrupt lines
- video output abstraction
- audio output abstraction
- board wrapper boundaries

No cycle-accurate Amiga chipset implementation is claimed by M0.

## Planned HDL

SystemVerilog is the preferred RTL language. The initial verification flow should support open tooling such as Verilator and/or Icarus Verilog, with synthesis tooling added per supported FPGA family.

## Target progression

```text
OCS/ECS development
        |
        v
    ECS baseline
        |
        v
     AGA core
        |
        v
 A1200 reference system
        |
        +---- low-cost FPGA boards
        +---- larger FPGA boards
        +---- custom AmiCore hardware
```
