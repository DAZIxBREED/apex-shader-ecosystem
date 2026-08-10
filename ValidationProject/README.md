# Apex Validation Project

Open this folder directly in Unity **2022.3.22f1**. Its package manifest references every Apex package in the repository through local `file:` dependencies.

Use **Apex Validation > Build Scene And Validate** to rebuild the stress scene and run Package Doctor. In 0.3.4, Package Doctor first verifies the exact ordered ShaderLab pass contract for every current Apex shader, then runs material checks and the synchronous compiler audit.

Generated validation artifacts:

```text
Assets/ApexValidation/Generated/ApexValidationScene.unity
Assets/ApexValidation/Generated/ApexValidationSceneManifest.json
Assets/ApexValidation/Generated/ApexShaderCompilerReport.json
Assets/ApexValidation/Generated/Textures/ApexValidationAlphaChecker.png
Assets/ApexValidation/Generated/Meshes/ApexValidationVertexBlendSphere.asset
```

The scene expands quality-aware shaders into Standard, Mobile, and High fixtures and adds detail/alpha stress fixtures where supported. The compiler report records Unity version, active build target, graphics API, shader/profile/pass coverage, pass names, and compiler diagnostics.

The intentional pass contracts are documented in `../Documentation/VALIDATION_MATRIX.md`. Missing or unexpected passes are validation errors rather than silently accepted changes.

Batch-mode entry point:

```bash
Unity -batchmode -quit \
  -projectPath ./ValidationProject \
  -executeMethod ApexValidationProjectEntry.RunBatch \
  -logFile ./ValidationProject/apex-validation.log
```

Run the project once for each target/API matrix being qualified. Static repository CI is not proof of Direct3D 11, Vulkan/GLES3, Metal, VRChat SDK, stereo, or device-performance correctness.
