#if UNITY_EDITOR
using System;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace DAZI.Apex.Tools
{
    public sealed class ApexPackedMaskTextureWindow : EditorWindow
    {
        [Serializable]
        private sealed class ChannelSource
        {
            public Texture2D texture;
            [Range(0f, 1f)] public float fallback;
            public bool invert;
        }

        [SerializeField] private ChannelSource metallic = new ChannelSource { fallback = 0f };
        [SerializeField] private ChannelSource occlusion = new ChannelSource { fallback = 1f };
        [SerializeField] private ChannelSource effectMask = new ChannelSource { fallback = 0f };
        [SerializeField] private ChannelSource smoothness = new ChannelSource { fallback = 0.5f };
        [SerializeField] private int outputSize = 1024;

        [MenuItem("Apex/Texture Tools/Packed Mask Builder")]
        private static void Open()
        {
            GetWindow<ApexPackedMaskTextureWindow>("Apex Mask Builder");
        }

        private void OnGUI()
        {
            EditorGUILayout.HelpBox(
                "Builds Apex's packed mask layout: R Metallic, G Occlusion, B Effect Mask, A Smoothness. Source textures do not need Read/Write enabled.",
                MessageType.Info
            );

            DrawChannel("R — Metallic", metallic);
            DrawChannel("G — Occlusion", occlusion);
            DrawChannel("B — Effect Mask", effectMask);
            DrawChannel("A — Smoothness", smoothness);

            outputSize = EditorGUILayout.IntPopup(
                "Output Size",
                outputSize,
                new[] { "256", "512", "1024", "2048", "4096" },
                new[] { 256, 512, 1024, 2048, 4096 }
            );

            if (GUILayout.Button("Build Packed Mask PNG", GUILayout.Height(32f)))
            {
                BuildTexture();
            }
        }

        private static void DrawChannel(string label, ChannelSource channel)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.LabelField(label, EditorStyles.boldLabel);
            channel.texture = (Texture2D)EditorGUILayout.ObjectField("Texture", channel.texture, typeof(Texture2D), false);
            channel.fallback = EditorGUILayout.Slider("Fallback", channel.fallback, 0f, 1f);
            channel.invert = EditorGUILayout.Toggle("Invert", channel.invert);
            EditorGUILayout.EndVertical();
        }

        private void BuildTexture()
        {
            var path = EditorUtility.SaveFilePanelInProject(
                "Save Apex packed mask",
                "Apex_PackedMask.png",
                "png",
                "Choose an output path inside the Unity project."
            );
            if (string.IsNullOrEmpty(path))
            {
                return;
            }

            Texture2D metallicReadable = null;
            Texture2D occlusionReadable = null;
            Texture2D effectReadable = null;
            Texture2D smoothnessReadable = null;
            Texture2D output = null;

            try
            {
                metallicReadable = MakeReadable(metallic.texture);
                occlusionReadable = MakeReadable(occlusion.texture);
                effectReadable = MakeReadable(effectMask.texture);
                smoothnessReadable = MakeReadable(smoothness.texture);
                output = new Texture2D(outputSize, outputSize, TextureFormat.RGBA32, false, true);
                var pixels = new Color32[outputSize * outputSize];

                for (var y = 0; y < outputSize; y++)
                {
                    if ((y & 31) == 0)
                    {
                        EditorUtility.DisplayProgressBar("Apex Packed Mask", $"Packing row {y + 1} of {outputSize}", y / (float)outputSize);
                    }

                    var v = (y + 0.5f) / outputSize;
                    for (var x = 0; x < outputSize; x++)
                    {
                        var u = (x + 0.5f) / outputSize;
                        pixels[y * outputSize + x] = new Color32(
                            ToByte(Sample(metallic, metallicReadable, u, v)),
                            ToByte(Sample(occlusion, occlusionReadable, u, v)),
                            ToByte(Sample(effectMask, effectReadable, u, v)),
                            ToByte(Sample(smoothness, smoothnessReadable, u, v))
                        );
                    }
                }

                output.SetPixels32(pixels);
                output.Apply(false, false);

                var projectRoot = Directory.GetParent(Application.dataPath)?.FullName;
                if (string.IsNullOrEmpty(projectRoot))
                {
                    throw new InvalidOperationException("Could not resolve the Unity project root.");
                }

                var absolutePath = Path.Combine(projectRoot, path);
                File.WriteAllBytes(absolutePath, output.EncodeToPNG());
                AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceSynchronousImport);

                var importer = AssetImporter.GetAtPath(path) as TextureImporter;
                if (importer != null)
                {
                    importer.sRGBTexture = false;
                    importer.alphaSource = TextureImporterAlphaSource.FromInput;
                    importer.mipmapEnabled = true;
                    importer.textureCompression = TextureImporterCompression.Compressed;
                    importer.SaveAndReimport();
                }

                var created = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
                Selection.activeObject = created;
                EditorGUIUtility.PingObject(created);
                Debug.Log($"Apex packed mask created: {path}", created);
            }
            finally
            {
                EditorUtility.ClearProgressBar();
                DestroyImmediateSafe(metallicReadable);
                DestroyImmediateSafe(occlusionReadable);
                DestroyImmediateSafe(effectReadable);
                DestroyImmediateSafe(smoothnessReadable);
                DestroyImmediateSafe(output);
            }
        }

        private static float Sample(ChannelSource source, Texture2D readable, float u, float v)
        {
            var value = readable != null ? readable.GetPixelBilinear(u, v).grayscale : source.fallback;
            return source.invert ? 1f - value : value;
        }

        private static byte ToByte(float value)
        {
            return (byte)Mathf.RoundToInt(Mathf.Clamp01(value) * 255f);
        }

        private static Texture2D MakeReadable(Texture2D source)
        {
            if (source == null)
            {
                return null;
            }

            var previous = RenderTexture.active;
            var temporary = RenderTexture.GetTemporary(source.width, source.height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);
            try
            {
                Graphics.Blit(source, temporary);
                RenderTexture.active = temporary;
                var readable = new Texture2D(source.width, source.height, TextureFormat.RGBA32, false, true);
                readable.ReadPixels(new Rect(0, 0, source.width, source.height), 0, 0, false);
                readable.Apply(false, false);
                return readable;
            }
            finally
            {
                RenderTexture.active = previous;
                RenderTexture.ReleaseTemporary(temporary);
            }
        }

        private static void DestroyImmediateSafe(UnityEngine.Object value)
        {
            if (value != null)
            {
                DestroyImmediate(value);
            }
        }
    }
}
#endif
