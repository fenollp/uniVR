// Shader downloaded from https://www.shadertoy.com/view/ldfXDj
// written by shadertoy user P_Malin
//
// Name: 3D Audio
// Description: Just playing around making horrible noises. Stereo panning, distance attenuation and independent doppler for each ear.
//    TODO: make nice noises
//////////////////////////////////////

// These need to match the Sound shader

mat3 GetCameraRotMatrix(const in vec3 vCameraPos, const in vec3 vCameraTarget )
{
	vec3 vForward = normalize(vCameraTarget - vCameraPos);
	vec3 vRight = normalize(cross(vec3(0.0, 1.0, 0.0), vForward));
	vec3 vUp = normalize(cross(vForward, vRight));
    
    return mat3(vRight, vUp, vForward);
}

void GetCamera( const in float fTime, out vec3 vCameraPos, out mat3 mCameraRot )
{
	vCameraPos = vec3(sin(fTime * 0.5) * 20.0, 0.0, -10.0);
	//vec3 vCameraTarget = vec3(sin(fTime * 1.0) * 16.0, 0.0, 0.0);
    vec3 vCameraTarget = vCameraPos + vec3(sin(fTime), 0.0, cos(fTime)) * 3.0;    
    mCameraRot = GetCameraRotMatrix(vCameraPos, vCameraTarget);
}

//////////////////////////////////////

vec2 GetWindowCoord( const in vec2 vUV )
{
	vec2 vWindow = vUV * 2.0 - 1.0;
	vWindow.x *= iResolution.x / iResolution.y;

	return vWindow;	
}

vec3 CameraToWorld( vec3 vCameraPos, const in mat3 mCameraRot )
{
    return vCameraPos * mCameraRot;
}

vec3 GetCameraRayDir( const in vec2 vWindow, const in mat3 mCameraRot )
{
	vec3 vDir = normalize( CameraToWorld(vec3(vWindow.x, vWindow.y, 2.0), mCameraRot) );

	return vDir;
}

vec3 ApplyVignetting( const in vec2 vUV, const in vec3 vInput )
{
	vec2 vOffset = (vUV - 0.5) * sqrt(2.0);
	
	float fDist = dot(vOffset, vOffset);
	
	const float kStrength = 0.8;
	
	float fShade = mix( 1.0, 1.0 - kStrength, fDist );	

	return vInput * fShade;
}

vec3 ApplyTonemap( const in vec3 vLinear )
{
	const float kExposure = 1.0;
	
	return 1.0 - exp2(vLinear * -kExposure);	
}

vec3 ApplyGamma( const in vec3 vLinear )
{
	const float kGamma = 2.2;

	return pow(vLinear, vec3(1.0/kGamma));	
}

float Checker(const in vec2 vUV)
{
	return step(fract((floor(vUV.x) + floor(vUV.y)) * 0.5), 0.25);
}

vec3 GetSource0Pos(float t)
{
    return vec3(0.0, 0.0, 0.0);
}

vec3 GetSource1Pos(float t)
{
    return vec3(mod(t * 10.0, 50.0) - 25.0, 0.0, -5.0);
}

vec3 GetLight( vec3 vLightPos, vec3 vLightColour, const in vec3 vRayOrigin,  const in vec3 vRayDir )
{    
    vec3 vToLight = vLightPos - vRayOrigin;
    float fPointDot = dot(vToLight, vRayDir);
    fPointDot = clamp(fPointDot, 0.0, 100.0);

    vec3 vClosestPoint = vRayOrigin + vRayDir * fPointDot;
    float fDist = length(vClosestPoint - vLightPos);
	return sqrt(vLightColour * 0.5 / (fDist * fDist));    
}

vec3 GetSceneColour( const in vec3 vRayOrigin,  const in vec3 vRayDir )
{
    vec3 vResult = vec3(0.0);

    vec3 d = vec3(1.0, 1.0, 3.0) / vRayDir;
	float t = -d.y;
    if( (t > 0.0) && (t < 20.0))
    {
		vec3 vPos = vRayOrigin + vRayDir * t + vec3(0.5);
		vResult = mix(vec3(1.0), vec3(0.0), Checker(vPos.xz) );
        if(vPos.x > 0.0)
            vResult *= 0.5;
    }
 
    vec3 vLight0Colour = mix(vec3(1.0, 1.0, 0.1), vec3(0.1, 0.05, 0.0),  floor(fract(iGlobalTime) * 2.0)) * 10.0;
    
    vResult += GetLight(GetSource0Pos(iGlobalTime), vLight0Colour, vRayOrigin, vRayDir);

    vec3 vLight1Colour = vec3(0.2, 0.9, 2.0) * 10.0;
    //vec3 vLight1Colour = mix(vec3(0.2, 0.9, 2.0), vec3(0.0, 0.25, 0.5),  floor(fract(iGlobalTime + 0.5) * 2.0)) * 10.0;
    vResult += GetLight(GetSource1Pos(iGlobalTime), vLight1Colour, vRayOrigin, vRayDir);

    return vResult;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 vUV = fragCoord.xy / iResolution.xy;

	vec3 vCameraPos;
    mat3 mCameraRot;
    
    GetCamera(iGlobalTime, vCameraPos, mCameraRot);

	vec3 vRayOrigin = vCameraPos;
    vec3 vRayDir = GetCameraRayDir( GetWindowCoord(vUV), mCameraRot );
	
	vec3 vResult = GetSceneColour(vRayOrigin, vRayDir);
	
	vResult = ApplyVignetting( vUV, vResult );	
	
	vec3 vFinal = ApplyGamma(ApplyTonemap(vResult));
	
	fragColor = vec4(vFinal, 1.0);
}
