# Apex SpectraOverdrive Bridge

Dedicated compatibility bridge between Apex shader packages and **SpectraOverdrive** show-control data.

Author: **DAZIxBREED**  
Version: **0.1.0**  
Minimum targets: **iOS, Quest, Android, PCVR**

## Purpose

This package gives Apex shaders a stable, optional-looking but Apex-native way to receive SpectraOverdrive controls:

- intensity
- color
- beat pulse
- blackout
- safe strobe pulse
- fixture/material group id

Apex shader packages depend on this bridge so they can be SpectraOverdrive-compatible from day one without hardcoding show logic into Avatar, World, Water, Fog, FX, Screens, or Toon.
