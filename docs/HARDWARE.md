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
- dedicated classic Amiga keyboard interface/port
- internal keyboard header where appropriate for original/reproduction keyboard assemblies
- USB keyboard support through the modern input bridge
- physical floppy/Gotek interface
- SD/microSD
- wired Ethernet
- optional Wi-Fi/Bluetooth module
- RTC
- JTAG/UART/programming access
- diagnostic test points

The A1200 full board additionally targets IDE, a physical 16-bit PCMCIA Type II slot, appropriate A1200 expansion facilities, and an internal keyboard connection suitable for an original/reproduction A1200 keyboard where electrically and mechanically practical.

## Keyboard

Keyboard support is a mandatory compatibility interface, not an optional modern-input feature. The classic keyboard protocol must terminate at a documented FPGA/system boundary and be qualified for reset, clock/data timing and keyboard-controller handshaking. Full boards must expose a dedicated physical keyboard connection; Mini boards may use an internal header while USB remains the convenient default input path.

AmiCore 500 should support an A500-style classic keyboard path and AmiCore 1200 should support an A1200-style path. The full AmiCore 1200 mechanical/electrical design should explicitly investigate compatibility with original and reproduction A1200 keyboard assemblies. USB and Bluetooth keyboards are additional bridges and must not replace the classic interface in Authentic profiles.

## Floppy / Gotek

Provide a 34-pin floppy/Gotek-compatible connection and suitable power provision. Preserve all signals/timing required for authentic Amiga floppy behaviour. Where useful, expose headers for Gotek OLED, rotary encoder and buttons.

A real drive and a Gotek must be first-class qualification targets rather than board-specific hacks.

## Greaseweazle / flux readiness

Expose relevant floppy signals at accessible test points or a debug header. Avoid a board topology that prevents high-resolution observation of drive transitions.

A later FPGA implementation may provide flux transition timestamping, a capture FIFO, capture to RAM/SD/host, flux replay, physical disk writing, and preservation-oriented image workflows.

This is complementary to Gotek: Gotek provides convenient disk-image emulation, while flux support targets physical-media preservation and unusual/protected formats.

## Ethernet

Full boards target wired Ethernet with RJ45. The exact implementation is selected after resource/cost evaluation; candidate architectures include an RTL MAC with an external RMII/MII PHY or a low-cost external Ethernet controller.

Mini boards should be able to omit the physical Ethernet hardware while retaining a standard expansion/module interface.

Requirements include an open documented Amiga-visible device interface, deterministic interrupt behaviour, packet-level simulation, an initial programmed-I/O implementation if useful, a path to future DMA/bus-master operation, an open AmigaOS driver/API, and compatibility consideration for established Amiga TCP/IP stacks. Networking must not perturb chipset timing.

## Wi-Fi and Bluetooth

Wireless support is optional and must not increase the minimum FPGA requirement. Radio, baseband and protocol-stack work belongs in a replaceable external module rather than the classic chipset RTL.

Official boards should define a vendor-independent module interface. SPI and UART are the baseline control/data transports; SDIO may be evaluated where bandwidth justifies the added pins and complexity. The connector should expose suitable power, reset, interrupt/wake and service signals.

Wi-Fi should feed the common AmiCore network abstraction so Amiga-side software can use a documented network-device/driver interface independent of the radio module chosen.

Bluetooth should initially target HID bridging for keyboard, mouse and gamepads. The bridge translates Bluetooth HID events into AmiCore's classic input interfaces; Bluetooth is not part of OCS/AGA semantics.

A specific ESP32-class or similar module may be used as a reference implementation, but the electrical and firmware contract must not make AmiCore dependent on one vendor or module generation.

## PCMCIA / legacy A1200 cards

The AmiCore 1200 full board targets a physical 16-bit PCMCIA Type II slot compatible with the A1200 interface. The purpose is not merely to provide a modern expansion connector: using surviving original A1200 PCMCIA cards is an explicit compatibility goal.

The FPGA/system implementation therefore needs a Gayle-compatible PCMCIA controller model covering the software-visible register behaviour, address mapping, card detect/status, reset, interrupts and required bus cycles/timing.

The PCB design must handle PCMCIA power, buffering/level requirements and protection deliberately. Compatibility qualification should use a matrix of representative legacy cards, including SRAM cards, CompactFlash/storage adapters, Ethernet/network cards and other common A1200 I/O cards where examples are available.

AmiCore 1200 Mini may omit the physical slot while retaining the PCMCIA controller logic as an optional build feature. This keeps the software-visible architecture reusable without forcing the large legacy connector onto a minimum-size PCB.

After physical PCMCIA compatibility is mature, a virtual-PCMCIA backend may be investigated. Internal AmiCore devices could then emulate selected PCMCIA device interfaces for compatibility, but virtual devices must not substitute for the physical-slot goal on AmiCore 1200 full.

## Video

HDMI is the standard modern display output. The conversion pipeline should prioritize low latency, deterministic timing and integer/pixel-accurate modes.

Native Amiga RGB timing remains available internally and should be routable through a header/adapter for CRT and measurement use.

## Modern input

Classic DE-9 input and the dedicated classic keyboard interface are mandatory on full boards. USB keyboard/mouse/gamepad support may be provided by a service/input bridge. USB and Bluetooth behaviour must be translated into the classic machine interface rather than embedded into chipset semantics.

## Storage

- SD/microSD for configuration, disk images and mass-storage use
- physical floppy/Gotek
- A1200 IDE
- physical A1200 PCMCIA storage compatibility
- future virtual IDE backed by SD where appropriate

## Expansion

Provide a board-independent internal expansion/peripheral bus. Use it for optional Ethernet, wireless, RTG, storage and future accelerator/peripheral blocks. Preserve classic A500/A1200 expansion semantics where software compatibility requires them.

## Serviceability

Every official board should include JTAG/programming access, UART/debug access, useful clock/bus/floppy/video test points, recovery for broken FPGA/firmware updates, documented power rails and connector pinouts, and reproducible KiCad sources, BOM and manufacturing outputs.

## Optimization metrics

Each board/FPGA profile should record FPGA family/device, LUT/LE, FF/registers, BRAM/block RAM, PLL/DSP, external RAM type/capacity, Fmax, board area, estimated BOM cost and power measurements when hardware exists.

Optimization must never silently trade away machine compatibility. Resource reductions are accepted together with regression qualification.
