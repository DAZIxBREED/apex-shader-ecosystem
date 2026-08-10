# Apex Release Gates

This document defines the non-negotiable validation gates used by the locked roadmap in `ROADMAP.md`.

A release may satisfy more gates than its milestone requires, but it may not claim a gate it has not actually executed. Static source validation and generated test infrastructure are evidence of readiness to test, not evidence that a target platform passed.

## Gate A — Repository integrity

Required for every merged release branch.

- `VERSION` is valid semantic `MAJOR.MINOR.PATCH`.
- All twelve Apex package manifests match `VERSION`.
- All direct internal Apex dependency pins match `VERSION`.
- `repository.json` matches `VERSION` and the package list.
- Core HLSL version macros match `VERSION`.
- Required package files exist.
- Unity `.meta` files are present, unique, and deterministic.
- Local `Packages/...` HLSL includes resolve.
- Shader names are unique.
- ShaderLab blocks are structurally valid under static checks.
- Required shaders and pass names are present.
- Repository whitespace/syntax gates pass.
- Generated metadata produces zero diff.
- All twelve UPM archives build twice with identical output.

**Pass condition:** GitHub static validation workflow is green on the exact release head.

## Gate B — Unity editor compilation

Required beginning with the 0.3.x compiler-hardening phase and mandatory for 0.4+ qualification claims.

- Validation Project opens under Unity 2022.3.22f1.
- Apex editor C# compiles with no blocking error.
- Every required shader can be found by `Shader.Find`.
- Every required shader pass is requested through the synchronous compiler audit.
- Standard/Mobile/High profiles are compiled where available.
- Detail/alpha stress profiles are compiled where available.
- Compiler messages are retained in `ApexShaderCompilerReport.json`.
- No shader compiler error remains for the target/API being qualified.

**Pass condition:** compiler report contains zero blocking shader errors and the Unity validation command exits successfully.

## Gate C — Generated visual validation scene

Required for shader/runtime milestones.

- Validation scene is regenerated from clean inputs.
- Scene manifest is retained.
- Every production shader has at least one representative fixture.
- Quality-aware shaders include required quality fixtures.
- Alpha-cutout paths visibly exercise alpha rejection.
- Vertex-blend paths contain non-uniform vertex data.
- Lighting/GI/probe/stereo fixtures required by the active milestone are present.
- No fixture is pink/missing-shader.
- No fixture is black/blank because of missing validation input unless blank output is the expected case.

**Pass condition:** expected fixtures render coherently and the manifest matches the intended validation coverage.

## Gate D — Target build qualification

Required for 0.4+ platform qualification.

Each supported target must retain:

- Unity version.
- active build target.
- graphics API.
- compiler report.
- validation-scene manifest.
- build log.
- build success/failure classification.

Target matrix for the 1.0 runway:

| Target | Primary API | Qualification role |
|---|---|---|
| Windows PCVR/Desktop | Direct3D 11 | Required PC baseline |
| Android/Quest | Vulkan | Required mobile VR baseline |
| Android/Quest | GLES3 | Required only while retained in the declared support matrix |
| iOS | Metal | Required iOS baseline |

**Pass condition:** every advertised target successfully compiles/builds under its declared API or is explicitly removed from the advertised support matrix.

## Gate E — VRChat workflow qualification

Required before 1.0.

- Current supported VRChat Worlds SDK can build representative Apex world content.
- PC custom avatar workflow builds/uploads with Apex-supported PC shaders.
- Generated mobile avatar fallback materials use SDK-provided `VRChat/Mobile` shaders.
- Android/Quest/iOS avatar fallback workflows do not rely on unsupported custom avatar shaders.
- Spectra `_Udon` global names remain compliant with the Apex integration contract.

**Pass condition:** representative world and avatar workflows complete without Apex-caused blocker errors.

## Gate F — VR/stereo and device behavior

Required before final platform claims and 1.0.

- Representative single-pass stereo scene renders correctly.
- No eye-dependent corruption from missing stereo setup macros.
- Instanced materials behave correctly where instancing is enabled.
- Lighting/shadow/reflection behavior is visually coherent on representative hardware.
- Mobile shader quality tiers resolve as intended.
- Transparent effects do not violate declared platform budgets without warnings/fallbacks.

**Pass condition:** retained manual/automated evidence exists for representative target hardware and no blocker is open.

## Gate G — Performance qualification

Required for 0.8.1 and 1.0.

- Variant counts recorded.
- Sampler/pass counts documented.
- Transparent/overdraw risk classified.
- PCVR baseline profiling recorded.
- Quest/Android baseline profiling recorded.
- iOS profiling recorded where required by the advertised support matrix.
- Mobile/Standard/High presets are tuned from measurement.
- Regression comparison exists against the 0.8.1 baseline during RC.

**Pass condition:** every production shader has a declared target tier and no known blocker violates that tier.

## Gate H — Material/API compatibility

Required for 0.9+ and 1.0.

- Public shader names are frozen.
- Public property names are frozen.
- Stable pass names used by tooling are frozen.
- Package names/dependency topology are frozen.
- Migration handles supported pre-1.0 material contracts.
- Migration dry-run exists.
- Migration is backup/undo-safe and does not silently destroy source materials.
- Deprecated paths have explicit migration or diagnostic behavior.

**Pass condition:** RC migration regression suite passes and no known data-loss defect remains.

## Gate I — SpectraOverdrive compatibility

Required for 0.7+ Spectra claims and 1.0.

- Apex renders neutrally when SpectraOverdrive is absent.
- Existing ABI 1.0 base fields remain compatible.
- Optional extension fields are versioned and optional.
- Unity and `_Udon` global paths are validated.
- Intensity, blackout, group/band routing, and safety caps behave consistently across Spectra-aware production shaders.

**Pass condition:** Spectra regression suite passes without requiring Spectra for ordinary Apex rendering.

## Gate J — Release packaging and documentation

Required for every public release candidate and 1.0.

- README version/state is correct.
- Changelog contains the release.
- Repository status is current.
- Installation guide is current.
- Shader reference is current.
- Platform compatibility matrix is current.
- Validation instructions are current.
- Performance budgets are current where applicable.
- Migration guide is current where applicable.
- Release archives are reproducible.
- Release commit is identified exactly.

For `1.0.0` additionally:

- `v1.0.0` tag points at the exact validated commit.
- GitHub release is created from that tag.
- release notes describe supported targets and known limitations.

**Pass condition:** release assets/docs correspond exactly to the validated code commit.

---

# Milestone gate map

| Milestone | Required gates |
|---|---|
| 0.3.4 | A + parity-specific B/C readiness contracts |
| 0.3.5 | A + expanded B/C readiness contracts |
| 0.3.6 | A + platform harness readiness for D |
| 0.4.0 | A + B + C + D + initial E/F |
| 0.4.1 | Re-run every gate affected by platform fixes |
| 0.4.2 | A + B + C + D + platform-profile portions of F/J |
| 0.5.0–0.5.2 | A + B + C, plus D regression sampling for new families |
| 0.6.0–0.6.1 | A + B + C + H development gates |
| 0.7.0–0.7.1 | A + B + C + I, with E where VRChat/Udon is exercised |
| 0.8.0 | A + B + C + G instrumentation |
| 0.8.1 | A + B + C + D + F + G |
| 0.9.0 | A + B + C + H + I + J; public contract freezes |
| 0.9.1 | A through J as applicable to full regression qualification |
| 0.9.2 | Full A–J final audit |
| 1.0.0 | Full A–J on the exact release commit |

---

# Failure policy

A failed required gate blocks the milestone.

Allowed responses to a failing gate are:

1. fix the defect and rerun the affected evidence;
2. remove the failing feature/platform from the declared support contract before the milestone closes; or
3. if the roadmap explicitly allows it, defer a non-blocking feature to the post-1.0 backlog.

What is not allowed: relabeling an unexecuted or failed gate as "designed," "expected," or "probably compatible" and treating it as passed.
