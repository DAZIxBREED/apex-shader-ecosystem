# Apex Validation Project

Open this folder directly in Unity **2022.3.22f1**. Its package manifest references every package in the repository through local `file:` dependencies.

Use **Apex Validation > Build Scene And Validate** to rebuild the 0.3.3 stress scene and run Package Doctor. Package Doctor also runs the synchronous shader compiler audit across the required Apex shader/pass profiles.

Generated validation artifacts:

```text
Assets/ApexValidation/Generated/ApexValidationScene.unity
Assets/ApexValidation/Generated/ApexValidationSceneManifest.json
Assets/ApexValidation/Generated/ApexShaderCompilerReport.json
Assets/ApexValidation/Generated/Textures/ApexValidationAlphaChecker.png
Assets/ApexValidation/Generated/Meshes/ApexValidationVertexBlendSphere.asset
```

The scene expands quality-aware shaders into Standard, Mobile, and High fixtures and adds detail/alpha stress fixtures where supported. The alpha checker makes cutout behavior visible, while the generated vertex-gradient sphere drives both layers of `Apex/World/VertexBlendLite`.

The compiler report records the Unity version, active build target, graphics API, shader/profile/pass coverage, active pass names, and every Unity shader compiler warning or error with platform and source location. The scene manifest records the generated fixture/material/keyword/pass matrix.

Batch-mode entry point:

```bash
Unity -batchmode -quit \
  -projectPath ./ValidationProject \
  -executeMethod ApexValidationProjectEntry.RunBatch \
  -logFile ./ValidationProject/apex-validation.log
```

Batch validation throws a failure when required shaders/fixtures are missing or the compiler audit reports shader errors, causing Unity batch mode to return failure rather than silently producing a green validation result.

Run the project once for each target/API matrix being validated. The repository does not treat a static source scan as proof of Direct3D 11, Vulkan/GLES3, Metal, VRChat SDK, stereo, or device performance correctness.
