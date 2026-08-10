# Apex 0.3.4 Validation Matrix

## Repository/static checks

- All package manifests and local dependency versions match `VERSION`.
- Local HLSL includes resolve and Unity metadata GUIDs are deterministic/unique.
- The locked 1.0 roadmap contract is validated.
- Every current shader must match its exact ordered ShaderLab pass contract.
- 0.3.4 parity invariants protect vertex-alpha shadow coverage, World Meta vertex/detail parity, VertexBlend masked Meta emission, Dissolve shared clip/edge math, and Toon ForwardAdd/Meta coverage.
- Shader names, quality contracts, properties/uniforms, stereo setup, instancing, and mobile-world restrictions are checked.
- SpectraOverdrive ABI 1.0 and `_Udon` safety globals are checked.
- UPM archives must build reproducibly.

## Intentional pass matrix

| Shader | Required ordered passes |
|---|---|
| `Apex/Core/Debug` | `FORWARD_BASE` |
| `Apex/Avatar/Standard` | `FORWARD_BASE`, `FORWARD_ADD`, `SHADOW_CASTER` |
| `Apex/World/Standard` | `FORWARD_BASE`, `FORWARD_ADD`, `SHADOW_CASTER`, `META` |
| `Apex/World/VertexBlendLite` | `FORWARD_BASE`, `FORWARD_ADD`, `SHADOW_CASTER`, `META` |
| `Apex/Water/PoolLite` | `FORWARD_BASE` |
| `Apex/Water/OpaqueMobile` | `FORWARD_BASE`, `FORWARD_ADD` |
| `Apex/Fog/CardLite` | `UNLIT_FOG` |
| `Apex/FX/HologramLite` | `HOLOGRAM` |
| `Apex/FX/DissolveCutout` | `FORWARD_BASE`, `FORWARD_ADD`, `SHADOW_CASTER`, `META` |
| `Apex/Screens/VideoPanelLite` | `VIDEO_PANEL` |
| `Apex/Screens/LEDPanelLite` | `LED_PANEL` |
| `Apex/Toon/CharacterLite` | `FORWARD_BASE`, `FORWARD_ADD`, `SHADOW_CASTER`, `META` |

These omissions are intentional. Avatar is not a baked-world shader; transparent PoolLite remains a focused transparent pass; OpaqueMobile water remains animated/dynamic rather than claiming static baked/shadow parity.

## Unity compiler audit

`ApexShaderCompilerAudit` synchronously requests compilation of every active pass/profile and writes:

```text
Assets/ApexValidation/Generated/ApexShaderCompilerReport.json
```

Package Doctor also compares Unity's actual pass names/order with `ApexShaderCatalog` before compiler auditing.

## Generated validation scene

The Validation Project generates:

```text
Assets/ApexValidation/Generated/ApexValidationScene.unity
Assets/ApexValidation/Generated/ApexValidationSceneManifest.json
Assets/ApexValidation/Generated/Textures/ApexValidationAlphaChecker.png
Assets/ApexValidation/Generated/Meshes/ApexValidationVertexBlendSphere.asset
```

## Runtime matrix

| Test | Windows PCVR/Desktop | Android/Quest | iOS |
|---|---:|---:|---:|
| Unity 2022.3.22f1 clean import | Pending | Pending | Pending |
| 0.3.4 synchronous shader compiler audit | Pending | Pending | Pending |
| 0.3.4 stress-scene render | Pending | Pending | Pending |
| Exact ShaderLab pass contract in Unity | Pending | Pending | Pending |
| Alpha-cutout visual/shadow/meta parity | Pending | Pending | Pending |
| Vertex-blend baked emission parity | Pending | Pending | Pending |
| Single-pass stereo | Pending | Pending | Pending |
| GPU instancing | Pending | Pending | Pending |
| Directional, point, spot, shadows | Pending | Pending | Pending |
| Lightmap/SH and reflection probe | Pending | Pending | Pending |
| VRChat SDK world build | Pending | Pending | Pending |
| On-device performance capture | N/A | Pending | Pending |
| PC custom avatar upload | Pending | N/A | N/A |
| Generated SDK mobile avatar fallback | N/A | Pending | Pending |

## Batch entry point

```bash
Unity -batchmode -quit \
  -projectPath ./ValidationProject \
  -executeMethod ApexValidationProjectEntry.RunBatch \
  -logFile ./ValidationProject/apex-validation.log
```

## 0.3.4 exit gate

- Static CI green.
- Exact pass-contract CI green.
- All known forward/shadow/Meta mismatches in the current shader set corrected or explicitly documented as intentional pass omissions.
- Validation scene and compiler audit continue to describe the same stress profiles.

The next locked milestone is **0.3.5 — lighting, GI, instancing, and stereo hardening**.
