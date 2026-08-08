# Apex Shader Ecosystem

A clean-room, modular, handwritten HLSL/CG shader ecosystem by **DAZIxBREED** for Unity **2022.3.22f1**, the Built-in Render Pipeline, and VRChat-oriented content.

**Current development version:** `0.3.0` pre-alpha
**World design targets:** Windows PCVR/Desktop, Android/Quest, and iOS
**Avatar design targets:** Apex custom shaders on PC; SDK-provided `VRChat/Mobile` fallback materials on Android, Quest, and iOS

## What changed in 0.3.0

Apex 0.3.0 turns the first visual baselines into a quality-managed and validation-oriented ecosystem:

- Core now has Standard, Mobile, and High local quality tiers plus reflection-probe environment specular for supported tiers.
- World gains `Apex/World/VertexBlendLite`, a two-layer vertex-red blend shader with independent base, normal, and packed-mask inputs.
- Water gains `Apex/Water/OpaqueMobile`, a three-sampler opaque alternative for severe transparency/fill-rate budgets.
- FX gains `Apex/FX/DissolveCutout`, including lit dissolve edges, shadow casting, baked Meta output, and SpectraOverdrive response.
- Screens gains `Apex/Screens/LEDPanelLite`, a one-sampler procedural LED/pixel-grid video panel with RGB subpixel simulation.
- SpectraOverdrive now exposes a frozen ABI 1.0 and safety policy globals that can cap intensity and strobe response without breaking 0.2 drivers.
- Apex Tools now includes material quality profiles, avatar skin/cloth/hair/hard-surface presets, deterministic mobile-fallback pairing records, batch fallback generation, shader variant stripping, variant usage reports, a global bridge monitor, and an automated validation-scene builder.
- `ValidationProject/` is a dedicated Unity 2022.3.22f1 project that references all twelve local packages and exposes a batch validation entry point.

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

Unity Package Manager supports a monorepo subfolder URL. Example for Core:

```text
https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.core#agent/advance-0.3.0
```

Pin all installed Apex packages to the same branch, commit, or release tag.

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
