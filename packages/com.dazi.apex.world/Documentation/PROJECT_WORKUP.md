# Apex World — Project Workup

## 0.3.0 implementation

- `Apex/World/Standard`: packed PBR, detail layer, cutout, lightmaps/SH, forward lights, shadows, Meta output, reflection probes, quality tiers, and SpectraOverdrive.
- `Apex/World/VertexBlendLite`: two independent base/normal/packed-mask layers blended by vertex red with bias/contrast, four rendering passes, reflection probes, and SpectraOverdrive.

## Performance contract

Standard uses three samplers by default and four with detail. Vertex Blend uses six and must be profiled on mobile standalone targets.

## Next work

- Triplanar-lite and terrain families.
- Device validation for opaque, cutout, and vertex-blended scenes.
