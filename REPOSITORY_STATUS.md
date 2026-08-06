# Repository Status

**Version:** 0.2.0
**Maturity:** Pre-alpha implementation
**Unity baseline:** 2022.3.22f1, Built-in Render Pipeline

## Implemented

- Twelve independent UPM packages with deterministic Unity metadata.
- Shared handwritten HLSL for stereo/instancing, tangent-space normals, packed PBR inputs, baked GI/lightmaps, forward lighting, attenuation/shadows, fog, platform helpers, and debug output.
- Distinct Avatar, World, Water, Fog, Hologram, Screen, and Toon shader behavior.
- SpectraOverdrive intensity/color/beat/blackout/strobe/band/group bridge with neutral defaults and dual Unity/VRChat-safe `_Udon` global inputs.
- Generic optional integration globals for audio, light-volume, LTCGI-style, and VRSL-style drivers, including `_Udon`-prefixed VRChat inputs.
- PC avatar/toon fallback metadata using Standard-compatible property names and exact `toonstandard` tags, plus an editor generator for SDK-approved mobile fallback materials.
- Packed mask texture authoring tool and project/material validation tool with imported shader, texture-import, transparency, instancing, and platform checks.
- Static monorepo validation, Package Manager sample exposure, pinned Git/UPM installation documentation, and deterministic package archives.

## Platform contract

| Content | PCVR/Desktop | Android/Quest | iOS |
|---|---:|---:|---:|
| Apex custom world shaders | Designed | Designed, must profile | Designed, must profile |
| Apex custom avatar shaders | Designed | Not permitted by VRChat | Not permitted by VRChat |
| Generated SDK mobile avatar fallback | Optional | Required | Required |

## Not yet proven

- Unity batch compilation of every shader variant.
- VRChat SDK build validation on all three build targets.
- On-device performance and visual parity measurements.
- All package roadmap families; 0.2.0 still supplies one production-oriented baseline per visual package rather than every planned shader.

No unsupported platform claim should be inferred from package naming alone.
