
# Apex Shader Ecosystem

A clean-room, modular, handwritten HLSL/CG shader ecosystem by **DAZIxBREED** for Unity 2022.3 Built-in Render Pipeline and VRChat-oriented content.

**Current release:** `0.1.0` pre-alpha  
**Minimum design targets:** iOS, Android, Quest standalone, and PCVR  
**Status:** implemented foundation; platform compilation and in-client validation remain required

## Monorepo packages

| Package | Responsibility |
|---|---|
| `com.dazi.apex.core` | Shared structs, math, packing, lighting, platform gates, fog, and debug helpers. |
| `com.dazi.apex.spectraoverdrive` | Dedicated SpectraOverdrive show-control uniform bridge. |
| `com.dazi.apex.integrations` | Optional AudioLink, LTCGI, VRC Light Volumes, and VRSL-style compatibility boundaries. |
| `com.dazi.apex.avatar` | Avatar material shaders. |
| `com.dazi.apex.world` | World and environment shaders. |
| `com.dazi.apex.water` | Water and liquid shaders. |
| `com.dazi.apex.fog` | Fog, haze, smoke-card, and atmospheric shaders. |
| `com.dazi.apex.fx` | Hologram, dissolve, shield, portal, and energy effects. |
| `com.dazi.apex.screens` | Video panels, LED walls, signs, CRT, and glitch displays. |
| `com.dazi.apex.toon` | Dedicated toon and anime-style shading. |
| `com.dazi.apex.tools` | Editor validation and future authoring utilities. |
| `com.dazi.apex.examples` | Importable quick-start materials and future sample scenes. |

## Architecture rules

Every visual package depends on `com.dazi.apex.core`. Packages that consume show-control data depend on `com.dazi.apex.spectraoverdrive`. Optional external systems belong behind `com.dazi.apex.integrations`; they must never be required just to compile Apex.

Mobile and Quest paths must not require compute shaders, geometry shaders, tessellation, GrabPass, excessive samplers, or uncontrolled shader variants.

## Install from a local checkout

Copy the desired folders from `packages/` into the Unity project's `Packages/` directory. Install dependencies first:

1. `com.dazi.apex.core`
2. `com.dazi.apex.spectraoverdrive`
3. `com.dazi.apex.integrations` when needed
4. Desired visual packages
5. `com.dazi.apex.tools`
6. `com.dazi.apex.examples`

## Install from Git after publication

Unity Package Manager supports a monorepo subfolder URL. Example for Core:

```text
https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.core#v0.1.0
```

Change the path for each package. During active development, omit the tag or use a branch name instead.

## Validate and package

```bash
python3 scripts/validate_repo.py
python3 scripts/build_release_archives.py
```

The validator checks package manifests, local dependency versions, required files, Unity metadata, and repository-local shader includes. Release archives are written to `artifacts/`.

## Honest scope

This is a working clean-room foundation, not yet a finished replacement for mature all-in-one shader suites. Read [REPOSITORY_STATUS.md](REPOSITORY_STATUS.md) and [APEX_ECOSYSTEM_WORKUP.md](APEX_ECOSYSTEM_WORKUP.md) before treating roadmap features as implemented.

## License

Copyright © 2026 DAZIxBREED. All rights reserved. See [LICENSE.md](LICENSE.md).
