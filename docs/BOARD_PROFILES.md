# AmiCore Board Profiles

Status: **DRAFT — interface and mechanical freeze pending**

This matrix defines the intended physical AmiCore product variants. Exact connector part numbers, electrical pinouts and mechanical coordinates remain subject to the documented TBD/interface-freeze process.

| Capability | 500 Classic-Fit | 500 External-Keyboard | 1200 Classic-Fit | 1200 External-Keyboard | Mini profiles |
| --- | --- | --- | --- | --- | --- |
| Target machine | A500/OCS-ECS | A500/OCS-ECS | A1200/AGA | A1200/AGA | corresponding 500/1200 |
| Authentic/Turbo | required | required | required | required | required |
| Original/repro case fit | required target | no | required target | no | no |
| Original/repro internal keyboard fit | A500 path/geometry target | no | A1200 keyboard target | no | no |
| External keyboard | supported | primary | supported | primary | primary |
| 2 x DE-9 | required | required | required | required | profile-dependent |
| HDMI video/audio | required | required | required | required | required |
| Native RGB | TBD physical connector | TBD physical connector | TBD physical connector | TBD physical connector | header/optional |
| Analog stereo audio | required, connector TBD | required, connector TBD | required, connector TBD | required, connector TBD | optional/profile-dependent |
| Serial | required | required | required | required | optional |
| Parallel | required | required | required | required | optional |
| Internal floppy/Gotek | required | required | required | required | profile-dependent |
| External Amiga floppy | required target, placement TBD | required target | required target, placement TBD | required target | optional |
| SD/microSD | required | required | required | required | required |
| IDE | optional/future | optional/future | required | required | 1200 profile target |
| PCMCIA Type II | N/A | N/A | required physical slot | required physical slot | RTL optional, connector may be omitted |
| A500 side expansion | required physical target | required physical target | N/A | N/A | optional |
| A1200 expansion | N/A | N/A | required physical target | required physical target | optional |
| A1200 clock port | N/A | N/A | required physical target | required physical target | optional |
| Wired Ethernet | required | required | required | required | optional/module |
| Wi-Fi/Bluetooth | optional module | optional module | optional module | optional module | optional module |
| USB modern input/service | required | required | required | required | required |
| RTC | required | required | required | required | profile-dependent |
| JTAG/UART/debug | required | required | required | required | required |
| Greaseweazle/flux access | test/debug access | test/debug access | test/debug access | test/debug access | optional |
| Power | architecture TBD | architecture TBD | architecture TBD | architecture TBD | architecture TBD |

## Mechanical policy

### Classic-Fit

Classic-Fit boards are replacement-motherboard targets. Their PCB outline, mounting holes, keyboard interfaces, legacy expansion interfaces and external connector datums are constrained by measured original/reproduction enclosure geometry. Dimensions must be sourced from verified measurements or authoritative mechanical documentation and recorded as machine-readable interface data where practical.

Modern connectors that did not exist on the original machines must be placed deliberately. HDMI, Ethernet, USB/service and SD access must not silently compromise legacy case fit. Where an additional aperture is unavoidable, it must be documented as part of the Classic-Fit installation contract.

### External-Keyboard

External-Keyboard boards preserve the same functional machine I/O without inheriting the original motherboard outline. Connector grouping, PCB area, routing, thermals, manufacturing cost and serviceability may therefore be optimized for an original AmiCore enclosure. The classic keyboard protocol remains part of the machine boundary even though the normal physical keyboard is external.

## Shared implementation rule

Classic-Fit and External-Keyboard are physical profiles of the same AmiCore architecture. Chipset/CPU RTL, Authentic behaviour and software-visible compatibility must not fork merely because the PCB geometry differs. Board-specific top-level wrappers, pin constraints and optional peripheral population are the intended variation points.

## Freeze gates

Before any production PCB or enclosure is frozen:

1. resolve the interface TBD items in `ROADMAP.md`;
2. verify Classic-Fit case, mounting, keyboard and connector datums;
3. assign every interface a concrete connector or documented omission for every profile;
4. generate matching PCB STEP models and enclosure/interface CAD;
5. pass mechanical interference and mating-envelope checks;
6. qualify that External-Keyboard optimization has not removed required machine-facing functionality.
