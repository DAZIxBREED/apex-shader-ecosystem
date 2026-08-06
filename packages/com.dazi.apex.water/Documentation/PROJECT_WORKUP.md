# Apex Water — Project Workup

## 0.3.0 implementation

- `Apex/Water/PoolLite`: transparent dual-normal water with depth tint, Fresnel, foam, lighting, fog, and SpectraOverdrive.
- `Apex/Water/OpaqueMobile`: three-sampler opaque alternative that preserves dual normals, depth tint, Fresnel, foam, baked/dynamic lighting, and Spectra response without transparency overdraw.

## Next work

- Safe depth-texture shoreline fade.
- Caustics receiver/emitter pair.
- Measured fill-rate comparisons between PoolLite and OpaqueMobile.
