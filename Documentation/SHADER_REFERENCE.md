# Apex 0.3.4 Shader Reference

Property names remain pre-1.0 development contracts, but the SpectraOverdrive global ABI is separately versioned and frozen at 1.0.

| Shader | Intended use | Ordered pass contract | Unique samplers | Target |
|---|---|---|---:|---:|
| `Apex/Core/Debug` | UV/vertex diagnostic display | `FORWARD_BASE` | 1 | 2.0 |
| `Apex/Avatar/Standard` | PCVR/Desktop avatar materials | `FORWARD_BASE`, `FORWARD_ADD`, `SHADOW_CASTER` | 3 | 3.0 |
| `Apex/World/Standard` | Opaque/cutout environment PBR | `FORWARD_BASE`, `FORWARD_ADD`, `SHADOW_CASTER`, `META` | 3 default, 4 with detail | 3.0 |
| `Apex/World/VertexBlendLite` | Two-layer vertex-red environment blend | `FORWARD_BASE`, `FORWARD_ADD`, `SHADOW_CASTER`, `META` | 6 | 3.0 |
| `Apex/Water/PoolLite` | Transparent pools/liquids | `FORWARD_BASE` | 3 | 3.0 |
| `Apex/Water/OpaqueMobile` | Opaque low-overdraw animated water | `FORWARD_BASE`, `FORWARD_ADD` | 3 | 3.0 |
| `Apex/Fog/CardLite` | Transparent fog/haze cards | `UNLIT_FOG` | 2 | 2.0 |
| `Apex/FX/HologramLite` | Additive hologram effects | `HOLOGRAM` | 2 | 3.0 |
| `Apex/FX/DissolveCutout` | Lit cutout dissolve with edge emission | `FORWARD_BASE`, `FORWARD_ADD`, `SHADOW_CASTER`, `META` | 4 | 3.0 |
| `Apex/Screens/VideoPanelLite` | Opaque video and emissive panels | `VIDEO_PANEL` | 1 | 2.0 |
| `Apex/Screens/LEDPanelLite` | Procedural LED/pixel-grid video panel | `LED_PANEL` | 1 | 2.0 |
| `Apex/Toon/CharacterLite` | Stylized world/PC material shading | `FORWARD_BASE`, `FORWARD_ADD`, `SHADOW_CASTER`, `META` | 3 | 3.0 |

## 0.3.4 parity rules

- Alpha-clipped Avatar, World Standard, and Toon shadows use base alpha × material alpha × vertex alpha, matching the visible surface path.
- World Standard Meta output carries vertex tint/alpha and its detail layer.
- VertexBlendLite Meta emission uses the blended packed-mask B channel, matching runtime effect-mask emission.
- Dissolve forward, additive, shadow, and Meta paths share `ApexDissolveClipValue`; forward and Meta edge emission share `ApexDissolveEdge`.
- Toon now has additional-light and Meta coverage instead of silently omitting those paths.

Avatar intentionally has no Meta pass because it is the PC avatar shader rather than a baked world material. PoolLite remains transparent ForwardBase-only. OpaqueMobile water remains a dynamic ForwardBase+ForwardAdd material rather than claiming static baked/shadow behavior.

## Quality profiles

World, Avatar, Toon, Vertex Blend, and Dissolve materials use mutually exclusive local keywords:

- no quality keyword: **Standard**
- `_APEX_QUALITY_MOBILE`: disables environment reflection sampling
- `_APEX_QUALITY_HIGH`: enables the high specular-energy path

Use **Apex > Materials > Quality** rather than changing keywords by hand. Mobile builds strip High variants automatically.

## Shared packed mask

- **R:** metallic
- **G:** ambient occlusion
- **B:** effect/SpectraOverdrive mask
- **A:** smoothness

Create it with **Apex > Texture Tools > Packed Mask Builder**.

## SpectraOverdrive

Visual shaders expose `_SpectraAmount`, `_SpectraGroup`, and `_SpectraBandWeights`. Drivers use ordinary `_ApexSpectra...` globals or `_UdonApexSpectra...` globals in VRChat. See the [ABI document](../packages/com.dazi.apex.spectraoverdrive/Documentation/ABI.md).

## Avatar platform rule

`Apex/Avatar/Standard` is a custom PC shader. Use **Apex > Mobile Avatar** tools to generate SDK-provided `VRChat/Mobile` materials for Android, Quest, and iOS avatar variants.

## Debug modes

| Value | View |
|---:|---|
| 0 | Final lighting |
| 1 | Albedo |
| 2 | World normal |
| 3 | Metallic / occlusion / smoothness |
| 4 | UV0 |
| 5 | Vertex color |
| 6 | Emission |
| 7 | Effect mask |
| 8 | Baked GI |
