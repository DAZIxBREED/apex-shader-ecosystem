# Changelog

## 0.3.3 — Stress-scene and pass-parity hardening

### Added

- Validation-scene profile expansion for Standard, Mobile, and High quality states.
- Detail, alpha-cutout, and combined detail+alpha stress fixtures where supported.
- Generated checker-alpha texture for visible cutout validation.
- Generated vertex-gradient mesh for `Apex/World/VertexBlendLite` so both blend layers are exercised.
- `ApexValidationSceneManifest.json` with fixture/material/profile/pass/keyword coverage.
- Pass names and total requested pass compiles in `ApexShaderCompilerReport.json`.
- Repository validation requiring every ShaderLab pass to be named and preserving the 0.3.3 stress-harness contracts.

### Fixed

- `Apex/World/Standard` Meta pass now applies the detail layer and alpha cutout so baked albedo/coverage matches the forward material path.

### Changed

- Compiler auditing now requests the same alpha/detail stress profiles represented in the generated validation scene.
- All twelve UPM packages, direct Apex dependency pins, repository metadata, and Core HLSL version constants are aligned to `0.3.3`.

### Validation boundary

- Hosted repository CI still validates source structure, package/dependency consistency, deterministic Unity metadata, and reproducible UPM archives.
- The generated stress scene and synchronous compiler audit require Unity 2022.3.22f1.
- Direct3D 11, Vulkan/GLES3, Metal, VRChat SDK builds, stereo/device rendering, and profiling remain target-runtime validation work.

## 0.3.2 — Shader compiler audit and validation hardening

### Added

- Shared required-shader catalog for editor validation.
- Synchronous Unity shader compiler audit using `ShaderUtil.CompilePass` and `ShaderUtil.GetShaderMessages`.
- Standard, Mobile, High, and Standard+Detail audit profiles where those local shader keywords exist.
- Machine-readable `ApexShaderCompilerReport.json` output with Unity version, build target, graphics API, compiler platform, source file/line, severity, profile, and pass counts.
- Shared AssetDatabase-safe generated-folder utility for Apex editor tooling.

### Changed

- Package Doctor full/batch validation now incorporates compiler-audit errors and warnings.
- Mobile Avatar Fallback Builder and Shader Variant Usage Report now share the same generated asset-folder implementation.
- Core HLSL version constants now report `0.3.2` instead of remaining at the old 0.3.0 patch value.
- All twelve UPM packages and direct Apex dependency pins are aligned to `0.3.2`.

### Validation boundary

- Hosted repository CI validates source structure, package/dependency consistency, deterministic Unity metadata, and reproducible UPM archives.
- The new compiler audit requires Unity 2022.3.22f1 and runs through the Validation Project; hosted CI still does not contain a licensed Unity editor.
- Direct3D 11, Vulkan/GLES3, Metal, VRChat SDK builds, stereo/device rendering, and profiling remain runtime validation work.

## 0.3.1 — CI and editor-tool hardening

### Fixed

- Removed trailing whitespace from the Dissolve Cutout and Vertex Blend sample materials, allowing the repository whitespace gate to complete instead of failing before package validation.
- Corrected Git installation documentation that referenced a nonexistent `v0.3.0` tag.
- Mobile Avatar Fallback Builder now ensures destination folders exist in Unity's AssetDatabase before creating materials and pairing records.
- Shader Variant Usage Report now creates its generated output folder through the AssetDatabase instead of relying on a raw filesystem directory.

### Changed

- Updated GitHub validation and packaging workflows to `actions/checkout@v6` and `actions/setup-python@v6` for Node 24 compatibility.
- Bumped all twelve UPM packages and all direct Apex dependency pins to `0.3.1`.
- Current pre-alpha Git installation examples use `main`; exact commit pinning is recommended for reproducible projects until version tags are published.

### Validation

- GitHub static validation passes on the 0.3.1 branch.
- Unity metadata regeneration is reproducible with no repository diff.
- All twelve UPM archives build twice with identical SHA-256 output.
- Unity 2022.3.22f1 shader/C# compilation and device validation remain required.

## 0.3.0 — Quality tiers, validation project, and second shader families

### Added

- Core local quality profiles and reflection-probe environment specular.
- World two-layer vertex blend shader, opaque mobile water, lit dissolve/cutout FX, and procedural LED video panel.
- SpectraOverdrive shader ABI 1.0 with optional intensity/strobe safety limits and neutral backward-compatible defaults.
- Material quality profile commands and Avatar skin, cloth, hair, and hard-surface presets.
- Batch mobile-avatar fallback generation with source/fallback JSON pairing records.
- Apex-only build-time shader variant stripping and project shader-keyword usage reporting.
- Live Unity/Udon global bridge diagnostics.
- Automated validation scene generation with directional, point, and spot lights plus a realtime reflection probe.
- Dedicated Unity 2022.3.22f1 `ValidationProject` with a batch-mode entry point.

### Changed

- World, Avatar, and Toon base shaders can consume reflection probes outside the Mobile quality tier.
- Package Doctor validates all new shader families, contradictory quality keywords, and expensive mobile vertex-blend usage.
- Documentation now treats Unity compilation/device testing as an executable matrix rather than a future concept.

### Validation still required

- Clean Unity import and shader compilation on Direct3D 11, Vulkan/GLES3, and Metal.
- VRChat SDK world and avatar build tests.
- Single-pass stereo, device profiling, and visual comparison captures.

## 0.2.0 — Foundation hardening and first distinct shader families

### Added

- Core packed-surface include, shadow include, lightmap/SH sampling, forward direct/ambient lighting, additional-light evaluation, stereo/instancing support, math/color helpers, and expanded debug views.
- PC Avatar shader with packed PBR, soft-wrap lighting, rim, alpha clip, additional lights, shadows, SpectraOverdrive grouping/band weights, Standard-compatible property names, and an explicit `toonstandard` VRChat fallback tag.
- Lightmapped World shader with detail keyword, additional lights, shadows, alpha clip, and a Meta pass for baked albedo/emission.
- Dual-normal Fresnel/foam water, layered card fog, scanline/flicker/glitch hologram, `_MainTex` video panel grading, and banded toon lighting with Standard-compatible fallback properties.
- SpectraOverdrive four-band and group-routing data with both ordinary Unity globals and VRChat-safe `_Udon` global names.
- Generic dependency-free audio/light-volume/LTCGI/VRSL global hooks with dual Unity and VRChat-safe `_Udon` inputs.
- Mobile Avatar Fallback Builder, Packed Mask Builder, and expanded Package Doctor with shader-error, texture-import, transparency, instancing, and mobile-avatar compatibility checks.
- Git/UPM installation guide, shader reference, platform validation matrix, and an importable Package Manager sample entry for the quick-start materials.

### Changed

- Corrected the compatibility contract: custom VRChat mobile avatar shaders are not supported; Apex Tools generates materials using SDK-provided mobile shaders instead.
- Upgraded package descriptions and documentation from scaffold language to implemented 0.2.0 behavior.
- Integrations now explicitly depends on the SpectraOverdrive bridge it includes.

### Validation still required

- Unity 2022.3.22f1 import and shader compilation.
- Windows, Android/Quest, and iOS world build tests.
- PC avatar and generated mobile fallback upload tests.

## 0.1.0 — Initial clean-room repository

- Created the twelve-package monorepo, baseline HLSL files, package metadata, static validator, release archive builder, examples, and initial documentation.
