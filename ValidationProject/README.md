# Apex Validation Project

Open this folder directly in Unity **2022.3.22f1**. Its package manifest references every package in the repository through local `file:` dependencies.

Use **Apex Validation > Build Scene And Validate** to generate `Assets/ApexValidation/Generated/ApexValidationScene.unity` and run Package Doctor. In Apex 0.3.2, Package Doctor also runs the synchronous shader compiler audit across the required Apex shader/pass profiles.

Compiler results are written to:

```text
Assets/ApexValidation/Generated/ApexShaderCompilerReport.json
```

The report records the Unity version, active build target, graphics API, shader/profile/pass coverage, and every Unity shader compiler warning or error with platform and source location.

Batch-mode entry point:

```bash
Unity -batchmode -quit \
  -projectPath ./ValidationProject \
  -executeMethod ApexValidationProjectEntry.RunBatch \
  -logFile ./ValidationProject/apex-validation.log
```

Batch validation throws a build failure when required shaders are missing or the compiler audit reports shader errors, causing Unity batch mode to return failure rather than silently producing a green validation result.

Run the project once for each target/API matrix being validated. The repository does not treat a static source scan as proof of Direct3D 11, Vulkan/GLES3, Metal, VRChat SDK, stereo, or device performance correctness.
