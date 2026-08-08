#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace DAZI.Apex.Tools
{
    public static class ApexShaderVariantReport
    {
        [Serializable]
        private sealed class Report
        {
            public string generatedUtc;
            public int apexMaterialCount;
            public int apexShaderCount;
            public ShaderUsage[] shaders;
        }

        [Serializable]
        private sealed class ShaderUsage
        {
            public string shader;
            public int materialCount;
            public string[] keywords;
            public string[] materials;
        }

        [MenuItem("Apex/Validation/Write Shader Variant Usage Report")]
        public static void WriteReport()
        {
            const string outputFolder = "Assets/ApexValidation/Generated";
            const string outputPath = outputFolder + "/ApexShaderVariantReport.json";
            Directory.CreateDirectory(outputFolder);

            var materials = AssetDatabase.FindAssets("t:Material")
                .Select(AssetDatabase.GUIDToAssetPath)
                .Select(path => AssetDatabase.LoadAssetAtPath<Material>(path))
                .Where(IsApexMaterial)
                .ToArray();

            var shaderUsage = materials
                .GroupBy(material => material.shader.name)
                .OrderBy(group => group.Key, StringComparer.Ordinal)
                .Select(group => new ShaderUsage
                {
                    shader = group.Key,
                    materialCount = group.Count(),
                    keywords = group.SelectMany(material => material.shaderKeywords)
                        .Distinct(StringComparer.Ordinal)
                        .OrderBy(keyword => keyword, StringComparer.Ordinal)
                        .ToArray(),
                    materials = group.Select(AssetDatabase.GetAssetPath)
                        .OrderBy(path => path, StringComparer.Ordinal)
                        .ToArray()
                })
                .ToArray();

            var report = new Report
            {
                generatedUtc = DateTime.UtcNow.ToString("O"),
                apexMaterialCount = materials.Length,
                apexShaderCount = shaderUsage.Length,
                shaders = shaderUsage
            };

            File.WriteAllText(outputPath, JsonUtility.ToJson(report, true));
            AssetDatabase.ImportAsset(outputPath);
            var asset = AssetDatabase.LoadAssetAtPath<TextAsset>(outputPath);
            Selection.activeObject = asset;
            EditorGUIUtility.PingObject(asset);
            Debug.Log($"Apex wrote shader variant usage report: {outputPath}", asset);
        }

        private static bool IsApexMaterial(Material material)
        {
            return material != null && material.shader != null &&
                   material.shader.name.StartsWith("Apex/", StringComparison.Ordinal);
        }
    }
}
#endif
