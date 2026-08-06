# Apex FX — Project Workup

## Purpose

Apex FX owns specialized visual-effect materials that should not bloat the Avatar, World, or Screen packages.

## 0.2.0 implementation

- `Apex/FX/HologramLite` additive hologram shader.
- Base and authored mask sampling.
- Scanlines, temporal flicker, Fresnel edge glow, and lightweight object-space vertex glitch.
- SpectraOverdrive group and four-band response.

## Performance contract

The baseline uses one transparent pass and two samplers. Geometry, tessellation, GrabPass, and compute are intentionally excluded.

## Next work

- Dissolve/cutout family.
- Shield and portal families with mobile and PC quality tiers.
- Flipbook and distortion paths with explicit sampler/overdraw budgets.
