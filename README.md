# AmiCore

Open FPGA core and hardware project for a clean-room, hardware-compatible Amiga implementation.

AmiCore has two primary machine goals: implement a highly compatible A500-class machine on the smallest practical low-cost FPGA/hardware, and implement an A1200-class machine on the smallest practical FPGA/hardware capable of AGA and 68020-class operation. Resource efficiency, cost, compatibility, reproducibility, and low latency are first-class project metrics.

The compatibility core is board-independent. A common RTL architecture is configured into A500, A1200, Mini, full-board, and development profiles rather than maintained as separate incompatible cores.

## Primary machine profiles

- **AmiCore 500 Mini** — minimum practical OCS/68000 machine with HDMI, storage and modern input/service connectivity.
- **AmiCore 500** — A500 profile with classic physical I/O, real floppy/Gotek support and expansion.
- **AmiCore 1200 Mini** — minimum practical AGA/68020-class machine with HDMI and modern storage/I/O.
- **AmiCore 1200** — A1200 profile with classic physical I/O, IDE, floppy/Gotek and expansion.
- **AmiCore Developer Board** — larger FPGA/RAM and extensive debug/test connectivity for development before functionality is optimized down into the minimum profiles.

## Hardware goals

Official AmiCore PCB designs are part of the project. Depending on profile they should provide:

- two DE-9 Amiga joystick/mouse ports
- serial and parallel ports
- HDMI video with digital audio
- analog Paula-compatible stereo audio
- real floppy-drive and Gotek/FlashFloppy-compatible interface
- SD/microSD storage
- A1200 IDE where applicable
- keyboard interface
- RTC
- USB for modern keyboard/mouse/gamepad and service where appropriate
- Ethernet capability, preferably through a low-cost PHY/MAC or optional module/footprint without making the minimum board unnecessarily large
- JTAG/UART/programming and useful hardware test points
- safe bitstream/firmware recovery

Native Amiga video timing remains an internal core interface; HDMI is a board/output function. Native RGB should remain available through an optional header/adapter path for CRT and compatibility work.

## Floppy and preservation

AmiCore should support physical Amiga floppy drives and standard Gotek/FlashFloppy devices through the expected floppy interface. The hardware and RTL architecture must also be **flux-ready**: expose and preserve the timing/signals needed for Greaseweazle-style capture/write workflows and allow a later FPGA-native flux capture/generation engine.

This permits three complementary storage paths: real floppy media, Gotek disk-image emulation, and future raw flux preservation/creation.

## Networking

Ethernet is an explicit roadmap target. Networking must not be baked into the classic chipset core: the core exposes a reusable expansion/peripheral interface and board profiles provide the physical Ethernet implementation. This allows minimum boards to omit the PHY when cost/area matters while full boards can provide RJ45 Ethernet.

Longer term, AmiCore should support an Amiga-visible network adapter implemented in RTL/firmware with documented drivers/APIs, while retaining compatibility paths for software expecting established Amiga networking conventions.

## Goals

- clean-room, functionally compatible Amiga implementation
- smallest practical FPGA/hardware for the A500 target
- smallest practical FPGA/hardware for the A1200 target
- SystemVerilog-first RTL
- deterministic simulation and automated CI
- measurable LUT/LE, FF, BRAM, RAM and Fmax budgets
- scalable OCS/ECS/AGA architecture
- board-independent core with separate FPGA/PCB targets
- open KiCad hardware, documentation and reproducible builds
- classic I/O plus carefully separated modern conveniences

## Non-goals

AmiCore does not copy proprietary HDL, netlists, gate-level implementations, or copyrighted ROM contents. Compatibility is developed from publicly available technical information and independently created tests.

Modern conveniences such as HDMI, USB, Ethernet and SD storage must not silently redefine chipset-visible behaviour or timing.

## Repository

```text
rtl/          Core RTL
sim/          Simulation testbenches
boards/       FPGA board wrappers and constraints
scripts/      Development and verification helpers
docs/         Architecture, hardware and qualification documentation
.github/      CI workflows
```

## Status

M0 foundation is established and M1 CPU/core infrastructure is under active qualification. Later milestones build the OCS A500 target first, then ECS/AGA and the A1200 target, followed by optimized FPGA and custom PCB profiles.
