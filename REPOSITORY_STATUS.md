# Repository Status

**Version:** 0.3.4
**Maturity:** Pre-alpha implementation
**Unity baseline:** 2022.3.22f1, Built-in Render Pipeline

## Implemented

- Twelve independent UPM packages with deterministic Unity metadata and reproducible release archives.
- Shared handwritten HLSL for packed surfaces, lightmaps/SH, forward lighting, shadows, fog, stereo/instancing, reflection probes, and local Mobile/Standard/High quality tiers.
- Twelve ShaderLab shaders across Core, Avatar, World, Water, Fog, FX, Screens, and Toon.
- Exact ordered ShaderLab pass contracts enforced by repository CI and Unity Package Doctor.
- SpectraOverdrive ABI 1.0 with Unity and `_Udon` globals, routing, four bands, blackout, and optional intensity/strobe safety limits.
- Dependency-free optional integration globals plus editor diagnostics.
- PC character fallback metadata, batch SDK mobile-material generation, and machine-readable source/fallback pairing records.
- Material quality profiles, Avatar presets, packed-mask authoring, project/material validation, variant stripping/reporting, synchronous shader compiler auditing, and generated stress-scene validation.

## 0.3.4 pass-parity hardening

- Added exact pass contracts for every current Apex shader and a dedicated static validator.
- Package Doctor now compares Unity's actual ordered pass list against the same contracts.
- Added Toon `FORWARD_ADD` and `META` paths so additional lights and baked albedo/emission are no longer absent.
- Shared ShadowCaster varyings now carry vertex alpha.
- Avatar, World Standard, and Toon cutout shadows now match ForwardBase vertex/base alpha behavior.
- World Standard Meta output now respects vertex tint/alpha in addition to detail/cutout parity.
- VertexBlendLite Meta emission now follows the runtime blended effect mask.
- Dissolve Meta uses the shared dissolve clip/edge functions used by visible/shadow paths and respects vertex tint.
- All package versions, internal dependency pins, repository version metadata, and Core HLSL version macros are aligned to 0.3.4.

## Intentional pass contracts

- Avatar Standard: ForwardBase + ForwardAdd + ShadowCaster; no baked-world Meta pass.
- Transparent PoolLite: ForwardBase only.
- OpaqueMobile water: ForwardBase + ForwardAdd; animated water is not presented as a static baked/shadow surface.
- Unlit fog, hologram, and screen families retain their focused single-pass contracts.

## Platform contract

| Content | PCVR/Desktop | Android/Quest | iOS |
|---|---:|---:|---:|
| Apex custom world shaders | Designed | Designed, must profile | Designed, must profile |
| Apex custom avatar shaders | Designed | Not permitted by VRChat | Not permitted by VRChat |
| Generated SDK mobile avatar fallback | Optional | Required | Required |

## Validation boundary

Repository CI verifies roadmap integrity, exact pass contracts, source/package contracts, deterministic Unity metadata, and reproducible package archives. Unity 2022.3.22f1 still needs to execute the compiler/stress matrix across Direct3D 11, Vulkan/GLES3, and Metal.

## Next locked milestone

**0.3.5 — Lighting, GI, instancing, and stereo hardening.**

## Not yet proven

- Unity batch compilation across all target graphics APIs.
- VRChat SDK build/upload validation.
- Correct single-pass stereo on device.
- On-device performance and visual parity measurements.
