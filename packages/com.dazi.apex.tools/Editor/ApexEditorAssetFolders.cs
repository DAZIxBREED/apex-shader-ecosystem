#if UNITY_EDITOR
using System;
using UnityEditor;

namespace DAZI.Apex.Tools
{
    internal static class ApexEditorAssetFolders
    {
        public static void Ensure(string assetFolder)
        {
            if (string.IsNullOrWhiteSpace(assetFolder))
            {
                throw new ArgumentException("Asset folder path cannot be empty.", nameof(assetFolder));
            }

            var normalized = assetFolder.Replace('\\', '/').TrimEnd('/');
            if (string.Equals(normalized, "Assets", StringComparison.Ordinal))
            {
                return;
            }

            if (!normalized.StartsWith("Assets/", StringComparison.Ordinal))
            {
                throw new ArgumentException(
                    "Apex editor output folders must live under Assets/: " + normalized,
                    nameof(assetFolder)
                );
            }

            if (AssetDatabase.IsValidFolder(normalized))
            {
                return;
            }

            var separator = normalized.LastIndexOf('/');
            if (separator <= 0 || separator == normalized.Length - 1)
            {
                throw new ArgumentException("Invalid Unity asset folder path: " + normalized, nameof(assetFolder));
            }

            var parent = normalized.Substring(0, separator);
            var name = normalized.Substring(separator + 1);
            Ensure(parent);

            var guid = AssetDatabase.CreateFolder(parent, name);
            if (string.IsNullOrEmpty(guid) && !AssetDatabase.IsValidFolder(normalized))
            {
                throw new InvalidOperationException("Unity could not create asset folder: " + normalized);
            }
        }
    }
}
#endif
