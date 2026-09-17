# AmiCore Classic-Fit Mechanical Datums

Status: **research baseline — dimensions are not frozen**

## Purpose

Classic-Fit boards are intended to install into original or reproduction A500/A1200 enclosures. This document defines the datum-capture process before KiCad outlines or connector coordinates are treated as authoritative.

## Evidence policy

Mechanical coordinates are never inferred from photographs. A datum becomes `verified` only when supported by an authoritative engineering drawing or by repeatable physical measurement. Replica-board CAD may be used as a cross-check, not silently treated as original Commodore source data.

For every dimension record: model/revision, source, datum origin, X/Y/Z, tolerance or measurement uncertainty, verification state, and notes.

## A500 source baseline

Primary historical material includes the Commodore A500/A2000 Technical Reference Manual and A500 service/system schematics. The Technical Reference Manual contains an engineering drawing specifically for the A500 expansion-connector location and states dimensions in millimetres.

The A500 schematic connector inventory establishes the legacy connector set that must be located during physical measurement: two DE-9 ports, stereo RCA, external floppy, DB25 serial, DB25 parallel, power, DB23 video, internal floppy, floppy power, keyboard and the side expansion edge.

Open replacement-board projects may be used later as independent fit cross-checks, especially for screw holes and I/O connector placement, but do not replace direct verification.

## A1200 source baseline

Use Commodore A1200 Rev.1/Rev.2 schematics for electrical connector identity and mounting/test-hole references. Physical A1200 enclosure/board measurements are still required for exact Classic-Fit coordinates.

Capture at minimum: PCB perimeter, every mounting point, rear connector centerlines and mating envelopes, power, internal floppy and power, keyboard connector/cable path, IDE, PCMCIA slot/ejection envelope, trapdoor/expansion connector and any case/shield keep-outs.

## Coordinate convention

Each Classic-Fit model will get one machine-readable datum file. Proposed convention:

- units: millimetres;
- XY origin: lower-left PCB corner when viewed from component side, unless physical-board study shows a more stable manufacturing datum;
- +X: toward the right-hand side of the computer;
- +Y: toward the rear connector edge;
- Z=0: component-side PCB surface;
- connector coordinates describe mating centerline plus body/mating envelope;
- mounting holes describe center, finished diameter and grounded/non-grounded requirement.

The convention is provisional until first-board measurement is captured.

## Required A500 datum set

- PCB outline and thickness
- all mounting holes/standoffs
- keyboard connector and cable envelope
- CN1/CN2 DE-9
- left/right analog audio
- external floppy
- serial
- parallel
- power
- native video
- internal floppy and power
- A500 side expansion edge/opening
- shielding and case keep-outs
- floppy-drive mounting/service envelope
- LED/case interaction where relevant

## Required A1200 datum set

- PCB outline and thickness
- all mounting holes/standoffs
- keyboard connector, membrane/cable and keyboard mounting envelope
- two DE-9 ports
- stereo analog audio
- external floppy
- serial
- parallel
- power
- native video
- internal floppy and power
- IDE connector and cable/device envelope
- physical PCMCIA slot and insertion/ejection envelope
- A1200 expansion/trapdoor connector
- clock-port location if exposed by the chosen board revision/profile
- shielding and case keep-outs
- floppy-drive mounting/service envelope
- LED/case interaction where relevant

## Modern connector overlay

HDMI, Ethernet, USB/service, SD and optional wireless/service access are a second overlay. They must be placed only after legacy datums are captured. Classic-Fit should prefer existing unused/replaceable openings or deliberately documented case modifications rather than moving legacy connectors away from their compatible positions.

## Qualification gates

A Classic-Fit PCB cannot be called drop-in compatible until:

1. datum file is populated from verified evidence;
2. KiCad board outline/mounting holes match the datum file;
3. legacy connector mating envelopes match the corresponding case openings;
4. keyboard and floppy mechanisms fit;
5. A500 expansion or A1200 PCMCIA/expansion access fits;
6. PCB STEP model passes enclosure interference checks;
7. at least one physical original or known-compatible reproduction enclosure passes a prototype fit test.
