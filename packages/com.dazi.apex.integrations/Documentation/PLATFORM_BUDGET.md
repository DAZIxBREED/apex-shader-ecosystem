# Apex Integrations — Platform Budget

The 0.3.0 bridge functions add no samplers and no render passes.

- Audio uses four global bands plus one amplitude value.
- Light-volume, LTCGI-style, and VRSL-style bridges each use one global color.
- All functions return neutral behavior when globals are not driven.
- Concrete future adapters must document any additional sampler, keyword, or dependency cost.
