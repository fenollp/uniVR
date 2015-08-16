// Shader downloaded from https://www.shadertoy.com/view/ldl3zn
// written by shadertoy user P_Malin
//
// Name: Timewarp
// Description: A raymarching shader with a Dali theme. <br/>Use the mouse to rotate.
// TimeWarp @P_Malin
 
#define ENABLE_REFLECTIONS
#define ENABLE_FOG
#define ENABLE_SPECULAR
#define ENABLE_DIRECTIONAL_LIGHT
//#define ENABLE_MONTE_CARLO

float kPI = acos(0.0);
float kTwoPI = kPI * 2.0;

#ifdef ENABLE_MONTE_CARLO
uniform sampler2D backbuffer;
vec4 gPixelRandom;
vec3 gRandomNormal;
 
void CalcPixelRandom()
{
    // Nothing special here, just numbers generated by bashing keyboard
    vec4 s1 = sin(iGlobalTime * 3.3422 + fragCoord.xxxx * vec4(324.324234, 563.324234, 657.324234, 764.324234)) * 543.3423;
    vec4 s2 = sin(iGlobalTime * 1.3422 + fragCoord.yyyy * vec4(567.324234, 435.324234, 432.324234, 657.324234)) * 654.5423;
    gPixelRandom = fract(2142.4 + s1 + s2);
    gRandomNormal = normalize( gPixelRandom.xyz - 0.5);
}

float GetTime()
{
	return 0.0;
}
#else
float GetTime()
{
	return iGlobalTime;
}
#endif
 
struct C_Ray
{
    vec3 vOrigin;
    vec3 vDir;
};
 
struct C_HitInfo
{
    vec3 vPos;
    float fDistance;
    vec3 vObjectId;
};
 
struct C_Material
{
    vec3 cAlbedo;
    float fR0;
    float fSmoothness;
    vec2 vParam;
};
 
vec3 RotateX( const in vec3 vPos, const in float fAngle )
{
    float s = sin(fAngle);
    float c = cos(fAngle);
   
    vec3 vResult = vec3( vPos.x, c * vPos.y + s * vPos.z, -s * vPos.y + c * vPos.z);
   
    return vResult;
}
 
vec3 RotateY( const in vec3 vPos, const in float fAngle )
{
    float s = sin(fAngle);
    float c = cos(fAngle);
   
    vec3 vResult = vec3( c * vPos.x + s * vPos.z, vPos.y, -s * vPos.x + c * vPos.z);
   
    return vResult;
}
   
vec3 RotateZ( const in vec3 vPos, const in float fAngle )
{
    float s = sin(fAngle);
    float c = cos(fAngle);
   
    vec3 vResult = vec3( c * vPos.x + s * vPos.y, -s * vPos.x + c * vPos.y, vPos.z);
   
    return vResult;
}
 
vec4 DistCombineUnion( const in vec4 v1, const in vec4 v2 )
{
    //if(v1.x < v2.x) return v1; else return v2;
    return mix(v1, v2, step(v2.x, v1.x));
}
 
vec4 DistCombineIntersect( const in vec4 v1, const in vec4 v2 )
{
    return mix(v2, v1, step(v2.x,v1.x));
}
 
vec4 DistCombineSubtract( const in vec4 v1, const in vec4 v2 )
{
    return DistCombineIntersect(v1, vec4(-v2.x, v2.yzw));
}
 
vec3 DomainRepeatXZGetTile( const in vec3 vPos, const in vec2 vRepeat, out vec2 vTile )
{
    vec3 vResult = vPos;
    vec2 vTilePos = (vPos.xz / vRepeat) + 0.5;
    vTile = floor(vTilePos + 1000.0);
    vResult.xz = (fract(vTilePos) - 0.5) * vRepeat;
    return vResult;
}
 
vec3 DomainRepeatXZ( const in vec3 vPos, const in vec2 vRepeat )
{
    vec3 vResult = vPos;
    vec2 vTilePos = (vPos.xz / vRepeat) + 0.5;
    vResult.xz = (fract(vTilePos) - 0.5) * vRepeat;
    return vResult;
}
 
vec3 DomainRepeatY( const in vec3 vPos, const in float fSize )
{
    vec3 vResult = vPos;
    vResult.y = (fract(vPos.y / fSize + 0.5) - 0.5) * fSize;
    return vResult;
}
 
vec3 DomainRotateSymmetry( const in vec3 vPos, const in float fSteps )
{
    float angle = atan( vPos.x, vPos.z );
 
    float fScale = fSteps / (kTwoPI);
    float steppedAngle = (floor(angle * fScale + 0.5)) / fScale;
 
    float s = sin(-steppedAngle);
    float c = cos(-steppedAngle);
 
    vec3 vResult = vec3( c * vPos.x + s * vPos.z,
                vPos.y,
                -s * vPos.x + c * vPos.z);
 
    return vResult;
}
 
float GetDistanceXYTorus( const in vec3 p, const in float r1, const in float r2 )
{
    vec2 q = vec2(length(p.xy)-r1,p.z);
    return length(q)-r2;
}
float GetDistanceYZTorus( const in vec3 p, const in float r1, const in float r2 )
{
    vec2 q = vec2(length(p.yz)-r1,p.x);
    return length(q)-r2;
}
float GetDistanceCylinderY(const in vec3 vPos, const in float r)
{
    return length(vPos.xz) - r;
}
float GetDistanceBox( const in vec3 vPos, const in vec3 vSize )
{
    vec3 vDist = (abs(vPos) - vSize);
    return max(vDist.x, max(vDist.y, vDist.z));
}
 
float GetDistanceRoundedBox( const in vec3 vPos, const in vec3 vSize, float fRadius )
{
    vec3 vClosest = max(min(vPos, vSize), -vSize);
    return length(vClosest - vPos) - fRadius;
}
 
float GetDistanceWinder( const in vec3 vPos )
{
   float fWinderSize = 0.15;
   float fAngle = atan(vPos.x, vPos.z) + vPos.y * 2.0;
	
   float fBump = 1.0 + sin(fAngle * 10.0 * kPI) * 0.05;
   return length(vPos + vec3(0.0, -1.0 - 0.2, 0.0)) * fBump - fWinderSize;	
}

vec4 GetDistanceClock( const in vec3 vPos )
{
	const float fRadius = 1.0;
	const float fThickness = 0.1;
	const float fInsetRadius = 0.9;
	const float fInsetDepth = 0.1;
	float fTorusDist = GetDistanceXYTorus(vPos, 1.0, fThickness);
	
	float fCylinderDist = length(vPos.xy) - fRadius;
	float fCylinderCap = abs(vPos.z) - fThickness;
	fCylinderDist = max(fCylinderDist, fCylinderCap);
	float fDist = min(fTorusDist, fCylinderDist);
	
	float fWinderDist = GetDistanceWinder(vPos);
	fDist = min(fDist, fWinderDist);
	vec4 vResult = vec4(fDist, 2.0, 0.0, 0.0);
	
	float fInsetDist = length(vPos.xy) - fInsetRadius;
	float fInsetCap = abs(vPos.z - fThickness) - fInsetDepth;
	
	vec4 vInsetCapDist = vec4(fInsetCap, 3.0, vPos.x, vPos.y);
	vec4 vInsetDist = vec4(fInsetDist, 2.0, 0.0, 0.0);
	
	vInsetDist = DistCombineIntersect(vInsetDist, vInsetCapDist);
	
	vResult = DistCombineSubtract(vResult, vInsetDist);
	
	
	float fHandSeconds = iGlobalTime;
	
	fHandSeconds = floor(fHandSeconds) + (pow(fract(fHandSeconds), 50.0));
	float fHandAngle = -fHandSeconds * kPI * 2.0 / 60.0;
	
	vec3 vHandDomain = RotateZ(vPos, fHandAngle);
	float fHandHeight = 0.05;
	vHandDomain.z -= fThickness - fInsetDepth + fHandHeight;
	float fHandDist = length(vHandDomain.xz) - 0.01;
	fHandDist = max(fHandDist, (abs(vHandDomain.y + 0.4) - 0.4));
	
	vec4 vHandDist = vec4(fHandDist, 4.0, 0.0, 0.0);
	
	vResult = DistCombineUnion(vResult, vHandDist);
	
	return vResult;
}
 
vec3 WarpDomain( const in vec3 vPos )
{
    vec3 vResult = vPos + vec3(0.0, 0.1, 0.1);

    float fUnbend = clamp(atan(vResult.y, vResult.z), 0.0, kPI * 0.9);
    vResult = RotateX(vResult, -fUnbend);
     
    float fDroopBlend = max(-vResult.y, 0.0);	
    vResult.y += fDroopBlend * 0.4;
    vResult.z += sin(vResult.x * 4.0  + vResult.y * 6.0 + GetTime()) * fDroopBlend * 0.05;
    return vResult;
}

// result is x=scene distance y=material or object id; zw are material specific parameters (maybe uv co-ordinates)
vec4 GetDistanceScene( const in vec3 vPos )
{         
    vec4 vResult = vec4(10000.0, -1.0, 0.0, 0.0);
                    
    vec3 vClockDomain = WarpDomain(vPos + vec3(0.0, -0.1, -0.45));
    vClockDomain.y += 0.2;	
    vResult = DistCombineUnion(vResult, GetDistanceClock(vClockDomain));
        
    vec4 vWallDist1 = vec4(vPos.z - 0.2, 1.0, vPos.xy);
    vec4 vWallDist2 = vec4(vPos.y, 1.0, vPos.xz);
    vWallDist1 = DistCombineIntersect(vWallDist1, vWallDist2);
    vResult = DistCombineUnion(vResult, vWallDist1);
             
	
    vec4 vFloorDist = vec4(vPos.y + 2.3, 5.0, vPos.xz);
    vResult = DistCombineUnion(vResult, vFloorDist);
	
    return vResult;
}
 
vec3 GetWatchFaceColour( const vec2 vUV )
{
        float fRadius = length(vUV);
       
        float fFraction = (atan(vUV.x, -vUV.y) / (kPI * 2.0)) + (0.5 / 60.0);
               
        float fTickValue = fFraction * 60.0;   
        float fTickIndex = floor(fTickValue);
        float fTickFraction = fract(fTickValue);
               
	float fTickLength = 0.25;       
	fTickLength += step( fract(fTickIndex / 10.0), 0.5 / 10.0 ) * 0.1;
	fTickLength += step( fract(fTickIndex / 5.0), 0.5 / 5.0 ) * 0.05;
	
	float fTickWidth = 0.2;
	float fInTickSegment = step(abs(fTickFraction - 0.5), fTickWidth);
	
	float fInTickRadiusOuter = step(fRadius, 0.8);
	float fInTickRadiusInner = step(1.0 - fTickLength, fRadius);
	
	// 1.0 if not one of these...
	float fBlend = 1.0 - fInTickSegment * fInTickRadiusOuter * fInTickRadiusInner;
	
	// central dot
	fBlend = fBlend * step(0.025, fRadius);                                 
	
	return mix(vec3(0.05), vec3(0.95), fBlend);
}
 
C_Material GetObjectMaterial( const in vec3 vObjId, const in vec3 vPos, const in vec3 vNormal )
{
    C_Material mat;
             
    if(vObjId.x < 1.5)
    {
        // wall
        mat.fR0 = 0.2;
		vec3 cTextureSample = texture2D(iChannel0, vObjId.yz).rgb;
        mat.fSmoothness = cTextureSample.r * cTextureSample.b;
        mat.cAlbedo = cTextureSample * cTextureSample;
    }
    else
    if(vObjId.x < 2.5)
    {
        // silver
        mat.fR0 = 0.95;
        mat.fSmoothness = 0.9;
        mat.cAlbedo = vec3(0.9, 0.9, 0.91);
    }
    else
    if(vObjId.x < 3.5)
    {
	    // clock face
            mat.fR0 = 0.01;
            mat.fSmoothness = 0.9;
            mat.cAlbedo = GetWatchFaceColour( vObjId.yz );
    }
    else
    if(vObjId.x < 4.5)
    {
        // hand
        mat.fR0 = 0.01;
        mat.fSmoothness = 0.9;
        mat.cAlbedo = vec3(0.95, 0.05, 0.05);
    }
    else
    if(vObjId.x < 5.5)
    {
        // floor
        mat.fR0 = 0.01;
		vec3 cTextureSample = texture2D(iChannel1, vObjId.yz).rgb;
        mat.cAlbedo = cTextureSample * cTextureSample;
        mat.fSmoothness = cTextureSample.r * cTextureSample.g;
    }
 
    return mat;
}
vec3 GetLightDirection()
{
    vec3 vLightDir = vec3(1.0, 2.0, 1.0);

    #ifdef ENABLE_MONTE_CARLO       
    vLightDir += gRandomNormal * 0.01;
    #endif
    return normalize(vLightDir);
}
vec3 GetLightCol()
{
    return vec3(1.0, 0.7, 0.5) * 10.0;
}

vec3 GetSkyGradient( const in vec3 vDir )
{
	float fBlend = vDir.y * 0.5 + 0.5;
	return mix(vec3(0.0, 0.0, 0.0), vec3(0.25, 0.5, 1.0) * 4.0, fBlend);
}
 
vec3 GetAmbientLight(const in vec3 vNormal)
{
    return GetSkyGradient(vNormal);
}
 
#define kFogDensity 0.075
void ApplyAtmosphere(inout vec3 col, const in C_Ray ray, const in C_HitInfo intersection)
{
    #ifdef ENABLE_FOG
    // fog
    float fFogAmount = exp(intersection.fDistance * -kFogDensity);
    vec3 cFog = GetSkyGradient(ray.vDir);
    col = mix(cFog, col, fFogAmount);
    #endif
}

vec3 GetSceneNormal( const in vec3 vPos )
{
    // tetrahedron normal
    float fDelta = 0.01;
 
    vec3 vOffset1 = vec3( fDelta, -fDelta, -fDelta);
    vec3 vOffset2 = vec3(-fDelta, -fDelta,  fDelta);
    vec3 vOffset3 = vec3(-fDelta,  fDelta, -fDelta);
    vec3 vOffset4 = vec3( fDelta,  fDelta,  fDelta);
 
    float f1 = GetDistanceScene( vPos + vOffset1 ).x;
    float f2 = GetDistanceScene( vPos + vOffset2 ).x;
    float f3 = GetDistanceScene( vPos + vOffset3 ).x;
    float f4 = GetDistanceScene( vPos + vOffset4 ).x;
 
    vec3 vNormal = vOffset1 * f1 + vOffset2 * f2 + vOffset3 * f3 + vOffset4 * f4;
 
    return normalize( vNormal );
}
 
#define kRaymarchEpsilon 0.01
#define kRaymarchMatIter 20
#define kRaymarchStartDistance 0.01
// This is an excellent resource on ray marching -> http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
void Raymarch( const in C_Ray ray, out C_HitInfo result, const float fMaxDist, const int maxIter )
{       
    result.fDistance = kRaymarchStartDistance;
    result.vObjectId.x = 0.0;
                             
    for(int i=0;i<=kRaymarchMatIter;i++)             
    {
        result.vPos = ray.vOrigin + ray.vDir * result.fDistance;
        vec4 vSceneDist = GetDistanceScene( result.vPos );
        result.vObjectId = vSceneDist.yzw;
 
        // abs allows backward stepping - should only be necessary for non uniform distance functions
        if((abs(vSceneDist.x) <= kRaymarchEpsilon) || (result.fDistance >= fMaxDist) || (i > maxIter))
        {
            break;
        }                       
 
        result.fDistance = result.fDistance + vSceneDist.x;   
    }
     
      
    if(result.fDistance >= fMaxDist)
    {
        result.vPos = ray.vOrigin + ray.vDir * result.fDistance;
        result.vObjectId.x = 0.0;
        result.fDistance = 1000.0;
    }
}
 
float GetShadow( const in vec3 vPos, const in vec3 vLightDir, const in float fLightDistance )
{
    C_Ray shadowRay;
    shadowRay.vDir = vLightDir;
    shadowRay.vOrigin = vPos;
 
    C_HitInfo shadowIntersect;
    Raymarch(shadowRay, shadowIntersect, fLightDistance, 32);
                                                                                                       
    return step(0.0, shadowIntersect.fDistance) * step(fLightDistance, shadowIntersect.fDistance );         
}
 
// http://en.wikipedia.org/wiki/Schlick's_approximation
float Schlick( const in vec3 vNormal, const in vec3 vView, const in float fR0, const in float fSmoothFactor)
{
    float fDot = dot(vNormal, -vView);
    fDot = min(max((1.0 - fDot), 0.0), 1.0);
    float fDot2 = fDot * fDot;
    float fDot5 = fDot2 * fDot2 * fDot;
    return fR0 + (1.0 - fR0) * fDot5 * fSmoothFactor;
}
 
float GetDiffuseIntensity(const in vec3 vLightDir, const in vec3 vNormal)
{
    return max(0.0, dot(vLightDir, vNormal));
}
 
float GetBlinnPhongIntensity(const in C_Ray ray, const in C_Material mat, const in vec3 vLightDir, const in vec3 vNormal)
{         
    vec3 vHalf = normalize(vLightDir - ray.vDir);
    float fNdotH = max(0.0, dot(vHalf, vNormal));
 
    float fSpecPower = exp2(4.0 + 6.0 * mat.fSmoothness);
    float fSpecIntensity = (fSpecPower + 2.0) * 0.125;
 
    return pow(fNdotH, fSpecPower) * fSpecIntensity;
}
 
// use distance field to evaluate ambient occlusion
float GetAmbientOcclusion(const in C_Ray ray, const in C_HitInfo intersection, const in vec3 vNormal)
{
    vec3 vPos = intersection.vPos;
     
    float fAmbientOcclusion = 1.0;
     
    float fDist = 0.0;
    for(int i=0; i<=5; i++)
    {
        fDist += 0.1;
 
        vec4 vSceneDist = GetDistanceScene(vPos + vNormal * fDist);
 
        fAmbientOcclusion *= 1.0 - max(0.0, (fDist - vSceneDist.x) * 0.2 / fDist );                                 
    }
     
    return fAmbientOcclusion;
}
 
vec3 GetObjectLighting(const in C_Ray ray, const in C_HitInfo intersection, const in C_Material material, const in vec3 vNormal, const in vec3 cReflection)
{
    vec3 cScene ;
   
    vec3 vSpecularReflection = vec3(0.0);
    vec3 vDiffuseReflection = vec3(0.0);
   
    float fAmbientOcclusion = GetAmbientOcclusion(ray, intersection, vNormal);
    vec3 vAmbientLight = GetAmbientLight(vNormal) * fAmbientOcclusion;
   
    vDiffuseReflection += vAmbientLight;
   
    vSpecularReflection += cReflection * fAmbientOcclusion;
             
    #ifdef ENABLE_DIRECTIONAL_LIGHT
    vec3 vLightDir = GetLightDirection();
      
    float fShadowBias = 0.05;           
    float fShadowFactor = GetShadow( intersection.vPos + vLightDir * fShadowBias, vLightDir, 10.0 );
    vec3 vIncidentLight = GetLightCol() * fShadowFactor;
   
    vDiffuseReflection += GetDiffuseIntensity( vLightDir, vNormal ) * vIncidentLight;                                                                               
    vSpecularReflection += GetBlinnPhongIntensity( ray, material, vLightDir, vNormal ) * vIncidentLight;
    #endif // ENABLE_DIRECTIONAL_LIGHT
   
    vDiffuseReflection *= material.cAlbedo;             
    
    #ifdef ENABLE_SPECULAR
    float fFresnel = Schlick(vNormal, ray.vDir, material.fR0, material.fSmoothness * 0.9 + 0.1);
    cScene = mix(vDiffuseReflection , vSpecularReflection, fFresnel);
    #else
    cScene = vDiffuseReflection;
    #endif
   
    return cScene;
}
 
vec3 GetSceneColourSimple( const in C_Ray ray )
{
    C_HitInfo intersection;
    Raymarch(ray, intersection, 10.0, 32);
                       
    vec3 cScene;
 
    if(intersection.vObjectId.x < 0.5)
    {
        cScene = GetSkyGradient(ray.vDir);
    }
    else
    {
        vec3 vNormal = GetSceneNormal(intersection.vPos);
        C_Material material = GetObjectMaterial(intersection.vObjectId, intersection.vPos, vNormal);
 
        // use sky gradient instead of reflection
        vec3 cReflection = GetSkyGradient(reflect(ray.vDir, vNormal));
 
        // apply lighting
        cScene = GetObjectLighting(ray, intersection, material, vNormal, cReflection );
    }
 
    ApplyAtmosphere(cScene, ray, intersection);
 
    return cScene;
}
 
vec3 GetSceneColour( const in C_Ray ray )
{                                                         
    C_HitInfo intersection;
    Raymarch(ray, intersection, 30.0, 256);
               
    vec3 cScene;
     
    if(intersection.vObjectId.x < 0.5)
    {
        cScene = GetSkyGradient(ray.vDir);
    }
    else
    {
        vec3 vNormal = GetSceneNormal(intersection.vPos);
        C_Material material = GetObjectMaterial(intersection.vObjectId, intersection.vPos, vNormal);
 
        #ifdef ENABLE_MONTE_CARLO
        vNormal = normalize(vNormal + gRandomNormal / (5.0 + material.fSmoothness * 200.0));
        #endif
 
        vec3 cReflection;
        #ifdef ENABLE_REFLECTIONS   
        {
            // get colour from reflected ray
            float fSepration = 0.05;
            C_Ray reflectRay;
            reflectRay.vDir = reflect(ray.vDir, vNormal);
            reflectRay.vOrigin = intersection.vPos + reflectRay.vDir * fSepration;
                                                                 
            cReflection = GetSceneColourSimple(reflectRay);                                                                       
        }
        #else
        cReflection = GetSkyGradient(reflect(ray.vDir, vNormal));                             
        #endif
        // apply lighting
        cScene = GetObjectLighting(ray, intersection, material, vNormal, cReflection );
    }
     
    ApplyAtmosphere(cScene, ray, intersection);
     
    return cScene;
}
 
void GetCameraRay( const in vec3 vPos, const in vec3 vForwards, const in vec3 vWorldUp, const in vec2 fragCoord, out C_Ray ray)
{
    vec2 vPixelCoord = fragCoord.xy;
    #ifdef ENABLE_MONTE_CARLO
    vPixelCoord += gPixelRandom.zw;
    #endif
    vec2 vUV = ( vPixelCoord / iResolution.xy );
    vec2 vViewCoord = vUV * 2.0 - 1.0;
 
    vViewCoord *= 0.75;
     
    float fRatio = iResolution.x / iResolution.y;
 
    vViewCoord.y /= fRatio;                         
 
    ray.vOrigin = vPos;
 
    vec3 vRight = normalize(cross(vForwards, vWorldUp));
    vec3 vUp = cross(vRight, vForwards);
       
    ray.vDir = normalize( vRight * vViewCoord.x + vUp * vViewCoord.y + vForwards);       
}
 
void GetCameraRayLookat( const in vec3 vPos, const in vec3 vInterest, const in vec2 fragCoord, out C_Ray ray)
{
    vec3 vForwards = normalize(vInterest - vPos);
    vec3 vUp = vec3(0.0, 1.0, 0.0);
 
    GetCameraRay(vPos, vForwards, vUp, fragCoord, ray);
}
 
vec3 OrbitPoint( const in float fHeading, const in float fElevation )
{
    return vec3(sin(fHeading) * cos(fElevation), sin(fElevation), cos(fHeading) * cos(fElevation));
}
 
vec3 Gamma( const in vec3 cCol )
{
    return sqrt(cCol);
}
 
vec3 InvGamma( const in vec3 cCol )
{
    return cCol * cCol;
}
 
 
vec3 Tonemap( const in vec3 cCol )
{
    
    vec3 vResult = 1.0 - exp2(-cCol);
 
    return Gamma(vResult);
}
 
vec3 InvTonemap( const in vec3 cCol )
{
    vec3 vResult = cCol;
    vResult = clamp(vResult, 0.01, 0.99);
    vResult = InvGamma(vResult);
    return - log2(1.0 - vResult);
}
 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    #ifdef ENABLE_MONTE_CARLO           
    CalcPixelRandom();
    #endif
     
    C_Ray ray;
     
    const float fCamreaHeadingMin = -0.8;
    const float fCamreaHeadingMax = 1.8;
    const float fCamreaElevationMin = 0.1;
    const float fCamreaElevationMax = 0.7;
    const float fCamreaDistMin = 3.0;
    const float fCamreaDistMax = 2.0;

    vec2 vMouse = iMouse.xy / iResolution.xy;
	
	// If we have never moved the mouse
	if(iMouse.x <= 0.0)
	{
		vMouse.xy = vec2(0.0, 1.0);
	}
			
	
    float fHeading = mix(fCamreaHeadingMin, fCamreaHeadingMax, vMouse.x);
    float fElevation = mix(fCamreaElevationMin, fCamreaElevationMax, vMouse.y);
    float fCameraDist = mix(fCamreaDistMax, fCamreaDistMin, vMouse.y);
   
    vec3 vCameraPos = OrbitPoint(fHeading, fElevation) * fCameraDist;
   
    #ifdef ENABLE_MONTE_CARLO           
    float fDepthOfField = 0.025;
    vCameraPos += gRandomNormal * fDepthOfField;
    #endif
     
    GetCameraRayLookat( vCameraPos, vec3(0.0, -0.5, 0.2), fragCoord, ray);
     
    vec3 cScene = GetSceneColour( ray ); 
      
    float fExposure = 0.4;
    cScene = cScene * fExposure;

	// vignette
	vec2 vUV = ((fragCoord.xy / iResolution.xy) - 0.5) * 2.0;
	float fDist = dot(vUV, vUV);
	fDist = fDist * fDist;
	float fAmount = 1.0 / (fDist * 5.0 + 1.0);
	cScene = cScene * fAmount;

    #ifdef ENABLE_MONTE_CARLO                             
    vec3 cPrev = texture2D(backbuffer, vUV).xyz;
    // add noise to pixel value (helps values converge)
    cPrev += (gPixelRandom.xyz - 0.5) * (1.0 / 255.0);
    cPrev = InvTonemap(cPrev);
    // converge speed
    //float fBlend = 0.1;
	float fBlend = 1.0;
    vec3 cFinal = mix(cPrev, cScene, fBlend);
    #else
    vec3 cFinal = cScene;
    #endif
   
    cFinal = Tonemap(cFinal);
         
    float fAlpha = 1.0;
     
    fragColor = vec4( cFinal, fAlpha );
}
 