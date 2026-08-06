# Apex Water — Project Workup

## Purpose

Apex Water supplies practical transparent liquid shaders for pools, decorative water, stage surfaces, and lightweight world effects.

## 0.2.0 implementation

- `Apex/Water/PoolLite` with base tint/texture.
- Two independently scrolling normal layers.
- Shallow/deep tint blend, Fresnel edge color, authored foam mask, opacity, lighting, fog, and SpectraOverdrive response.
- One transparent forward-base pass and three samplers.

## Performance contract

The baseline avoids refraction, GrabPass, tessellation, geometry shaders, and compute. Transparency and screen coverage still require on-device profiling.

## Next work

- Optional depth-texture shoreline fade where safe.
- Caustics receiver/emitter pair.
- Opaque mobile-water alternative for severe fill-rate budgets.
