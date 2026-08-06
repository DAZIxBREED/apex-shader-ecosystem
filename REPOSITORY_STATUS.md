# Repository Status

**Version:** 0.3.0
**Maturity:** Pre-alpha implementation
**Unity baseline:** 2022.3.22f1, Built-in Render Pipeline

## Implemented

- Twelve independent UPM packages with deterministic Unity metadata and release archives.
- Shared handwritten HLSL for packed surfaces, lightmaps/SH, forward lighting, shadows, fog, stereo/instancing, reflection probes, and local Mobile/Standard/High quality tiers.
- Twelve ShaderLab shaders across Core, Avatar, World, Water, Fog, FX, Screens, and Toon, including second focused families for World, Water, FX, and Screens.
- SpectraOverdrive ABI 1.0 with Unity and `_Udon` globals, routing, four bands, blackout, and optional intensity/strobe safety limits.
- Dependency-free optional integration globals plus an editor monitor for live Unity/Udon values.
- PC character fallback metadata, batch SDK mobile-material generation, and machine-readable source/fallback pairing records.
- Material quality profiles, Avatar look presets, packed-mask authoring, project/material validation, variant stripping, and variant usage reports.
- Dedicated local-package Unity validation project and automated scene builder.

## Platform contract

| Content | PCVR/Desktop | Android/Quest | iOS |
|---|---:|---:|---:|
| Apex custom world shaders | Designed | Designed, must profile | Designed, must profile |
| Apex custom avatar shaders | Designed | Not permitted by VRChat | Not permitted by VRChat |
| Generated SDK mobile avatar fallback | Optional | Required | Required |

## Not yet proven

- Unity batch compilation of every pass and variant on each target graphics API.
- VRChat SDK build/upload validation.
- Correct single-pass stereo on device.
- On-device performance and visual parity measurements.
- Remaining roadmap families such as depth-intersection fog/water, toon outlines, shields, portals, terrain, and advanced avatar hair/skin shaders.
