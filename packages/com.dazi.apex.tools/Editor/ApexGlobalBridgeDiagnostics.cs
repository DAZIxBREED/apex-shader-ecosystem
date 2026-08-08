#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace DAZI.Apex.Tools
{
    public sealed class ApexGlobalBridgeDiagnostics : EditorWindow
    {
        private bool autoRefresh = true;
        private Vector2 scroll;

        [MenuItem("Apex/Diagnostics/Global Bridge Monitor")]
        private static void Open()
        {
            GetWindow<ApexGlobalBridgeDiagnostics>("Apex Globals");
        }

        private void OnEnable()
        {
            EditorApplication.update += EditorUpdate;
        }

        private void OnDisable()
        {
            EditorApplication.update -= EditorUpdate;
        }

        private void EditorUpdate()
        {
            if (autoRefresh)
            {
                Repaint();
            }
        }

        private void OnGUI()
        {
            using (new EditorGUILayout.HorizontalScope())
            {
                autoRefresh = EditorGUILayout.ToggleLeft("Auto refresh", autoRefresh, GUILayout.Width(110f));
                if (GUILayout.Button("Refresh", GUILayout.Width(80f)))
                {
                    Repaint();
                }
            }

            scroll = EditorGUILayout.BeginScrollView(scroll);
            DrawSpectra("Unity", "_ApexSpectra");
            EditorGUILayout.Space();
            DrawSpectra("VRChat Udon", "_UdonApexSpectra");
            EditorGUILayout.Space();
            DrawIntegration("Unity", false);
            EditorGUILayout.Space();
            DrawIntegration("VRChat Udon", true);
            EditorGUILayout.EndScrollView();
        }

        private static void DrawSpectra(string label, string prefix)
        {
            EditorGUILayout.LabelField(label + " SpectraOverdrive", EditorStyles.boldLabel);
            DrawFloat(prefix + "Intensity");
            DrawVector(prefix + "Color");
            DrawVector(prefix + "Bands");
            DrawFloat(prefix + "Beat");
            DrawFloat(prefix + "Blackout");
            DrawFloat(prefix + "Strobe");
            DrawFloat(prefix + "GroupId");
            DrawFloat(prefix + "Time");
            DrawFloat(prefix + "SafetyActive");
            DrawVector(prefix + "Safety");
        }

        private static void DrawIntegration(string label, bool udon)
        {
            EditorGUILayout.LabelField(label + " Optional Integrations", EditorStyles.boldLabel);
            var prefix = udon ? "_UdonApex" : "_Apex";
            if (udon)
            {
                DrawFloat("_UdonApexIntegrationActive");
            }
            DrawFloat(prefix + "AudioAmplitude");
            DrawVector(prefix + "AudioBands");
            DrawVector(prefix + "LightVolumeColor");
            DrawVector(prefix + "LTCGIColor");
            DrawVector(prefix + "VRSLColor");
        }

        private static void DrawFloat(string property)
        {
            EditorGUILayout.FloatField(property, Shader.GetGlobalFloat(property));
        }

        private static void DrawVector(string property)
        {
            EditorGUILayout.Vector4Field(property, Shader.GetGlobalVector(property));
        }
    }
}
#endif
