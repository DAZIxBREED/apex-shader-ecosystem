#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace DAZI.Apex.Tools
{
    public static class ApexPackageDoctor
    {
        [MenuItem("Apex/Validation/Run Full Project Validation")]
        public static void RunFullValidation()
        {
            var errors = new List<string>();
            var warnings = new List<string>();
            ValidateShaders(errors, warnings);
            ValidateMaterials(errors, warnings);
            ApexShaderCompilerAudit.AppendCompilerDiagnostics(errors, warnings, true);
            PrintReport("Apex full project validation", errors, warnings);
        }

        public static void RunBatchValidation()
        {
            var errors = new List<string>();
            var warnings = new List<string>();
            ValidateShaders(errors, warnings);
            ValidateMaterials(errors, warnings);
            ApexShaderCompilerAudit.AppendCompilerDiagnostics(errors, warnings, true);
            PrintReport("Apex batch project validation", errors, warnings);
            if (errors.Count > 0)
            {
                throw new UnityEditor.Build.BuildFailedException(
                    $"Apex validation failed with {errors.Count} error(s)."
                );
            }
        }

        [MenuItem("Apex/Validation/Validate Selected Materials")]
        public static void ValidateSelectedMaterials()
        {
            var materials = Selection.objects.OfType<Material>().ToArray();
            if (materials.Length == 0)
            {
                Debug.LogWarning("Apex: Select one or more materials first.");
                return;
            }

            var errors = new List<string>();
            var warnings = new List<string>();
            foreach (var material in materials)
            {
                ValidateMaterial(material, errors, warnings);
            }
            PrintReport("Apex selected material validation", errors, warnings);
        }

        [MenuItem("Apex/Validation/Print Compatibility Contract")]
        public static void PrintCompatibilityContract()
        {
            Debug.Log(
                "Apex 0.3.2 compatibility contract:\n" +
                "• Unity/VRChat baseline: Unity 2022.3.22f1, Built-in Render Pipeline.\n" +
                "• Custom Apex world shaders: designed for Windows PCVR, Android/Quest, and iOS world builds.\n" +
                "• Custom Apex avatar shaders: PCVR/Desktop only in VRChat. Mobile avatar uploads must use SDK-provided VRChat/Mobile shaders.\n" +
                "• Full validation synchronously compiles the current Apex material/pass profiles and writes a compiler report.\n" +
                "• Use Apex > Mobile Avatar Fallback Builder to generate a legal mobile material."
            );
        }

        private static void ValidateShaders(List<string> errors, List<string> warnings)
        {
            foreach (var shaderName in ApexShaderCatalog.RequiredShaderNames)
            {
                var shader = Shader.Find(shaderName);
                if (shader == null)
                {
                    errors.Add($"Required shader was not found: {shaderName}");
                    continue;
                }

                if (!shader.isSupported)
                {
                    warnings.Add($"Shader is present but unsupported by the current editor graphics API: {shaderName}");
                }
            }
        }

        private static void ValidateMaterials(List<string> errors, List<string> warnings)
        {
            foreach (var guid in AssetDatabase.FindAssets("t:Material"))
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                var material = AssetDatabase.LoadAssetAtPath<Material>(path);
                if (material != null && material.shader != null && material.shader.name.StartsWith("Apex/", StringComparison.Ordinal))
                {
                    ValidateMaterial(material, errors, warnings);
                }
            }
        }

        private static void ValidateMaterial(Material material, List<string> errors, List<string> warnings)
        {
            if (material.shader == null)
            {
                errors.Add($"{material.name}: missing shader.");
                return;
            }

            var shaderName = material.shader.name;
            if (!shaderName.StartsWith("Apex/", StringComparison.Ordinal))
            {
                warnings.Add($"{material.name}: is not using an Apex shader.");
                return;
            }

            if (shaderName.StartsWith("Apex/Avatar/", StringComparison.Ordinal) ||
                shaderName.StartsWith("Apex/Toon/", StringComparison.Ordinal))
            {
                warnings.Add(
                    $"{material.name}: Apex custom avatar shaders are PC-only in VRChat. " +
                    "Generate an SDK mobile fallback before Android, Quest, or iOS avatar upload."
                );
            }

            if (!material.enableInstancing &&
                !shaderName.StartsWith("Apex/Avatar/", StringComparison.Ordinal) &&
                !shaderName.StartsWith("Apex/Toon/", StringComparison.Ordinal))
            {
                warnings.Add($"{material.name}: GPU instancing is disabled.");
            }

            var standardQuality = material.IsKeywordEnabled("_APEX_QUALITY_STANDARD");
            var mobileQuality = material.IsKeywordEnabled("_APEX_QUALITY_MOBILE");
            var highQuality = material.IsKeywordEnabled("_APEX_QUALITY_HIGH");
            var enabledQualityCount = (standardQuality ? 1 : 0) + (mobileQuality ? 1 : 0) + (highQuality ? 1 : 0);
            if (enabledQualityCount > 1)
            {
                errors.Add($"{material.name}: multiple Apex quality keywords are enabled.");
            }
            if (mobileQuality && material.HasProperty("_EnvironmentStrength") &&
                material.GetFloat("_EnvironmentStrength") > 0.001f)
            {
                warnings.Add($"{material.name}: mobile quality disables reflection probes; set Environment Strength to 0 for clear authoring intent.");
            }
            if (shaderName == "Apex/World/VertexBlendLite" && mobileQuality)
            {
                warnings.Add($"{material.name}: VertexBlendLite uses six texture samplers; profile it on the target standalone headset or phone.");
            }

            CheckTexture(material, "_BaseMap", warnings, TextureExpectation.Color);
            CheckTexture(material, "_MainTex", warnings, TextureExpectation.Color);
            CheckTexture(material, "_NormalMap", warnings, TextureExpectation.Normal);
            CheckTexture(material, "_BumpMap", warnings, TextureExpectation.Normal);
            CheckTexture(material, "_MaskMap", warnings, TextureExpectation.Linear);
            CheckTexture(material, "_MetallicGlossMap", warnings, TextureExpectation.Linear);
            CheckTexture(material, "_NoiseMap", warnings, TextureExpectation.Linear);

            if (material.HasProperty("_AlphaClip") && material.GetFloat("_AlphaClip") > 0.5f &&
                material.HasProperty("_Cutoff") && material.GetFloat("_Cutoff") <= 0.001f)
            {
                warnings.Add($"{material.name}: alpha clipping is enabled with a near-zero cutoff.");
            }

            if (shaderName == "Apex/Fog/CardLite" ||
                shaderName == "Apex/Water/PoolLite" ||
                shaderName == "Apex/FX/HologramLite")
            {
                warnings.Add($"{material.name}: transparent effects should be profiled for mobile fill-rate cost.");
            }
        }

        private enum TextureExpectation
        {
            Color,
            Linear,
            Normal
        }

        private static void CheckTexture(
            Material material,
            string propertyName,
            List<string> warnings,
            TextureExpectation expectation)
        {
            if (!material.HasProperty(propertyName))
            {
                return;
            }

            var texture = material.GetTexture(propertyName) as Texture2D;
            if (texture == null)
            {
                return;
            }

            if (texture.width > 2048 || texture.height > 2048)
            {
                warnings.Add(
                    $"{material.name}: {propertyName} is {texture.width}x{texture.height}; " +
                    "consider a 1024 or 2048 mobile override."
                );
            }

            var path = AssetDatabase.GetAssetPath(texture);
            var importer = AssetImporter.GetAtPath(path) as TextureImporter;
            if (importer == null)
            {
                return;
            }

            if (expectation == TextureExpectation.Normal && importer.textureType != TextureImporterType.NormalMap)
            {
                warnings.Add($"{material.name}: {propertyName} should be imported as a Normal map.");
            }
            else if (expectation == TextureExpectation.Linear && importer.sRGBTexture)
            {
                warnings.Add($"{material.name}: {propertyName} should have sRGB disabled for data/mask sampling.");
            }
            else if (expectation == TextureExpectation.Color && !importer.sRGBTexture)
            {
                warnings.Add($"{material.name}: {propertyName} is a color texture but sRGB is disabled.");
            }
        }

        private static void PrintReport(string title, List<string> errors, List<string> warnings)
        {
            var builder = new StringBuilder();
            builder.AppendLine(title);
            builder.AppendLine($"Errors: {errors.Count}; warnings: {warnings.Count}");

            foreach (var error in errors)
            {
                builder.AppendLine($"ERROR: {error}");
            }
            foreach (var warning in warnings)
            {
                builder.AppendLine($"WARNING: {warning}");
            }

            if (errors.Count > 0)
            {
                Debug.LogError(builder.ToString());
            }
            else if (warnings.Count > 0)
            {
                Debug.LogWarning(builder.ToString());
            }
            else
            {
                builder.AppendLine("No Apex issues found.");
                Debug.Log(builder.ToString());
            }
        }
    }
}
#endif
