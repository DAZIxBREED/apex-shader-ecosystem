# Apex Shader Ecosystem — Locked Roadmap to 1.0

This document is the development contract for the Apex Shader Ecosystem from the current `0.3.3` pre-alpha through the `1.0.0` production release.

The sequence, milestone purposes, and exit gates below are intentionally fixed. New ideas do not displace these milestones. Emergency patch releases may be inserted only for blocker fixes, security issues, build breakage, or data-loss risks; they must not expand scope or change the purpose of later milestones.

## North-star definition

Apex 1.0 is a modular, handwritten HLSL/CG shader ecosystem for Unity 2022.3.22f1 Built-in Render Pipeline and VRChat-oriented content with:

- independent UPM packages for Core, Avatar, World, Water, Fog, FX, Screens, Toon, Tools, Examples, Integrations, and SpectraOverdrive
- custom world shaders designed and validated for Windows PCVR/Desktop, Android/Quest, and iOS
- PC custom avatar shaders plus VRChat SDK-provided mobile avatar fallback generation for Android/Quest/iOS
- stable material/property contracts and migration support
- stable SpectraOverdrive interoperability
- reproducible packages and deterministic Unity metadata
- documented performance budgets and mobile quality profiles
- executable validation evidence rather than compatibility claims based on source inspection alone

## Locked development rules

1. **No skipped validation gates.** A version is not complete because code exists; its required gates must pass.
2. **All twelve package manifests move together.** `VERSION`, every Apex package version, internal Apex dependency pins, repository metadata, changelog, docs, and Core HLSL version macros must agree.
3. **Patch releases harden; milestone releases expand.** `0.x.y` patch work is bug fixing, parity, validation, migration, performance, or tooling hardening unless the roadmap explicitly assigns a feature to that patch.
4. **No custom mobile-avatar shader claim.** VRChat mobile avatars use SDK-provided mobile shaders through the Apex fallback workflow.
5. **No breaking SpectraOverdrive ABI change before 1.0.** Backward-compatible extension fields may be added only when versioned and optional.
6. **No shader-family monolith.** New capabilities remain focused shaders/includes rather than one giant shader with hundreds of toggles.
7. **No platform claim without evidence.** Static CI is not proof of Unity compilation, VRChat SDK success, stereo correctness, or device performance.
8. **No new top-level Apex package before 1.0 unless required by an existing milestone.** The twelve-package architecture is frozen for the 1.0 runway.
9. **No URP/HDRP migration before 1.0.** The 1.0 baseline remains Unity 2022.3.22f1 Built-in Render Pipeline.
10. **Post-1.0 ideas go to backlog.** They do not interrupt the locked sequence unless they fix a blocker in the current milestone.

---

# Phase 0 — Foundation closure

## Apex 0.3.4 — Pass-parity hardening

**Purpose:** make the existing shader families internally correct before broader platform qualification.

### Scope

- Audit ForwardBase, ForwardAdd, ShadowCaster, and Meta parity across every lit Apex shader.
- Fix alpha-clip parity between visible, shadow, and Meta paths.
- Fix emission/detail parity where a Meta pass exists.
- Ensure every pass has an explicit stable pass name.
- Record expected pass sets per shader in the validation catalog.
- Extend static validation so required pass contracts cannot silently disappear.
- Add stress materials for parity-sensitive paths not covered in 0.3.3.

### Exit gate

- Static CI green.
- All expected ShaderLab pass names present.
- No known forward/shadow/Meta mismatch in the current shader set.
- Validation scene and compiler report describe the same stress profiles.

---

## Apex 0.3.5 — Lighting, GI, instancing, and stereo hardening

**Purpose:** close correctness gaps in shared Core rendering behavior before platform execution.

### Scope

- Validate directional, point, and spot lighting contracts.
- Harden baked lightmap and SH fallback behavior.
- Harden reflection-probe sampling and quality-tier behavior.
- Validate fog application in base/additive/unlit paths.
- Audit GPU instancing macros and material instancing defaults.
- Audit single-pass stereo macro placement in every vertex/fragment path.
- Add validation-scene fixtures for baked GI, realtime lights, reflection probes, and stereo-sensitive materials.
- Add machine-readable scene expectations for lighting/probe/stereo coverage.

### Exit gate

- Static CI green.
- Compiler harness covers every required shader and quality profile.
- No known missing stereo setup or instancing contract.
- Validation scene contains explicit lighting/GI/probe test groups.

---

## Apex 0.3.6 — Platform execution harness

**Purpose:** make platform qualification repeatable instead of manual and anecdotal.

### Scope

- Add command-line validation entry points for target/API runs.
- Add target result manifests with Unity version, build target, graphics API, shader compiler report, validation-scene manifest, and log location.
- Add result aggregation for multiple target/API runs.
- Add expected target matrix definitions for:
  - Windows / Direct3D 11
  - Android/Quest / Vulkan
  - Android/Quest / GLES3 fallback where supported/needed
  - iOS / Metal
- Add failure classification for compile, build, shader, scene, and runtime-validation failures.
- Add VRChat SDK build hooks where the SDK/environment is available without making the repository depend on the SDK package at runtime.

### Exit gate

- Static CI green.
- A platform result can be produced deterministically from a validation invocation.
- Missing target evidence is clearly reported as missing, never as passing.

---

# Phase 1 — Platform qualification

## Apex 0.4.0 — First cross-platform qualification

**Purpose:** execute the platform matrix for real.

### Scope

Run and retain evidence for the 0.3.6 harness on available target environments:

- Windows PCVR/Desktop — Direct3D 11
- Android/Quest — Vulkan
- Android/Quest — GLES3 where retained as a supported fallback
- iOS — Metal
- VRChat world build validation on supported target platforms
- PC custom avatar build/upload validation
- generated SDK mobile avatar fallback build validation
- single-pass stereo checks on representative VR hardware

No new shader family is added in 0.4.0.

### Exit gate

- Every supported target has a retained result record.
- No shader compiler errors on supported target APIs.
- No pink validation fixtures.
- Build failures are either fixed or explicitly classified as unsupported before the milestone can close.

---

## Apex 0.4.1 — Platform fix pack

**Purpose:** repair defects found by 0.4.0 rather than hiding them behind platform exceptions.

### Scope

- Fix target-specific shader compilation failures.
- Fix precision issues and unsupported mobile constructs.
- Fix stereo, reflection, fog, lightmap, and shadow discrepancies found on device.
- Fix VRChat build/upload workflow defects.
- Add regressions for every platform-specific bug fixed.

### Exit gate

- All 0.4.0 blocker defects closed or intentionally removed from the support matrix with documentation.
- Re-run affected target matrices successfully.

---

## Apex 0.4.2 — Platform profile freeze

**Purpose:** turn validated platform behavior into stable quality/build profiles used by later releases.

### Scope

- Freeze named quality profiles for PC High, PC Balanced, Quest Balanced, Quest Performance, Android, and iOS.
- Freeze shader-variant stripping rules for supported targets.
- Freeze mobile texture/sampler/pass recommendations for the current families.
- Add target-aware material validation warnings.
- Publish the first evidence-backed platform compatibility table.

### Exit gate

- Platform profiles are reproducible and documented.
- High-only variants are excluded from mobile builds where intended.
- The 0.4.x support matrix is green enough to permit shader-family expansion.

---

# Phase 2 — Production shader families

## Apex 0.5.0 — Character and world family expansion

**Purpose:** move from baseline shaders to the production character/world set.

### Avatar / character scope

- Skin-focused shader path.
- Hair-focused shader path.
- Eye-focused shader path.
- Cloth/fabric-focused path.
- Glass/transparent accessory path where viable under platform budgets.
- Hard-surface/metal accessory path.
- Preserve VRChat fallback-compatible property naming where applicable.

### World scope

- Production Standard environment path.
- 3/4-layer or bounded multi-layer vertex blend path.
- Terrain/triplanar material path.
- Decal/detail workflow that does not require unsupported mobile techniques.
- Interior/lightmapped material presets.

### Exit gate

- Each added shader has package docs, sample material, validation fixture, compiler-audit coverage, and platform budget classification.
- No regression of 0.4.2 supported target matrix.

---

## Apex 0.5.1 — Water, fog, FX, screens, and toon family expansion

**Purpose:** complete the production visual family set.

### Water

- Pool.
- Ocean/open water.
- River/flowing water.
- Waterfall/sheet water.
- Opaque mobile water.
- Bounded depth/intersection foam where platform-feasible.

### Fog

- Fog card.
- Ground fog.
- Height fog.
- Localized haze/smoke volume approximation suitable for BIRP/mobile constraints.

### FX

- Hologram.
- Dissolve/cutout.
- Shield/force field.
- Portal/energy surface.

### Screens

- Video panel.
- LED wall.
- Projection/display surface.
- CRT/glitch display.

### Toon

- Character.
- World.
- Face/skin-focused controls.
- Hair controls.
- Outline implementation only if it passes mobile/platform budgets; otherwise PC-only with documented fallback.

### Exit gate

- Every production family has examples, docs, validation fixtures, compiler coverage, and platform tier classification.
- No unsupported technique is silently enabled on mobile.

---

## Apex 0.5.2 — Shader-family stabilization

**Purpose:** stop adding families and make the 0.5 shader set dependable.

### Scope

- Cross-family property naming cleanup.
- Remove duplicate math/sampling logic into appropriate shared includes.
- Fix shader-family regressions from 0.5.0/0.5.1.
- Stabilize pass naming and fallback behavior.
- Expand material migration rules for renamed pre-1.0 properties.
- Re-run the full platform matrix on representative families.

### Exit gate

- Production shader list is feature-complete for 1.0.
- No new shader family after 0.5.2 unless required to fix a 1.0 blocker.

---

# Phase 3 — Creator authoring system

## Apex 0.6.0 — Material authoring UX

**Purpose:** make Apex usable without requiring creators to understand the HLSL internals.

### Scope

- Custom ShaderGUI/MaterialEditor experience for production shaders.
- Grouped controls and contextual help.
- Automatic keyword management.
- Platform quality selector.
- Packed-mask visualization and channel hints.
- Texture import warnings.
- One-click quality presets.
- Avatar look presets.
- World/water/fog/FX/screen/toon presets.
- Inline platform-cost warnings.
- Clear mobile-avatar fallback actions.

### Exit gate

- Common authoring tasks do not require manual keyword editing.
- Invalid contradictory quality states cannot be produced through the Apex inspector.

---

## Apex 0.6.1 — Migration and material reliability

**Purpose:** protect projects from pre-1.0 material contract changes.

### Scope

- Versioned Apex material metadata.
- Material upgrader/migrator.
- Dry-run migration report.
- Backup/undo-safe migration behavior.
- Property rename/copy rules.
- Shader replacement rules where required.
- Batch project migration.
- Regression samples for old Apex material versions.

### Exit gate

- Supported 0.x materials can be upgraded automatically or receive an explicit blocking diagnostic.
- Migration never silently destroys source materials.

---

# Phase 4 — SpectraOverdrive-native integration

## Apex 0.7.0 — SpectraOverdrive-native shader layer

**Purpose:** make Apex the preferred shader layer for SpectraOverdrive without making Apex unusable on its own.

### Scope

- Preserve the existing SpectraOverdrive ABI 1.0 base contract.
- Add backward-compatible optional extension fields only when versioned.
- Fixture/group addressing.
- Beat phase and bounded band data.
- Global intensity and blackout.
- Palette/color routing.
- Cue/transition-compatible values.
- Strobe safety limits.
- World-zone/group routing where feasible.
- Neutral behavior when SpectraOverdrive is absent.
- Apex/Spectra diagnostic monitor showing resolved Unity/Udon values.

### Exit gate

- Apex renders correctly with Spectra disabled/uninstalled.
- ABI 1.0 consumers continue working.
- New extension fields are optional and version-detectable.

---

## Apex 0.7.1 — Integration hardening

**Purpose:** prove Spectra integration survives real world usage.

### Scope

- Validate Unity global and `_Udon` global paths.
- Validate blackout/intensity/safety behavior across shader families.
- Validate group/band routing.
- Stress late joiner/current-state scenarios in VRChat-oriented test worlds where possible.
- Add diagnostics for missing/malformed Spectra drivers.
- Fix integration regressions without changing the stable base ABI.

### Exit gate

- No shader requires Spectra to render normally.
- Safety caps and blackout behavior are consistent across all Spectra-aware production shaders.

---

# Phase 5 — Performance and mobile qualification

## Apex 0.8.0 — Performance architecture

**Purpose:** make performance measurable and enforceable.

### Scope

- Shader variant counts by family/profile.
- Pass counts and sampler counts.
- Transparent/overdraw classifications.
- Mobile precision audit (`half`/`fixed` where safe).
- Reflection/specular cost audit.
- LOD/distance material substitution strategy where useful.
- Aggressive target-aware variant stripping.
- Texture packing recommendations.
- Material batching/instancing diagnostics.
- Performance report generation for validation scenes.

### Exit gate

- Every production shader has a documented performance tier and platform budget.
- Build-time stripping/reporting is deterministic.

---

## Apex 0.8.1 — Performance qualification

**Purpose:** use real hardware measurements to tune the production set.

### Scope

- Profile representative scenes on PCVR hardware.
- Profile representative Quest/Android devices.
- Profile iOS where hardware/build access is available.
- Measure transparent hot spots and screen/water/fog costs.
- Tune Mobile/Standard/High presets using evidence.
- Fix avoidable shader/compiler regressions found by profiling.
- Record baseline frame/GPU measurements for the release candidate phase.

### Exit gate

- No known production shader violates its declared target tier without a documented warning/fallback.
- Mobile presets are based on measured behavior, not assumptions.

---

# Phase 6 — Release candidate freeze

## Apex 0.9.0 — RC1 / public contract freeze

**Purpose:** freeze the public surface and stop feature development.

### Freeze at 0.9.0

- Public shader names.
- Public material property names.
- Stable pass names used by tools/integrations.
- Package names and package dependency topology.
- SpectraOverdrive 1.x compatibility rules.
- Quality profile names.
- Material migration contract.

### Scope

- Remove experimental/dead paths.
- Mark deprecated properties/shaders with migration paths.
- Complete shader/material reference docs.
- Complete per-platform install and validation docs.
- Produce representative example materials/scenes for every production family.
- Freeze the 1.0 feature list.

### Exit gate

- No planned feature remains for 1.0.
- Any change after RC1 must be a bug fix, compatibility fix, documentation fix, migration fix, or performance fix.

---

## Apex 0.9.1 — RC2 / regression and compatibility pass

**Purpose:** attack regressions under frozen public contracts.

### Scope

- Full platform compiler/build matrix.
- Full validation-scene matrix.
- VRChat world build validation.
- PC avatar and mobile fallback validation.
- Material migration regression suite.
- Spectra interoperability regression suite.
- Performance regression comparison against 0.8.1 baselines.

### Exit gate

- No open blocker or critical defect.
- No known data-loss migration defect.
- No unsupported platform is still advertised as supported.

---

## Apex 0.9.2 — RC3 / final release audit

**Purpose:** prove the exact release candidate is shippable.

### Scope

- Clean-clone validation.
- Fresh Unity 2022.3.22f1 import.
- All twelve packages install independently where dependency rules allow.
- Exact-commit reproducibility check.
- Deterministic metadata check.
- Deterministic package archive check.
- License/header/documentation audit.
- Release notes.
- Upgrade-from-supported-0.x test.
- Final target matrix replay.

### Exit gate

All 1.0 release gates in `Documentation/RELEASE_GATES.md` must be green. Any blocker resets RC3 evidence after the fix.

---

# Apex 1.0.0 — Production release

Apex 1.0.0 ships only when RC3 evidence is green and retained.

## Required 1.0 state

- Unity 2022.3.22f1 Built-in Render Pipeline baseline is documented and validated.
- Supported PC world/PCVR shader paths compile and render correctly on the declared PC graphics API baseline.
- Supported Android/Quest world paths compile, build, and meet declared performance tiers.
- Supported iOS world paths compile/build on Metal and meet declared compatibility requirements.
- PC custom avatar workflow is validated.
- VRChat SDK mobile avatar fallback workflow is validated.
- Single-pass stereo has representative validation evidence.
- Lighting, shadow, Meta, lightmap/SH, fog, reflection-probe, instancing, and quality-profile contracts are regression-tested.
- Production shader families are complete and frozen.
- Material authoring UI is production-usable.
- Material migration path is production-usable.
- SpectraOverdrive integration is stable and optional.
- All twelve UPM packages are version `1.0.0` with aligned dependency pins.
- CI is green.
- Release archives are reproducible.
- `v1.0.0` tag and GitHub release are created from the exact validated commit.
- Release notes, installation guide, shader reference, platform matrix, migration guide, and performance budgets are complete.

## 1.0 support contract

After `1.0.0`, breaking public shader/property/package/ABI changes require a major-version policy decision. Normal `1.x` work should preserve material compatibility wherever technically possible.

---

# Explicitly post-1.0 backlog

These are valuable, but they do not interrupt the locked 1.0 runway:

- URP support.
- HDRP support.
- Unity versions beyond the frozen 2022.3.22f1 baseline as a primary target.
- Compute-driven shader features.
- Tessellation/geometry-shader feature families.
- New top-level Apex packages.
- Major SpectraOverdrive ABI break/rewrite.
- Large experimental rendering systems that require abandoning the mobile/BIRP constraints.
- Optional non-VRChat engine integrations that do not contribute directly to the 1.0 support contract.

---

# Canonical release sequence

The planned sequence is:

```text
0.3.3  current baseline
0.3.4  pass parity
0.3.5  lighting/GI/stereo
0.3.6  platform execution harness
0.4.0  first platform qualification
0.4.1  platform fixes
0.4.2  platform profile freeze
0.5.0  character/world production families
0.5.1  water/fog/FX/screens/toon production families
0.5.2  shader-family stabilization
0.6.0  material authoring UX
0.6.1  migration/material reliability
0.7.0  SpectraOverdrive-native integration
0.7.1  integration hardening
0.8.0  performance architecture
0.8.1  performance qualification
0.9.0  RC1 / public contract freeze
0.9.1  RC2 / regression qualification
0.9.2  RC3 / final release audit
1.0.0  production release
```

Emergency patch releases may be inserted only to fix blockers in the active milestone. They do not alter the scope or ordering above.
