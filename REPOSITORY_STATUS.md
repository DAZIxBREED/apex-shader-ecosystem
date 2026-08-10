# Repository Status

**Version:** 0.3.3
**Maturity:** Pre-alpha implementation
**Unity baseline:** 2022.3.22f1, Built-in Render Pipeline

## Implemented

- Twelve independent UPM packages with deterministic Unity metadata and release archives.
- Shared handwritten HLSL for packed surfaces, lightmaps/SH, forward lighting, shadows, fog, stereo/instancing, reflection probes, and local Mobile/Standard/High quality tiers.
- Twelve ShaderLab shaders across Core, Avatar, World, Water, Fog, FX, Screens, and Toon, including second focused families for World, Water, FX, and Screens.
- SpectraOverdrive ABI 1.0 with Unity and `_Udon` globals, routing, four bands, blackout, and optional intensity/strobe safety limits.
- Dependency-free optional integration globals plus an editor monitor for live Unity/Udon values.
- PC character fallback metadata, batch SDK mobile-material generation, and machine-readable source/fallback pairing records.
- Material quality profiles, Avatar look presets, packed-mask authoring, project/material validation, variant stripping, variant usage reports, and synchronous shader compiler auditing.
- Dedicated local-package Unity validation project with a generated stress-profile scene.
- Machine-readable compiler and validation-scene manifest output under `Assets/ApexValidation/Generated/` when validation runs in Unity.

## 0.3.3 hardening

- Expanded validation-scene coverage into Standard, Mobile, High, detail, alpha-cutout, and combined detail+alpha stress profiles where supported.
- Added a generated checker-alpha texture so cutout fixtures exercise real coverage differences.
- Added a generated vertex-gradient mesh so `Apex/World/VertexBlendLite` visibly exercises both blend layers.
- Compiler reports now include active pass names and total requested pass compiles while matching the scene's stress-profile labels.
- Repository validation now requires named ShaderLab passes and protects the new stress-harness contracts.
- Corrected `Apex/World/Standard` Meta-pass detail and alpha-cutout parity for lightmapping.
- Aligned every package, direct internal dependency pin, repository version, and Core HLSL version macro to 0.3.3.

## Platform contract

| Content | PCVR/Desktop | Android/Quest | iOS |
|---|---:|---:|---:|
| Apex custom world shaders | Designed | Designed, must profile | Designed, must profile |
| Apex custom avatar shaders | Designed | Not permitted by VRChat | Not permitted by VRChat |
| Generated SDK mobile avatar fallback | Optional | Required | Required |

## Validation boundary

Repository CI verifies static source/package contracts, metadata reproducibility, and deterministic package archives. The 0.3.3 compiler audit and stress scene require Unity 2022.3.22f1; they are wired into the Validation Project but still need execution across the target graphics APIs and devices.

## Not yet proven

- Unity batch compilation on Direct3D 11, Vulkan/GLES3, and Metal using the compiler audit.
- VRChat SDK build/upload validation.
- Correct single-pass stereo on device.
- On-device performance and visual parity measurements.
- Remaining roadmap families such as depth-intersection fog/water, toon outlines, shields, portals, terrain, and advanced avatar hair/skin shaders.
