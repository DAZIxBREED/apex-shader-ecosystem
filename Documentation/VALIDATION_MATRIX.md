# Apex 0.2.0 Validation Matrix

## Completed in this repository

- Manifest JSON parses and all local package versions/dependencies match `VERSION`.
- Local `Packages/...` HLSL includes resolve to tracked files.
- Unity `.meta` files exist with unique deterministic GUIDs.
- Shader names are unique.
- ShaderLab program/pass delimiters and braces are balanced.
- Mobile-world shaders are checked for banned baseline constructs such as GrabPass, compute, geometry, hull, and domain stages.
- Python tooling compiles and shell publishing scripts pass syntax checks.
- Deterministic UPM archives are built twice and compared by SHA-256 in CI.
- Character shaders are checked for exact `toonstandard` fallback metadata and Standard-compatible base/normal properties.
- SpectraOverdrive and integration bridges are checked for VRChat-safe `_Udon` global contracts.

## Required before claiming runtime validation

| Test | Windows PCVR/Desktop | Android/Quest | iOS |
|---|---:|---:|---:|
| Unity 2022.3.22f1 clean import | Pending | Pending | Pending |
| Shader variant compilation | Pending | Pending | Pending |
| Sample material render test | Pending | Pending | Pending |
| Single-pass stereo test | Pending | Pending | Pending |
| GPU instancing test | Pending | Pending | Pending |
| Lightmap/SH and dynamic-light test | Pending | Pending | Pending |
| SpectraOverdrive Unity global-driver test | Pending | Pending | Pending |
| SpectraOverdrive `_Udon` global-driver test | N/A | Pending | Pending |
| VRChat SDK world build | Pending | Pending | Pending |
| On-device performance capture | N/A | Pending | Pending |
| PC custom avatar upload | Pending | N/A | N/A |
| Generated SDK mobile avatar fallback upload | N/A | Pending | Pending |

## Acceptance criteria for 0.3

- No shader compile errors in the clean-import matrix.
- No pink materials in the sample scene.
- Correct left/right-eye rendering in single-pass stereo.
- Correct lightmap, shadow, point-light, spot-light, and directional-light behavior.
- Mobile world effects remain within documented sampler/pass budgets.
- Avatar fallback generation succeeds with the current VRChat Avatars SDK.
- A VRChat Udon adapter can drive every `_UdonApexSpectra...` field through `VRCShader.SetGlobal`.
