# Apex Shader Ecosystem

A clean-room, modular, handwritten HLSL/CG shader ecosystem by **DAZIxBREED** for Unity **2022.3.22f1**, the Built-in Render Pipeline, and VRChat-oriented content.

**Current development version:** `0.3.3` pre-alpha
**World design targets:** Windows PCVR/Desktop, Android/Quest, and iOS
**Avatar design targets:** Apex custom shaders on PC; SDK-provided `VRChat/Mobile` fallback materials on Android, Quest, and iOS

## What changed in 0.3.3

Apex 0.3.3 turns the 0.3.2 compiler harness into a stronger shader/runtime stress matrix:

- Validation-scene generation now expands quality-aware shaders into separate Standard, Mobile, and High fixtures instead of showing only one material state.
- Detail and alpha-cutout stress profiles are generated where the shader exposes those paths, including a combined Standard+Detail+AlphaClip fixture.
- The scene builder generates a checker-alpha texture so cutout fixtures visibly exercise alpha rejection instead of merely setting a float.
- `Apex/World/VertexBlendLite` receives a generated mesh with an actual red-channel vertex gradient, exercising both material layers in the validation scene.
- `ApexValidationSceneManifest.json` records each generated fixture, material path, position, active keywords, pass names, and stress flags.
- Compiler reports now record active ShaderLab pass names and total requested pass compiles, and audit the same alpha/detail stress profiles used by the scene.
- Repository validation now requires every Apex ShaderLab pass to be named and protects the new compiler/scene stress contracts.
- Fixed `Apex/World/Standard` Meta-pass parity: detail albedo and alpha cutout are now represented during lightmapping instead of baking a solid base-only surface.
- Aligned all twelve UPM packages, dependency pins, repository metadata, and Core HLSL version constants to `0.3.3`.

The hosted repository CI still does not contain a licensed Unity editor. The generated scene, compiler report, and runtime stress fixtures become active when `ValidationProject` is opened or run under Unity 2022.3.22f1.

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
| `com.dazi.apex.tools` | Compiler auditing, stress-scene generation/manifests, validation, profiles, variant control/reporting, fallback generation, diagnostics, and texture packing. |
| `com.dazi.apex.examples` | Importable quick-start materials and setup references. |

## Install from Git

Unity Package Manager supports a monorepo subfolder URL. For the current pre-alpha development line, Core can be installed from `main`:

```text
https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.core#main
```

Pin all installed Apex packages to the same branch or, preferably, the same exact commit for reproducible projects. Do not use a version tag unless that tag actually exists in the repository.

## Validation project

Open `ValidationProject/` directly in Unity 2022.3.22f1, then use **Apex Validation > Build Scene And Validate**. Package Doctor performs the synchronous compiler audit as part of full/batch validation. The validation run generates the stress scene, compiler report, and scene manifest under `Assets/ApexValidation/Generated/`. Batch mode is documented in [ValidationProject/README.md](ValidationProject/README.md).

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

Static validation is not a substitute for Unity shader compilation, VRChat SDK builds, stereo testing, or device profiling. Apex 0.3.3 makes the Unity-side stress scene and compiler audit substantially more representative, but target-runtime validation remains required.

## License

Copyright © 2026 DAZIxBREED. All rights reserved. See [LICENSE.md](LICENSE.md).
