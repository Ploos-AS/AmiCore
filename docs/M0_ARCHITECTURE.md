# AmiCore M0 Architecture

## Purpose

AmiCore is an open FPGA and hardware implementation project targeting functional and timing compatibility with classic Amiga systems.

The project has two principal machine targets:

- **AmiCore 500:** reproduce the original A500 gaming/demo experience as closely as practical on the smallest practical low-cost FPGA and supporting hardware.
- **AmiCore 1200:** reproduce an original A1200 as closely as practical and provide a full-featured replacement machine, including legacy peripheral compatibility, on efficient modern hardware.

Compatibility and resource efficiency are both architectural requirements, but Authentic-mode compatibility takes precedence over resource savings. Larger development targets may be used during implementation before functionality is optimized into minimum profiles.

## Design principles

1. Authentic behaviour is the compatibility reference; acceleration is an optional mode, not the baseline.
2. Keep the Amiga-compatible core independent of any particular FPGA board.
3. Keep CPU, chipset, memory, storage, networking, and peripheral interfaces as explicit modules.
4. Prefer deterministic RTL and reproducible simulation over board-specific shortcuts.
5. Develop compatibility from public technical documentation, independently authored tests and measurements against original hardware where practical.
6. Keep proprietary ROM contents and proprietary HDL/netlists outside the repository.
7. Keep modern I/O such as HDMI, USB, Ethernet and SD outside the definition of classic chipset behaviour.
8. Treat FPGA resources, external component count, board area and cost as measurable optimization targets.
9. Preserve native timing and electrical abstractions so classic and modern physical interfaces can coexist.
10. Qualify timing-sensitive A500 games/demos and A1200 software/peripherals as first-class workloads.

## Operating modes

### Authentic

Authentic is the default mode for A500 and A1200 production profiles. It targets the clocks, timing, contention and observable behaviour of the corresponding original machine. CPU speed, chipset timing, DMA slots, Copper/Blitter interaction, raster timing, Paula audio/floppy timing, CIA timing and interrupt behaviour must not be accelerated merely because the FPGA can run faster.

A modern HDMI/storage/network subsystem may physically remain present, but it must not alter machine-visible timing unless explicitly documented as unavoidable output adaptation.

### Turbo

Turbo deliberately enables enhancements. Candidate features include higher CPU clock, Fast RAM, accelerated storage, faster memory paths, networking and future RTG/accelerator functions.

Turbo and Authentic share the same compatibility implementation. Turbo features should be isolated behind explicit configuration and must not be prerequisites for Authentic operation.

Mode selection should eventually be available through a board configuration mechanism and software-visible management interface, with a safe Authentic default after reset or configuration recovery.

## Logical layers

```text
+------------------------------------------------------------------+
|                         Board Wrapper                            |
| HDMI | RGB | Audio | RAM | SD | USB | Ethernet | Floppy | I/O  |
+-------------------------------+----------------------------------+
                                |
+-------------------------------v----------------------------------+
|                          AmiCore Top                             |
|     mode: Authentic / Turbo                                     |
|                                                                  |
|  CPU -------- System Bus -------- Memory / ROM                   |
|                    |                                             |
|          +---------+----------+                                  |
|          |                    |                                  |
|      Chipset             CIA / Peripheral / Expansion            |
|   OCS/ECS/AGA            interfaces                              |
|          |                    |                                  |
| Video | Audio | DMA | Floppy | Serial | Parallel | Joystick     |
+------------------------------------------------------------------+
```

## Machine profiles

### AmiCore 500 Mini

Resource-minimized OCS/68000 profile. Authentic mode prioritizes the original A500 game/demo experience. Modern compact I/O may reduce board size without changing software-visible A500 behaviour.

### AmiCore 500

Full A500-oriented PCB with classic joystick/mouse, serial, parallel, audio and physical floppy/Gotek connectivity plus HDMI and modern storage conveniences. Authentic is the default; Turbo is an explicit enhancement.

### AmiCore 1200 Mini

Resource-minimized AGA/68020-class profile. It retains the same Authentic/Turbo distinction but may omit large physical legacy connectors.

### AmiCore 1200

Full A1200 replacement PCB including classic I/O, IDE, physical PCMCIA, physical floppy/Gotek, HDMI and expansion facilities. Authentic mode targets original A1200 behaviour and legacy hardware compatibility.

### AmiCore Developer Board

A deliberately less constrained implementation with a larger FPGA, additional RAM, GPIO, JTAG/UART and test points. It supports measuring Authentic behaviour and developing Turbo features before resource optimization.

## A500 authenticity focus

The A500 qualification strategy must include timing-sensitive games and demos, not merely synthetic register tests. Important domains include:

- 68000/chip-bus interaction
- Agnus DMA scheduling and contention
- Copper timing
- Blitter timing and nasty mode
- Denise raster/display timing
- Paula audio DMA and channel behaviour
- floppy timing and disk-change behaviour
- CIA timers, interrupts and ports
- joystick/mouse input timing
- PAL/NTSC behaviour
- reset/boot behaviour

Where feasible, measurements and traces from original A500 hardware should become reusable qualification vectors.

## A1200 replacement focus

AmiCore 1200 adds full-machine replacement requirements: AGA/68020 behaviour, Gayle, IDE, PCMCIA, floppy, DE-9, serial, parallel, keyboard, RTC and relevant expansion interfaces. Qualification should include real legacy hardware, particularly PCMCIA and storage devices, rather than software-only tests.

## Video and audio

The core produces native Amiga-compatible video timing and audio semantics. Board wrappers may convert these to HDMI and HDMI audio. HDMI must not become the timing reference for chipset behaviour. Output conversion should minimize buffering and latency; Authentic mode should avoid unnecessary frame buffering.

A native RGB abstraction should remain available for optional CRT/RGB adapters and compatibility measurement. Full boards should also provide analog stereo audio.

## Floppy architecture

The floppy subsystem must support physical Amiga-compatible floppy drives, standard Gotek/FlashFloppy devices, DF0:/DF1: and external-drive semantics, complete relevant control/status/timing signals, and future raw flux capture/generation.

The PCB should expose enough of the floppy boundary through connectors/test points that an external Greaseweazle-style workflow can be used without redesigning the board. A later AmiCore FPGA block may timestamp flux transitions into a FIFO and replay flux for physical media writing.

## Networking architecture

Ethernet is a supported expansion, deliberately separate from the classic chipset core. Full boards should target integrated wired Ethernet; Mini boards may expose an optional module/footprint. Networking and wireless enhancements must not change Authentic chipset timing.

## Physical I/O targets

Full boards should provide or explicitly route for 2 x DE-9 Amiga joystick/mouse, serial, parallel, HDMI, analog stereo audio, 34-pin floppy/Gotek, SD/microSD, keyboard, Ethernet, RTC, and A1200 IDE/PCMCIA where applicable. USB may provide modern input/maintenance through a translation layer outside the classic core.

## Expansion philosophy

A board-independent peripheral/expansion interface should permit Ethernet, wireless, RTG, storage, accelerators and future peripherals without modifying chipset internals. Classic A500 side-expansion and A1200 expansion/clock-port behaviour should be represented where practical.

## Resource qualification

Every supported FPGA profile should eventually produce machine-readable synthesis reports containing LUT/LE usage, flip-flops/registers, BRAM/block memory, PLL/DSP use, required external RAM, achieved Fmax and FPGA device/family. CI should track these values, but a resource regression is preferable to an Authentic compatibility regression until a correct optimization is found.

## Initial contracts

Implementation phases define system clock/reset, CPU/bus transactions, address/data widths, memory response semantics, interrupts, video/audio abstractions, floppy boundary, peripheral/expansion bus, board wrappers, and the Authentic/Turbo mode boundary.

## Planned HDL

SystemVerilog is the preferred RTL language. Verification should use open tooling such as Verilator and/or Icarus Verilog where possible, with reproducible synthesis tooling per supported FPGA family.

## Target progression

```text
68000/core infrastructure
          |
          v
    A500 / OCS Authentic baseline
          |
          +---- original-hardware/game/demo qualification
          +---- Turbo enhancements
          +---- A500 minimum-FPGA optimization
          +---- AmiCore 500 PCB
          |
          v
         ECS
          |
          v
    AGA / A1200 Authentic baseline
          |
          +---- software + legacy-hardware qualification
          +---- Turbo enhancements
          +---- A1200 minimum-FPGA optimization
          +---- AmiCore 1200 PCB
```
