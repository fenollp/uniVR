// Shader downloaded from https://www.shadertoy.com/view/XsX3Dr
// written by shadertoy user P_Malin
//
// Name: Palindrome
// Description: My attempt at a demo like sequence in a shader.
//    The code is a bit messy. I was just having fun.
//    The framerate is low. I may try to optimize some bits and pieces.
#define kRaymarchMaxIter 96

//#define LOW_QUALITY

//#define OVERRIDE_TIME

const vec3 cSkyColourTop = vec3(0.2, 0.05, 0.15) * 0.5;
const vec3 cSkyColourHorizon = vec3(0.4, 0.1, 0.01) * 2.0;
const vec3 cSunScatteringColour = vec3(1.0, 0.01, 0.005) * 1.0;

const vec3 cFogColour = vec3(0.4, 0.05, 0.01) * 2.0;

const vec3 cSunColour = vec3(1.0, 0.01, 0.005) * 5.0;
vec3 vSunDirection = normalize(vec3(-0.3, 0.2, -0.7));

const vec3 cSunLightColour = vec3(1.0, 0.15, 0.025) * 1.0;
const vec3 cAmbientLight = vec3(0.4, 0.1, 0.01) * 0.2;

const vec3 vPortalPos = vec3(0.0, 2.7, 20.0);

const float fSequenceLength = 18.0;

mat3 g_mPortalRotation;
float g_fTime = 0.0;
float g_fSceneTime = 0.0;
float g_ReverseEffectEnabled= 0.0;

struct C_Ray
{
    vec3 vOrigin;
    vec3 vDir;
    float fStartDistance;
    float fLength;
};

struct C_HitInfo
{
    vec3 vPos;
    float fDistance;
    float fObjectId;
};
    
struct C_Surface
{
    vec3 vNormal; 
};

struct C_Material
{
    vec3 cAlbedo;
};
	
/////////////////////////////////////
// Distance Field CSG
// These carry with them the material parameters in y

vec2 DistCombineUnion( const in vec2 v1, const in vec2 v2 )
{
    //if(v1.x < v2.x) return v1; else return v2;
    return mix(v1, v2, step(v2.x, v1.x));
}

/////////////////////////////////////
// Scene Description 

float GetRayFirstStep( const in C_Ray ray )
{
	return ray.fStartDistance;
}

float hash( const in float n ) {
	return fract(sin(n)*43758.5453);
}

float smoothnoise(const in float o) 
{
	float p = floor(o);
	float f = fract(o);
		
	float n = p;

	float a = hash(n+  0.0);
	float b = hash(n+  1.0);
	
	float f2 = f * f;
	float f3 = f2 * f;
	
	float t = 3.0 * f2 - 2.0 * f3;
	
	return mix(a, b, t);
}

float smoothnoise(in vec2 o) 
{
	vec2 p = floor(o);
	vec2 f = fract(o);
		
	float n = p.x + p.y*57.0;

	float a = hash(n+  0.0);
	float b = hash(n+  1.0);
	float c = hash(n+ 57.0);
	float d = hash(n+ 58.0);
	
	vec2 f2 = f * f;
	vec2 f3 = f2 * f;
	
	vec2 t = 3.0 * f2 - 2.0 * f3;
	vec2 dt = 6.0 * f - 6.0 * f2;
	
	float u = t.x;
	float du = dt.x;	
	float v = t.y;
	float dv = dt.y;	

	float res = a + (b-a)*u +(c-a)*v + (a-b+d-c)*u*v;
	
	//float dx = (b-a)*du + (a-b+d-c)*du*v;
	//float dy = (c-a)*dv + (a-b+d-c)*u*dv;
	
	return res;
}

float smoothnoise(const in vec3 o) 
{
	vec3 p = floor(o);
	vec3 fr = fract(o);
		
	float n = p.x + p.y*101.0 + p.z * 4001.0;

	float a = hash(n+   0.0);
	float b = hash(n+   1.0);
	float c = hash(n+ 101.0);
	float d = hash(n+ 102.0);
	float e = hash(n+4001.0);
	float f = hash(n+4002.0);
	float g = hash(n+4102.0);
	float h = hash(n+4103.0);
	
	vec3 fr2 = fr * fr;
	vec3 fr3 = fr2 * fr;
	
	vec3 t = 3.0 * fr2 - 2.0 * fr3;
		
	return mix(
			    mix( mix(a,b, t.x),
		             mix(c,d, t.x), t.y),
			    mix( mix(e,f, t.x),
		             mix(g,h, t.x), t.y),
			t.z);
}

float GetDistanceGround( const in vec3 vPos )
{
	float fResult = vPos.y;
	
	float h = smoothnoise(vPos.xz * 0.1);		
	float fRidgePos = vPos.x + h * 10.0;
	
	float s = sin(fRidgePos);
	s *= sin(vPos.z * 0.1 + vPos.x * 0.2);
	s = s * 0.5 + 0.5;	
	s = sqrt(s);
	
	vec2 vFlattenPos = abs(vPos.xz);
	float fFlattenDist = max(vFlattenPos.x, vFlattenPos.y);
	float fFlatten = smoothstep(50.0, 65.0, fFlattenDist);
	fResult += mix(0.0, s, fFlatten);

	#ifndef LOW_QUALITY
	float s2= sin(fRidgePos * 40.0);
	s2 = s2 * 0.5 + 0.5;	
	fResult += s2 * s * 0.01;
	#endif

	return fResult;
}

vec2 GetDistancePyramid(const in vec3 vPos, const in float fWorldNoise)
{
	vec2 vResult;
	vResult.y = 2.0; // object id

	float fPyramidSize = 50.0;
	
	vec3 vStepPos = vPos;
	vStepPos.y -= fPyramidSize;
	vStepPos.xz = abs(vStepPos.xz) - 0.5;
	vec2 vStepOffset = floor((vStepPos.y - vStepPos.xz) * 0.5 + 0.5);
	float fStepOffset = min(vStepOffset.x, vStepOffset.y);
	
	vStepPos.x += fStepOffset;	
	vStepPos.y -= fStepOffset;
	vStepPos.z += fStepOffset;

	vec3 vClosest = min(vStepPos.xyz, vec3(0.0));	
	
	vResult.x = length(vStepPos - vClosest);	
	
	float fFlatSide = (vPos.y + max(abs(vPos.x), abs(vPos.z))) - 50.0;
	vResult.x = mix(vResult.x, fFlatSide, 0.3);
		
	const float fTunnelHeight = 4.0;
	const float fTunnelWidth = 1.0;
	float fTunnelInner = min(min(fTunnelWidth - abs(vPos.x), fTunnelHeight - vPos.y), 35.0-vPos.z);

	const float fTunnelThickness = 1.5;
	const float fTunnelExtent = 2.0;
	float fTunnelOuter = max(abs(vPos.x) - (fTunnelWidth + fTunnelThickness), vPos.y - (fTunnelHeight + fTunnelThickness));
	fTunnelOuter = max(fTunnelOuter, vPos.y + abs(vPos.z + fTunnelExtent) - (fPyramidSize));
	
	vResult.x = min(vResult.x, fTunnelOuter);
	vResult.x = max(vResult.x, fTunnelInner);
	
	float fRoomWallDist = (vPos.y + max(abs(vPos.x), abs(vPos.z - 20.0)));
	float fInnerRoom = 20.0 - fRoomWallDist;
	vResult.x = max(vResult.x, fInnerRoom);
	
	vResult.x -= 0.1 - clamp(fWorldNoise, 0.0, 1.0) * 0.1;	
	
	return vResult;
}

vec2 GetDistancePyramids( const in vec3 vPos )
{
	#ifdef LOW_QUALITY
	float fWorldNoise = 0.0;
	#else
	float fWorldNoise = smoothnoise(vPos * 2.0);
	#endif
		
	float fHeight = 0.0;
	vec3 vPyramidPos = vPos;
	if(vPyramidPos.x > 50.0)
	{
		vPyramidPos.x -= 100.0;
		vPyramidPos.z += 100.0;
		fHeight = 10.0;
	}

	if(vPyramidPos.x < -70.0)
	{
		vPyramidPos.x += 100.0;
		vPyramidPos.z += 200.0;
		fHeight = 20.0;
	}
	
	vPyramidPos.y = max(vPyramidPos.y + fHeight, fHeight);
	
	vec2 vPyramidDistance = GetDistancePyramid( vPyramidPos, fWorldNoise );	
	
	return vPyramidDistance;
}

// result is x=scene distance y=material or object id; zw are material specific parameters (maybe uv co-ordinates)
vec2 GetDistanceScene( const in vec3 vPos, const in float fShadow )
{          
    vec2 vResult = vec2(10000.0, -1.0);
    
	float fScale = 1.0;
	vec3 vPyramidPos = vPos;
	vec3 vSmallPyramidPos = vPyramidPos - vec3(0.0, 0.0, 20.0);
	vec3 vAbsPos = abs(vSmallPyramidPos);	
	if( max(vAbsPos.x, vAbsPos.z) + vSmallPyramidPos.y < 15.0 )
	{
		vSmallPyramidPos.y -= 0.5;
		fScale = 30.0;
		vPyramidPos = vSmallPyramidPos * fScale;
	}	
	
	vec2 vPyramidDistance = GetDistancePyramids( vPyramidPos );	
	vPyramidDistance.x /= fScale;
	
	float fRoomWallDist = (vPos.y + max(abs(vPos.x), abs(vPos.z - 17.0)));
	float fPedistalDist = max(fRoomWallDist - 7.0, vPos.y - 0.5);
	vPyramidDistance.x = min(vPyramidDistance.x, fPedistalDist);
	
	vec2 vFloorDistance = vec2(GetDistanceGround( vPos ), 1.0);
	vResult = vFloorDistance;

	vResult = DistCombineUnion(vResult, vPyramidDistance);
	
	if(fShadow > 0.5)
	{
		vec2 vPortalDistance = vec2( (length(vPos - vPortalPos) - 0.1), 3.0);
		vResult = DistCombineUnion(vResult, vPortalDistance);
	}
	
    return vResult;
}

C_Material GetObjectMaterial( const in C_HitInfo hitInfo )
{
    C_Material mat;  
        
	mat.cAlbedo = vec3(0.8, 0.5, 0.3);
	
	if(hitInfo.fObjectId > 1.0)
	{
    	mat.cAlbedo = vec3(1.0, 0.8, 0.5);
	}
	else if(hitInfo.fObjectId > 2.0)
	{
		mat.cAlbedo = vec3(1.0, 1.0, 1.0);
	}

    return mat;
}

vec3 GetSkyColour( const in vec3 vDir )
{

    float fBlend = clamp(vDir.y, 0.0, 1.0);
	fBlend = 1.0 - fBlend;
	
	
    vec3 vResult =  mix(cSkyColourHorizon, cSkyColourTop, 1.0 - fBlend * fBlend * fBlend);
		
	float fSunDot = max(dot(vDir, vSunDirection), 0.0);
	vResult += (pow(fSunDot, 500.0) + fSunDot * fSunDot) * cSunScatteringColour;
	
	float fSun = clamp(5000.0 * (fSunDot - 0.999), 0.0, 1.0);	
	vResult = vResult + cSunColour * fSun;
	
	return vResult;
}

////////////////////////////////
// Raymarching 

vec3 GetSceneNormal( const in vec3 vPos )
{
    // tetrahedron normal
    const float fDelta = 0.025;

    vec3 vOffset1 = vec3( fDelta, -fDelta, -fDelta);
    vec3 vOffset2 = vec3(-fDelta, -fDelta,  fDelta);
    vec3 vOffset3 = vec3(-fDelta,  fDelta, -fDelta);
    vec3 vOffset4 = vec3( fDelta,  fDelta,  fDelta);

    float f1 = GetDistanceScene( vPos + vOffset1, 1.0 ).x;
    float f2 = GetDistanceScene( vPos + vOffset2, 1.0 ).x;
    float f3 = GetDistanceScene( vPos + vOffset3, 1.0 ).x;
    float f4 = GetDistanceScene( vPos + vOffset4, 1.0 ).x;

    vec3 vNormal = vOffset1 * f1 + vOffset2 * f2 + vOffset3 * f3 + vOffset4 * f4;

    return normalize( vNormal );
}

#define kRaymarchEpsilon 0.001

// This is an excellent resource on ray marching -> http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
void Raymarch( const in C_Ray ray, out C_HitInfo result, const int maxIter, const in float fShadow )
{        
    result.fDistance = GetRayFirstStep( ray );
    result.fObjectId = 0.0;
        
    for(int i=0;i<=kRaymarchMaxIter;i++)              
    {
        result.vPos = ray.vOrigin + ray.vDir * result.fDistance;
        vec2 vSceneDist = GetDistanceScene( result.vPos, fShadow );
        result.fObjectId = vSceneDist.y;
        
        // abs allows backward stepping - should only be necessary for non uniform distance functions
        if((abs(vSceneDist.x) <= kRaymarchEpsilon) || (result.fDistance >= ray.fLength) || (i > maxIter))
        {
            break;
        }                        

        result.fDistance = result.fDistance + vSceneDist.x; 
    }


    if(result.fDistance >= ray.fLength)
    {
        result.fDistance = 1000.0;
        result.vPos = ray.vOrigin + ray.vDir * result.fDistance;
        result.fObjectId = 0.0;
    }
}

float calcAO( in vec3 pos, in vec3 nor )
{
	float totao = 0.0;
    float sca = 1.0;
    for( int aoi=0; aoi<8; aoi++ )
    {
        float hr = 0.01 + 1.2*pow(float(aoi)/8.0,1.5);
        vec3 aopos =  nor * hr + pos;
        float dd = GetDistanceScene( aopos, 0.0 ).x;
        totao += -(dd-hr)*sca;
        sca *= 0.85;
    }
    return clamp( 1.0 - 1.0*totao, 0.0, 1.0 );
}

vec3 ShadeSurface(const in C_Ray ray, const in C_HitInfo hitInfo, const in C_Surface surface, const in C_Material material, float fInsideDist)
{
    vec3 cScene;
    
    vec3 vAmbientLight;
			
	vec3 vDiffuseLight = vec3(0.0);

	vec3 vToLight;
	vec3 cLightColour;
	
	float fPortalOn = smoothstep(9.0, 9.5, g_fTime);
	
	if(fInsideDist > 0.0)
	{
		vToLight = vSunDirection * 100.0;
		cLightColour = cSunLightColour;
		vAmbientLight = cAmbientLight;
	}
	else
	{
		vec3 vLightPos;		
		
		// apply point light
		{
			
			if((hitInfo.vPos.z - hitInfo.vPos.y) < 0.01)
			{
				float fLightId = floor(min(max(hitInfo.vPos.z, -50.0), 0.0) * 0.1 + 0.5);
				vLightPos = vec3(0.5 * sign(hitInfo.vPos.x), 2.5, 10.0 * fLightId - 0.5);		
				
				float fFlicker = (smoothnoise(fLightId + iGlobalTime * 500.0) * 0.5 + 0.5);
				cLightColour = vec3(1.0, 0.5, 0.1) * fFlicker * 0.01;
				vAmbientLight = cAmbientLight * 0.01;
			}
			else
			{
				vLightPos = vPortalPos;
				vec3 vToLight = vLightPos - hitInfo.vPos;
				
				cLightColour = textureCube(iChannel0, vToLight * g_mPortalRotation).rgb;
				cLightColour = cLightColour * cLightColour * 10.0 * vec3(0.0, 1.0, 0.0);

				float fFft = smoothstep(0.7, 0.9, texture2D(iChannel3, vec2(0.018, 0.0)).r);
				fFft = fFft * fFft;
				cLightColour = vec3(1.0, 0.2, 0.1) * fFft + cLightColour * fPortalOn;
				vAmbientLight = vec3(1.0, 0.2, 0.1) * 0.001;								
			}					
		}
		
		vToLight = vLightPos - hitInfo.vPos;
		float fDist2 = dot(vToLight, vToLight);
		cLightColour /= fDist2;
	}

	C_Ray shadowRay;
	shadowRay.vOrigin = hitInfo.vPos;
	shadowRay.fLength = length(vToLight);
	shadowRay.vDir = normalize(vToLight);
	shadowRay.fStartDistance = dot(shadowRay.vDir, surface.vNormal);
	C_HitInfo shadowHitInfo;
	Raymarch(shadowRay, shadowHitInfo, 64, 0.0);
	
	float fShadow = 1.0;
	if(shadowHitInfo.fDistance < 90.0)
	{
		fShadow = 0.0;
	}
	
	vec3 vLightDir = normalize(vToLight);
	float fDiffuseLight = clamp(dot(surface.vNormal, vLightDir), 0.0, 1.0) * fShadow;
	
	vDiffuseLight += fDiffuseLight * cLightColour;
	
	float fAmbientOcclusion = calcAO(hitInfo.vPos, surface.vNormal);
	
    vDiffuseLight += vAmbientLight * fAmbientOcclusion;
              
    vec3 vDiffuseReflection = vDiffuseLight * material.cAlbedo;              

    cScene = vDiffuseReflection;
    
    return cScene;
}

vec3 GetSceneColour( const in C_Ray ray )
{                                                          
    C_HitInfo intersection;
    Raymarch(ray, intersection, 256, 1.0);
                
    vec3 cScene;

    if(intersection.fObjectId < 0.5)
    {
		cScene = GetSkyColour(ray.vDir);
    }
    else
    {
        C_Surface surface;
        
        surface.vNormal = GetSceneNormal(intersection.vPos);

		if(intersection.fObjectId > 2.5)
		{
			// flip portal light source surface
			surface.vNormal = -surface.vNormal;
		}

        C_Material material = GetObjectMaterial(intersection);

		vec3 vAbsPos = abs(intersection.vPos);
		float fInsideDist = (max(vAbsPos.x, vAbsPos.z) + vAbsPos.y) - 46.0;

        // apply lighting
        cScene = ShadeSurface(ray, intersection, surface, material, fInsideDist);					
		
		if( fInsideDist > 0.0 )
		{
			// apply fog	
			float fNoise = smoothnoise((intersection.vPos.xz) * 0.1 + g_fSceneTime * 10.0);
			float fDensity= 0.04;
			float fHeightFalloff = 0.5;
			
			float fogAmount = fDensity * exp(-ray.vOrigin.y*fHeightFalloff) * (1.0-exp(-intersection.fDistance*ray.vDir.y*fHeightFalloff ))/ray.vDir.y;
			fogAmount *= (0.5 + fNoise * 0.5);
			cScene = mix(cScene, cFogColour, fogAmount);
		}
    }
	
    return cScene;
}

float kFarClip = 1000.0;

void GetCameraRay( const in vec3 vPos, const in vec3 vForwards, const in vec3 vWorldUp, in vec2 fragCoord, out C_Ray ray)
{
    vec2 vUV = ( fragCoord.xy / iResolution.xy );
    vec2 vViewCoord = vUV * 2.0 - 1.0;
	
    float fRatio = iResolution.x / iResolution.y;
    vViewCoord.y /= fRatio;                          

	vViewCoord *= 0.75;
	
    ray.vOrigin = vPos;
	
    vec3 vRight = normalize(cross(vForwards, vWorldUp));
    vec3 vUp = cross(vRight, vForwards);
        
    ray.vDir = normalize( vRight * vViewCoord.x + vUp * vViewCoord.y + vForwards); 
    ray.fStartDistance = 0.0;
    ray.fLength = kFarClip;      
}

void GetCameraRayLookat( const in vec3 vPos, const in vec3 vInterest, in vec2 fragCoord, out C_Ray ray)
{
    vec3 vForwards = normalize(vInterest - vPos);
    vec3 vUp = vec3(0.0, 1.0, 0.0);

    GetCameraRay(vPos, vForwards, vUp, fragCoord, ray);	
}


void GetCameraPosAndTarget( float fCameraIndex, out vec3 vCameraPos, out vec3 vCameraTarget )
{
	float fCameraCount = 14.0;
	float fCameraIndexModCount = max(min(fCameraIndex, fCameraCount), 0.0);

	if(fCameraIndexModCount < 0.5)
	{
		vCameraPos = vec3(2000.0, 3.0, 500.0);
		vCameraTarget = vCameraPos + vec3(-10.0, -3.0, -10.0);
	}
	else if(fCameraIndexModCount < 1.5)
	{
		vCameraPos = vec3(2000.0, 4.0, 500.0);
		vCameraTarget = vCameraPos + vec3(-10.0, -3.0, -10.0);
	}
	else if(fCameraIndexModCount < 2.5)
	{
		vCameraPos = vec3(2000.0, 3.0, 500.0);
		vCameraTarget = vCameraPos + vec3(15.0, -4.0, -10.0);
	}
	else if(fCameraIndexModCount < 3.5)
	{
		vCameraPos = vec3(2000.0, 20.0, 500.0);
		vCameraTarget = vCameraPos + vec3(15.0, -8.0, -10.0);
	}
	else if(fCameraIndexModCount < 4.5)
	{
		vCameraPos = vec3(500.0, 20.0, 500.0);
		vCameraTarget = vCameraPos + vec3(15.0, -3.0, -10.0);
	}
	else if(fCameraIndexModCount < 5.5)
	{
		vCameraPos = vec3(500.0, 3.0, 500.0) + vec3(100.0, 0.0, 0.0);
		vCameraTarget = vCameraPos + vec3(10.0, -3.0, -10.0);
	}
	else if(fCameraIndexModCount < 6.5)
	{
		vCameraPos = vec3(500.0, 5.0, 500.0) + vec3(100.0, 0.0, 0.0);
		vCameraTarget = vec3(0.0, 10.0, 0.0);
	}
	else if(fCameraIndexModCount < 7.5)
	{
		vCameraPos = vec3(-30.0, 20.0, -200.0);
		vCameraTarget = vec3(0.0, 10.0, 0.0);
	}
	else if(fCameraIndexModCount < 8.5)
	{
		vCameraPos = vec3(0.0, 5.0, -100.0);
		vCameraTarget = vec3(0.0, 0.0, 0.0);
	}
	else if(fCameraIndexModCount < 9.5)
	{
		vCameraPos = vec3(0.0, 1.0, 5.0);
		vCameraTarget = vec3(0.0, 1.0, 20.0);
	}
	else if(fCameraIndexModCount < 10.5)
	{
		vCameraPos = vec3(0.0, 2.0, 5.0);
		vCameraTarget = vec3(0.0, 1.0, 20.0);
	}
	else if(fCameraIndexModCount < 11.5)
	{
		vCameraPos = vec3(10.0, 5.0, 30.0);
		vCameraTarget = vec3(0.0, 1.0, 20.0);
	}
	else if(fCameraIndexModCount < 12.5)
	{
		vCameraPos = vec3(10.0, 6.0, 30.0);
		vCameraTarget = vec3(0.0, 1.0, 20.0);
	}
	else if(fCameraIndexModCount < 13.5)
	{
		vCameraPos = vec3(0.0, 6.0, 20.0);
		vCameraTarget = vec3(0.0, -1.0, 19.0);
	}
	else
	{
		vCameraPos = vec3(0.0, 2.0, 20.0);
		vCameraTarget = vec3(0.0, -10.0, 19.0);
	}
}

vec3 BSpline( const in vec3 a, const in vec3 b, const in vec3 c, const in vec3 d, const in float t)
{
	const mat4 mSplineBasis = mat4( -1.0,  3.0, -3.0, 1.0,
							         3.0, -6.0,  0.0, 4.0,
							        -3.0,  3.0,  3.0, 1.0,
							         1.0,  0.0,  0.0, 0.0) / 6.0;	
	
	float t2 = t * t;
	vec4 T = vec4(t2 * t, t2, t, 1.0);
		
	vec4 vWeights = T * mSplineBasis;
	
	vec3 vResult;

	vec4 vCoeffsX = vec4(a.x, b.x, c.x, d.x);
	vec4 vCoeffsY = vec4(a.y, b.y, c.y, d.y);
	vec4 vCoeffsZ = vec4(a.z, b.z, c.z, d.z);
	
	vResult.x = dot(vWeights, vCoeffsX);
	vResult.y = dot(vWeights, vCoeffsY);
	vResult.z = dot(vWeights, vCoeffsZ);
	
	return vResult;
}

void GetCamera(out vec3 vCameraPos, out vec3 vCameraTarget)
{
	float fCameraGlobalTime = g_fSceneTime;		
	
	float fCameraTime = fract(fCameraGlobalTime);
	float fCameraIndex = floor(fCameraGlobalTime);
	
	vec3 vCameraPosA;
	vec3 vCameraTargetA;
	GetCameraPosAndTarget(fCameraIndex, vCameraPosA, vCameraTargetA);
	
	vec3 vCameraPosB;
	vec3 vCameraTargetB;
	GetCameraPosAndTarget(fCameraIndex + 1.0, vCameraPosB, vCameraTargetB);
	
	vec3 vCameraPosC;
	vec3 vCameraTargetC;
	GetCameraPosAndTarget(fCameraIndex + 2.0, vCameraPosC, vCameraTargetC);
	
	vec3 vCameraPosD;
	vec3 vCameraTargetD;
	GetCameraPosAndTarget(fCameraIndex + 3.0, vCameraPosD, vCameraTargetD);
	
	vCameraPos = BSpline(vCameraPosA, vCameraPosB, vCameraPosC, vCameraPosD, fCameraTime);
	vCameraTarget = BSpline(vCameraTargetA, vCameraTargetB, vCameraTargetC, vCameraTargetD, fCameraTime);
}


vec3 Tonemap( const in vec3 cCol )
{
    return sqrt(1.0 - exp(-cCol));
}

float GetTime()
{
	float fTime = iChannelTime[3] / 8.0;
	#ifdef OVERRIDE_TIME
	fTime = iMouse.x * fSequenceLength / iResolution.x;
	#endif
	
	// hack the preview image
	if(iGlobalTime == 10.0)
	{
		fTime = 30.0 / 8.0;
	}
	
	return mod(fTime, fSequenceLength);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 vUV = (fragCoord.xy / iResolution.xy) * 2.0 - 1.0;

	g_fTime = GetTime();

	// (noisy) motion blur by dithering time per pixel!
	g_fTime += (texture2D(iChannel1, (fragCoord.xy / 64.0) + 0.5).r - 0.5) * 0.005;	
	
	float fTimeWarp = 0.0;
	
	g_ReverseEffectEnabled = smoothstep(13.0, 14.0, g_fTime);
	
	// During the reverse sequence time is further backward at the edge of the screen
	g_fSceneTime = g_fTime;
	if(g_fSceneTime > 13.0)
	{
		float t = (g_fSceneTime - 13.0);
		
		float l = length(vUV);
		fTimeWarp = l * l * g_ReverseEffectEnabled;
		t += fTimeWarp * 0.2;
		
		g_fSceneTime = 13.0 - t * t;

	}	

	g_fSceneTime = max(g_fSceneTime, 0.0);
	
	float a = (g_fSceneTime - 8.0);
	a = a * a * a;
	g_mPortalRotation = mat3(sin(a), 0.0, cos(a), 
					  0.0, 1.0, 0.0,
					  cos(a), 0.0, -sin(a));
 
    vec3 vCameraPos;
    vec3 vCameraInterest;
	GetCamera(vCameraPos, vCameraInterest);
	
	C_Ray ray;
    GetCameraRayLookat( vCameraPos, vCameraInterest, fragCoord, ray);

    vec3 cScene = GetSceneColour( ray );  
    
	float fExposure = 1.5;    
	
	fExposure = mix(fExposure, 0.3, smoothstep(3.45, 3.6, g_fTime));
	fExposure = mix(fExposure, 1.0, smoothstep(5.35, 5.5, g_fTime));
	fExposure = mix(fExposure, 20.0, smoothstep(7.6, 7.8, g_fTime));

	fExposure = mix(fExposure, 1.5, smoothstep(15.0, 17.0, g_fTime));
	
	// vignette
	float fDist = dot(vUV, vUV);
	fDist = fDist * fDist;
	float fAmount = 1.0 / (fDist + 1.0);
	cScene = cScene * fAmount;	
	
	vec3 cColour = Tonemap(cScene * fExposure);

    fragColor = vec4(cColour, 1.0 );
}
