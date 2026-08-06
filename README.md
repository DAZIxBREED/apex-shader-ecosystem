# Apex Shader Ecosystem

A clean-room, modular, handwritten HLSL/CG shader ecosystem by **DAZIxBREED** for Unity **2022.3.22f1**, the Built-in Render Pipeline, and VRChat-oriented content.

**Current development version:** `0.2.0` pre-alpha
**World design targets:** Windows PCVR/Desktop, Android/Quest, and iOS
**Avatar design targets:** Apex custom shaders on PC; SDK-provided `VRChat/Mobile` fallback materials on Android, Quest, and iOS

## What changed in 0.2.0

The initial package skeleton has been replaced with distinct implementation paths:

- Core stereo/instancing varyings, corrected tangent basis, packed material sampling, lightmaps/SH, forward-base and forward-add lighting, shadows, platform helpers, and expanded debug views.
- Apex Avatar now has packed PBR, soft lighting wrap, rim light, alpha clip, additional lights, shadows, SpectraOverdrive routing, Standard-compatible property names, and `VRCFallback="toonstandard"`.
- Apex World now has lightmapped PBR, shadows, additional lights, optional detail, emissive meta output, alpha clip, and SpectraOverdrive routing.
- Water now has two scrolling normal layers, depth tint, Fresnel, foam, transparency, lighting, and fog.
- Fog now has two animated noise layers plus distance, height, view-angle, authored-mask, and vertex-color control.
- Hologram now has masked additive output, scanlines, flicker, Fresnel, and lightweight vertex glitch.
- Screens now use `_MainTex` for video-player compatibility and add UV crop/flip, brightness, contrast, saturation, gamma, scanlines, and vignette.
- Toon now has real banded lighting, shadow color, hard specular, rim light, normal maps, AO, effect masks, alpha clip, Standard-compatible property names, and `VRCFallback="toonstandard"`.
- SpectraOverdrive and optional integrations now expose ordinary Unity globals plus VRChat-safe `_UdonApex...` globals for `VRCShader.SetGlobal` adapters.
- Apex Tools now includes a project/material doctor with shader/import/platform checks, a packed mask texture builder, and a VRChat mobile avatar fallback generator.
- The Examples package exposes Quick Start Materials through Unity Package Manager, and the repository now includes pinned Git/UPM installation documentation.

## Compatibility truth

VRChat permits custom shaders in mobile **worlds**, but Android/Quest mobile **avatars** are restricted to shaders provided by the VRChat SDK. iOS follows the Android/mobile content rules. Apex therefore treats `Apex/Avatar/Standard` as a PC shader and generates a second material using `VRChat/Mobile/Toon Standard`, `Standard Lite`, or `Toon Lit` for mobile avatar uploads.

This is not a downgrade in project scope; it is the only honest way to provide an Apex-authored PC avatar look while producing legal Quest/Android/iOS avatar variants. The PC Avatar and Toon shaders use Standard-compatible property names and the exact `toonstandard` fallback tag so VRChat can preserve supported same-named material data when a custom shader is unavailable.

## Monorepo packages

| Package | Responsibility |
|---|---|
| `com.dazi.apex.core` | Shared structs, math, packing, surfaces, lighting, lightmaps, shadows, platform gates, fog, stereo/instancing, and debug helpers. |
| `com.dazi.apex.spectraoverdrive` | SpectraOverdrive show-control uniform bridge with groups, band weighting, and Unity/VRChat-safe global inputs. |
| `com.dazi.apex.integrations` | Dependency-free generic global hooks for audio, light-volume, LTCGI-style, and VRSL-style data, including `_Udon` aliases. |
| `com.dazi.apex.avatar` | PC custom avatar material shader. |
| `com.dazi.apex.world` | World and environment shaders. |
| `com.dazi.apex.water` | Water and liquid shaders. |
| `com.dazi.apex.fog` | Fog, haze, smoke-card, and atmospheric shaders. |
| `com.dazi.apex.fx` | Hologram and isolated special-effect shader families. |
| `com.dazi.apex.screens` | Video panels, LED walls, signs, CRT, and glitch displays. |
| `com.dazi.apex.toon` | Toon/anime-style shading for PC materials and world objects. |
| `com.dazi.apex.tools` | Validation, mobile avatar fallback generation, and texture packing. |
| `com.dazi.apex.examples` | Importable quick-start materials and setup references. |

## Install from Git

Unity Package Manager supports a monorepo subfolder URL. Example for Core during development:

```text
https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.core#main
```

Install dependencies first:

1. `com.dazi.apex.core`
2. `com.dazi.apex.spectraoverdrive`
3. `com.dazi.apex.integrations` when its generic hooks are needed
4. Desired visual packages
5. `com.dazi.apex.tools`
6. `com.dazi.apex.examples`

## Reference and validation

- [Installation guide](Documentation/INSTALLATION.md)
- [Shader reference](Documentation/SHADER_REFERENCE.md)
- [Validation matrix](Documentation/VALIDATION_MATRIX.md)

## Validate and package

```bash
python3 scripts/generate_unity_meta.py
python3 scripts/validate_repo.py
python3 scripts/build_release_archives.py
```

The static validator checks manifests, inferred package dependencies, Unity metadata, local includes, ShaderLab block balance, duplicate shader names, pass/program pairing, mobile-world constraints, instancing/stereo setup, material-uniform/property consistency, mobile-avatar fallback metadata, and version consistency.

## Current validation boundary

Static validation is performed in this repository. Final release claims still require Unity batch compilation and device/client testing in Unity 2022.3.22f1 for Windows, Android/Quest, and iOS. Custom mobile avatar shaders are intentionally not claimed because VRChat does not permit them.

## License

Copyright © 2026 DAZIxBREED. All rights reserved. See [LICENSE.md](LICENSE.md).
