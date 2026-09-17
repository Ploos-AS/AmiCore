# AmiCore A1200 PCMCIA Compatibility

## Goal

AmiCore 1200 Full should accept real surviving 16-bit PCMCIA Type II cards intended for the Amiga 1200. The physical slot is a compatibility feature, not merely a convenient modern expansion connector.

A user should be able to move a supported legacy card from an original A1200 to AmiCore 1200 and use the same class of Amiga software/driver wherever the implemented Gayle and electrical behaviour permit it.

## Architecture

```text
68020-class CPU / system bus
          |
          v
 Gayle-compatible PCMCIA block
          |
          +-- attribute/common/I/O mapping
          +-- card detect/status
          +-- reset
          +-- interrupt
          +-- bus timing/control
          |
          v
 electrical protection/buffering
          |
          v
 16-bit PCMCIA Type II socket
```

The Gayle-compatible block belongs to the A1200 machine profile. The physical socket and electrical interface belong to the AmiCore 1200 Full board wrapper/PCB.

## Compatibility priorities

Qualification should progressively cover representative examples of:

1. SRAM cards
2. CompactFlash and storage adapters
3. Ethernet cards commonly used with A1200 systems
4. serial/modem and other I/O cards where available
5. cards with different CIS/attribute-memory layouts and interrupt behaviour

Compatibility is determined by observed bus/register behaviour and independent tests. No proprietary Commodore logic or ROM content is required.

## Electrical design requirements

Before PCB routing is frozen, verify the original A1200 PCMCIA electrical expectations and the requirements of the selected FPGA/level-interface components. The board design must explicitly address:

- socket supply and current budget
- supported card voltage classes
- FPGA I/O voltage isolation/translation
- bidirectional bus buffering
- card insertion/removal protection
- ESD protection
- reset sequencing
- card-detect/status inputs
- interrupt input
- address/data/control signal integrity

Do not connect a legacy PCMCIA bus directly to FPGA pins merely because nominal logic levels appear compatible.

## Mini profile

AmiCore 1200 Mini may omit the physical PCMCIA socket. The Gayle/PCMCIA RTL should remain selectable so the Mini and Full profiles share the same machine architecture and test suite.

## Virtual PCMCIA

Virtual PCMCIA is a later compatibility feature, after physical cards work. It may expose internal AmiCore peripherals through selected PCMCIA-compatible device models. Possible uses include internal network or storage devices using existing Amiga driver conventions.

Virtual PCMCIA must not replace physical PCMCIA support on AmiCore 1200 Full.

## Qualification matrix

For every tested physical card record:

- manufacturer/model
- card type
- CIS identification
- voltage/power requirements
- Amiga driver/software used
- machine/ROM/OS configuration
- cold insertion at power-off
- detection/reset result
- memory/I/O access result
- interrupt result
- sustained transfer result where applicable
- PASS/FAIL/KNOWN-LIMITATION

The matrix should be kept in the repository so PCMCIA compatibility becomes reproducible rather than anecdotal.
