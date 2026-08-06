# Apex SpectraOverdrive Bridge — Platform Budget

The bridge adds no texture samplers and no render passes.

- Eight global show-control values: intensity, color, four bands, beat, blackout, strobe, group, and time.
- Per-material response is a small amount of scalar/vector arithmetic.
- A material only pays the bridge cost when its shader calls the helper functions.
- External drivers should update globals at a bounded cadence appropriate to the show system.
