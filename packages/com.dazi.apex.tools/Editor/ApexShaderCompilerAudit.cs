#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;

namespace DAZI.Apex.Tools
{
    public static class ApexShaderCompilerAudit
    {
        public const string OutputFolder = "Assets/ApexValidation/Generated";
        public const string ReportPath = OutputFolder + "/ApexShaderCompilerReport.json";

        [Serializable]
        private sealed class CompilerReport
        {
            public string generatedUtc;
            public string unityVersion;
            public string activeBuildTarget;
            public string graphicsDeviceType;
            public int shaderCount;
            public int compiledProfileCount;
            public int requestedPassCompileCount;
            public int errorCount;
            public int warningCount;
            public ShaderRecord[] shaders;
        }

        [Serializable]
        private sealed class ShaderRecord
        {
            public string shader;
            public bool found;
            public bool supported;
            public int passCount;
            public string[] passNames;
            public ProfileRecord[] profiles;
        }

        [Serializable]
        private sealed class ProfileRecord
        {
            public string profile;
            public string[] keywords;
            public bool detailEnabled;
            public bool alphaClipEnabled;
            public int requestedPassCount;
            public string[] passNames;
            public MessageRecord[] messages;
        }

        [Serializable]
        private sealed class MessageRecord
        {
            public string severity;
            public string platform;
            public string file;
            public int line;
            public string message;
            public string details;
        }

        private sealed class CompileProfile
        {
            public string name;
            public string qualityKeyword;
            public float qualityValue;
            public bool detail;
            public bool alphaClip;
        }

        [MenuItem("Apex/Validation/Run Shader Compiler Audit")]
        public static void RunInteractive()
        {
            var errors = new List<string>();
            var warnings = new List<string>();
            var report = Execute(errors, warnings);
            WriteReport(report);

            var summary = $"Apex shader compiler audit completed: {errors.Count} error(s), {warnings.Count} warning(s). Report: {ReportPath}";
            if (errors.Count > 0)
            {
                Debug.LogError(summary + "\n" + string.Join("\n", errors));
            }
            else if (warnings.Count > 0)
            {
                Debug.LogWarning(summary + "\n" + string.Join("\n", warnings));
            }
            else
            {
                Debug.Log(summary);
            }
        }

        public static void AppendCompilerDiagnostics(
            List<string> errors,
            List<string> warnings,
            bool writeReport)
        {
            if (errors == null) throw new ArgumentNullException(nameof(errors));
            if (warnings == null) throw new ArgumentNullException(nameof(warnings));

            var report = Execute(errors, warnings);
            if (writeReport)
            {
                WriteReport(report);
            }
        }

        private static CompilerReport Execute(List<string> errors, List<string> warnings)
        {
            var startErrorCount = errors.Count;
            var startWarningCount = warnings.Count;
            var records = new List<ShaderRecord>();
            var compiledProfileCount = 0;
            var requestedPassCompileCount = 0;

            foreach (var shaderName in ApexShaderCatalog.RequiredShaderNames)
            {
                var shader = Shader.Find(shaderName);
                if (shader == null)
                {
                    errors.Add("Compiler audit could not find required shader: " + shaderName);
                    records.Add(new ShaderRecord
                    {
                        shader = shaderName,
                        found = false,
                        supported = false,
                        passCount = 0,
                        passNames = Array.Empty<string>(),
                        profiles = Array.Empty<ProfileRecord>()
                    });
                    continue;
                }

                var probeMaterial = new Material(shader)
                {
                    hideFlags = HideFlags.HideAndDontSave
                };
                string[] passNames;
                try
                {
                    passNames = ReadPassNames(probeMaterial, warnings);
                }
                finally
                {
                    UnityEngine.Object.DestroyImmediate(probeMaterial);
                }

                if (!shader.isSupported)
                {
                    warnings.Add($"{shaderName}: shader is unsupported by the current editor graphics API {SystemInfo.graphicsDeviceType}.");
                }

                var shaderRecord = new ShaderRecord
                {
                    shader = shaderName,
                    found = true,
                    supported = shader.isSupported,
                    passCount = passNames.Length,
                    passNames = passNames
                };

                var profiles = BuildProfiles(shader);
                var profileRecords = new List<ProfileRecord>();
                foreach (var profile in profiles)
                {
                    var profileRecord = CompileProfileAndCollect(shader, profile, errors, warnings);
                    profileRecords.Add(profileRecord);
                    requestedPassCompileCount += profileRecord.requestedPassCount;
                    compiledProfileCount++;
                }

                shaderRecord.profiles = profileRecords.ToArray();
                records.Add(shaderRecord);
            }

            return new CompilerReport
            {
                generatedUtc = DateTime.UtcNow.ToString("O"),
                unityVersion = Application.unityVersion,
                activeBuildTarget = EditorUserBuildSettings.activeBuildTarget.ToString(),
                graphicsDeviceType = SystemInfo.graphicsDeviceType.ToString(),
                shaderCount = records.Count,
                compiledProfileCount = compiledProfileCount,
                requestedPassCompileCount = requestedPassCompileCount,
                errorCount = errors.Count - startErrorCount,
                warningCount = warnings.Count - startWarningCount,
                shaders = records.ToArray()
            };
        }

        private static ProfileRecord CompileProfileAndCollect(
            Shader shader,
            CompileProfile profile,
            List<string> errors,
            List<string> warnings)
        {
            var material = new Material(shader)
            {
                name = "Apex Compiler Audit " + shader.name + " " + profile.name,
                hideFlags = HideFlags.HideAndDontSave,
                enableInstancing = true
            };

            try
            {
                ConfigureProfile(material, profile);
                var passNames = ReadPassNames(material, warnings);
                if (passNames.Length == 0)
                {
                    errors.Add($"{shader.name} [{profile.name}]: material exposes zero active passes.");
                }

                ShaderUtil.ClearShaderMessages(shader);
                for (var pass = 0; pass < material.passCount; pass++)
                {
                    ShaderUtil.CompilePass(material, pass, true);
                }

                var compilerMessages = ShaderUtil.GetShaderMessages(shader);
                var messageRecords = compilerMessages.Select(ToMessageRecord).ToArray();
                foreach (var compilerMessage in compilerMessages)
                {
                    var location = string.IsNullOrEmpty(compilerMessage.file)
                        ? shader.name
                        : $"{compilerMessage.file}:{compilerMessage.line}";
                    var text = $"{shader.name} [{profile.name}] {location}: {compilerMessage.message}";
                    if (compilerMessage.severity == ShaderCompilerMessageSeverity.Error)
                    {
                        errors.Add(text);
                    }
                    else
                    {
                        warnings.Add(text);
                    }
                }

                if (ShaderUtil.ShaderHasError(shader) &&
                    !compilerMessages.Any(message => message.severity == ShaderCompilerMessageSeverity.Error))
                {
                    errors.Add($"{shader.name} [{profile.name}]: Unity reports a shader compile error without a detailed ShaderMessage.");
                }

                return new ProfileRecord
                {
                    profile = profile.name,
                    keywords = material.shaderKeywords.OrderBy(keyword => keyword, StringComparer.Ordinal).ToArray(),
                    detailEnabled = profile.detail,
                    alphaClipEnabled = profile.alphaClip,
                    requestedPassCount = material.passCount,
                    passNames = passNames,
                    messages = messageRecords
                };
            }
            catch (Exception exception)
            {
                errors.Add($"{shader.name} [{profile.name}]: compiler audit threw {exception.GetType().Name}: {exception.Message}");
                return new ProfileRecord
                {
                    profile = profile.name,
                    keywords = material.shaderKeywords.OrderBy(keyword => keyword, StringComparer.Ordinal).ToArray(),
                    detailEnabled = profile.detail,
                    alphaClipEnabled = profile.alphaClip,
                    requestedPassCount = 0,
                    passNames = Array.Empty<string>(),
                    messages = Array.Empty<MessageRecord>()
                };
            }
            finally
            {
                UnityEngine.Object.DestroyImmediate(material);
            }
        }

        private static string[] ReadPassNames(Material material, List<string> warnings)
        {
            var passNames = new string[material.passCount];
            var seen = new HashSet<string>(StringComparer.Ordinal);
            for (var pass = 0; pass < material.passCount; pass++)
            {
                var passName = material.GetPassName(pass) ?? string.Empty;
                passNames[pass] = passName;
                if (string.IsNullOrWhiteSpace(passName))
                {
                    warnings.Add($"{material.shader.name}: pass index {pass} is unnamed.");
                }
                else if (!seen.Add(passName))
                {
                    warnings.Add($"{material.shader.name}: duplicate active pass name {passName}.");
                }
            }
            return passNames;
        }

        private static List<CompileProfile> BuildProfiles(Shader shader)
        {
            var profiles = new List<CompileProfile>();
            var hasStandard = HasLocalKeyword(shader, "_APEX_QUALITY_STANDARD");
            var hasMobile = HasLocalKeyword(shader, "_APEX_QUALITY_MOBILE");
            var hasHigh = HasLocalKeyword(shader, "_APEX_QUALITY_HIGH");
            var hasQualityContract = hasStandard || hasMobile || hasHigh;
            var hasDetail = HasLocalKeyword(shader, "_APEX_DETAIL");
            var hasAlphaClip = shader.FindPropertyIndex("_AlphaClip") >= 0;

            if (hasQualityContract)
            {
                if (hasStandard)
                {
                    profiles.Add(new CompileProfile
                    {
                        name = "Standard",
                        qualityKeyword = "_APEX_QUALITY_STANDARD",
                        qualityValue = 0f
                    });
                }
                if (hasMobile)
                {
                    profiles.Add(new CompileProfile
                    {
                        name = "Mobile",
                        qualityKeyword = "_APEX_QUALITY_MOBILE",
                        qualityValue = 1f
                    });
                }
                if (hasHigh)
                {
                    profiles.Add(new CompileProfile
                    {
                        name = "High",
                        qualityKeyword = "_APEX_QUALITY_HIGH",
                        qualityValue = 2f
                    });
                }
            }
            else
            {
                profiles.Add(new CompileProfile { name = "Default" });
            }

            if (hasDetail)
            {
                profiles.Add(new CompileProfile
                {
                    name = "Standard+Detail",
                    qualityKeyword = hasStandard ? "_APEX_QUALITY_STANDARD" : null,
                    qualityValue = 0f,
                    detail = true
                });
            }

            if (hasAlphaClip)
            {
                profiles.Add(new CompileProfile
                {
                    name = hasQualityContract ? "Standard+AlphaClip" : "Default+AlphaClip",
                    qualityKeyword = hasStandard ? "_APEX_QUALITY_STANDARD" : null,
                    qualityValue = 0f,
                    alphaClip = true
                });
            }

            if (hasDetail && hasAlphaClip)
            {
                profiles.Add(new CompileProfile
                {
                    name = "Standard+Detail+AlphaClip",
                    qualityKeyword = hasStandard ? "_APEX_QUALITY_STANDARD" : null,
                    qualityValue = 0f,
                    detail = true,
                    alphaClip = true
                });
            }

            return profiles;
        }

        private static void ConfigureProfile(Material material, CompileProfile profile)
        {
            DisableIfValid(material, "_APEX_QUALITY_STANDARD");
            DisableIfValid(material, "_APEX_QUALITY_MOBILE");
            DisableIfValid(material, "_APEX_QUALITY_HIGH");
            DisableIfValid(material, "_APEX_DETAIL");

            if (!string.IsNullOrEmpty(profile.qualityKeyword))
            {
                material.EnableKeyword(profile.qualityKeyword);
            }
            if (material.HasProperty("_APEX_QUALITY"))
            {
                material.SetFloat("_APEX_QUALITY", profile.qualityValue);
            }

            if (profile.detail)
            {
                if (HasLocalKeyword(material.shader, "_APEX_DETAIL"))
                {
                    material.EnableKeyword("_APEX_DETAIL");
                }
                if (material.HasProperty("_DetailEnabled"))
                {
                    material.SetFloat("_DetailEnabled", 1f);
                }
                if (material.HasProperty("_DetailStrength"))
                {
                    material.SetFloat("_DetailStrength", 0.8f);
                }
            }

            if (material.HasProperty("_AlphaClip"))
            {
                material.SetFloat("_AlphaClip", profile.alphaClip ? 1f : 0f);
            }
            if (profile.alphaClip && material.HasProperty("_Cutoff"))
            {
                material.SetFloat("_Cutoff", 0.5f);
            }
        }

        private static void DisableIfValid(Material material, string keyword)
        {
            if (HasLocalKeyword(material.shader, keyword))
            {
                material.DisableKeyword(keyword);
            }
        }

        private static bool HasLocalKeyword(Shader shader, string keyword)
        {
            return shader != null && shader.keywordSpace.FindKeyword(keyword).isValid;
        }

        private static MessageRecord ToMessageRecord(ShaderMessage message)
        {
            return new MessageRecord
            {
                severity = message.severity.ToString(),
                platform = message.platform.ToString(),
                file = message.file ?? string.Empty,
                line = message.line,
                message = message.message ?? string.Empty,
                details = message.messageDetails ?? string.Empty
            };
        }

        private static void WriteReport(CompilerReport report)
        {
            ApexEditorAssetFolders.Ensure(OutputFolder);
            File.WriteAllText(ReportPath, JsonUtility.ToJson(report, true));
            AssetDatabase.ImportAsset(ReportPath, ImportAssetOptions.ForceUpdate);
        }
    }
}
#endif
