# Apex Shader Ecosystem

A clean-room, modular, handwritten HLSL/CG shader ecosystem by **DAZIxBREED** for Unity **2022.3.22f1**, the Built-in Render Pipeline, and VRChat-oriented content.

**Current development version:** `0.3.2` pre-alpha
**World design targets:** Windows PCVR/Desktop, Android/Quest, and iOS
**Avatar design targets:** Apex custom shaders on PC; SDK-provided `VRChat/Mobile` fallback materials on Android, Quest, and iOS

## What changed in 0.3.2

Apex 0.3.2 turns Unity shader compilation into an explicit validation step instead of relying only on static source checks:

- Added a shared required-shader catalog used by Package Doctor and compiler validation.
- Added `ApexShaderCompilerAudit`, which synchronously requests compilation of every pass in the current Apex material profiles through Unity's editor shader compiler.
- Quality-managed shaders are audited in Standard, Mobile, and High configurations; shaders exposing `_APEX_DETAIL` also receive a Standard+Detail compile pass.
- Compiler errors and warnings are captured with severity, platform, source path, line, details, build target, graphics API, Unity version, shader profile, and pass counts in `Assets/ApexValidation/Generated/ApexShaderCompilerReport.json`.
- Package Doctor batch validation now fails when the compiler audit reports shader errors.
- Centralized generated `Assets/` folder creation so compiler reports, variant reports, and mobile-avatar fallback output use one AssetDatabase-safe implementation.
- Corrected the Core HLSL version constants to `0.3.2` and aligned all twelve UPM packages plus internal dependency pins to the same patch version.

The repository's hosted static CI still does not contain a licensed Unity editor, so the compiler audit runs when `ValidationProject` is opened or executed with Unity 2022.3.22f1.

## Compatibility truth

VRChat permits custom shaders in mobile **worlds**, but mobile **avatars** are restricted to shaders provided by the VRChat SDK. Apex therefore treats `Apex/Avatar/Standard` as a PC shader and generates a second material using `VRChat/Mobile/Toon Standard`, `Standard Lite`, or `Toon Lit` for mobile avatar uploads.

The PC Avatar and Toon shaders use Standard-compatible property names and the exact `toonstandard` fallback tag so supported same-named material data can survive shader fallback.

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
| `com.dazi.apex.tools` | Compiler auditing, validation, profiles, variant control/reporting, fallback generation, diagnostics, and texture packing. |
| `com.dazi.apex.examples` | Importable quick-start materials and setup references. |

## Install from Git

Unity Package Manager supports a monorepo subfolder URL. For the current pre-alpha development line, Core can be installed from `main`:

```text
https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.core#main
```

Pin all installed Apex packages to the same branch or, preferably, the same exact commit for reproducible projects. Do not use a version tag unless that tag actually exists in the repository.

## Validation project

Open `ValidationProject/` directly in Unity 2022.3.22f1, then use **Apex Validation > Build Scene And Validate**. Package Doctor now performs the synchronous shader compiler audit as part of full/batch validation and writes the compiler report under `Assets/ApexValidation/Generated/`. Batch mode is documented in [ValidationProject/README.md](ValidationProject/README.md).

## Reference

- [Installation guide](Documentation/INSTALLATION.md)
- [Shader reference](Documentation/SHADER_REFERENCE.md)
- [Validation matrix](Documentation/VALIDATION_MATRIX.md)
- [SpectraOverdrive ABI 1.0](packages/com.dazi.apex.spectraoverdrive/Documentation/ABI.md)

## Static validation and packaging

```bash
python3 scripts/generate_unity_meta.py
python3 scripts/validate_repo.py
python3 scripts/build_release_archives.py
```

Static validation is not a substitute for Unity shader compilation, VRChat SDK builds, stereo testing, or device profiling. Apex 0.3.2 adds the Unity-side compiler audit needed to begin closing that gap.

## License

Copyright © 2026 DAZIxBREED. All rights reserved. See [LICENSE.md](LICENSE.md).
