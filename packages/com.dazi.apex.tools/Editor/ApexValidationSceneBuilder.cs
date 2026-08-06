#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace DAZI.Apex.Tools
{
    public static class ApexValidationSceneBuilder
    {
        public const string RootFolder = "Assets/ApexValidation/Generated";
        public const string MaterialFolder = RootFolder + "/Materials";
        public const string ScenePath = RootFolder + "/ApexValidationScene.unity";

        private struct ShaderFixture
        {
            public string shaderName;
            public PrimitiveType primitive;
            public Vector3 scale;

            public ShaderFixture(string shaderName, PrimitiveType primitive, Vector3 scale)
            {
                this.shaderName = shaderName;
                this.primitive = primitive;
                this.scale = scale;
            }
        }

        private static readonly ShaderFixture[] Fixtures =
        {
            new ShaderFixture("Apex/Avatar/Standard", PrimitiveType.Capsule, new Vector3(1f, 1f, 1f)),
            new ShaderFixture("Apex/World/Standard", PrimitiveType.Cube, Vector3.one),
            new ShaderFixture("Apex/World/VertexBlendLite", PrimitiveType.Sphere, Vector3.one),
            new ShaderFixture("Apex/Water/PoolLite", PrimitiveType.Quad, new Vector3(1.6f, 1.6f, 1.6f)),
            new ShaderFixture("Apex/Water/OpaqueMobile", PrimitiveType.Cube, new Vector3(1.25f, 0.25f, 1.25f)),
            new ShaderFixture("Apex/Fog/CardLite", PrimitiveType.Quad, new Vector3(1.5f, 1.5f, 1.5f)),
            new ShaderFixture("Apex/FX/HologramLite", PrimitiveType.Capsule, Vector3.one),
            new ShaderFixture("Apex/FX/DissolveCutout", PrimitiveType.Sphere, Vector3.one),
            new ShaderFixture("Apex/Screens/VideoPanelLite", PrimitiveType.Quad, new Vector3(1.6f, 0.9f, 1f)),
            new ShaderFixture("Apex/Screens/LEDPanelLite", PrimitiveType.Quad, new Vector3(1.6f, 0.9f, 1f)),
            new ShaderFixture("Apex/Toon/CharacterLite", PrimitiveType.Capsule, Vector3.one),
            new ShaderFixture("Apex/Core/Debug", PrimitiveType.Sphere, Vector3.one)
        };

        [MenuItem("Apex/Validation/Create Or Rebuild Validation Scene")]
        public static void CreateValidationScene()
        {
            EnsureFolder(RootFolder);
            EnsureFolder(MaterialFolder);

            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            CreateLighting();
            CreateCamera();
            CreateGround();

            for (var index = 0; index < Fixtures.Length; index++)
            {
                CreateFixture(Fixtures[index], index);
            }

            if (!EditorSceneManager.SaveScene(scene, ScenePath))
            {
                throw new InvalidOperationException("Apex validation scene could not be saved: " + ScenePath);
            }

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            var sceneAsset = AssetDatabase.LoadAssetAtPath<SceneAsset>(ScenePath);
            Selection.activeObject = sceneAsset;
            EditorGUIUtility.PingObject(sceneAsset);
            Debug.Log($"Apex validation scene generated: {ScenePath}", sceneAsset);
        }

        public static void BuildAndValidateBatch()
        {
            CreateValidationScene();
            ApexPackageDoctor.RunBatchValidation();
        }

        private static void CreateLighting()
        {
            var directionalObject = new GameObject("Directional Light");
            var directional = directionalObject.AddComponent<Light>();
            directional.type = LightType.Directional;
            directional.intensity = 1.1f;
            directional.shadows = LightShadows.Soft;
            directionalObject.transform.rotation = Quaternion.Euler(48f, -32f, 0f);

            var pointObject = new GameObject("Point Light");
            var point = pointObject.AddComponent<Light>();
            point.type = LightType.Point;
            point.range = 12f;
            point.intensity = 3f;
            point.color = new Color(0.35f, 0.55f, 1f);
            point.shadows = LightShadows.Soft;
            pointObject.transform.position = new Vector3(-3f, 3f, -1f);

            var spotObject = new GameObject("Spot Light");
            var spot = spotObject.AddComponent<Light>();
            spot.type = LightType.Spot;
            spot.range = 18f;
            spot.spotAngle = 42f;
            spot.intensity = 4f;
            spot.color = new Color(1f, 0.35f, 0.2f);
            spot.shadows = LightShadows.Hard;
            spotObject.transform.position = new Vector3(4f, 5f, -3f);
            spotObject.transform.rotation = Quaternion.Euler(42f, 205f, 0f);

            var probeObject = new GameObject("Reflection Probe");
            var probe = probeObject.AddComponent<ReflectionProbe>();
            probe.mode = UnityEngine.Rendering.ReflectionProbeMode.Realtime;
            probe.refreshMode = UnityEngine.Rendering.ReflectionProbeRefreshMode.OnAwake;
            probe.timeSlicingMode = UnityEngine.Rendering.ReflectionProbeTimeSlicingMode.IndividualFaces;
            probe.size = new Vector3(18f, 8f, 18f);
            probe.resolution = 128;
            probeObject.transform.position = new Vector3(0f, 2f, 2f);
        }

        private static void CreateCamera()
        {
            var cameraObject = new GameObject("Validation Camera");
            var camera = cameraObject.AddComponent<Camera>();
            camera.clearFlags = CameraClearFlags.Skybox;
            camera.fieldOfView = 52f;
            camera.nearClipPlane = 0.05f;
            camera.farClipPlane = 100f;
            cameraObject.tag = "MainCamera";
            cameraObject.transform.position = new Vector3(0f, 5.5f, -15f);
            cameraObject.transform.rotation = Quaternion.Euler(14f, 0f, 0f);
        }

        private static void CreateGround()
        {
            var ground = GameObject.CreatePrimitive(PrimitiveType.Plane);
            ground.name = "Apex World Ground";
            ground.transform.localScale = new Vector3(2.2f, 1f, 2.2f);
            ground.transform.position = new Vector3(0f, -1.05f, 2f);
            var material = GetOrCreateMaterial("Apex/World/Standard");
            if (material != null)
            {
                material.SetColor("_BaseColor", new Color(0.18f, 0.2f, 0.24f, 1f));
                ground.GetComponent<Renderer>().sharedMaterial = material;
            }
        }

        private static void CreateFixture(ShaderFixture fixture, int index)
        {
            var shader = Shader.Find(fixture.shaderName);
            if (shader == null)
            {
                Debug.LogError("Apex validation fixture shader not found: " + fixture.shaderName);
                return;
            }

            var row = index / 4;
            var column = index % 4;
            var gameObject = GameObject.CreatePrimitive(fixture.primitive);
            gameObject.name = fixture.shaderName.Replace('/', ' ');
            gameObject.transform.position = new Vector3((column - 1.5f) * 3.1f, row * 2.6f, 2f);
            gameObject.transform.localScale = fixture.scale;
            if (fixture.primitive == PrimitiveType.Quad)
            {
                gameObject.transform.rotation = Quaternion.Euler(0f, 180f, 0f);
            }

            var material = GetOrCreateMaterial(fixture.shaderName);
            if (material != null)
            {
                ConfigureFixtureMaterial(material, index);
                gameObject.GetComponent<Renderer>().sharedMaterial = material;
            }
        }

        private static Material GetOrCreateMaterial(string shaderName)
        {
            var shader = Shader.Find(shaderName);
            if (shader == null)
            {
                return null;
            }

            var safeName = shaderName.Replace('/', '_');
            var path = MaterialFolder + "/" + safeName + ".mat";
            var material = AssetDatabase.LoadAssetAtPath<Material>(path);
            if (material == null)
            {
                material = new Material(shader)
                {
                    name = safeName,
                    enableInstancing = true
                };
                AssetDatabase.CreateAsset(material, path);
            }
            else if (material.shader != shader)
            {
                material.shader = shader;
            }
            return material;
        }

        private static void ConfigureFixtureMaterial(Material material, int index)
        {
            var hue = Mathf.Repeat(index * 0.083f, 1f);
            var color = Color.HSVToRGB(hue, 0.55f, 0.9f);
            color.a = 1f;
            SetColorIfPresent(material, "_BaseColor", color);
            SetColorIfPresent(material, "_Color", color);
            SetColorIfPresent(material, "_Tint", color);
            SetFloatIfPresent(material, "_EnvironmentStrength", 0.8f);
            SetFloatIfPresent(material, "_SpectraAmount", 0.25f);
            SetFloatIfPresent(material, "_DissolveAmount", 0.35f);
            SetFloatIfPresent(material, "_Opacity", 0.7f);
            SetTextureIfPresent(material, "_MainTex", Texture2D.whiteTexture);
            material.enableInstancing = true;
            EditorUtility.SetDirty(material);
        }

        private static void SetColorIfPresent(Material material, string property, Color value)
        {
            if (material.HasProperty(property))
            {
                material.SetColor(property, value);
            }
        }

        private static void SetFloatIfPresent(Material material, string property, float value)
        {
            if (material.HasProperty(property))
            {
                material.SetFloat(property, value);
            }
        }

        private static void SetTextureIfPresent(Material material, string property, Texture texture)
        {
            if (material.HasProperty(property))
            {
                material.SetTexture(property, texture);
            }
        }

        private static void EnsureFolder(string path)
        {
            var normalized = path.Replace('\\', '/');
            if (AssetDatabase.IsValidFolder(normalized))
            {
                return;
            }

            var parent = Path.GetDirectoryName(normalized)?.Replace('\\', '/');
            var name = Path.GetFileName(normalized);
            if (!string.IsNullOrEmpty(parent))
            {
                EnsureFolder(parent);
                AssetDatabase.CreateFolder(parent, name);
            }
        }
    }
}
#endif
