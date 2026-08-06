# Changelog

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
