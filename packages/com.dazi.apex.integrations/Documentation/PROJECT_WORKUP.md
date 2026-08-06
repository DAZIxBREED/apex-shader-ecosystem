# Apex Integrations — Project Workup

## Purpose

Apex Integrations provides dependency-free HLSL contracts that external systems can drive without making the shader packages compile against those external packages.

## 0.2.0 implementation

- Compatibility forwarding include for the canonical SpectraOverdrive bridge.
- Global four-band audio and amplitude inputs.
- Global light-volume multiplier.
- Global LTCGI-style and VRSL-style emission inputs.
- Neutral fallback behavior when no external driver writes the globals.

## Ownership boundaries

- These are interoperability contracts, not vendor SDK reimplementations.
- The package does not claim native AudioLink, LTCGI, VRC Light Volumes, or VRSL API binding yet.
- Concrete adapters must be optional and isolated so importing Apex never requires those packages.

## Next work

- Add opt-in adapter includes after validating exact upstream APIs and licenses.
- Add an editor diagnostics panel showing which global inputs are actively driven.
- Add versioned bridge contracts to prevent property-name drift.
