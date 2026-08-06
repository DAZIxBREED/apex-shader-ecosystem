# Apex Avatar — Platform Budget

## Platform contract

- `Apex/Avatar/Standard` is a custom PCVR/Desktop avatar shader.
- VRChat Android/Quest/iOS avatars must use SDK-provided `VRChat/Mobile` shaders.
- Apex Tools generates a second mobile fallback material and transfers compatible textures/colors.

## PC shader budget

- Shader Model 3.0.
- Base, normal, and packed mask textures.
- One ForwardBase pass, one additive-light pass, and one ShadowCaster pass.
- Optional alpha clipping, rim, soft wrap, and SpectraOverdrive response.

## Mobile fallback budget

- Prefer one material and a packed texture layout supported by the selected SDK mobile shader.
- Prefer 1024 textures; use 2048 only where justified.
- Enable GPU instancing where the SDK shader supports it.
- Validate the fallback in the Android and iOS build targets rather than assuming PC parity.
