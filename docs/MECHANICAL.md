# AmiCore Mechanical Design

## Purpose

AmiCore treats the enclosure and PCB as one mechanical system. Connector positions, keyboard geometry, mounting holes and service access must be defined before PCB and enclosure freeze.

## Source and interchange formats

- Keep the mechanical design parametric.
- Keep editable CAD sources in `mechanical/`.
- Use STEP as the board/enclosure interchange format.
- Publish printable STL and 3MF derivatives under `mechanical/print/`.
- Do not use STL as the design master.
- Keep critical dimensions in a small machine-readable interface definition where practical so PCB and enclosure changes can be checked together.

## Product family

Mechanical profiles are required for AmiCore 500 Mini, AmiCore 500, AmiCore 1200 Mini, AmiCore 1200 and the Developer Board.

The full 500 and 1200 machines should visually reference the practical desktop/wedge ergonomics of classic Amiga systems without requiring a copied Commodore enclosure. The design must remain original and manufacturing-friendly.

## Keyboard integration

Keyboard geometry is a first-order enclosure constraint.

Full boards require a dedicated classic keyboard connection. AmiCore 1200 must investigate mounting and cable geometry for original and reproduction A1200 keyboard assemblies. AmiCore 500 must provide a practical classic keyboard path. Mini profiles may rely on USB for normal use but should retain access to the classic keyboard interface through an internal header when practical.

The CAD model must reserve the keyboard envelope, connector/header location, cable bend radius, strain relief, retention points and service/removal path before PCB freeze.

## PCB/mechanical contract

For every board profile record:

- PCB outline and thickness
- mounting-hole coordinates and diameters
- component maximum-height zones
- top/bottom keep-outs
- connector body and mating-plug envelopes
- connector centerlines and panel datum coordinates
- keyboard envelope and cable route
- cooling/ventilation zones
- SD-card insertion/removal envelope
- Gotek/floppy insertion and service envelope where fitted
- PCMCIA insertion/ejection envelope on AmiCore 1200
- expansion access and service headers

A STEP export of the PCB assembly is the mechanical fit-check reference.

## 3D-printing baseline

Initial prototypes target FDM printing. Enclosures should avoid unnecessary supports, use replaceable threaded hardware or heat-set inserts where repeated access is expected, and keep wall/clearance values parameterized rather than embedded throughout the model.

Exact tolerances are printer/material dependent and will be qualified with fit coupons before production dimensions are frozen. Printable artifacts must identify the CAD revision and matching PCB revision.

## Fit qualification

Before a board or enclosure is frozen, perform:

1. CAD interference check.
2. PCB STEP/enclosure assembly check.
3. Connector mating-envelope check.
4. Keyboard fit and removal-path check.
5. SD/floppy/Gotek/PCMCIA service-access check as applicable.
6. Printed prototype fit check.
7. Thermal/ventilation sanity check with representative hardware.

## Repository layout

```text
mechanical/
  README.md
  cad/
  interfaces/
  step/
  print/
    stl/
    3mf/
```

Generated STEP/STL/3MF files may be published for users, but editable parametric CAD remains the source of truth.
