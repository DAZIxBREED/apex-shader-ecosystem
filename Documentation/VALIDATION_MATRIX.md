# Apex 0.3.2 Validation Matrix

## Repository/static checks

- All package manifests and local dependency versions match `VERSION`.
- Local HLSL includes resolve and Unity metadata GUIDs are deterministic/unique.
- Shader names, ShaderLab blocks, local quality contracts, properties/uniforms, stereo setup, instancing, and mobile-world restrictions are checked.
- SpectraOverdrive ABI 1.0 and `_Udon` safety globals are checked.
- The dedicated validation project must reference all twelve local packages and Unity 2022.3.22f1.
- Python/shell tooling parses and UPM archives are reproducible.

## Unity compiler audit

`ApexShaderCompilerAudit` runs inside Unity and synchronously requests compilation of every pass for each required Apex shader. Quality-managed shaders are compiled in Standard, Mobile, and High profiles; `_APEX_DETAIL` shaders also receive a Standard+Detail profile.

The audit writes:

```text
Assets/ApexValidation/Generated/ApexShaderCompilerReport.json
```

Each compiler message records severity, compiler platform, source file, source line, message/details, shader/profile context, Unity version, active build target, and graphics API. Package Doctor full/batch validation includes these messages and batch validation fails when the audit reports compiler errors.

## Runtime matrix

| Test | Windows PCVR/Desktop | Android/Quest | iOS |
|---|---:|---:|---:|
| Unity 2022.3.22f1 clean import | Pending | Pending | Pending |
| 0.3.2 synchronous shader compiler audit | Pending | Pending | Pending |
| Generated validation scene render | Pending | Pending | Pending |
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

`RunBatch` builds the validation scene, runs Package Doctor, and therefore executes the 0.3.2 compiler audit before returning success.

## Acceptance criteria for 0.4

- The full clean-import/compiler-audit matrix is executed and logs/reports are retained.
- No shader compiler errors or pink validation fixtures.
- Correct stereo, light, shadow, lightmap, and reflection-probe behavior.
- Mobile profiles show no High-quality variants in build logs.
- Mobile world effects meet documented sampler/pass/overdraw budgets on target devices.
- Current VRChat SDK successfully builds the world matrix and generated mobile avatar fallbacks.
