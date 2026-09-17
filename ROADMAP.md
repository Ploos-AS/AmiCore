# AmiCore Roadmap

## Project targets

AmiCore has two primary compatibility targets:

1. **AmiCore 500:** reproduce the original A500 gaming/demo experience as closely as practical using the smallest practical low-cost FPGA and supporting hardware.
2. **AmiCore 1200:** reproduce an original A1200 as closely as practical and provide a full-featured replacement machine, including legacy peripheral compatibility, using efficient modern hardware.

Every production profile must provide at least **Authentic** and **Turbo** operating modes. Authentic is the default compatibility reference. Turbo enables explicit enhancements without weakening Authentic behaviour.

The same board-independent RTL architecture should scale across Mini, full-board and Developer Board profiles. FPGA resource use and external hardware cost are measurable criteria, but Authentic compatibility takes precedence over resource reduction.

## M0 — Foundation

- [x] Define project scope and clean-room compatibility policy
- [x] Establish repository documentation baseline
- [x] Establish SystemVerilog toolchain
- [x] Add simulation smoke test
- [x] Add GitHub Actions CI
- [x] Define top-level bus and clock/reset contracts
- [x] Define board-independent core interfaces
- [x] Define Authentic and Turbo operating-mode policy

## M1 — Core infrastructure

- [x] CPU integration boundary
- [x] 68000-compatible execution baseline (M1.1 minimal instruction set)
- [x] Address/data bus
- [x] Chip RAM interface
- [x] ROM interface
- [x] Interrupt and reset infrastructure
- [x] Deterministic simulation vectors
- [ ] Expand 68000 instruction coverage
- [x] Exception execution baseline (M1.3 reset SSP/PC, vector fetch, SR/PC stack frame)
- [x] Interrupt priority/mask and autovector baseline (M1.4 levels 1-7)
- [x] RTE and basic CCR N/Z baseline (M1.5)
- [x] D0-D7/A0-A7 register baseline and register-direct MOVE subset (M1.6)
- [x] MOVE.L memory baseline with (An), (An)+ and -(An) (M1.7)
- [x] BRA.w, BSR.s/BSR.w and RTS subroutine control-flow baseline (M1.8)
- [x] A0-A7 MOVEA chain and non-D0 memory-transfer qualification (M1.9)
- [x] ADDQ.L/SUBQ.L 32-bit X/N/Z/V/C arithmetic baseline (M1.10)
- [x] Integrate ADDQ.L/SUBQ.L X/N/Z/V/C semantics into CPU execution path (M1.11)
- [x] User/supervisor stack-pointer banking, MOVE USP and RTE bank restore (M1.12)
- [x] Privilege-violation vector 8 qualification from user mode with supervisor frame and RTE bank restore (M1.13)
- [x] Bcc.s/Bcc.w conditional branch baseline with CCR condition qualification (M1.14)
- [x] DBcc and register-direct Scc baseline with exhaustive condition-code and CPU execution qualification (M1.15)
- [x] JMP/JSR control-flow and effective-address baseline: (An), xxx.W and xxx.L (M1.16)
- [x] LEA/PEA effective-address generation baseline: (An), d16(An), xxx.W and xxx.L (M1.17)
- [x] CPU clock/timing control boundary for Authentic/Turbo modes with shared-bus stall semantics (M1.18)
- [x] PC-relative d16(PC) control effective addresses for LEA/PEA/JMP/JSR with baseline CPU qualification (M1.19)
- [ ] indexed d8(An,Xn) / d8(PC,Xn) control effective-address baseline (M1.20)
- [ ] complete remaining 68000 instruction/addressing coverage needed before OCS software qualification (M1.20+)

## M2 — A500 / OCS Authentic baseline

- [ ] Agnus-compatible memory/DMA model
- [ ] Denise-compatible video model
- [ ] Paula-compatible audio/serial/floppy model
- [ ] CIA timers/ports/interrupts
- [ ] authentic A500 68000/chip-bus timing
- [ ] authentic DMA-slot scheduling and bus contention
- [ ] Copper timing qualification
- [ ] Blitter and nasty-mode timing qualification
- [ ] PAL/NTSC raster timing qualification
- [ ] A500 memory map and machine profile
- [ ] classic A500 keyboard protocol/interface
- [ ] dedicated physical A500 keyboard port/header and electrical qualification
- [ ] two DE-9 joystick/mouse interfaces
- [ ] serial interface
- [ ] parallel interface
- [ ] physical Amiga floppy interface and timing
- [ ] Gotek/FlashFloppy compatibility
- [ ] DF0:/DF1: and external-drive behaviour
- [ ] timing-sensitive A500 game qualification suite
- [ ] timing-sensitive A500 demo qualification suite
- [ ] original-A500 trace/measurement corpus where practical
- [ ] A500 Authentic integration tests

## M3 — A500 Turbo / ECS

- [ ] explicit A500 Turbo CPU clock configuration
- [ ] optional Fast RAM in Turbo mode
- [ ] accelerated storage path in Turbo mode
- [ ] prove Turbo features do not alter Authentic regression results
- [ ] ECS chipset extensions
- [ ] ECS timing qualification
- [ ] ECS machine profiles

## M4 — AGA

- [ ] AGA register model
- [ ] Lisa/AGA video pipeline
- [ ] AGA memory and DMA extensions
- [ ] AGA timing tests

## M5 — A1200 Authentic reference platform

- [ ] 68020-class CPU integration
- [ ] authentic A1200 CPU/chipset clock and bus timing
- [ ] A1200 memory map
- [ ] IDE interface and timing
- [ ] RTC
- [ ] serial and parallel interfaces
- [ ] two DE-9 joystick/mouse interfaces
- [ ] physical floppy/Gotek support
- [ ] classic A1200 keyboard protocol/interface
- [ ] dedicated physical/internal A1200 keyboard connector and original/reproduction keyboard qualification
- [ ] Gayle-compatible PCMCIA controller/register model
- [ ] PCMCIA memory and I/O address mapping
- [ ] PCMCIA card detect, reset, interrupt and status semantics
- [ ] 16-bit PCMCIA Type II bus-cycle/timing qualification
- [ ] A1200-compatible expansion interfaces
- [ ] real legacy peripheral qualification
- [ ] A1200 Authentic system integration tests

## M6 — Turbo and FPGA optimization

- [ ] A1200 Turbo CPU configuration
- [ ] Turbo Fast RAM
- [ ] accelerated storage/memory paths
- [ ] future RTG/accelerator hooks
- [ ] prove Turbo features do not alter A1200 Authentic regression results
- [ ] AmiCore 500 Mini profile
- [ ] AmiCore 500 full profile
- [ ] AmiCore 1200 Mini profile
- [ ] AmiCore 1200 full profile
- [ ] AmiCore Developer Board profile
- [ ] first low-cost FPGA target
- [ ] SDRAM/PSRAM controller as required by target
- [ ] HDMI output with low-latency/pixel-accurate scaling modes
- [ ] avoid unnecessary frame buffering in Authentic mode
- [ ] HDMI digital audio
- [ ] analog stereo audio
- [ ] native RGB timing output/header path
- [ ] SD/microSD storage
- [ ] USB modern-input/service bridge where appropriate
- [ ] vendor-independent wireless-module interface (SPI/UART baseline; SDIO optional)
- [ ] board constraints and reproducible builds
- [ ] automated per-profile LUT/LE, FF, BRAM, PLL/DSP, external-RAM and Fmax reports
- [ ] explicit resource budgets for minimum A500 and A1200 targets
- [ ] regression gates preventing accidental resource growth without sacrificing Authentic compatibility

## TBD — Interface decisions before PCB/mechanical freeze

These items are intentionally **TO BE DECIDED** before the AmiCore I/O/interface specification is frozen and before final KiCad placement and enclosure CAD are locked.

- [ ] **TBD:** physical native RGB/video connector strategy on full boards (original-style connector vs dedicated modern/header solution)
- [ ] **TBD:** analog audio connector strategy (RCA/phono, 3.5 mm, or both)
- [ ] **TBD:** final power architecture and connector (including USB-C, power switch, protection and recovery behaviour)
- [ ] **TBD:** exact physical keyboard connector(s), pinout and internal/external arrangement for AmiCore 500 and AmiCore 1200
- [ ] **TBD:** exact external Amiga floppy-drive connector implementation and mechanical placement
- [ ] **TBD:** exact physical A500 side-expansion connector implementation
- [ ] **TBD:** exact physical A1200 expansion and clock-port connector implementation
- [ ] Review all remaining legacy connectors and explicitly classify each as mandatory, optional, internal-header-only or omitted on every board profile
- [ ] Freeze the I/O/interface specification only after the decisions above are documented

## M7 — AmiCore hardware / PCB

- [ ] common board-level electrical/interface specification
- [ ] keyboard connector/pinout/electrical specification for 500 and 1200 profiles
- [ ] reference KiCad schematics
- [ ] AmiCore 500 Classic-Fit PCB: replacement motherboard matching original A500 case, mounting and external connector locations where practical
- [ ] AmiCore 1200 Classic-Fit PCB: replacement motherboard matching original A1200 case, mounting, keyboard and external connector locations where practical
- [ ] AmiCore 500 External-Keyboard PCB: optimized original AmiCore enclosure layout with the same functional I/O set and external keyboard
- [ ] AmiCore 1200 External-Keyboard PCB: optimized original AmiCore enclosure layout with the same functional I/O set and external keyboard
- [ ] keep Classic-Fit and External-Keyboard variants on the same board-independent RTL/profile architecture
- [ ] Mini-board feasibility/layout studies
- [ ] Developer Board PCB
- [ ] hardware Authentic/Turbo selection/recovery mechanism
- [ ] two DE-9 joystick/mouse ports on full boards
- [ ] serial connector/interface
- [ ] parallel connector/interface
- [ ] HDMI connector/output circuitry
- [ ] analog audio output
- [ ] 34-pin physical floppy/Gotek-compatible connector
- [ ] floppy power provision
- [ ] optional Gotek OLED/encoder/button headers
- [ ] SD/microSD
- [ ] A1200 IDE connector/interface
- [ ] physical 16-bit PCMCIA Type II slot on AmiCore 1200 full board
- [ ] PCMCIA voltage/power protection and level-interface design
- [ ] qualify representative legacy A1200 PCMCIA SRAM, CompactFlash, Ethernet and I/O cards
- [ ] optional vendor-independent Wi-Fi/Bluetooth module footprint/header
- [ ] RTC and battery-backed timekeeping
- [ ] optional native RGB adapter/header
- [ ] JTAG, UART, programming header and debug/test points
- [ ] safe FPGA bitstream/firmware recovery path defaults to Authentic mode
- [ ] BOM and cost targets
- [ ] manufacturing/Gerber files
- [ ] bring-up documentation

## M7.1 — Mechanical / CAD / enclosure

- [ ] define PCB outlines, keep-outs, connector datum positions and mounting-hole coordinates
- [ ] establish parametric mechanical CAD source and STEP interchange workflow
- [ ] qualify AmiCore 500 Classic-Fit PCB against original/reproduction A500 enclosure geometry and connector apertures
- [ ] qualify AmiCore 1200 Classic-Fit PCB against original/reproduction A1200 enclosure, keyboard and connector geometry
- [ ] AmiCore 500 External-Keyboard enclosure: optimized top/bottom shell, standoffs, ventilation and service access
- [ ] AmiCore 1200 External-Keyboard enclosure: optimized top/bottom shell, standoffs, ventilation and service access
- [ ] AmiCore 500 Mini enclosure
- [ ] AmiCore 1200 Mini enclosure
- [ ] Developer Board enclosure/test-frame option
- [ ] keyboard opening, retention and cable-routing design
- [ ] investigate original/reproduction A1200 keyboard and enclosure fit compatibility
- [ ] connector cut-outs for HDMI, USB, Ethernet, DE-9, serial, parallel, audio, SD, floppy/Gotek and expansion
- [ ] model buttons, LEDs/light-pipes and removable service panels where useful
- [ ] define FDM tolerances, wall thickness, clearances, screw sizes and heat-set inserts
- [ ] export versioned STEP plus printable STL/3MF artifacts
- [ ] document print orientation, supports, assembly and hardware
- [ ] mechanical fit-check against PCB STEP model before board/enclosure freeze
- [ ] maintain enclosure/PCB interface dimensions as CI-checkable data where practical

## M8 — Ethernet, wireless and expansion

- [ ] define board-independent AmiCore peripheral/expansion bus
- [ ] define Amiga-visible Ethernet device model
- [ ] evaluate low-cost 10/100 Ethernet MAC+PHY architectures
- [ ] optional Ethernet footprint/module path for Mini boards
- [ ] integrated RJ45 Ethernet target for full boards
- [ ] interrupt and DMA/bus integration where appropriate
- [ ] open AmigaOS Ethernet driver/API support
- [ ] compatibility strategy for established Amiga TCP/IP stacks
- [ ] loopback and packet-level RTL tests
- [ ] hardware network qualification
- [ ] define vendor-independent Wi-Fi/Bluetooth module protocol
- [ ] Wi-Fi network backend through the common AmiCore network abstraction
- [ ] Bluetooth HID bridge for keyboard, mouse and gamepads
- [ ] keep wireless optional so minimum FPGA/PCB profiles do not pay its cost
- [ ] evaluate virtual PCMCIA devices after physical PCMCIA compatibility is established
- [ ] preserve A500 side-expansion semantics where practical
- [ ] preserve A1200 expansion/clock-port semantics where practical

## M9 — Floppy preservation / flux

- [ ] document complete floppy signal/timing boundary
- [ ] Greaseweazle-friendly test points/header strategy
- [ ] raw flux capture architecture
- [ ] raw flux generation/write architecture
- [ ] FPGA timestamp/capture FIFO
- [ ] stream captured flux to RAM/SD/host
- [ ] physical-drive write qualification
- [ ] ADF plus preservation-oriented flux-image workflow
- [ ] integrate with AmiDisk tooling where appropriate

## M10 — Qualification

- [ ] automated RTL simulation qualification
- [ ] automated synthesis qualification
- [ ] FPGA hardware smoke qualification
- [ ] A500 Authentic game/demo compatibility matrix
- [ ] A500 original-hardware timing comparison
- [ ] AGA/A1200 Authentic software compatibility matrix
- [ ] A1200 original-hardware timing comparison
- [ ] physical floppy and Gotek qualification
- [ ] serial/parallel/joystick qualification
- [ ] HDMI/audio latency and timing qualification
- [ ] Ethernet qualification
- [ ] Wi-Fi/Bluetooth qualification where fitted
- [ ] physical PCMCIA compatibility matrix with legacy cards
- [ ] Authentic/Turbo isolation regression suite
- [ ] long-running stability tests
- [ ] cross-board deterministic compatibility suite
