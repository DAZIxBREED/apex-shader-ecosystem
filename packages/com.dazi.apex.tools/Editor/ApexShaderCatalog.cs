#if UNITY_EDITOR
namespace DAZI.Apex.Tools
{
    /// <summary>
    /// Single source of truth for shader families that are required to be present
    /// in the current Apex validation matrix.
    /// </summary>
    public static class ApexShaderCatalog
    {
        public static readonly string[] RequiredShaderNames =
        {
            "Apex/Core/Debug",
            "Apex/Avatar/Standard",
            "Apex/World/Standard",
            "Apex/World/VertexBlendLite",
            "Apex/Water/PoolLite",
            "Apex/Water/OpaqueMobile",
            "Apex/Fog/CardLite",
            "Apex/FX/HologramLite",
            "Apex/FX/DissolveCutout",
            "Apex/Screens/VideoPanelLite",
            "Apex/Screens/LEDPanelLite",
            "Apex/Toon/CharacterLite"
        };
    }
}
#endif
