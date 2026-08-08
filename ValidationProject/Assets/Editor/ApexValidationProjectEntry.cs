#if UNITY_EDITOR
using DAZI.Apex.Tools;
using UnityEditor;

public static class ApexValidationProjectEntry
{
    [MenuItem("Apex Validation/Build Scene And Validate")]
    public static void BuildSceneAndValidate()
    {
        ApexValidationSceneBuilder.BuildAndValidateBatch();
    }

    public static void RunBatch()
    {
        ApexValidationSceneBuilder.BuildAndValidateBatch();
    }
}
#endif
