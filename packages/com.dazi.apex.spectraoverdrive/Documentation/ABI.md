# SpectraOverdrive Shader ABI 1.0

Apex 0.3.0 freezes the first versioned shader-global contract. Drivers may use ordinary Unity globals (`_Apex...`) or VRChat Udon-safe globals (`_UdonApex...`). Set `_UdonApexSpectraActive` to `1` when Udon owns the bridge.

## Required scalar/vector fields

| Purpose | Unity global | Udon global |
|---|---|---|
| Driver active | implicit | `_UdonApexSpectraActive` |
| Intensity | `_ApexSpectraIntensity` | `_UdonApexSpectraIntensity` |
| RGB color | `_ApexSpectraColor` | `_UdonApexSpectraColor` |
| Four bands | `_ApexSpectraBands` | `_UdonApexSpectraBands` |
| Beat pulse | `_ApexSpectraBeat` | `_UdonApexSpectraBeat` |
| Blackout | `_ApexSpectraBlackout` | `_UdonApexSpectraBlackout` |
| Strobe pulse | `_ApexSpectraStrobe` | `_UdonApexSpectraStrobe` |
| Group ID | `_ApexSpectraGroupId` | `_UdonApexSpectraGroupId` |
| Show time | `_ApexSpectraTime` | `_UdonApexSpectraTime` |
| Safety enabled | `_ApexSpectraSafetyActive` | `_UdonApexSpectraSafetyActive` |
| Safety policy | `_ApexSpectraSafety` | `_UdonApexSpectraSafety` |

`Safety` is a four-component vector:

- **X:** maximum accepted global intensity.
- **Y:** strobe enabled (`>= 0.5`) or disabled.
- **Z:** maximum accepted strobe pulse.
- **W:** reserved and must be written as zero.

When safety is not active, the bridge uses `(1, 1, 1, 0)` so existing drivers retain their 0.2 behavior. Blackout is always applied after tint and emission response.

## Compatibility rule

ABI 1.x additions must use new fields with neutral defaults. Existing field meaning and type may not change before ABI 2.0.
