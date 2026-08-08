#if UNITY_EDITOR
using System;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace DAZI.Apex.Tools
{
    public static class ApexAvatarMaterialPresets
    {
        private enum AvatarPreset
        {
            Skin,
            Cloth,
            Hair,
            HardSurface
        }

        [MenuItem("Apex/Materials/Avatar Presets/Skin")]
        private static void Skin() => ApplySelection(AvatarPreset.Skin);

        [MenuItem("Apex/Materials/Avatar Presets/Cloth")]
        private static void Cloth() => ApplySelection(AvatarPreset.Cloth);

        [MenuItem("Apex/Materials/Avatar Presets/Hair")]
        private static void Hair() => ApplySelection(AvatarPreset.Hair);

        [MenuItem("Apex/Materials/Avatar Presets/Hard Surface")]
        private static void HardSurface() => ApplySelection(AvatarPreset.HardSurface);

        [MenuItem("Apex/Materials/Avatar Presets/Skin", true)]
        [MenuItem("Apex/Materials/Avatar Presets/Cloth", true)]
        [MenuItem("Apex/Materials/Avatar Presets/Hair", true)]
        [MenuItem("Apex/Materials/Avatar Presets/Hard Surface", true)]
        private static bool ValidateSelection()
        {
            return Selection.objects.OfType<Material>().Any(IsAvatarMaterial);
        }

        private static void ApplySelection(AvatarPreset preset)
        {
            var materials = Selection.objects.OfType<Material>().Where(IsAvatarMaterial).Distinct().ToArray();
            foreach (var material in materials)
            {
                Undo.RecordObject(material, $"Apply Apex avatar {preset} preset");
                Apply(material, preset);
                EditorUtility.SetDirty(material);
            }
            AssetDatabase.SaveAssets();
            Debug.Log($"Apex applied the {preset} preset to {materials.Length} avatar material(s).");
        }

        private static void Apply(Material material, AvatarPreset preset)
        {
            Set(material, "_AlphaClip", 0f);
            switch (preset)
            {
                case AvatarPreset.Skin:
                    Set(material, "_Metallic", 0f);
                    Set(material, "_Smoothness", 0.45f);
                    Set(material, "_WrapAmount", 0.35f);
                    Set(material, "_RimIntensity", 0.12f);
                    Set(material, "_EnvironmentStrength", 0.25f);
                    break;
                case AvatarPreset.Cloth:
                    Set(material, "_Metallic", 0f);
                    Set(material, "_Smoothness", 0.18f);
                    Set(material, "_WrapAmount", 0.12f);
                    Set(material, "_RimIntensity", 0.08f);
                    Set(material, "_EnvironmentStrength", 0.12f);
                    break;
                case AvatarPreset.Hair:
                    Set(material, "_Metallic", 0f);
                    Set(material, "_Smoothness", 0.72f);
                    Set(material, "_WrapAmount", 0.18f);
                    Set(material, "_RimIntensity", 0.42f);
                    Set(material, "_RimPower", 2.2f);
                    Set(material, "_EnvironmentStrength", 0.55f);
                    Set(material, "_AlphaClip", 1f);
                    Set(material, "_Cutoff", 0.45f);
                    break;
                case AvatarPreset.HardSurface:
                    Set(material, "_Metallic", 0.75f);
                    Set(material, "_Smoothness", 0.78f);
                    Set(material, "_WrapAmount", 0f);
                    Set(material, "_RimIntensity", 0.18f);
                    Set(material, "_EnvironmentStrength", 1f);
                    break;
            }
            ApexMaterialQualityProfiles.Apply(material, ApexMaterialQualityProfiles.QualityProfile.Standard);
        }

        private static bool IsAvatarMaterial(Material material)
        {
            return material != null && material.shader != null &&
                   material.shader.name.StartsWith("Apex/Avatar/", StringComparison.Ordinal);
        }

        private static void Set(Material material, string property, float value)
        {
            if (material.HasProperty(property))
            {
                material.SetFloat(property, value);
            }
        }
    }
}
#endif
