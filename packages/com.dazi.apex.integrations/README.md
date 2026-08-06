# Apex Integrations

Dependency-free global-uniform interop boundaries.

Author: **DAZIxBREED**
Version: **0.3.0**
Compatibility: **All Apex visual targets when a driver populates the globals**
Pipeline: **Unity 2022.3.22f1 Built-in Render Pipeline, handwritten vertex/fragment HLSL/CG**

## Implemented in 0.3.0

- Four audio bands plus amplitude
- Dual `_Apex...` and VRChat-safe `_UdonApex...` input names with an explicit Udon ownership flag
- Light-volume color multiplier
- LTCGI-style emission input
- VRSL-style emission input
- Canonical SpectraOverdrive compatibility include

## Dependencies

- `com.dazi.apex.core`
- `com.dazi.apex.spectraoverdrive`

## Validation boundary

Static repository validation is included. Unity shader compilation and representative device/client tests remain required before a production release.
