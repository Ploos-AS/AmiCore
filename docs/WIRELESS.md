# AmiCore Wireless Architecture

## Goal

AmiCore may provide modern Wi-Fi and Bluetooth without making either technology part of the classic Amiga chipset or increasing the FPGA requirement of minimum machine profiles.

Wireless is implemented by a replaceable module behind a documented AmiCore service/peripheral interface.

## Principles

- wired Ethernet remains the deterministic reference network interface
- wireless hardware is optional
- no dependency on one radio/module vendor
- radio/baseband/protocol stacks stay outside OCS/ECS/AGA RTL
- the Amiga-visible interface remains stable when the physical module changes
- a missing wireless module must not prevent the machine from booting or operating

## Module interface baseline

The board-level module interface should provide:

- regulated power and ground
- SPI
- UART
- reset
- interrupt/wake
- boot/service indication as required
- optional SDIO pins on boards where justified
- optional USB data pair only if a future reference module requires it

The final connector pinout must be documented before board layout and should reserve a small number of expansion pins where practical.

## Wi-Fi

Wi-Fi traffic feeds the common AmiCore network-device abstraction. The Amiga-side driver should not depend on which radio module implements the link.

A module firmware protocol should cover at least:

- module discovery/version/capabilities
- interface up/down
- scan results
- association/disassociation
- network configuration/status
- packet transmit/receive
- signal/link statistics
- error reporting

Credentials and wireless configuration should be handled so they are not unnecessarily exposed to classic chipset RTL.

## Bluetooth

The first Bluetooth target is HID input:

```text
Bluetooth keyboard/mouse/gamepad
             |
             v
      wireless module
             |
             v
      AmiCore HID bridge
             |
       +-----+-----+
       |           |
 keyboard path   joystick/mouse path
       |           |
       +-----+-----+
             |
        Amiga-visible input
```

This permits modern controllers without requiring Amiga software to implement Bluetooth.

Later Bluetooth profiles may be considered only when there is a concrete use case and they do not burden minimum hardware.

## Reference modules

A readily available ESP32-class or similar module may be used for development and qualification. It is a reference implementation, not an architectural dependency. The host protocol should be sufficiently documented that another MCU/radio module can implement it.

## Security and updates

Wireless-module firmware should support authenticated update/recovery appropriate to the selected hardware. The AmiCore board should retain a service/recovery path for a failed module firmware update.

Network-facing module firmware is treated as replaceable and independently updateable from the FPGA bitstream.

## Qualification

Tests should cover:

- module absent
- module discovery/version negotiation
- Wi-Fi connect/disconnect/reconnect
- sustained packet transfer
- malformed/failed module responses
- Bluetooth keyboard
- Bluetooth mouse
- Bluetooth gamepad
- simultaneous classic DE-9 and Bluetooth input
- reset/power-cycle recovery
- no regression in chipset timing when wireless is busy
