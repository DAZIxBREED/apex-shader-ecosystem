# Apex Core

Shared HLSL foundation, structs, math, packing, debug, platform gates, and VRChat/BIRP helpers.

Author: **DAZIxBREED**  
Version: **0.1.0**  
Minimum targets: **iOS, Quest, Android, PCVR**  
Render pipeline: **Unity Built-in Render Pipeline, handwritten vertex/fragment HLSL/CG**

## Dependencies

- none

## SpectraOverdrive compatibility

This package is designed to remain compatible with SpectraOverdrive. Visual packages consume the shared SpectraOverdrive bridge from `com.dazi.apex.spectraoverdrive`; optional third-party systems remain isolated in `com.dazi.apex.integrations`. Missing show-driver data must never break compilation.
