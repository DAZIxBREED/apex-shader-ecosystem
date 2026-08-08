# Apex Shader Ecosystem

A clean-room, modular, handwritten HLSL/CG shader ecosystem by **DAZIxBREED** for Unity **2022.3.22f1**, the Built-in Render Pipeline, and VRChat-oriented content.

**Current development version:** `0.3.1` pre-alpha
**World design targets:** Windows PCVR/Desktop, Android/Quest, and iOS
**Avatar design targets:** Apex custom shaders on PC; SDK-provided `VRChat/Mobile` fallback materials on Android, Quest, and iOS

## What changed in 0.3.1

Apex 0.3.1 is a hardening patch over 0.3.0:

- Fixed the sample-material whitespace defect that caused the 0.3.0 GitHub validation workflow to fail before package validation could run.
- Moved GitHub validation and packaging workflows to Node-24-compatible `actions/checkout@v6` and `actions/setup-python@v6`.
- Hardened the Mobile Avatar Fallback Builder so output folders are created through Unity's `AssetDatabase` before material/pairing assets are written.
- Hardened shader-variant report output so generated report folders are also AssetDatabase-aware.
- Bumped all twelve UPM package manifests and internal Apex dependency pins together to `0.3.1`.
- Re-ran the full static validation chain successfully, including deterministic metadata and two identical UPM archive builds.

0.3.1 retains the 0.3.0 shader/runtime feature set: quality tiers, reflection-probe lighting, World vertex blending, opaque mobile water, lit dissolve, LED panels, SpectraOverdrive ABI 1.0, authoring profiles, variant tooling, and the Unity validation project.

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
| `com.dazi.apex.tools` | Validation, profiles, variant control/reporting, fallback generation, diagnostics, and texture packing. |
| `com.dazi.apex.examples` | Importable quick-start materials and setup references. |

## Install from Git

Unity Package Manager supports a monorepo subfolder URL. For the current pre-alpha development line, Core can be installed from `main`:

```text
https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.core#main
```

Pin all installed Apex packages to the same branch or, preferably, the same exact commit for reproducible projects. Do not use a version tag unless that tag actually exists in the repository.

## Validation project

Open `ValidationProject/` directly in Unity 2022.3.22f1, then use **Apex Validation > Build Scene And Validate**. Batch mode is documented in [ValidationProject/README.md](ValidationProject/README.md).

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

Static validation is not a substitute for Unity shader compilation, VRChat SDK builds, stereo testing, or device profiling.

## License

Copyright © 2026 DAZIxBREED. All rights reserved. See [LICENSE.md](LICENSE.md).
