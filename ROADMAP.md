# AmiCore Roadmap

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
