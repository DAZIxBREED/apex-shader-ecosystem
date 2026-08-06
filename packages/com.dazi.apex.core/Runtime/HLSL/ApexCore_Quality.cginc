#ifndef APEX_CORE_QUALITY_INCLUDED
#define APEX_CORE_QUALITY_INCLUDED

// Apex quality is intentionally a three-state local keyword contract.
// No keyword = Standard, which keeps existing materials stable.
#if defined(_APEX_QUALITY_MOBILE)
    #define APEX_QUALITY_LEVEL 0
    #define APEX_ENVIRONMENT_REFLECTIONS 0
    #define APEX_HIGH_QUALITY_SPECULAR 0
#elif defined(_APEX_QUALITY_HIGH)
    #define APEX_QUALITY_LEVEL 2
    #define APEX_ENVIRONMENT_REFLECTIONS 1
    #define APEX_HIGH_QUALITY_SPECULAR 1
#else
    #define APEX_QUALITY_LEVEL 1
    #define APEX_ENVIRONMENT_REFLECTIONS 1
    #define APEX_HIGH_QUALITY_SPECULAR 0
#endif

inline half ApexQualityLevel01()
{
    return (half)APEX_QUALITY_LEVEL * 0.5h;
}

inline half ApexQualityEnvironmentScale()
{
#if APEX_ENVIRONMENT_REFLECTIONS
    return 1.0h;
#else
    return 0.0h;
#endif
}

#endif
