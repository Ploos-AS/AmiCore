# AmiCore Roadmap

## M0 — Foundation

- [x] Define project scope and clean-room compatibility policy
- [x] Establish repository documentation baseline
- [ ] Establish SystemVerilog toolchain
- [ ] Add simulation smoke test
- [ ] Add GitHub Actions CI
- [ ] Define top-level bus and clock/reset contracts
- [ ] Define board-independent core interfaces

## M1 — Core infrastructure

- [ ] CPU integration boundary
- [ ] 68000-compatible execution baseline
- [ ] Address/data bus
- [ ] Chip RAM interface
- [ ] ROM interface
- [ ] Interrupt and reset infrastructure
- [ ] Deterministic simulation vectors

## M2 — OCS baseline

- [ ] Agnus-compatible memory/DMA model
- [ ] Denise-compatible video model
- [ ] Paula-compatible audio/serial/floppy model
- [ ] CIA timers/ports/interrupts
- [ ] OCS integration tests

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
- [ ] RTC/serial/joystick interfaces
- [ ] A1200-compatible expansion interfaces
- [ ] A1200 system integration tests

## M6 — FPGA boards

- [ ] First low-cost FPGA target
- [ ] SDRAM controller
- [ ] HDMI/video output
- [ ] Audio output
- [ ] Input peripherals
- [ ] Board constraints and reproducible builds

## M7 — Hardware

- [ ] Reference KiCad schematic
- [ ] Reference PCB
- [ ] BOM
- [ ] Bring-up documentation
- [ ] Manufacturing files

## M8 — Qualification

- [ ] Automated RTL simulation qualification
- [ ] Automated synthesis qualification
- [ ] FPGA hardware smoke qualification
- [ ] AGA/A1200 compatibility qualification
- [ ] Long-running stability tests
