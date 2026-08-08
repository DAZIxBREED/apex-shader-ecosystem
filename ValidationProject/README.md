# Apex Validation Project

Open this folder directly in Unity **2022.3.22f1**. Its package manifest references every package in the repository through local `file:` dependencies.

Use **Apex Validation > Build Scene And Validate** to generate `Assets/ApexValidation/Generated/ApexValidationScene.unity`, compile the imported shaders in the active editor graphics API, and run Package Doctor.

Batch-mode entry point:

```bash
Unity -batchmode -quit \
  -projectPath ./ValidationProject \
  -executeMethod ApexValidationProjectEntry.RunBatch \
  -logFile ./ValidationProject/apex-validation.log
```

Run the project once for each target/API matrix being validated. The repository does not treat a static source scan as proof of Direct3D 11, Vulkan/GLES3, Metal, VRChat SDK, stereo, or device performance correctness.
