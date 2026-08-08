# Apex 0.3.1 Shader Reference

Property names remain pre-1.0 development contracts, but the SpectraOverdrive global ABI is now separately versioned and frozen at 1.0.

| Shader | Intended use | Passes | Unique samplers | Target |
|---|---|---:|---:|---:|
| `Apex/Core/Debug` | UV/vertex diagnostic display | 1 | 1 | 2.0 |
| `Apex/Avatar/Standard` | PCVR/Desktop avatar materials | 3 | 3 | 3.0 |
| `Apex/World/Standard` | Opaque/cutout environment PBR | 4 | 3 default, 4 with detail | 3.0 |
| `Apex/World/VertexBlendLite` | Two-layer vertex-red environment blend | 4 | 6 | 3.0 |
| `Apex/Water/PoolLite` | Transparent pools/liquids | 1 | 3 | 3.0 |
| `Apex/Water/OpaqueMobile` | Opaque low-overdraw water | 2 | 3 | 3.0 |
| `Apex/Fog/CardLite` | Transparent fog/haze cards | 1 | 2 | 2.0 |
| `Apex/FX/HologramLite` | Additive hologram effects | 1 | 2 | 3.0 |
| `Apex/FX/DissolveCutout` | Lit cutout dissolve with edge emission | 4 | 4 | 3.0 |
| `Apex/Screens/VideoPanelLite` | Opaque video and emissive panels | 1 | 1 | 2.0 |
| `Apex/Screens/LEDPanelLite` | Procedural LED/pixel-grid video panel | 1 | 1 | 2.0 |
| `Apex/Toon/CharacterLite` | Stylized world/PC material shading | 2 | 3 | 3.0 |

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

Visual shaders expose `_SpectraAmount`, `_SpectraGroup`, and `_SpectraBandWeights`. Drivers use ordinary `_ApexSpectra...` globals or `_UdonApexSpectra...` globals in VRChat.

ABI 1.0 adds optional safety controls:

| Field | Meaning |
|---|---|
| `_ApexSpectraSafetyActive` / `_UdonApexSpectraSafetyActive` | Enables the safety vector. |
| `_ApexSpectraSafety` / `_UdonApexSpectraSafety` X | Maximum accepted intensity. |
| Y | Strobe enabled when `>= 0.5`. |
| Z | Maximum accepted strobe pulse. |
| W | Reserved; write zero. |

See the full [ABI document](../packages/com.dazi.apex.spectraoverdrive/Documentation/ABI.md).

## Avatar platform rule

`Apex/Avatar/Standard` is a custom PC shader. Use **Apex > Mobile Avatar** tools to generate SDK-provided `VRChat/Mobile` materials for Android, Quest, and iOS avatar variants. Batch generation writes `.apex-mobile-pairing.json` records beside the generated material.

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
