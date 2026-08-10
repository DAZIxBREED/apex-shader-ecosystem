# Apex Shader Ecosystem

A clean-room, modular, handwritten HLSL/CG shader ecosystem by **DAZIxBREED** for Unity **2022.3.22f1**, the Built-in Render Pipeline, and VRChat-oriented content.

**Current development version:** `0.3.4` pre-alpha
**World design targets:** Windows PCVR/Desktop, Android/Quest, and iOS
**Avatar design targets:** Apex custom shaders on PC; SDK-provided `VRChat/Mobile` fallback materials on Android, Quest, and iOS

Development through production 1.0 is governed by the **[locked roadmap](ROADMAP.md)** and its **[release gates](Documentation/RELEASE_GATES.md)**. New feature ideas do not displace that sequence.

## What changed in 0.3.4

Apex 0.3.4 closes the current ShaderLab pass-parity milestone before broader lighting and platform work:

- Every current Apex shader now has an explicit ordered pass contract, shared by the Unity Package Doctor and repository CI.
- `Apex/Toon/CharacterLite` now has `FORWARD_ADD` and `META` passes, so additional realtime lights and baked albedo/emission are represented instead of silently disappearing.
- The shared shadow caster now carries vertex alpha; Avatar, World Standard, and Toon alpha clipping therefore use the same effective vertex/base alpha in visible and shadow paths.
- World Standard Meta output now respects vertex tint/alpha while retaining the detail and cutout parity added in 0.3.3.
- VertexBlendLite Meta emission now uses the same blended B-channel effect mask as runtime emission.
- Dissolve Meta now uses the same shared dissolve clipping/edge helpers as ForwardBase, ForwardAdd, and ShadowCaster, and respects vertex tint.
- `scripts/validate_pass_contracts.py` fails CI when a current shader loses, gains, reorders, or renames a pass outside the locked contract.
- All twelve UPM packages, direct Apex dependency pins, repository metadata, and Core HLSL version macros are aligned to `0.3.4`.

The hosted repository CI does not contain a licensed Unity editor. Unity compilation, target graphics APIs, VRChat SDK builds, stereo correctness, and physical-device profiling remain executable runtime gates rather than source-level claims.

## Compatibility truth

VRChat permits custom shaders in mobile **worlds**, but mobile **avatars** are restricted to shaders provided by the VRChat SDK. Apex therefore treats `Apex/Avatar/Standard` as a PC shader and generates a second material using SDK `VRChat/Mobile` shaders for Android, Quest, and iOS avatar uploads.

## Monorepo packages

| Package | Responsibility |
|---|---|
| `com.dazi.apex.core` | Shared structs, math, packing, surfaces, lighting, reflection probes, shadows, quality tiers, platform gates, fog, stereo/instancing, and debug helpers. |
| `com.dazi.apex.spectraoverdrive` | Versioned SpectraOverdrive shader ABI, routing, band weighting, safety limits, and Unity/VRChat-safe globals. |
| `com.dazi.apex.integrations` | Dependency-free generic global hooks for audio, light-volume, LTCGI-style, and VRSL-style data. |
| `com.dazi.apex.avatar` | PC custom avatar material shader. |
| `com.dazi.apex.world` | Standard and two-layer vertex-blended environment shaders. |
| `com.dazi.apex.water` | Transparent pool water and opaque mobile water. |
| `com.dazi.apex.fog` | Fog, haze, smoke-card, and atmospheric shaders. |
| `com.dazi.apex.fx` | Hologram and lit dissolve/cutout effects. |
| `com.dazi.apex.screens` | Video panels and procedural LED walls. |
| `com.dazi.apex.toon` | Toon/anime-style shading for PC materials and world objects. |
| `com.dazi.apex.tools` | Pass-contract/compiler auditing, stress-scene generation, validation, profiles, fallback generation, diagnostics, variant tooling, and texture packing. |
| `com.dazi.apex.examples` | Importable quick-start materials and setup references. |

## Install from Git

```text
https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.core#main
```

Pin all Apex packages to the same branch or, preferably, the same exact commit for reproducible projects. Do not use a version tag unless that tag actually exists.

## Validation project

Open `ValidationProject/` in Unity 2022.3.22f1 and use **Apex Validation > Build Scene And Validate**. Package Doctor checks the exact pass contracts and runs the synchronous compiler audit. Generated validation artifacts live under `Assets/ApexValidation/Generated/`.

## Reference

- [Locked roadmap to 1.0](ROADMAP.md)
- [Release gates](Documentation/RELEASE_GATES.md)
- [Installation guide](Documentation/INSTALLATION.md)
- [Shader reference](Documentation/SHADER_REFERENCE.md)
- [Validation matrix](Documentation/VALIDATION_MATRIX.md)
- [SpectraOverdrive ABI 1.0](packages/com.dazi.apex.spectraoverdrive/Documentation/ABI.md)

## Static validation and packaging

```bash
python3 scripts/validate_roadmap.py
python3 scripts/validate_pass_contracts.py
python3 scripts/validate_repo.py
python3 scripts/generate_unity_meta.py
python3 scripts/build_release_archives.py
```

Static validation is not a substitute for Unity shader compilation, VRChat SDK builds, stereo testing, or device profiling.

## License

Copyright © 2026 DAZIxBREED. All rights reserved. See [LICENSE.md](LICENSE.md).
