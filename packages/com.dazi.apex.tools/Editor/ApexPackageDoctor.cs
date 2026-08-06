#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace DAZI.Apex.Tools
{
    public static class ApexPackageDoctor
    {
        [MenuItem("Apex/Package Doctor/Print Compatibility Targets")]
        public static void PrintCompatibilityTargets()
        {
            Debug.Log("Apex targets: iOS, Quest, Android, PCVR. Pipeline: Unity Built-in Render Pipeline. Shader style: handwritten vertex/fragment HLSL/CG. SpectraOverdrive bridge: com.dazi.apex.spectraoverdrive.");
        }
    }
}
#endif
