#if UNITY_EDITOR
using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace DAZI.Apex.Tools
{
    public sealed class ApexMobileAvatarFallbackBuilder : EditorWindow
    {
        public enum MobileShaderProfile
        {
            ToonStandard,
            StandardLite,
            ToonLit
        }

        [Serializable]
        private sealed class PairingRecord
        {
            public string sourceMaterialGuid;
            public string sourceMaterialPath;
            public string mobileMaterialGuid;
            public string mobileMaterialPath;
            public string mobileShader;
            public string profile;
            public string generatedUtc;
        }

        [SerializeField] private Material sourceMaterial;
        [SerializeField] private MobileShaderProfile profile = MobileShaderProfile.ToonStandard;

        [MenuItem("Apex/Mobile Avatar/Fallback Builder")]
        private static void Open()
        {
            GetWindow<ApexMobileAvatarFallbackBuilder>("Apex Mobile Fallback");
        }

        [MenuItem("Apex/Mobile Avatar/Create Fallbacks For Selected Materials")]
        private static void CreateSelectedFallbacks()
        {
            var materials = Selection.objects.OfType<Material>()
                .Where(IsApexPcAvatarMaterial)
                .Distinct()
                .ToArray();
            if (materials.Length == 0)
            {
                Debug.LogWarning("Apex: select one or more Apex Avatar or Apex Toon materials.");
                return;
            }

            const string outputFolder = "Assets/ApexMobileFallbacks";
            ApexEditorAssetFolders.Ensure(outputFolder);
            var created = 0;
            foreach (var source in materials)
            {
                var fileName = SanitizeFileName(source.name) + "_Mobile.mat";
                var outputPath = AssetDatabase.GenerateUniqueAssetPath(outputFolder + "/" + fileName);
                if (CreateFallbackMaterial(source, MobileShaderProfile.ToonStandard, outputPath) != null)
                {
                    created++;
                }
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            Debug.Log($"Apex created {created} mobile avatar fallback material(s) in {outputFolder}.");
        }

        [MenuItem("Apex/Mobile Avatar/Create Fallbacks For Selected Materials", true)]
        private static bool ValidateCreateSelectedFallbacks()
        {
            return Selection.objects.OfType<Material>().Any(IsApexPcAvatarMaterial);
        }

        private void OnGUI()
        {
            EditorGUILayout.HelpBox(
                "VRChat mobile avatars cannot use custom Apex shaders. This tool creates a second material using an SDK-provided VRChat/Mobile shader, transfers compatible values, and writes a source/fallback pairing record.",
                MessageType.Info
            );

            sourceMaterial = (Material)EditorGUILayout.ObjectField("PC Apex Material", sourceMaterial, typeof(Material), false);
            profile = (MobileShaderProfile)EditorGUILayout.EnumPopup("Mobile Shader", profile);

            using (new EditorGUI.DisabledScope(sourceMaterial == null))
            {
                if (GUILayout.Button("Create Mobile Fallback Material", GUILayout.Height(32f)))
                {
                    CreateFallback();
                }
            }
        }

        private void CreateFallback()
        {
            if (sourceMaterial == null)
            {
                return;
            }

            if (!IsApexPcAvatarMaterial(sourceMaterial))
            {
                EditorUtility.DisplayDialog(
                    "Unsupported source material",
                    "Choose an Apex/Avatar or Apex/Toon PC material.",
                    "OK"
                );
                return;
            }

            var defaultName = sourceMaterial.name + "_Mobile";
            var path = EditorUtility.SaveFilePanelInProject(
                "Save mobile fallback material",
                defaultName,
                "mat",
                "Choose where to create the SDK-compatible mobile material."
            );
            if (string.IsNullOrEmpty(path))
            {
                return;
            }

            var target = CreateFallbackMaterial(sourceMaterial, profile, path);
            if (target != null)
            {
                Selection.activeObject = target;
                EditorGUIUtility.PingObject(target);
            }
        }

        public static Material CreateFallbackMaterial(
            Material source,
            MobileShaderProfile selectedProfile,
            string outputPath)
        {
            if (source == null || string.IsNullOrWhiteSpace(outputPath))
            {
                return null;
            }

            var directory = Path.GetDirectoryName(outputPath)?.Replace('\\', '/');
            if (string.IsNullOrEmpty(directory))
            {
                Debug.LogError("Apex: mobile fallback output path has no valid asset folder: " + outputPath);
                return null;
            }
            ApexEditorAssetFolders.Ensure(directory);

            var shader = FindMobileShader(selectedProfile);
            if (shader == null)
            {
                EditorUtility.DisplayDialog(
                    "VRChat mobile shader not found",
                    "Install or update the VRChat Avatars SDK, then retry. The builder searched the SDK shader names for the selected profile.",
                    "OK"
                );
                return null;
            }

            var target = new Material(shader)
            {
                name = source.name + " Mobile",
                enableInstancing = true
            };

            TransferTexture(source, target, new[] { "_BaseMap", "_MainTex" }, new[] { "_MainTex", "_BaseMap" });
            TransferTexture(source, target, new[] { "_NormalMap", "_BumpMap" }, new[] { "_BumpMap", "_NormalMap" });
            TransferTexture(source, target, new[] { "_MaskMap", "_MetallicGlossMap" }, new[] { "_MetallicGlossMap", "_MaskMap" });
            TransferColor(source, target, new[] { "_BaseColor", "_Color" }, new[] { "_Color", "_BaseColor" });
            TransferColor(source, target, new[] { "_EmissionColor" }, new[] { "_EmissionColor" });
            TransferFloat(source, target, new[] { "_NormalScale", "_BumpScale" }, new[] { "_BumpScale", "_NormalScale" });
            TransferFloat(source, target, new[] { "_Metallic" }, new[] { "_Metallic" });
            TransferFloat(source, target, new[] { "_Smoothness" }, new[] { "_Glossiness", "_Smoothness" });
            TransferFloat(source, target, new[] { "_Cutoff" }, new[] { "_Cutoff" });

            AssetDatabase.CreateAsset(target, outputPath);
            AssetDatabase.SaveAssets();
            AssetDatabase.ImportAsset(outputPath, ImportAssetOptions.ForceUpdate);
            WritePairingRecord(source, target, selectedProfile, outputPath);
            Debug.Log($"Apex created mobile avatar fallback: {outputPath} using {shader.name}", target);
            return target;
        }

        private static Shader FindMobileShader(MobileShaderProfile selectedProfile)
        {
            string[] candidates;
            switch (selectedProfile)
            {
                case MobileShaderProfile.StandardLite:
                    candidates = new[] { "VRChat/Mobile/Standard Lite", "VRChat/Mobile/Standard Lite (Quest)" };
                    break;
                case MobileShaderProfile.ToonLit:
                    candidates = new[] { "VRChat/Mobile/Toon Lit" };
                    break;
                default:
                    candidates = new[] { "VRChat/Mobile/Toon Standard", "VRChat/Mobile/Toon Lit" };
                    break;
            }

            foreach (var candidate in candidates)
            {
                var shader = Shader.Find(candidate);
                if (shader != null)
                {
                    return shader;
                }
            }
            return null;
        }

        private static void WritePairingRecord(
            Material source,
            Material target,
            MobileShaderProfile selectedProfile,
            string targetPath)
        {
            var sourcePath = AssetDatabase.GetAssetPath(source);
            var record = new PairingRecord
            {
                sourceMaterialGuid = AssetDatabase.AssetPathToGUID(sourcePath),
                sourceMaterialPath = sourcePath,
                mobileMaterialGuid = AssetDatabase.AssetPathToGUID(targetPath),
                mobileMaterialPath = targetPath,
                mobileShader = target.shader != null ? target.shader.name : string.Empty,
                profile = selectedProfile.ToString(),
                generatedUtc = DateTime.UtcNow.ToString("O")
            };

            var directory = Path.GetDirectoryName(targetPath)?.Replace('\\', '/');
            if (string.IsNullOrEmpty(directory))
            {
                return;
            }
            ApexEditorAssetFolders.Ensure(directory);
            var jsonPath = AssetDatabase.GenerateUniqueAssetPath(
                directory + "/" + Path.GetFileNameWithoutExtension(targetPath) + ".apex-mobile-pairing.json"
            );
            File.WriteAllText(jsonPath, JsonUtility.ToJson(record, true));
            AssetDatabase.ImportAsset(jsonPath, ImportAssetOptions.ForceUpdate);
        }

        private static bool IsApexPcAvatarMaterial(Material material)
        {
            if (material == null || material.shader == null)
            {
                return false;
            }
            return material.shader.name.StartsWith("Apex/Avatar/", StringComparison.Ordinal) ||
                   material.shader.name.StartsWith("Apex/Toon/", StringComparison.Ordinal);
        }

        private static string SanitizeFileName(string value)
        {
            foreach (var character in Path.GetInvalidFileNameChars())
            {
                value = value.Replace(character, '_');
            }
            return value;
        }

        private static void TransferTexture(Material source, Material target, string[] sourceProperties, string[] targetProperties)
        {
            foreach (var sourceProperty in sourceProperties)
            {
                if (!source.HasProperty(sourceProperty))
                {
                    continue;
                }

                var texture = source.GetTexture(sourceProperty);
                if (texture == null)
                {
                    continue;
                }

                foreach (var targetProperty in targetProperties)
                {
                    if (!target.HasProperty(targetProperty))
                    {
                        continue;
                    }
                    target.SetTexture(targetProperty, texture);
                    target.SetTextureScale(targetProperty, source.GetTextureScale(sourceProperty));
                    target.SetTextureOffset(targetProperty, source.GetTextureOffset(sourceProperty));
                    return;
                }
            }
        }

        private static void TransferColor(Material source, Material target, string[] sourceProperties, string[] targetProperties)
        {
            foreach (var sourceProperty in sourceProperties)
            {
                if (!source.HasProperty(sourceProperty)) continue;
                foreach (var targetProperty in targetProperties)
                {
                    if (!target.HasProperty(targetProperty)) continue;
                    target.SetColor(targetProperty, source.GetColor(sourceProperty));
                    return;
                }
            }
        }

        private static void TransferFloat(Material source, Material target, string[] sourceProperties, string[] targetProperties)
        {
            foreach (var sourceProperty in sourceProperties)
            {
                if (!source.HasProperty(sourceProperty)) continue;
                foreach (var targetProperty in targetProperties)
                {
                    if (!target.HasProperty(targetProperty)) continue;
                    target.SetFloat(targetProperty, source.GetFloat(sourceProperty));
                    return;
                }
            }
        }
    }
}
#endif
