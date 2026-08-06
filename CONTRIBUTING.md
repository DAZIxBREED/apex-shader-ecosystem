
# Contributing

Apex is currently a controlled clean-room project maintained by DAZIxBREED.

## Ground rules

- Do not copy source code from third-party shaders or decompiled packages.
- Keep every package independently understandable and narrowly owned.
- Preserve safe rendering paths for iOS, Android, Quest, and PCVR.
- Avoid compute, geometry, tessellation, GrabPass, and large variant explosions as required dependencies.
- New integrations must compile safely when the external system is absent.
- Run `python3 scripts/validate_repo.py` before committing.

## Commit style

Use focused imperative messages, such as `Add mobile fog depth fade` or `Fix Spectra color fallback`.
