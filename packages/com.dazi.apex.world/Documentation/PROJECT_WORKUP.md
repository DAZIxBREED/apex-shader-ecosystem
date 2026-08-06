# Apex World — Project Workup

## Purpose

Apex World is the baseline physically based material path for VRChat environments, props, architecture, stages, and emissive world surfaces.

## 0.2.0 implementation

- `Apex/World/Standard` with base, normal, packed mask, and optional detail textures.
- Metallic/smoothness/AO, alpha clip, vertex tint, emission, and SpectraOverdrive response.
- Lightmap or spherical-harmonic GI, main and additional lights, attenuation, shadows, fog, stereo, and instancing.
- ShadowCaster and Meta passes for cutout shadows and baked emissive/albedo contribution.

## Performance contract

- Three samplers by default; four with detail enabled.
- No GrabPass, tessellation, geometry, or compute stages.
- Prefer baked lighting and instancing for repeated world geometry.

## Next work

- Reflection-probe/environment specular quality tier.
- Triplanar-lite and terrain/vertex-blend families with explicit sampler budgets.
- Unity and device validation matrix for opaque and cutout variants.
