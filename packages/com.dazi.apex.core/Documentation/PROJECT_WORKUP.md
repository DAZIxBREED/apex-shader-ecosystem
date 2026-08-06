# Apex Core — Project Workup

## Purpose

Apex Core is the dependency floor for every handwritten Apex shader. It owns shared vertex formats, stereo/instancing setup, tangent-space conversion, packed-material decoding, baked and dynamic lighting helpers, fog, shadow-caster helpers, platform gates, and debug output.

## 0.2.0 implementation

- `ApexCore_Common.cginc`: BIRP vertex/varying contracts, single-pass stereo, GPU instancing, fog, corrected tangent basis, normal unpacking, UV helpers, hashes, and view direction.
- `ApexCore_Surface.cginc`: common packed-surface construction and alpha clipping.
- `ApexCore_Packing.cginc`: R metallic, G occlusion, B effect mask, A smoothness contract.
- `ApexCore_Lighting.cginc`: lightmaps or spherical harmonics, main/additional lights, attenuation, PBR-style direct light, wrapped diffuse, rim, and toon helpers.
- `ApexCore_Shadow.cginc`: reusable instanced shadow-caster vertex path.
- `ApexCore_Debug.cginc`: albedo, normals, MOS, UV, vertex color, emission, effect mask, and baked-GI views.
- `ApexCore_Platform.cginc`: Android, iOS, GLES, and desktop quality gates.

## Ownership boundaries

- Core contains no visual-family-specific look.
- SpectraOverdrive state belongs to `com.dazi.apex.spectraoverdrive`.
- Optional third-party/global bridges belong to `com.dazi.apex.integrations`.
- Material authoring and validation UI belongs to `com.dazi.apex.tools`.

## Next work

- Unity batch compile every shader pass and keyword variant.
- Add reflection-probe/specular-environment sampling behind a documented quality tier.
- Add a formal shader variant stripping policy.
- Lock include API compatibility before 1.0.
