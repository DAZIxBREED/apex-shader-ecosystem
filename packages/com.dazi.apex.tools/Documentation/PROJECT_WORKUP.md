# Apex Tools — Project Workup

## Purpose

Apex Tools owns editor-only authoring, conversion, and validation workflows for the shader ecosystem.

## 0.2.0 implementation

- **Package Doctor:** verifies required Apex shaders, scans all Apex materials, reports unsupported shaders, missing mobile avatar fallbacks, disabled instancing, oversized textures, suspicious alpha clipping, and transparent fill-rate risks.
- **Packed Mask Builder:** creates the R metallic / G occlusion / B effect / A smoothness texture from readable or non-readable source textures, with per-channel fallback and inversion.
- **Mobile Avatar Fallback Builder:** creates a second material using an installed SDK `VRChat/Mobile` shader and transfers compatible base, normal, mask, color, emission, metallic, smoothness, and cutoff values without a hard SDK compile dependency.

## Ownership boundaries

- Tools is editor-only and must add no player/runtime assemblies.
- It does not bypass VRChat platform rules or upload content.
- It does not silently rewrite source materials.

## Next work

- Batch fallback generation and source/fallback pairing metadata.
- Material migration from common BIRP shaders.
- Shader variant report and mobile overdraw checks.
- Automated Unity batch validation entry points.
