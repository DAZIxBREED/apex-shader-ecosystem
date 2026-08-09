# Repository Status

**Version:** 0.3.2
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
- Dedicated local-package Unity validation project and automated scene builder.
- Machine-readable compiler report output under `Assets/ApexValidation/Generated/` when validation runs in Unity.

## 0.3.2 hardening

- Added a shared required-shader catalog used by compiler validation and Package Doctor.
- Added synchronous per-pass shader compilation for Standard, Mobile, High, and detail-enabled profiles where applicable.
- Package Doctor now includes compiler messages in full/batch validation and fails batch validation on shader compiler errors.
- Centralized Unity AssetDatabase folder creation for generated reports and mobile fallback output.
- Corrected Core HLSL version constants and aligned every package/direct internal dependency pin to 0.3.2.

## Platform contract

| Content | PCVR/Desktop | Android/Quest | iOS |
|---|---:|---:|---:|
| Apex custom world shaders | Designed | Designed, must profile | Designed, must profile |
| Apex custom avatar shaders | Designed | Not permitted by VRChat | Not permitted by VRChat |
| Generated SDK mobile avatar fallback | Optional | Required | Required |

## Validation boundary

Repository CI verifies static source/package contracts, metadata reproducibility, and deterministic package archives. The 0.3.2 compiler audit requires Unity 2022.3.22f1; it is now wired into the Validation Project but has not yet been executed on every target graphics API in this repository workflow.

## Not yet proven

- Unity batch compilation on Direct3D 11, Vulkan/GLES3, and Metal using the new compiler audit.
- VRChat SDK build/upload validation.
- Correct single-pass stereo on device.
- On-device performance and visual parity measurements.
- Remaining roadmap families such as depth-intersection fog/water, toon outlines, shields, portals, terrain, and advanced avatar hair/skin shaders.
