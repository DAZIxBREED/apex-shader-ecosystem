#ifndef APEX_CORE_PLATFORM_INCLUDED
#define APEX_CORE_PLATFORM_INCLUDED

#if defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(UNITY_ANDROID) || defined(UNITY_IOS)
    #define APEX_MOBILE_TARGET 1
#else
    #define APEX_MOBILE_TARGET 0
#endif

#if defined(UNITY_ANDROID)
    #define APEX_ANDROID_TARGET 1
#else
    #define APEX_ANDROID_TARGET 0
#endif

#if defined(UNITY_IOS)
    #define APEX_IOS_TARGET 1
#else
    #define APEX_IOS_TARGET 0
#endif

#if defined(SHADER_API_GLES)
    #define APEX_GLES2_TARGET 1
#else
    #define APEX_GLES2_TARGET 0
#endif

inline half ApexPlatformQualityScalar()
{
#if APEX_GLES2_TARGET
    return 0.5h;
#elif APEX_MOBILE_TARGET
    return 0.75h;
#else
    return 1.0h;
#endif
}

inline half ApexPlatformAnimationScalar()
{
#if APEX_MOBILE_TARGET
    return 0.75h;
#else
    return 1.0h;
#endif
}

#endif
