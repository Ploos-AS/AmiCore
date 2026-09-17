# AmiCore

Open FPGA core and hardware project for a clean-room, hardware-compatible Amiga implementation.

AmiCore has two primary machine goals. **AmiCore 500** should reproduce the original A500 gaming and demo experience as closely as practical. **AmiCore 1200** should reproduce an original A1200 as closely as practical and become a full-featured replacement for the physical machine, including compatibility with legacy peripherals.

Resource efficiency, cost, compatibility, reproducibility, timing accuracy and low latency are first-class project metrics. Resource optimization must never silently reduce Authentic-mode compatibility.

The compatibility core is board-independent. A common RTL architecture is configured into A500, A1200, Mini, full-board, and development profiles rather than maintained as separate incompatible cores.

## Operating modes

Every production machine profile has at least two explicit operating modes:

- **Authentic** — default compatibility mode. CPU/chipset clocks, DMA/bus contention, raster timing, floppy timing, audio behaviour and other machine-visible timing are constrained to reproduce the corresponding original machine as closely as practical. Enhancements must not leak into this mode unless they are electrically present but software/timing transparent.
- **Turbo** — enhanced mode. AmiCore may enable faster CPU operation, Fast RAM, accelerated storage, networking and other modern enhancements while preserving the Amiga programming model where practical.

Authentic and Turbo are configurations of the same AmiCore implementation. Turbo must not become the implementation on which Authentic is approximated; the original machine behaviour is the reference for Authentic mode.

## Primary machine profiles

- **AmiCore 500 Mini** — minimum practical OCS/68000 machine focused on an authentic A500 game/demo experience, with HDMI, storage and modern input/service connectivity.
- **AmiCore 500** — full A500 replacement profile with classic physical I/O, real floppy/Gotek support and expansion.
- **AmiCore 1200 Mini** — minimum practical AGA/68020-class machine with HDMI and modern storage/I/O.
- **AmiCore 1200** — full A1200 replacement with classic physical I/O, IDE, PCMCIA, floppy/Gotek and expansion compatibility.
- **AmiCore Developer Board** — larger FPGA/RAM and extensive debug/test connectivity for development before functionality is optimized down into the minimum profiles.

## Compatibility priorities

For A500, timing-sensitive games and demos are first-class qualification workloads. OCS, 68000 timing, DMA contention, Copper, Blitter, Paula, CIA, raster, floppy and controller behaviour should be measured against original hardware wherever practical.

For A1200, compatibility includes both software and physical hardware. AGA/68020, Gayle, IDE, PCMCIA, floppy, DE-9, serial, parallel, keyboard, RTC and expansion behaviour are part of the replacement-machine goal. Existing A1200 peripherals should remain useful wherever the electrical and protocol interfaces can be reproduced safely.

## Hardware goals

Official AmiCore PCB designs are part of the project. Depending on profile they should provide:

- two DE-9 Amiga joystick/mouse ports
- serial and parallel ports
- HDMI video with digital audio
- analog Paula-compatible stereo audio
- real floppy-drive and Gotek/FlashFloppy-compatible interface
- SD/microSD storage
- A1200 IDE where applicable
- physical PCMCIA on AmiCore 1200 full
- keyboard interface
- RTC
- USB for modern keyboard/mouse/gamepad and service where appropriate
- Ethernet capability, preferably through a low-cost PHY/MAC or optional module/footprint without making the minimum board unnecessarily large
- optional vendor-independent Wi-Fi/Bluetooth module
- JTAG/UART/programming and useful hardware test points
- safe bitstream/firmware recovery

Native Amiga video timing remains an internal core interface; HDMI is a board/output function. Native RGB should remain available through an optional header/adapter path for CRT and compatibility work. HDMI conversion should minimize buffering and input-to-display latency.

## Floppy and preservation

AmiCore should support physical Amiga floppy drives and standard Gotek/FlashFloppy devices through the expected floppy interface. The hardware and RTL architecture must also be **flux-ready**: expose and preserve the timing/signals needed for Greaseweazle-style capture/write workflows and allow a later FPGA-native flux capture/generation engine.

This permits three complementary storage paths: real floppy media, Gotek disk-image emulation, and future raw flux preservation/creation.

## Networking

Ethernet is an explicit roadmap target. Networking must not be baked into the classic chipset core: the core exposes a reusable expansion/peripheral interface and board profiles provide the physical Ethernet implementation. This allows minimum boards to omit the PHY when cost/area matters while full boards can provide RJ45 Ethernet.

Longer term, AmiCore should support an Amiga-visible network adapter implemented in RTL/firmware with documented drivers/APIs, while retaining compatibility paths for software expecting established Amiga networking conventions.

## Goals

- A500 gaming/demo experience as close to original hardware as practical
- A1200 full-replacement compatibility target
- Authentic mode as the default reference behaviour
- Turbo mode for deliberate enhancements
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

Modern conveniences such as HDMI, USB, Ethernet and SD storage must not silently redefine chipset-visible behaviour or timing. Turbo enhancements must never be required for software that belongs to the corresponding original machine's Authentic compatibility target.

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
