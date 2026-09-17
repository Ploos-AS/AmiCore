# AmiCore M0 Architecture

## Purpose

AmiCore is an open FPGA and hardware implementation project targeting functional compatibility with classic Amiga systems.

The project has two principal optimization targets:

- an A500/OCS/68000-compatible system on the smallest practical low-cost FPGA and supporting hardware;
- an A1200/AGA/68020-class system on the smallest practical FPGA and supporting hardware.

Compatibility and resource efficiency are both architectural requirements. Larger development targets may be used during implementation, but functionality should subsequently be optimized into the minimum machine profiles.

## Design principles

1. Keep the Amiga-compatible core independent of any particular FPGA board.
2. Keep CPU, chipset, memory, storage, networking, and peripheral interfaces as explicit modules.
3. Prefer deterministic RTL and reproducible simulation over board-specific shortcuts.
4. Develop compatibility from public technical documentation and independently authored tests.
5. Keep proprietary ROM contents and proprietary HDL/netlists outside the repository.
6. Keep modern I/O such as HDMI, USB, Ethernet and SD outside the definition of classic chipset behaviour.
7. Treat FPGA resources, external component count, board area and cost as measurable optimization targets.
8. Preserve native timing and electrical abstractions so classic and modern physical interfaces can coexist.

## Logical layers

```text
+------------------------------------------------------------------+
|                         Board Wrapper                            |
| HDMI | RGB | Audio | RAM | SD | USB | Ethernet | Floppy | I/O  |
+-------------------------------+----------------------------------+
                                |
+-------------------------------v----------------------------------+
|                          AmiCore Top                             |
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

Resource-minimized OCS/68000 profile. Modern compact I/O may be used to reduce board size, while software-visible A500 behaviour remains the compatibility target.

### AmiCore 500

Full A500-oriented PCB with classic joystick/mouse, serial, parallel, audio and physical floppy/Gotek connectivity plus HDMI and modern storage conveniences.

### AmiCore 1200 Mini

Resource-minimized AGA/68020-class profile with compact modern physical I/O.

### AmiCore 1200

Full A1200-oriented PCB including classic I/O, IDE, physical floppy/Gotek, HDMI and expansion facilities.

### AmiCore Developer Board

A deliberately less constrained implementation with a larger FPGA, additional RAM, GPIO, JTAG/UART and test points. New functionality can be qualified here before resource optimization for Mini/full production profiles.

## Video and audio

The core produces native Amiga-compatible video timing and audio semantics. Board wrappers may convert these to HDMI and HDMI audio. HDMI must not become the timing reference for chipset behaviour.

A native RGB abstraction should remain available for optional CRT/RGB adapters and compatibility measurement. Full boards should also provide analog stereo audio.

## Floppy architecture

The floppy subsystem must support:

- physical Amiga-compatible floppy drives;
- standard Gotek/FlashFloppy devices;
- DF0:/DF1: and external-drive semantics as profiles require;
- complete relevant control/status/timing signals at the board boundary;
- future raw flux capture and flux generation.

The PCB should expose enough of the floppy boundary through connectors/test points that an external Greaseweazle-style workflow can be used without redesigning the board. A later AmiCore FPGA block may timestamp flux transitions into a FIFO and replay flux for physical media writing.

## Networking architecture

Ethernet is a supported expansion, but it is deliberately separate from the classic chipset core.

```text
Amiga software / driver
        |
        v
AmiCore network-device model
        |
        v
Peripheral / expansion bus
        |
        +---- RTL MAC + external PHY
        +---- low-cost MAC/PHY controller
        +---- optional network module
        |
        v
      RJ45
```

Full AmiCore boards should target integrated wired Ethernet. Mini boards may expose an optional module/footprint so the smallest machine is not forced to carry unused PHY/magnetics/RJ45 hardware.

The network-device interface and driver should be open and documented. The architecture should permit interrupt-driven operation first and DMA/bus-master acceleration later without coupling networking into OCS/AGA timing.

## Physical I/O targets

Full boards should provide or explicitly route for:

- 2 x DE-9 Amiga joystick/mouse
- serial
- parallel
- HDMI
- analog stereo audio
- 34-pin floppy/Gotek
- SD/microSD
- keyboard
- Ethernet
- RTC
- A1200 IDE where applicable
- programming/debug interfaces

USB may be used for modern keyboard/mouse/gamepad and maintenance through a translation layer outside the classic core.

## Expansion philosophy

A board-independent peripheral/expansion interface should permit Ethernet, RTG, storage, accelerators and future peripherals without modifying chipset internals. Classic A500 side-expansion and A1200 expansion/clock-port behaviour should be represented where practical, while compact boards may expose electrically appropriate headers rather than mechanically reproducing every legacy connector.

## Resource qualification

Every supported FPGA profile should eventually produce machine-readable synthesis reports containing at least:

- LUT/LE usage
- flip-flops/registers
- BRAM/block memory
- PLL/DSP use
- required external RAM
- achieved Fmax
- FPGA device/family

CI should track these values so compatibility improvements can be evaluated alongside resource cost and accidental growth can be detected.

## Initial contracts

Implementation phases define:

- system clock and reset
- CPU/bus transaction abstraction
- address and data widths
- memory response semantics
- interrupt lines
- video/audio abstractions
- floppy boundary
- peripheral/expansion bus
- board wrapper boundaries

## Planned HDL

SystemVerilog is the preferred RTL language. Verification should use open tooling such as Verilator and/or Icarus Verilog where possible, with reproducible synthesis tooling per supported FPGA family.

## Target progression

```text
68000/core infrastructure
          |
          v
    A500 / OCS baseline
          |
          +---- A500 Developer target
          +---- A500 minimum-FPGA optimization
          +---- AmiCore 500 PCB
          |
          v
         ECS
          |
          v
    AGA / 68020-class
          |
          +---- A1200 Developer target
          +---- A1200 minimum-FPGA optimization
          +---- AmiCore 1200 PCB
          |
          +---- Ethernet / expansion
          +---- Gotek / physical floppy
          +---- flux preservation
```
