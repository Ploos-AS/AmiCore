# AmiCore Roadmap

## Project targets

AmiCore has two primary optimization targets:

1. A highly compatible A500/OCS/68000 implementation using the smallest practical low-cost FPGA and supporting hardware.
2. A highly compatible A1200/AGA/68020-class implementation using the smallest practical FPGA and supporting hardware.

The same board-independent RTL architecture should scale across Mini, full-board and Developer Board profiles. FPGA resource use and external hardware cost are measurable project criteria, not afterthoughts.

## M0 — Foundation

- [x] Define project scope and clean-room compatibility policy
- [x] Establish repository documentation baseline
- [x] Establish SystemVerilog toolchain
- [x] Add simulation smoke test
- [x] Add GitHub Actions CI
- [x] Define top-level bus and clock/reset contracts
- [x] Define board-independent core interfaces

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
- [ ] LEA/PEA effective-address generation baseline (M1.17)

## M2 — A500 / OCS baseline

- [ ] Agnus-compatible memory/DMA model
- [ ] Denise-compatible video model
- [ ] Paula-compatible audio/serial/floppy model
- [ ] CIA timers/ports/interrupts
- [ ] A500 memory map and machine profile
- [ ] keyboard protocol/interface
- [ ] two DE-9 joystick/mouse interfaces
- [ ] serial interface
- [ ] parallel interface
- [ ] physical Amiga floppy interface
- [ ] Gotek/FlashFloppy compatibility
- [ ] DF0:/DF1: and external-drive behaviour
- [ ] OCS/A500 integration tests

## M3 — ECS

- [ ] ECS chipset extensions
- [ ] ECS timing qualification
- [ ] ECS machine profiles

## M4 — AGA

- [ ] AGA register model
- [ ] Lisa/AGA video pipeline
- [ ] AGA memory and DMA extensions
- [ ] AGA timing tests

## M5 — A1200 reference platform

- [ ] 68020-class CPU integration
- [ ] A1200 memory map
- [ ] IDE interface
- [ ] RTC
- [ ] serial and parallel interfaces
- [ ] two DE-9 joystick/mouse interfaces
- [ ] physical floppy/Gotek support
- [ ] keyboard interface
- [ ] A1200-compatible expansion interfaces
- [ ] A1200 system integration tests

## M6 — FPGA optimization and board profiles

- [ ] AmiCore 500 Mini profile
- [ ] AmiCore 500 full profile
- [ ] AmiCore 1200 Mini profile
- [ ] AmiCore 1200 full profile
- [ ] AmiCore Developer Board profile
- [ ] first low-cost FPGA target
- [ ] SDRAM/PSRAM controller as required by target
- [ ] HDMI output with low-latency/pixel-accurate scaling modes
- [ ] HDMI digital audio
- [ ] analog stereo audio
- [ ] native RGB timing output/header path
- [ ] SD/microSD storage
- [ ] USB modern-input/service bridge where appropriate
- [ ] board constraints and reproducible builds
- [ ] automated per-profile LUT/LE, FF, BRAM, PLL/DSP, external-RAM and Fmax reports
- [ ] explicit resource budgets for minimum A500 and A1200 targets
- [ ] regression gates preventing accidental resource growth

## M7 — AmiCore hardware / PCB

- [ ] common board-level electrical/interface specification
- [ ] reference KiCad schematics
- [ ] AmiCore 500 PCB
- [ ] AmiCore 1200 PCB
- [ ] Mini-board feasibility/layout studies
- [ ] Developer Board PCB
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
- [ ] RTC and battery-backed timekeeping
- [ ] optional native RGB adapter/header
- [ ] JTAG, UART, programming header and debug/test points
- [ ] safe FPGA bitstream/firmware recovery path
- [ ] BOM and cost targets
- [ ] manufacturing/Gerber files
- [ ] bring-up documentation

## M8 — Ethernet and expansion

- [ ] define board-independent AmiCore peripheral/expansion bus
- [ ] define Amiga-visible Ethernet device model
- [ ] evaluate low-cost 10/100 Ethernet MAC+PHY architectures
- [ ] optional Ethernet footprint/module path for Mini boards
- [ ] integrated RJ45 Ethernet target for full boards
- [ ] interrupt and DMA/bus integration where appropriate
- [ ] open AmigaOS driver/API support
- [ ] compatibility strategy for established Amiga TCP/IP stacks
- [ ] loopback and packet-level RTL tests
- [ ] hardware network qualification
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
- [ ] A500/OCS compatibility qualification
- [ ] AGA/A1200 compatibility qualification
- [ ] physical floppy and Gotek qualification
- [ ] serial/parallel/joystick qualification
- [ ] HDMI/audio latency and timing qualification
- [ ] Ethernet qualification
- [ ] long-running stability tests
- [ ] cross-board deterministic compatibility suite
