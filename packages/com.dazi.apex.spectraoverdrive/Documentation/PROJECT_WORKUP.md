# Apex SpectraOverdrive Bridge — Project Workup

## Purpose

This package defines the shared shader-side data contract between Apex visual packages and SpectraOverdrive show-control systems.

## 0.2.0 implementation

- Global intensity, RGB color, four frequency bands, beat, blackout, strobe, group ID, and show-time inputs.
- Broadcast group (`0`) and exact local group routing.
- Normalized band weighting per material.
- Shared pulse, tint, and emission helpers.
- Neutral white/default behavior when globals are not driven.
- Compatibility overloads for 0.1-era call sites.

## Ownership boundaries

- This package does not schedule shows, synchronize Udon state, author timelines, or operate fixtures.
- It only defines deterministic shader inputs and response helpers.

## Next work

- Freeze and document the Udon/global-property ABI.
- Add a reference driver in the SpectraOverdrive repository.
- Add bounded strobe/safety policy inputs and validation.
