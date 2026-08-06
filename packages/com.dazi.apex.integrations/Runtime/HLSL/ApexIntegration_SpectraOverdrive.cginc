#ifndef APEX_INTEGRATION_SPECTRAOVERDRIVE_INCLUDED
#define APEX_INTEGRATION_SPECTRAOVERDRIVE_INCLUDED

// Compatibility include retained for projects that referenced the original
// integrations path. The canonical implementation lives in its own package.
#include "Packages/com.dazi.apex.spectraoverdrive/Runtime/HLSL/ApexSpectraOverdrive_Bridge.cginc"

inline half3 ApexApplySpectraEmission(half3 baseEmission, half mask)
{
    return ApexSpectraEmission(baseEmission, mask);
}

inline half3 ApexApplySpectraTint(half3 baseColor, half amount)
{
    return ApexSpectraTint(baseColor, amount);
}

#endif
