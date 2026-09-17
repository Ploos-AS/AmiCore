# AmiCore Hardware Requirements

## Scope

This document defines the hardware direction for official AmiCore boards. It is intentionally independent of a final FPGA vendor or exact component selection.

## Core requirement

AmiCore should produce the smallest practical hardware implementations of two primary compatibility targets:

- A500 / OCS / 68000
- A1200 / AGA / 68020-class

"Smallest" means a balance of FPGA resources, external component count, PCB area, cost, power and availability without sacrificing the compatibility target.

## Board families

| Board | Intent |
| --- | --- |
| AmiCore 500 Mini | minimum practical A500-compatible hardware |
| AmiCore 500 | full-I/O A500-compatible standalone computer |
| AmiCore 1200 Mini | minimum practical A1200-compatible hardware |
| AmiCore 1200 | full-I/O A1200-compatible standalone computer |
| AmiCore Developer Board | unconstrained development, measurement and qualification |

## Full-board baseline I/O

- 2 x DE-9 joystick/mouse
- HDMI video and audio
- analog stereo audio
- serial
- parallel
- keyboard interface
- physical floppy/Gotek interface
- SD/microSD
- wired Ethernet
- RTC
- JTAG/UART/programming access
- diagnostic test points

The A1200 board additionally targets IDE and appropriate A1200 expansion facilities.

## Floppy / Gotek

Provide a 34-pin floppy/Gotek-compatible connection and suitable power provision. Preserve all signals/timing required for authentic Amiga floppy behaviour. Where useful, expose headers for Gotek OLED, rotary encoder and buttons.

A real drive and a Gotek must be first-class qualification targets rather than board-specific hacks.

## Greaseweazle / flux readiness

Expose relevant floppy signals at accessible test points or a debug header. Avoid a board topology that prevents high-resolution observation of drive transitions.

A later FPGA implementation may provide:

- flux transition timestamping
- capture FIFO
- capture to RAM/SD/host
- flux replay
- physical disk writing
- preservation-oriented image workflows

This is complementary to Gotek: Gotek provides convenient disk-image emulation, while flux support targets physical-media preservation and unusual/protected formats.

## Ethernet

Full boards target wired Ethernet with RJ45. The exact implementation is selected after resource/cost evaluation; candidate architectures include an RTL MAC with an external RMII/MII PHY or a low-cost external Ethernet controller.

Mini boards should be able to omit the physical Ethernet hardware while retaining a standard expansion/module interface.

Requirements:

- open, documented Amiga-visible device interface
- deterministic interrupt behaviour
- packet-level simulation
- initial programmed-I/O implementation may precede DMA
- future DMA/bus-master operation must be architecturally possible
- networking must not perturb chipset timing
- open AmigaOS driver/API
- compatibility with normal Amiga TCP/IP software should be considered during driver design

Wi-Fi is not required for the minimum machine. It may later be provided through an optional module without replacing wired Ethernet as the deterministic reference interface.

## Video

HDMI is the standard modern display output. The conversion pipeline should prioritize low latency, deterministic timing and integer/pixel-accurate modes.

Native Amiga RGB timing remains available internally and should be routable through a header/adapter for CRT and measurement use.

## Modern input

Classic DE-9 input is mandatory on full boards. USB keyboard/mouse/gamepad support may be provided by a service/input bridge. USB behaviour must be translated into the classic machine interface rather than embedded into chipset semantics.

## Storage

- SD/microSD for configuration, disk images and mass-storage use
- physical floppy/Gotek
- A1200 IDE
- future virtual IDE backed by SD where appropriate

## Expansion

Provide a board-independent internal expansion/peripheral bus. Use it for optional Ethernet, RTG, storage and future accelerator/peripheral blocks. Preserve classic A500/A1200 expansion semantics where software compatibility requires them.

## Serviceability

Every official board should include:

- JTAG/programming access
- UART/debug access
- useful clock/bus/floppy/video test points
- recovery mechanism for broken FPGA/firmware updates
- documented power rails
- documented connector pinouts
- reproducible KiCad sources, BOM and manufacturing outputs

## Optimization metrics

Each board/FPGA profile should record:

- FPGA family/device
- LUT/LE
- FF/registers
- BRAM/block RAM
- PLL/DSP
- external RAM type/capacity
- Fmax
- board area
- estimated BOM cost
- power measurements when hardware exists

Optimization must never silently trade away machine compatibility. Resource reductions are accepted together with regression qualification.
