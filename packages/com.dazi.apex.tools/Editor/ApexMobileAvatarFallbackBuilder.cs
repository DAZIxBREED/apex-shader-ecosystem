#if UNITY_EDITOR
using System;
using UnityEditor;
using UnityEngine;

namespace DAZI.Apex.Tools
{
    public sealed class ApexMobileAvatarFallbackBuilder : EditorWindow
    {
        private enum MobileShaderProfile
        {
            ToonStandard,
            StandardLite,
            ToonLit
        }

        [SerializeField] private Material sourceMaterial;
        [SerializeField] private MobileShaderProfile profile = MobileShaderProfile.ToonStandard;

        [MenuItem("Apex/Mobile Avatar Fallback Builder")]
        private static void Open()
        {
            GetWindow<ApexMobileAvatarFallbackBuilder>("Apex Mobile Fallback");
        }

        private void OnGUI()
        {
            EditorGUILayout.HelpBox(
                "VRChat mobile avatars cannot use custom Apex shaders. This tool creates a second material using an SDK-provided VRChat/Mobile shader and transfers compatible textures and colors.",
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

            var shader = FindMobileShader(profile);
            if (shader == null)
            {
                EditorUtility.DisplayDialog(
                    "VRChat mobile shader not found",
                    "Install or update the VRChat Avatars SDK, then retry. The builder searched the SDK shader names for the selected profile.",
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

            var target = new Material(shader)
            {
                name = sourceMaterial.name + " Mobile",
                enableInstancing = true
            };

            TransferTexture(sourceMaterial, target, new[] { "_BaseMap", "_MainTex" }, new[] { "_MainTex", "_BaseMap" });
            TransferTexture(sourceMaterial, target, new[] { "_NormalMap", "_BumpMap" }, new[] { "_BumpMap", "_NormalMap" });
            TransferTexture(sourceMaterial, target, new[] { "_MaskMap", "_MetallicGlossMap" }, new[] { "_MetallicGlossMap", "_MaskMap" });
            TransferColor(sourceMaterial, target, new[] { "_BaseColor", "_Color" }, new[] { "_Color", "_BaseColor" });
            TransferColor(sourceMaterial, target, new[] { "_EmissionColor" }, new[] { "_EmissionColor" });
            TransferFloat(sourceMaterial, target, new[] { "_NormalScale", "_BumpScale" }, new[] { "_BumpScale", "_NormalScale" });
            TransferFloat(sourceMaterial, target, new[] { "_Metallic" }, new[] { "_Metallic" });
            TransferFloat(sourceMaterial, target, new[] { "_Smoothness" }, new[] { "_Glossiness", "_Smoothness" });
            TransferFloat(sourceMaterial, target, new[] { "_Cutoff" }, new[] { "_Cutoff" });

            AssetDatabase.CreateAsset(target, path);
            AssetDatabase.SaveAssets();
            AssetDatabase.ImportAsset(path);
            Selection.activeObject = target;
            EditorGUIUtility.PingObject(target);
            Debug.Log($"Apex created mobile avatar fallback: {path} using {shader.name}", target);
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
