#if UNITY_EDITOR
using System.Linq;

namespace DAZI.Apex.Tools
{
    /// <summary>
    /// Single source of truth for shader families and their intentional ShaderLab
    /// pass contracts in the current Apex validation matrix.
    /// </summary>
    public static class ApexShaderCatalog
    {
        public sealed class ShaderContract
        {
            public string ShaderName { get; }
            public string[] ExpectedPassNames { get; }

            public ShaderContract(string shaderName, params string[] expectedPassNames)
            {
                ShaderName = shaderName;
                ExpectedPassNames = expectedPassNames;
            }
        }

        public static readonly ShaderContract[] RequiredShaders =
        {
            new ShaderContract("Apex/Core/Debug", "DEBUG"),
            new ShaderContract("Apex/Avatar/Standard", "FORWARD_BASE", "FORWARD_ADD", "SHADOW_CASTER"),
            new ShaderContract("Apex/World/Standard", "FORWARD_BASE", "FORWARD_ADD", "SHADOW_CASTER", "META"),
            new ShaderContract("Apex/World/VertexBlendLite", "FORWARD_BASE", "FORWARD_ADD", "SHADOW_CASTER", "META"),
            new ShaderContract("Apex/Water/PoolLite", "FORWARD_BASE"),
            new ShaderContract("Apex/Water/OpaqueMobile", "FORWARD_BASE", "FORWARD_ADD"),
            new ShaderContract("Apex/Fog/CardLite", "UNLIT_FOG"),
            new ShaderContract("Apex/FX/HologramLite", "HOLOGRAM"),
            new ShaderContract("Apex/FX/DissolveCutout", "FORWARD_BASE", "FORWARD_ADD", "SHADOW_CASTER", "META"),
            new ShaderContract("Apex/Screens/VideoPanelLite", "VIDEO_PANEL"),
            new ShaderContract("Apex/Screens/LEDPanelLite", "LED_PANEL"),
            new ShaderContract("Apex/Toon/CharacterLite", "FORWARD_BASE", "FORWARD_ADD", "SHADOW_CASTER", "META")
        };

        public static readonly string[] RequiredShaderNames =
            RequiredShaders.Select(contract => contract.ShaderName).ToArray();

        public static ShaderContract FindContract(string shaderName)
        {
            return RequiredShaders.FirstOrDefault(contract => contract.ShaderName == shaderName);
        }
    }
}
#endif
