# SpectraOverdrive Compatibility Contract

Apex packages are compatible with SpectraOverdrive through a minimal material uniform bridge.

## Uniforms

```hlsl
float _ApexSpectraIntensity;
float4 _ApexSpectraColor;
float _ApexSpectraBeat;
float _ApexSpectraBlackout;
float _ApexSpectraStrobe;
float _ApexSpectraGroupId;
```

## Behavior

- `Intensity` drives general energy.
- `Color` tints or adds reactive emission.
- `Beat` drives musical pulse.
- `Blackout` fades output down for emergency or operator blackout.
- `Strobe` is a safe shader-side pulse input, not a guarantee of high-frequency flashing.
- `GroupId` can be used by SpectraOverdrive drivers to target fixture/material groups.

## Safety

All values default safely. Apex must compile without SpectraOverdrive installed.
