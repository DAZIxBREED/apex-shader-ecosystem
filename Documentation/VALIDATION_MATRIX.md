# Apex 0.3.3 Validation Matrix

## Repository/static checks

- All package manifests and local dependency versions match `VERSION`.
- Local HLSL includes resolve and Unity metadata GUIDs are deterministic/unique.
- Shader names, named ShaderLab passes, local quality contracts, properties/uniforms, stereo setup, instancing, and mobile-world restrictions are checked.
- SpectraOverdrive ABI 1.0 and `_Udon` safety globals are checked.
- The dedicated validation project must reference all twelve local packages and Unity 2022.3.22f1.
- World/Standard Meta-pass detail/cutout parity and the 0.3.3 stress-harness contracts are statically protected.
- Python/shell tooling parses and UPM archives are reproducible.

## Unity compiler audit

`ApexShaderCompilerAudit` runs inside Unity and synchronously requests compilation of every active pass for each required Apex shader. Quality-managed shaders are compiled in Standard, Mobile, and High profiles. Detail and alpha-cutout stress profiles are also requested where those material paths exist.

The audit writes:

```text
Assets/ApexValidation/Generated/ApexShaderCompilerReport.json
```

The report records pass names, requested pass-compile counts, active keywords, detail/alpha stress flags, compiler severity/platform/source location, shader/profile context, Unity version, active build target, and graphics API. Package Doctor full/batch validation includes these messages and batch validation fails when the audit reports compiler errors.

## Generated validation scene

`ApexValidationSceneBuilder` now creates separate fixtures for quality/stress profiles rather than one material per shader. It also generates:

```text
Assets/ApexValidation/Generated/ApexValidationScene.unity
Assets/ApexValidation/Generated/ApexValidationSceneManifest.json
Assets/ApexValidation/Generated/Textures/ApexValidationAlphaChecker.png
Assets/ApexValidation/Generated/Meshes/ApexValidationVertexBlendSphere.asset
```

The checker texture makes alpha-cutout coverage visible. The generated vertex-gradient sphere drives both layers of `Apex/World/VertexBlendLite`. The scene manifest records every fixture, material path, object position, active keywords, active pass names, and stress-profile flags.

## Runtime matrix

| Test | Windows PCVR/Desktop | Android/Quest | iOS |
|---|---:|---:|---:|
| Unity 2022.3.22f1 clean import | Pending | Pending | Pending |
| 0.3.3 synchronous shader compiler audit | Pending | Pending | Pending |
| 0.3.3 generated stress-scene render | Pending | Pending | Pending |
| Alpha-cutout visual/shadow/meta parity | Pending | Pending | Pending |
| Vertex-blend two-layer visual coverage | Pending | Pending | Pending |
| Single-pass stereo | Pending | Pending | Pending |
| GPU instancing | Pending | Pending | Pending |
| Directional, point, spot, shadows | Pending | Pending | Pending |
| Lightmap/SH and reflection probe | Pending | Pending | Pending |
| Spectra Unity global driver | Pending | Pending | Pending |
| Spectra `_Udon` driver and safety caps | N/A | Pending | Pending |
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

`RunBatch` rebuilds the stress scene, writes its manifest/test assets, runs Package Doctor, and therefore executes the compiler audit before returning success.

## Acceptance criteria for 0.4

- The full clean-import/compiler-audit matrix is executed and logs/reports are retained.
- No shader compiler errors or pink validation fixtures.
- Alpha cutout, detail, vertex blending, shadows, and Meta/lightmap behavior match their forward-rendered materials.
- Correct stereo, light, shadow, lightmap, and reflection-probe behavior.
- Mobile profiles show no High-quality variants in build logs.
- Mobile world effects meet documented sampler/pass/overdraw budgets on target devices.
- Current VRChat SDK successfully builds the world matrix and generated mobile avatar fallbacks.
