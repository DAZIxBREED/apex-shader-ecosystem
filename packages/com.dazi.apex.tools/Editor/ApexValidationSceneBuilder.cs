#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
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
        public const string MeshFolder = RootFolder + "/Meshes";
        public const string TextureFolder = RootFolder + "/Textures";
        public const string ScenePath = RootFolder + "/ApexValidationScene.unity";
        public const string ManifestPath = RootFolder + "/ApexValidationSceneManifest.json";

        private const string AlphaCheckerPath = TextureFolder + "/ApexValidationAlphaChecker.png";
        private const string VertexBlendMeshPath = MeshFolder + "/ApexValidationVertexBlendSphere.asset";

        [Serializable]
        private sealed class ValidationManifest
        {
            public string generatedUtc;
            public string unityVersion;
            public int fixtureCount;
            public int shaderCount;
            public FixtureRecord[] fixtures;
        }

        [Serializable]
        private sealed class FixtureRecord
        {
            public string shader;
            public string profile;
            public string materialPath;
            public string gameObject;
            public Vector3 position;
            public string[] keywords;
            public string[] passNames;
            public bool detailEnabled;
            public bool alphaClipEnabled;
        }

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

        private struct FixtureProfile
        {
            public string name;
            public bool useQuality;
            public int quality;
            public bool detail;
            public bool alphaClip;

            public FixtureProfile(string name, bool useQuality, int quality, bool detail, bool alphaClip)
            {
                this.name = name;
                this.useQuality = useQuality;
                this.quality = quality;
                this.detail = detail;
                this.alphaClip = alphaClip;
            }
        }

        private static readonly ShaderFixture[] Fixtures =
        {
            new ShaderFixture("Apex/Avatar/Standard", PrimitiveType.Capsule, Vector3.one),
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
            ApexEditorAssetFolders.Ensure(RootFolder);
            ApexEditorAssetFolders.Ensure(MaterialFolder);
            ApexEditorAssetFolders.Ensure(MeshFolder);
            ApexEditorAssetFolders.Ensure(TextureFolder);

            var alphaChecker = GetOrCreateAlphaChecker();
            var vertexBlendMesh = CreateVertexBlendMesh();
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            CreateLighting();
            CreateCamera();
            CreateGround();

            var records = new List<FixtureRecord>();
            var expandedIndex = 0;
            foreach (var fixture in Fixtures)
            {
                var shader = Shader.Find(fixture.shaderName);
                if (shader == null)
                {
                    Debug.LogError("Apex validation fixture shader not found: " + fixture.shaderName);
                    continue;
                }

                foreach (var profile in BuildProfiles(shader))
                {
                    var record = CreateFixture(
                        fixture,
                        profile,
                        expandedIndex++,
                        alphaChecker,
                        vertexBlendMesh
                    );
                    if (record != null)
                    {
                        records.Add(record);
                    }
                }
            }

            ValidateCoverage(records);

            if (!EditorSceneManager.SaveScene(scene, ScenePath))
            {
                throw new InvalidOperationException("Apex validation scene could not be saved: " + ScenePath);
            }

            WriteManifest(records);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            var sceneAsset = AssetDatabase.LoadAssetAtPath<SceneAsset>(ScenePath);
            Selection.activeObject = sceneAsset;
            EditorGUIUtility.PingObject(sceneAsset);
            Debug.Log(
                $"Apex validation scene generated with {records.Count} fixtures across " +
                $"{records.Select(record => record.shader).Distinct().Count()} shaders: {ScenePath}",
                sceneAsset
            );
        }

        public static void BuildAndValidateBatch()
        {
            CreateValidationScene();
            ApexPackageDoctor.RunBatchValidation();
        }

        private static List<FixtureProfile> BuildProfiles(Shader shader)
        {
            var profiles = new List<FixtureProfile>();
            var hasQuality = HasLocalKeyword(shader, "_APEX_QUALITY_STANDARD") ||
                             HasLocalKeyword(shader, "_APEX_QUALITY_MOBILE") ||
                             HasLocalKeyword(shader, "_APEX_QUALITY_HIGH");
            var hasDetail = HasLocalKeyword(shader, "_APEX_DETAIL");
            var hasAlphaClip = shader.FindPropertyIndex("_AlphaClip") >= 0;

            if (hasQuality)
            {
                profiles.Add(new FixtureProfile("Standard", true, 0, false, false));
                profiles.Add(new FixtureProfile("Mobile", true, 1, false, false));
                profiles.Add(new FixtureProfile("High", true, 2, false, false));
            }
            else
            {
                profiles.Add(new FixtureProfile("Default", false, 0, false, false));
            }

            if (hasDetail)
            {
                profiles.Add(new FixtureProfile("Standard+Detail", hasQuality, 0, true, false));
            }

            if (hasAlphaClip)
            {
                profiles.Add(new FixtureProfile(
                    hasQuality ? "Standard+AlphaClip" : "Default+AlphaClip",
                    hasQuality,
                    0,
                    false,
                    true
                ));
            }

            if (hasDetail && hasAlphaClip)
            {
                profiles.Add(new FixtureProfile("Standard+Detail+AlphaClip", hasQuality, 0, true, true));
            }

            return profiles;
        }

        private static FixtureRecord CreateFixture(
            ShaderFixture fixture,
            FixtureProfile profile,
            int index,
            Texture2D alphaChecker,
            Mesh vertexBlendMesh)
        {
            var shader = Shader.Find(fixture.shaderName);
            if (shader == null)
            {
                return null;
            }

            const int columns = 5;
            var row = index / columns;
            var column = index % columns;
            var gameObject = GameObject.CreatePrimitive(fixture.primitive);
            gameObject.name = fixture.shaderName.Replace('/', ' ') + " [" + profile.name + "]";
            gameObject.transform.position = new Vector3((column - 2f) * 3.15f, row * 2.65f, 2f);
            gameObject.transform.localScale = fixture.scale;
            if (fixture.primitive == PrimitiveType.Quad)
            {
                gameObject.transform.rotation = Quaternion.Euler(0f, 180f, 0f);
            }

            if (fixture.shaderName == "Apex/World/VertexBlendLite" && vertexBlendMesh != null)
            {
                var meshFilter = gameObject.GetComponent<MeshFilter>();
                if (meshFilter != null)
                {
                    meshFilter.sharedMesh = vertexBlendMesh;
                }
            }

            var materialPath = MaterialPath(fixture.shaderName, profile.name);
            var material = GetOrCreateMaterial(fixture.shaderName, profile.name);
            if (material == null)
            {
                return null;
            }

            ConfigureFixtureMaterial(material, index, profile, alphaChecker);
            gameObject.GetComponent<Renderer>().sharedMaterial = material;

            return new FixtureRecord
            {
                shader = fixture.shaderName,
                profile = profile.name,
                materialPath = materialPath,
                gameObject = gameObject.name,
                position = gameObject.transform.position,
                keywords = material.shaderKeywords.OrderBy(keyword => keyword, StringComparer.Ordinal).ToArray(),
                passNames = Enumerable.Range(0, material.passCount)
                    .Select(material.GetPassName)
                    .ToArray(),
                detailEnabled = profile.detail,
                alphaClipEnabled = profile.alphaClip
            };
        }

        private static Material GetOrCreateMaterial(string shaderName, string profileName)
        {
            var shader = Shader.Find(shaderName);
            if (shader == null)
            {
                return null;
            }

            var path = MaterialPath(shaderName, profileName);
            var material = AssetDatabase.LoadAssetAtPath<Material>(path);
            if (material == null)
            {
                material = new Material(shader)
                {
                    name = Path.GetFileNameWithoutExtension(path),
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

        private static string MaterialPath(string shaderName, string profileName)
        {
            var safeShader = shaderName.Replace('/', '_');
            var safeProfile = profileName.Replace('+', '_').Replace(' ', '_');
            return MaterialFolder + "/" + safeShader + "__" + safeProfile + ".mat";
        }

        private static void ConfigureFixtureMaterial(
            Material material,
            int index,
            FixtureProfile profile,
            Texture2D alphaChecker)
        {
            var hue = Mathf.Repeat(index * 0.071f, 1f);
            var color = Color.HSVToRGB(hue, 0.55f, 0.9f);
            color.a = 1f;

            SetColorIfPresent(material, "_BaseColor", color);
            SetColorIfPresent(material, "_Color", color);
            SetColorIfPresent(material, "_Tint", color);
            SetColorIfPresent(material, "_LayerAColor", Color.Lerp(color, Color.black, 0.35f));
            SetColorIfPresent(material, "_LayerBColor", Color.Lerp(color, Color.white, 0.45f));
            SetFloatIfPresent(material, "_EnvironmentStrength", 0.8f);
            SetFloatIfPresent(material, "_SpectraAmount", 0.25f);
            SetFloatIfPresent(material, "_DissolveAmount", 0.35f);
            SetFloatIfPresent(material, "_Opacity", 0.7f);
            SetTextureIfPresent(material, "_MainTex", Texture2D.whiteTexture);
            SetTextureIfPresent(material, "_BaseMap", Texture2D.whiteTexture);

            ConfigureQuality(material, profile);
            ConfigureDetail(material, profile.detail);
            ConfigureAlphaClip(material, profile.alphaClip, alphaChecker);

            material.enableInstancing = true;
            EditorUtility.SetDirty(material);
        }

        private static void ConfigureQuality(Material material, FixtureProfile profile)
        {
            DisableIfValid(material, "_APEX_QUALITY_STANDARD");
            DisableIfValid(material, "_APEX_QUALITY_MOBILE");
            DisableIfValid(material, "_APEX_QUALITY_HIGH");

            if (!profile.useQuality)
            {
                return;
            }

            var keyword = profile.quality == 1
                ? "_APEX_QUALITY_MOBILE"
                : profile.quality == 2
                    ? "_APEX_QUALITY_HIGH"
                    : "_APEX_QUALITY_STANDARD";
            if (HasLocalKeyword(material.shader, keyword))
            {
                material.EnableKeyword(keyword);
            }
            SetFloatIfPresent(material, "_APEX_QUALITY", profile.quality);
            if (profile.quality == 1)
            {
                SetFloatIfPresent(material, "_EnvironmentStrength", 0f);
            }
        }

        private static void ConfigureDetail(Material material, bool enabled)
        {
            DisableIfValid(material, "_APEX_DETAIL");
            SetFloatIfPresent(material, "_DetailEnabled", enabled ? 1f : 0f);
            if (!enabled)
            {
                return;
            }

            if (HasLocalKeyword(material.shader, "_APEX_DETAIL"))
            {
                material.EnableKeyword("_APEX_DETAIL");
            }
            SetFloatIfPresent(material, "_DetailStrength", 0.8f);
            SetColorIfPresent(material, "_DetailColor", new Color(0.65f, 1f, 0.8f, 1f));
            SetTextureIfPresent(material, "_DetailMap", Texture2D.grayTexture);
        }

        private static void ConfigureAlphaClip(Material material, bool enabled, Texture2D alphaChecker)
        {
            SetFloatIfPresent(material, "_AlphaClip", enabled ? 1f : 0f);
            SetFloatIfPresent(material, "_Cutoff", 0.5f);
            if (!enabled || alphaChecker == null)
            {
                return;
            }

            SetTextureIfPresent(material, "_BaseMap", alphaChecker);
            SetTextureIfPresent(material, "_MainTex", alphaChecker);
        }

        private static Texture2D GetOrCreateAlphaChecker()
        {
            var texture = new Texture2D(8, 8, TextureFormat.RGBA32, false, false)
            {
                name = "ApexValidationAlphaChecker",
                filterMode = FilterMode.Point,
                wrapMode = TextureWrapMode.Repeat
            };

            for (var y = 0; y < texture.height; y++)
            {
                for (var x = 0; x < texture.width; x++)
                {
                    var opaque = ((x / 2) + (y / 2)) % 2 == 0;
                    texture.SetPixel(x, y, new Color(1f, 1f, 1f, opaque ? 1f : 0f));
                }
            }
            texture.Apply(false, false);
            File.WriteAllBytes(AlphaCheckerPath, texture.EncodeToPNG());
            UnityEngine.Object.DestroyImmediate(texture);

            AssetDatabase.ImportAsset(AlphaCheckerPath, ImportAssetOptions.ForceUpdate);
            var importer = AssetImporter.GetAtPath(AlphaCheckerPath) as TextureImporter;
            if (importer != null)
            {
                importer.sRGBTexture = true;
                importer.alphaIsTransparency = false;
                importer.mipmapEnabled = false;
                importer.filterMode = FilterMode.Point;
                importer.wrapMode = TextureWrapMode.Repeat;
                importer.SaveAndReimport();
            }
            return AssetDatabase.LoadAssetAtPath<Texture2D>(AlphaCheckerPath);
        }

        private static Mesh CreateVertexBlendMesh()
        {
            var temporary = GameObject.CreatePrimitive(PrimitiveType.Sphere);
            var source = temporary.GetComponent<MeshFilter>().sharedMesh;
            var mesh = UnityEngine.Object.Instantiate(source);
            mesh.name = "ApexValidationVertexBlendSphere";
            UnityEngine.Object.DestroyImmediate(temporary);

            var bounds = mesh.bounds;
            var width = Mathf.Max(bounds.size.x, 0.0001f);
            var colors = new Color[mesh.vertexCount];
            var vertices = mesh.vertices;
            for (var index = 0; index < vertices.Length; index++)
            {
                var blend = Mathf.Clamp01((vertices[index].x - bounds.min.x) / width);
                colors[index] = new Color(blend, 1f - blend, 0f, 1f);
            }
            mesh.colors = colors;

            if (AssetDatabase.LoadAssetAtPath<Mesh>(VertexBlendMeshPath) != null)
            {
                AssetDatabase.DeleteAsset(VertexBlendMeshPath);
            }
            AssetDatabase.CreateAsset(mesh, VertexBlendMeshPath);
            return AssetDatabase.LoadAssetAtPath<Mesh>(VertexBlendMeshPath);
        }

        private static void ValidateCoverage(List<FixtureRecord> records)
        {
            var covered = new HashSet<string>(records.Select(record => record.shader), StringComparer.Ordinal);
            var missing = ApexShaderCatalog.RequiredShaderNames.Where(shader => !covered.Contains(shader)).ToArray();
            if (missing.Length > 0)
            {
                throw new InvalidOperationException(
                    "Apex validation scene is missing required shaders: " + string.Join(", ", missing)
                );
            }

            foreach (var shaderName in covered)
            {
                var shader = Shader.Find(shaderName);
                if (shader == null)
                {
                    continue;
                }

                var qualityAware = HasLocalKeyword(shader, "_APEX_QUALITY_STANDARD") ||
                                   HasLocalKeyword(shader, "_APEX_QUALITY_MOBILE") ||
                                   HasLocalKeyword(shader, "_APEX_QUALITY_HIGH");
                if (!qualityAware)
                {
                    continue;
                }

                var profiles = new HashSet<string>(
                    records.Where(record => record.shader == shaderName).Select(record => record.profile),
                    StringComparer.Ordinal
                );
                foreach (var required in new[] { "Standard", "Mobile", "High" })
                {
                    if (!profiles.Contains(required))
                    {
                        throw new InvalidOperationException(
                            $"Apex validation scene missing {required} fixture for {shaderName}."
                        );
                    }
                }
            }
        }

        private static void WriteManifest(List<FixtureRecord> records)
        {
            var manifest = new ValidationManifest
            {
                generatedUtc = DateTime.UtcNow.ToString("O"),
                unityVersion = Application.unityVersion,
                fixtureCount = records.Count,
                shaderCount = records.Select(record => record.shader).Distinct().Count(),
                fixtures = records.ToArray()
            };
            File.WriteAllText(ManifestPath, JsonUtility.ToJson(manifest, true));
            AssetDatabase.ImportAsset(ManifestPath, ImportAssetOptions.ForceUpdate);
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
            probe.size = new Vector3(24f, 16f, 24f);
            probe.resolution = 128;
            probeObject.transform.position = new Vector3(0f, 5f, 2f);
        }

        private static void CreateCamera()
        {
            var cameraObject = new GameObject("Validation Camera");
            var camera = cameraObject.AddComponent<Camera>();
            camera.clearFlags = CameraClearFlags.Skybox;
            camera.fieldOfView = 52f;
            camera.nearClipPlane = 0.05f;
            camera.farClipPlane = 150f;
            cameraObject.tag = "MainCamera";
            cameraObject.transform.position = new Vector3(0f, 10f, -22f);
            cameraObject.transform.rotation = Quaternion.Euler(18f, 0f, 0f);
        }

        private static void CreateGround()
        {
            var ground = GameObject.CreatePrimitive(PrimitiveType.Plane);
            ground.name = "Apex World Ground";
            ground.transform.localScale = new Vector3(3.5f, 1f, 5f);
            ground.transform.position = new Vector3(0f, -1.05f, 8f);
            var material = GetOrCreateMaterial("Apex/World/Standard", "Ground");
            if (material != null)
            {
                ConfigureQuality(material, new FixtureProfile("Ground", true, 0, false, false));
                material.SetColor("_BaseColor", new Color(0.18f, 0.2f, 0.24f, 1f));
                ground.GetComponent<Renderer>().sharedMaterial = material;
            }
        }

        private static bool HasLocalKeyword(Shader shader, string keyword)
        {
            return shader != null && shader.keywordSpace.FindKeyword(keyword).isValid;
        }

        private static void DisableIfValid(Material material, string keyword)
        {
            if (HasLocalKeyword(material.shader, keyword))
            {
                material.DisableKeyword(keyword);
            }
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
    }
}
#endif
