#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace DAZI.Apex.Tools
{
    public static class ApexMaterialQualityProfiles
    {
        public enum QualityProfile
        {
            Standard = 0,
            MobileWorld = 1,
            High = 2
        }

        [MenuItem("Apex/Materials/Quality/Apply Standard To Selection")]
        private static void ApplyStandard() => ApplyToSelection(QualityProfile.Standard);

        [MenuItem("Apex/Materials/Quality/Apply Mobile World To Selection")]
        private static void ApplyMobile() => ApplyToSelection(QualityProfile.MobileWorld);

        [MenuItem("Apex/Materials/Quality/Apply High To Selection")]
        private static void ApplyHigh() => ApplyToSelection(QualityProfile.High);

        [MenuItem("Apex/Materials/Quality/Apply Standard To Selection", true)]
        [MenuItem("Apex/Materials/Quality/Apply Mobile World To Selection", true)]
        [MenuItem("Apex/Materials/Quality/Apply High To Selection", true)]
        private static bool ValidateSelection()
        {
            return Selection.objects.OfType<Material>().Any(IsApexMaterial);
        }

        public static void Apply(Material material, QualityProfile profile)
        {
            if (!IsApexMaterial(material))
            {
                return;
            }

            Undo.RecordObject(material, $"Apply Apex {profile} quality");
            material.DisableKeyword("_APEX_QUALITY_STANDARD");
            material.DisableKeyword("_APEX_QUALITY_MOBILE");
            material.DisableKeyword("_APEX_QUALITY_HIGH");

            if (profile == QualityProfile.MobileWorld)
            {
                material.EnableKeyword("_APEX_QUALITY_MOBILE");
            }
            else if (profile == QualityProfile.High)
            {
                material.EnableKeyword("_APEX_QUALITY_HIGH");
            }
            else
            {
                material.EnableKeyword("_APEX_QUALITY_STANDARD");
            }

            if (material.HasProperty("_APEX_QUALITY"))
            {
                material.SetFloat("_APEX_QUALITY", (float)profile);
            }

            if (profile == QualityProfile.MobileWorld)
            {
                SetIfPresent(material, "_EnvironmentStrength", 0f);
                SetIfPresent(material, "_DetailEnabled", 0f);
                material.DisableKeyword("_APEX_DETAIL");
                material.enableInstancing = true;
            }
            else if (profile == QualityProfile.Standard)
            {
                ClampIfPresent(material, "_EnvironmentStrength", 0f, 1f);
                material.enableInstancing = true;
            }
            else
            {
                material.enableInstancing = true;
            }

            EditorUtility.SetDirty(material);
        }

        private static void ApplyToSelection(QualityProfile profile)
        {
            var materials = Selection.objects.OfType<Material>().Where(IsApexMaterial).Distinct().ToArray();
            if (materials.Length == 0)
            {
                Debug.LogWarning("Apex: select one or more Apex materials first.");
                return;
            }

            foreach (var material in materials)
            {
                Apply(material, profile);
            }

            AssetDatabase.SaveAssets();
            Debug.Log($"Apex applied {profile} quality to {materials.Length} material(s).");
        }

        private static bool IsApexMaterial(Material material)
        {
            return material != null && material.shader != null &&
                material.shader.name.StartsWith("Apex/", StringComparison.Ordinal);
        }

        private static void SetIfPresent(Material material, string property, float value)
        {
            if (material.HasProperty(property))
            {
                material.SetFloat(property, value);
            }
        }

        private static void ClampIfPresent(Material material, string property, float minimum, float maximum)
        {
            if (material.HasProperty(property))
            {
                material.SetFloat(property, Mathf.Clamp(material.GetFloat(property), minimum, maximum));
            }
        }
    }
}
#endif
