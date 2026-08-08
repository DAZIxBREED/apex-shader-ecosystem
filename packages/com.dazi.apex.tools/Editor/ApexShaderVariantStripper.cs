#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

namespace DAZI.Apex.Tools
{
    /// <summary>
    /// Keeps Apex's local quality contract bounded. Mobile builds never compile
    /// the High tier; contradictory quality keyword states are removed everywhere.
    /// </summary>
    public sealed class ApexShaderVariantStripper : IPreprocessShaders
    {
        public int callbackOrder => 100;

        public void OnProcessShader(
            Shader shader,
            ShaderSnippetData snippet,
            IList<ShaderCompilerData> variants)
        {
            if (shader == null || !shader.name.StartsWith("Apex/"))
            {
                return;
            }

            var standardKeyword = shader.keywordSpace.FindKeyword("_APEX_QUALITY_STANDARD");
            var mobileKeyword = shader.keywordSpace.FindKeyword("_APEX_QUALITY_MOBILE");
            var highKeyword = shader.keywordSpace.FindKeyword("_APEX_QUALITY_HIGH");
            if (!standardKeyword.isValid && !mobileKeyword.isValid && !highKeyword.isValid)
            {
                return;
            }

            var mobileBuild = EditorUserBuildSettings.activeBuildTarget == BuildTarget.Android ||
                              EditorUserBuildSettings.activeBuildTarget == BuildTarget.iOS;

            var removed = 0;
            for (var index = variants.Count - 1; index >= 0; --index)
            {
                var keywordSet = variants[index].shaderKeywordSet;
                var hasStandard = standardKeyword.isValid && keywordSet.IsEnabled(standardKeyword);
                var hasMobile = mobileKeyword.isValid && keywordSet.IsEnabled(mobileKeyword);
                var hasHigh = highKeyword.isValid && keywordSet.IsEnabled(highKeyword);
                var enabledQualityCount = (hasStandard ? 1 : 0) + (hasMobile ? 1 : 0) + (hasHigh ? 1 : 0);
                if (enabledQualityCount > 1 || (mobileBuild && hasHigh))
                {
                    variants.RemoveAt(index);
                    removed++;
                }
            }

            if (removed > 0)
            {
                Debug.Log($"Apex stripped {removed} variant(s) from {shader.name}/{snippet.passName} for {EditorUserBuildSettings.activeBuildTarget}.");
            }
        }
    }
}
#endif
