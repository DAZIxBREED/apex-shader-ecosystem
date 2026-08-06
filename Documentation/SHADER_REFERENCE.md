# Apex 0.2.0 Shader Reference

This reference describes the current baseline shaders. Property names are part of the 0.2 development contract and may still change before 1.0.

| Shader | Intended use | Passes | Unique samplers | Target |
|---|---|---:|---:|---:|
| `Apex/Core/Debug` | UV/vertex diagnostic display | 1 | 1 | 2.0 |
| `Apex/Avatar/Standard` | PCVR/Desktop avatar materials | 3 | 3 | 3.0 |
| `Apex/World/Standard` | Opaque/cutout environment PBR | 4 | 3 default, 4 with detail | 3.0 |
| `Apex/Water/PoolLite` | Transparent pools/liquids | 1 | 3 | 3.0 |
| `Apex/Fog/CardLite` | Transparent fog/haze cards | 1 | 2 | 2.0 |
| `Apex/FX/HologramLite` | Additive hologram effects | 1 | 2 | 3.0 |
| `Apex/Screens/VideoPanelLite` | Opaque video and emissive panels | 1 | 1 | 2.0 |
| `Apex/Toon/CharacterLite` | Stylized world/PC material shading | 2 | 3 | 3.0 |

## Shared packed mask

Apex packed material textures use:

- **R:** metallic
- **G:** ambient occlusion
- **B:** effect/SpectraOverdrive mask
- **A:** smoothness

Create this texture with **Apex > Texture Tools > Packed Mask Builder**.

## Shared SpectraOverdrive properties

Visual shaders expose:

- `_SpectraAmount`
- `_SpectraGroup`
- `_SpectraBandWeights`

The global bridge accepts intensity, color, four bands, beat, blackout, strobe, group ID, and show time. A local group of `0` listens as a broadcast group.

Use `_ApexSpectra...` names with ordinary Unity `Shader.SetGlobal*`. In VRChat/Udon, use the corresponding `_UdonApexSpectra...` names and set `_UdonApexSpectraActive` to `1`; VRChat only permits user-defined `VRCShader.SetGlobal` names with the `_Udon` prefix. The integration package follows the same pattern with `_UdonApexIntegrationActive`.

| VRChat/Udon global | Type | Meaning |
|---|---|---|
| `_UdonApexSpectraActive` | float | Set to `1` while the Udon adapter owns the bridge. |
| `_UdonApexSpectraIntensity` | float | Master reactive intensity. |
| `_UdonApexSpectraColor` | vector/color | Show color. |
| `_UdonApexSpectraBands` | vector | Four normalized bands. |
| `_UdonApexSpectraBeat` | float | Beat pulse. |
| `_UdonApexSpectraBlackout` | float | `1` suppresses Spectra-controlled output. |
| `_UdonApexSpectraStrobe` | float | Strobe pulse input. |
| `_UdonApexSpectraGroupId` | float | Active exact group; `0` is broadcast. |
| `_UdonApexSpectraTime` | float | Optional synchronized show time. |

Optional integrations use `_UdonApexAudioBands`, `_UdonApexAudioAmplitude`, `_UdonApexLightVolumeColor`, `_UdonApexLTCGIColor`, and `_UdonApexVRSLColor`. Set `_UdonApexIntegrationActive` to `1` while those values are owned by an Udon adapter.

## Avatar platform rule

`Apex/Avatar/Standard` is a custom PC shader. For a VRChat Android, Quest, or iOS avatar, create a second material with **Apex > Mobile Avatar Fallback Builder** and assign the generated SDK-provided `VRChat/Mobile` material to the mobile avatar variant.

The Avatar and Toon baselines deliberately expose `_MainTex`, `_Color`, `_BumpMap`, `_BumpScale`, `_MetallicGlossMap`, `_Metallic`, and `_Glossiness` where applicable. They also declare the exact `VRCFallback="toonstandard"` tag so supported same-named values can survive VRChat shader fallback instead of dropping to unrelated defaults.

## Debug modes

Shaders that expose `_DebugMode` use:

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
