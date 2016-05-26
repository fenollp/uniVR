// Shader downloaded from https://www.shadertoy.com/view/MlsSzf
// written by shadertoy user P_Malin
//
// Name: [SIG15] The DeLorean
// Description: Ironically running out of time to do everything I wanted - I should have started this a lot sooner. 
//    Thanks to my wife for her infinite patience.
// [SIG15] The DeLorean
// @P_Malin

// Entry for @shadertoy [SIG15] competition

// Ironically running out of time to do everything I wanted - I should have started this a lot sooner. 
// Thanks to my wife for her infinite patience.

// Performance
//#define SIMPLE_CAR
//#define EFFECTS_DISABLED

// Slow & not working
//#define REFLECT_EFFECTS

#define kRaymarchMaxIter 48
#define kEffectMaxIter 150

#define kBounceCount 2

// Debug
//#define TIME_SLIDER
//#define DISPLAY_TIME
//#define ORBIT_CAM

//#define DISABLE_MOTION_BLUR

float kFarClip=1000.0; 

vec3 vLightPos = vec3(0.0, -0.5, 0.0);			
vec3 vLightColour = vec3(1.0, 0.8, 0.4);

float gTimeDither;
float gTime;

float pixelRandom;

// Sequence globals

vec3 g_vCameraPos = vec3(0.0);
vec3 g_vCameraTarget = vec3(0.0, 0.0, -1.0);
vec3 g_vCarPos = vec3(0.0);
float fFieldOfView = 5.0;

float fSmoke = 0.0;
float fSpeedDisplay = -1.0;
float fGlowEffect = -1.0;
float g_fPanelDisplay = -1.0;
float gFogCoeff = 0.05;
float gEffectBegin = 0.0;
float gDrawCar = 1.0;
float gFlameEffect = -1.0;
vec3 g_vFlamePos = vec3(0.0);
float gFlameEffectEnd = 0.0;
float gFlameWidth = 0.3;
float gExplode = -1.0;
float gTextFade = 0.0;
float gEffectScale = 1.0;

float gFlash = 0.0;

float gWheelRotation = 0.0;


vec2 GetWindowCoord( const in vec2 vUV );
vec3 GetCameraRayDir( const in vec2 vWindow, const in vec3 vCameraPos, const in vec3 vCameraTarget );
vec3 GetSceneColour( in vec3 vRayOrigin,  in vec3 vRayDir );
vec3 ApplyPostFX( const in vec2 vUV, const in vec3 vInput );

float Debug_PrintFloatApprox( const in vec2 uv, const in vec2 fontSize, const in float value, const in float maxDigits, const in float decimalPlaces );

float noise( in vec2 x );
float noise( in vec3 x );

float kAccelTime = 13.0;

float kFinalDistance = 1000.0;

float CarZAtTravelTime( float t )
{
    float z = 0.0;
  
    if( t > kAccelTime )
    {
        float nt = t / kAccelTime;
        float kFinalSpeed = 100.0;
        z = kFinalDistance + t * kFinalSpeed;
    }
    else
    {
        // smoothstep shaped velocity curve v = nt * nt * nt - nt * nt * nt * nt * 0.5;         
   
        float _t = t / kAccelTime;
        z = (_t + 1.0) * log(_t + 1.0)  - _t;
        z = z * kFinalDistance;
    }

    return z;
}


vec3 CarPosAtTime( float t )
{
	float z = CarZAtTravelTime( max( 0.0, t - 5.0 ) );
    
	return vec3(0.0, -0.015, z );
}

void CameraSequence()
{    
    float kShotTyreSmokeTime= 0.0;
    float kShotStartMoveTime= 5.0;
    float kShotTrackStartAccelTime = 7.0;
    float kShotCarPovTime = 8.5;
    float kShotCarApproachTime = 10.0;
    float kShotCarZoomPastTime = 11.3;
    float kShotSpeedDisplayTime = 12.0;
    float kShotPanelsTime = 14.0;
    float kShotGlowEffectsTime = 15.0;
    float kShotEventSideOnTime = 18.0 + 1.0;
    float kShotFlameTrailsTime = 19.0 + 1.5;
    float kTextFadeTime = 26.0 + 1.5;

    //float kShotEventSideOnTime = 18.0;
    //float kShotFlameTrailsTime = 19.0;
    //float kTextFadeTime = 26.0;
    
    float kEventTime = kShotEventSideOnTime + 1.0;
    
    g_vCarPos = CarPosAtTime(gTimeDither);
    g_vCarPos.y += noise(g_vCarPos) * 0.01;
    
    gWheelRotation = g_vCarPos.z * 3.14 / 0.3;
    
    float fCameraShake = 0.0;
    
    if( gTime < kShotStartMoveTime )
    {
        // Static + tyre smoke        
        fSmoke = 1.0;
        
    	g_vCameraPos = g_vCarPos + vec3( 2.0, 0.5, 1.0 );
	    //g_vCameraTarget = g_vCarPos + vec3( 0.846435, 0.327574, -1.187590 ) ;
        g_vCameraTarget = g_vCarPos + vec3( 0.846435, 0.1, -1.187590 ) ;
        
        g_vCarPos.x += sin(gTimeDither) * 0.05;
        
        
    	fFieldOfView = 5.0; 
        
        gWheelRotation = gTimeDither * 10.0;
    }
    else if( gTime < kShotTrackStartAccelTime )
    {
        // Start Moving
        fSmoke = max( 1.0 - (gTime - kShotStartMoveTime), 0.0);
        
        g_vCameraPos = vec3( 3.0, 0.2, 10.0 );
        g_vCameraTarget = vec3(-2.0, 1.0, 0.0);
        fFieldOfView = 4.0;
    }
    else if( gTime < kShotCarPovTime )
    {
        // Tracking acceleration
        vec3 vSeqStartCarPos = CarPosAtTime( kShotTrackStartAccelTime ); 
            
        g_vCameraPos = vSeqStartCarPos + vec3( 5.0, 0.2, 20.0 );
        g_vCameraTarget = g_vCarPos + vec3(0.0, 0.5, 2.0);
        fFieldOfView = 3.0;
    }
    else if( gTime < kShotCarApproachTime )
    {
        // Car POV
        vec3 vSeqStartCarPos = CarPosAtTime( kShotCarPovTime ); 
            
        //g_vCameraPos = g_vCarPos + vec3( 0.0, 1.5, -2.0 );
        //g_vCameraTarget = g_vCarPos + vec3(0.0, -30.0, 100.0);
        //fFieldOfView = 3.0;
        g_vCameraPos = g_vCarPos + vec3( 0.0, 1.5, 10.0 );
        g_vCameraTarget = g_vCarPos + vec3(0.0, 0.5, 1.0);
        fFieldOfView = 5.0;
        
        fCameraShake = 1.0;
    }
    else if( gTime < kShotCarZoomPastTime )
    {
        // Head-on Car Approach
        vec3 vSeqStartCarPos = CarPosAtTime( kShotCarApproachTime ); 
            
        g_vCameraPos = vSeqStartCarPos + vec3( 0.1, 0.1, 40.0 );
        g_vCameraTarget = g_vCarPos + vec3(0.0, 0.5, 2.0);
        fFieldOfView = 3.0;
    }
    else if( gTime < kShotSpeedDisplayTime )
    {
        // Car zoom past
        vec3 vSeqStartCarPos = CarPosAtTime( kShotCarZoomPastTime ); 
            
        g_vCameraPos = vSeqStartCarPos + vec3( 2.0, 0.5, 9.5 );
        g_vCameraTarget = vSeqStartCarPos + vec3(0.0, 0.5, 7.5);
        fFieldOfView = 5.0;
    }
    else if( gTime < kShotPanelsTime )
    {    
        // Speed Display
        
        fSpeedDisplay = 88.4 + (gTime - kShotPanelsTime) * 2.0;
        
        g_vCameraTarget = vec3( 0.02, 1.1, 0.01 );
        g_vCameraPos = g_vCameraTarget + vec3( 0.0, 0.4, 0.02 );
        fFieldOfView = 9.0;
        
    }
    else if( gTime < kShotGlowEffectsTime )
    {
        // Time Travel Instrument Panels

        g_fPanelDisplay = gTime - kShotPanelsTime;
        
        g_vCameraTarget = vec3( 0.0, 1.0, 0.0 );
        g_vCameraPos = g_vCameraTarget + vec3( 0.3, 0.0, 1.5 );
        fFieldOfView = 4.0;
                
    }    
    else if (gTime < kShotEventSideOnTime)
    {
        // Glow Effects
        g_vCameraPos = g_vCarPos + vec3( 2.0, 0.6, 4.0 ) * 2.0;
        g_vCameraPos.x += (gTime - kShotGlowEffectsTime) * 0.1;
        g_vCameraTarget = g_vCarPos + vec3(0.0, 0.7, 1.0);
        fFieldOfView = 5.0;   
        
        fGlowEffect = gTime - kShotGlowEffectsTime;
        
        gFlash = min( abs(gTime - 16.3) + 0.01, abs(gTime - 16.6) + 0.01 );
        
        g_vCarPos.x += sin(gTimeDither * 3.0) * 0.25;
        
        fCameraShake = 0.5;
    }
    else if (gTime < kShotFlameTrailsTime)
    {
        // Event Side On
        
        vec3 vEventCarPos = CarPosAtTime( kEventTime ); 
        
        g_vCameraTarget = vEventCarPos + vec3(0.0, 0.5, 0.0);
        g_vCameraPos = g_vCameraTarget + vec3( 70.0, 1.1, 0.0 );
        
        g_vCameraTarget.y += 10.0;

        fFieldOfView = 3.0;   
        
        fGlowEffect = gTime - kShotGlowEffectsTime;
        
        gFogCoeff = 0.01;
        
        gEffectBegin = 69.0;
        
        gExplode = (gTime - kEventTime) + 0.1;

        gEffectScale = 4.0;
        
        g_vFlamePos = vEventCarPos;
        gFlameWidth = 1.0;
        
        if( gTime > kEventTime )
        {
            gDrawCar = -1.0;
            fGlowEffect = 0.0;
            
            gFlameEffect = gTime - kEventTime;
            
            gFlameEffectEnd = g_vCarPos.z - g_vFlamePos.z;
        }    
        
        gFlash = abs(gTime - kEventTime) + 0.01;
    }        
    else
    {
        // Flame Tracks
        
        vec3 vSeqStartCarPos = CarPosAtTime( kShotFlameTrailsTime ); 
        
        g_vCameraPos = vSeqStartCarPos + vec3(0.0, 1.0, 0.0); 
        g_vCameraTarget = g_vCameraPos + vec3(0.0, -8.0, 100.0);
        
        g_vFlamePos = vSeqStartCarPos;
        gFlameEffect = gTime - kShotFlameTrailsTime;
        
        gDrawCar = -1.0;
        fGlowEffect = 0.0;
        gFlameEffectEnd = (g_vCarPos.z - g_vFlamePos.z) * 0.25;
    }
    
    if( gTime > kTextFadeTime )
    {
        gTextFade = clamp((gTime -kTextFadeTime) * 0.2, 0.0, 1.0);
    }
            
    g_vCameraTarget.y += (noise(g_vCameraPos * 0.2) - 0.5) * fCameraShake / length(g_vCameraTarget - g_vCameraPos);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    pixelRandom = noise(fragCoord + iGlobalTime);
	vec2 vUV = (fragCoord.xy) / iResolution.xy;

    //gTime = iGlobalTime;
    gTime = max(0.0, iGlobalTime - 5.0);

    //gTime = 6.0;
    
#ifdef TIME_SLIDER
    float kSliderRange = 30.0;
    gTime = (iMouse.x / iResolution.x) * kSliderRange;
#endif
    
    gTimeDither = gTime;
    
#ifndef DISABLE_MOTION_BLUR
    gTimeDither -= pixelRandom * 1.0 / 60.0;
#endif    
    
    CameraSequence();

#ifdef ORBIT_CAM    
    float fDist = 6.0;

    float fAngle = radians(-30.0) + sin(iGlobalTime * 0.25) * 0.2;
    float fHeight = 2.0 + sin(iGlobalTime * 0.1567) * 1.5;
    
	vec2 vMouse = iMouse.xy / iResolution.xy;
	
    
    if(iMouse.z > 0.0)
    {
        fAngle = vMouse.x * 2.0 * 3.14;
        fHeight = vMouse.y * fDist;
    }
    
	g_vCameraPos = g_vCarPos + vec3(sin(fAngle) * fDist, fHeight, cos(fAngle) * fDist);
	g_vCameraTarget = g_vCarPos + vec3(0.0, 0.5, 0.0);
    
    fFieldOfView = 3.0;
#endif 
    
	vec3 vRayOrigin = g_vCameraPos;
	vec3 vRayDir = GetCameraRayDir( GetWindowCoord(vUV), g_vCameraPos, g_vCameraTarget );
	
	vec3 vResult = GetSceneColour(vRayOrigin, vRayDir);
	
    if ( gFlash > 0.0 )
    {
    	vResult += clamp( 1.0 - gFlash / 0.1, 0.0, 1.0) * 3.0;
    }
    
	vec3 vFinal = ApplyPostFX( vUV, vResult );

    vec3 vText = vec3(0.0);
    vec2 vTextUV = vUV.xy - vec2(0.5 - 0.1 * 2.5, 0.2);
    vTextUV = vTextUV / vec2(0.1, 0.2);
    if( vTextUV. y > 0.0 && vTextUV.y < 3.0)
    {
        vec3 vTextCol = vec3(0.5, 0.5, 0.0);
        if( vTextUV.y > 2.0 )
        {
            vTextCol = vec3(0.5, 0.0, 0.0);
        }
        else if( vTextUV.y > 1.0 )
        {
            vTextCol = vec3(0.0, 0.5, 0.0);
        }
        vec2 vTextUVWrap = vTextUV;
        vTextUVWrap.y = fract(vTextUVWrap.y);
        vText += vTextCol * Debug_PrintFloatApprox( vTextUVWrap, vec2(1.0, 1.0), 516.151, 3.0, 2.0 ) * 4.0;
    }
    
    vFinal = mix( vFinal, vText, gTextFade);            
    
#ifdef DISPLAY_TIME
    vFinal.r += Debug_PrintFloatApprox( fragCoord.xy, vec2(32.0, 48.0), gTime, 3.0, 2.0 ) * 4.0;    
#endif
    
#ifdef TIME_SLIDER
    {
        float screenX = gTime / kSliderRange;
        if ( length(vec2(screenX, 0.02) - vUV)  < 0.01 )
        {
            vFinal.g = 1.0;
        }
    }
#endif    
	fragColor = vec4(vFinal, 1.0);
}

// CAMERA

vec2 GetWindowCoord( const in vec2 vUV )
{
	vec2 vWindow = vUV * 2.0 - 1.0;
	vWindow.x *= iResolution.x / iResolution.y;

	return vWindow;	
}

vec3 GetCameraRayDir( const in vec2 vWindow, const in vec3 vCameraPos, const in vec3 vCameraTarget )
{
	vec3 vForward = normalize(vCameraTarget - vCameraPos);
	vec3 vRight = normalize(cross(vec3(0.0, 1.0, 0.0), vForward));
	vec3 vUp = normalize(cross(vForward, vRight));
							  
	vec3 vDir = normalize(vWindow.x * vRight + vWindow.y * vUp + vForward * fFieldOfView);

	return vDir;
}

// POSTFX

vec3 ApplyVignetting( const in vec2 vUV, const in vec3 vInput )
{
	vec2 vOffset = (vUV - 0.5) * sqrt(2.0);
	
	float fDist = dot(vOffset, vOffset);
	
	const float kStrength = 0.95;
	const float kPower = 1.5;

	return vInput * ((1.0 - kStrength) +  kStrength * pow(1.0 - fDist, kPower));
}

vec3 ApplyTonemap( const in vec3 vLinear )
{
	float kExposure = 0.5;
    
    if(gTime < 2.0)
    {
        kExposure *= gTime / 2.0;
    }
    	
	return 1.0 - exp2(vLinear * -kExposure);	
}

vec3 ApplyGamma( const in vec3 vLinear )
{
	const float kGamma = 2.2;

	return pow(vLinear, vec3(1.0/kGamma));	
}

vec3 ApplyBlackLevel( const in vec3 vColour )
{
    float fBlackLevel = 0.1;
    return vColour / (1.0 - fBlackLevel) - fBlackLevel;
}

vec3 ApplyPostFX( const in vec2 vUV, const in vec3 vInput )
{
	vec3 vTemp = ApplyVignetting( vUV, vInput );	
	
	vTemp = ApplyTonemap(vTemp);
	
	vTemp = ApplyGamma(vTemp);		
    
    vTemp = ApplyBlackLevel(vTemp);
    
    return vTemp;
}

// Scene materials
#define MAT_ROAD 			 1.0
#define MAT_CAR_BODY 		 2.0
#define MAT_CAR_WINDOW 		 3.0
#define MAT_CAR_HEADLIGHT 	 4.0
#define MAT_CAR_WHEEL		 5.0
#define MAT_SPEED_DISPLAY	 6.0
#define MAT_BLACK_PLASTIC    7.0
#define MAT_CHROME			 8.0
#define MAT_CHARGE_DISPLAY   9.0
#define MAT_FLUX_CAPACITOR 	10.0
#define MAT_GRILL		 	11.0

// RAYTRACE

struct C_Intersection
{
	vec3 vPos;
	float fDist;	
	vec3 vNormal;
	vec3 vUVW;
	float fObjectId;
};
    
   
float PlaneDist( const in vec3 vPos, const in vec4 vPlane )
{
    return dot(vPlane.xyz, vPos) - vPlane.w;
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float CarBodyMin( float a, float b )
{
    return smin(a, b, 0.03);
}
  
float CarBodyMax( float a, float b )
{
    return -CarBodyMin(-a, -b);
}

float WheelArchCombine( float a, float b )
{
    float size = 0.04;
    float r= clamp( 1.0 - abs(b) / size, 0.0, 1.0);
    a -= r * r * size;
    
    return CarBodyMax(a, b);
}

float udRoundBox( vec3 p, vec3 b, float r )
{
  return length(max(abs(p)-b,0.0))-r;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float GetWheelArchDist( vec3 vPos )
{
    vPos.y = max( vPos.y, 0.0 );
    return  0.32 - length( vPos.zy );
}

float GetWheelDist( vec3 vPos )
{
    float bevel = 0.03;
    float r = length( vPos.zy );
    
    float x = vPos.x + 0.1;
    
    if( r < 0.15 )
    {
        float unitr = r / 0.15;
    	x = x - sqrt(1.0 - unitr * unitr) * 0.01;
        x = x + 0.002;
    }
    
    vec2 rx = vec2( r,x );

    return length( max( abs(rx) - vec2(0.28 -bevel, 0.075), 0.0)) - bevel;
}
    
float CarBodyDisance( out vec4 vOutUVW_Id, const in vec3 _vPos )
{
    vec3 vCarPos = _vPos;
    
    vec3 vBodyPos = vCarPos;
    vBodyPos.x = abs(vBodyPos.x);
	vOutUVW_Id = vec4(vBodyPos.xyz, MAT_CAR_BODY);
    
    float distBonnet0 = PlaneDist(vBodyPos, vec4( -0.005687, 0.994044, 0.108829, 0.891393 ) );
    float distRoof0 = PlaneDist(vBodyPos, vec4( 0.004004, 0.999946, 0.009596, 1.124596 ) );
    float distFrontWindow0 = PlaneDist(vBodyPos, vec4( -0.002180, 0.918728, 0.394886, 1.033900 ) );
    float distDoorWindow0 = PlaneDist(vBodyPos, vec4( 0.765404, 0.643545, -0.002593, 1.145616 ) );
    float distSmallWindow0 = PlaneDist(vBodyPos, vec4( 0.760709, 0.645945, -0.063856, 1.201365 ) );
    float distDoorUpper0 = PlaneDist(vBodyPos, vec4( 0.945737, 0.324923, -0.002605, 1.045727 ) );
    float distDoorLower0 = PlaneDist(vBodyPos, vec4( 0.985543, -0.169304, 0.006400, 0.805219 ) );
    float distFront0 = PlaneDist(vBodyPos, vec4( 0.001169, 0.393724, 0.919228, 2.167077 ) );
    float distBase0 = PlaneDist(vBodyPos, vec4( -0.002855, -0.999987, 0.004094, -0.132802 ) );
    float distRearWindow0 = PlaneDist(vBodyPos, vec4( 0.001012, 0.976084, -0.217392, 1.302470 ) );
    float distRear0 = PlaneDist(vBodyPos, vec4( -0.000983, 0.100691, -0.994917, 2.116753 ) );
    float distFrontBase0 = PlaneDist(vBodyPos, vec4( 0.000408, -0.940669, 0.339326, 0.348749 ) );
    float distRearBase0 = PlaneDist(vBodyPos, vec4( 0.120237, -0.941372, -0.315218, 0.256832 ) );
    float distTopRearPanel0 = PlaneDist(vBodyPos, vec4( 0.909642, 0.405237, -0.091298, 1.161221 ) );
    float distBottomRearPanel0 = PlaneDist(vBodyPos, vec4( 0.974792, -0.205007, -0.088053, 0.849642 ) );

    float topCurveX = abs(vBodyPos.x);
    topCurveX = topCurveX * topCurveX;
    distBonnet0 += topCurveX * 0.05;
    distRoof0 += topCurveX * 0.1;
    distFrontWindow0 += topCurveX * 0.01;
    distRearWindow0 += topCurveX * 0.01;

    float topCurveZ = abs(vBodyPos.z);
    topCurveZ = topCurveZ * topCurveZ;
    distRoof0 += topCurveZ * 0.05;

    float result = -100000.0;
    
    result = CarBodyMax( result, distRoof0 );
    result = CarBodyMax( result, distDoorWindow0 );
    result = CarBodyMax( result, distSmallWindow0 );
    result = CarBodyMax( result, distDoorUpper0 );
    result = CarBodyMax( result, distDoorLower0 );
    result = CarBodyMax( result, distFront0 );
    result = CarBodyMax( result, distBase0 );
    result = CarBodyMax( result, distRearWindow0 );
    result = CarBodyMax( result, distRear0 );
    result = CarBodyMax( result, distFrontBase0 );
    result = CarBodyMax( result, distRearBase0 );
    result = CarBodyMax( result, distTopRearPanel0 );
    result = CarBodyMax( result, distBottomRearPanel0 );

    float distBonnetWindow = CarBodyMin(distBonnet0, distFrontWindow0);    
    result = CarBodyMax( result, distBonnetWindow );

#ifndef SIMPLE_CAR
    
    
    bool isGlass = false;
    
    if ( abs( distFrontWindow0 - result ) < 0.001 )
    {
        //if( abs(min(min(distBonnet0, -distRoof0), -distDoorWindow0)) > 0.01 )
        {
            isGlass = true;
        }
    }

    if ( abs( distDoorWindow0 - result ) < 0.001 )
    {
        //if( abs(min(min(distFrontWindow0, -distRoof0), -distSmallWindow0)) > 0.01 )
        {
            isGlass = true;
        }
    }

    /*if ( abs( distSmallWindow0 - result ) < 0.001 )
    {
        //if( abs(distRear0) > 0.5 && abs(distRearWindow0) > 0.1)
        {
            isGlass = true;
        }
    }*/

    if( isGlass )
    {
    	vOutUVW_Id.w = MAT_CAR_WINDOW;
    }
    
    //float trimHeight = 0.5;
    //float trimLineDist = clamp( 0.05 - (vBodyPos.y - trimHeight), 0.0, 0.05 );
    //result -= trimLineDist;

    
    // TODO - replace with measured one
    {
        vec3 vBumperPos = vBodyPos - vec3(0.0, 0.25, 1.8);
                
    	float fBumperDist = udRoundBox( vBumperPos, vec3(0.8, 0.1, 0.24) , 0.01 );
        fBumperDist -= clamp( -vBumperPos.y, 0.0, 0.04 );
        if( fBumperDist < result )
        {
            result = fBumperDist;
            vOutUVW_Id.w = MAT_CAR_BODY;
        }
    }

    
    
    vec3 vFrontWheelPos = -vec3( -0.853643, -0.289475, -1.271860 ) ;
    vec3 vRearWheelPos = -vec3( -0.846435, -0.327574, 1.187590 ) ;

    vec3 vWheelPos = vBodyPos - vFrontWheelPos;
    
    float fSeparation = (vFrontWheelPos.z - vRearWheelPos.z) * 0.5;
    vWheelPos.z = abs(vWheelPos.z + fSeparation ) - fSeparation;
    
    float fWheelArchDist = GetWheelArchDist( vWheelPos );
    
    result = WheelArchCombine( result, fWheelArchDist );
    
    float fWheelDist = GetWheelDist( vWheelPos );
    if ( fWheelDist < result )
    {
        result = fWheelDist;
    	vOutUVW_Id.xy =  vWheelPos.yz;
    	vOutUVW_Id.w =  5.0;
    }

    {
        vec3 vGrillPos = vBodyPos - vec3(0.0, 0.58, 2.03);
        vGrillPos.z += vGrillPos.y * 0.45;      
        
        vec3 vSize = vec3(0.45, 0.05, 0.1);
    	float fGrillDist = udRoundBox( vGrillPos, vSize , 0.02 );
        if( fGrillDist < result )
        {
            result = fGrillDist;
            vOutUVW_Id.xyz = vGrillPos / vSize;
            vOutUVW_Id.w = MAT_GRILL;
        }
    }    

    {
        vec3 vMirrorPos = vBodyPos - vec3(0.9, 0.85, 0.5);
        
    	float fMirrorDist = udRoundBox( vMirrorPos, vec3(0.06, 0.04, 0.02) , 0.03 );
        if( fMirrorDist < result )
        {
            result = fMirrorDist;
            vOutUVW_Id.w = MAT_BLACK_PLASTIC;
            
        }
    }    
    
    // TODO: Replace with measured
    {
        vec3 vHeadlightMountingDomain = vBodyPos - vec3(0.68, 0.58, 2.05);

        float headlightRecessDist = udRoundBox( vHeadlightMountingDomain, vec3(0.36 * 0.5, 0.04, 0.2) , 0.01 );

        result = max(result, -headlightRecessDist);
                
        vec3 vHeadlightPos = vHeadlightMountingDomain;
        
        bool off = false;
        if( vHeadlightPos.x < 0.0)
        {
            off = true;
        }
        
        float fSeparation = 0.1;
        vHeadlightPos.x = abs(vHeadlightPos.x) - fSeparation;
        
    	float headlightDist = udRoundBox( vHeadlightPos, vec3(0.06, 0.03, 0.05) , 0.01 );
        if( headlightDist < result )
        {
            result = headlightDist;
            vOutUVW_Id.w = MAT_CAR_HEADLIGHT;
            if ( off )
            {
                vOutUVW_Id.w = MAT_CHROME;
            }

        }

    }

    #endif //SIMPLE_CAR
    
    return result;
}

void GetPanelDist( inout float fOutDist, inout vec4 vOutUVW_Id, const in vec3 vPos, const in vec3 vPanelPos, const in vec3 vPanelSize, const in float fMaterial )
{
    vec3 vPanelDomain = vPos - vPanelPos;
	float fPanelDist = sdBox( vPanelDomain, vPanelSize );

    if( fPanelDist < fOutDist )
    {
        fOutDist = fPanelDist;
        vOutUVW_Id = vec4(vPanelDomain.xzy * (0.5 / vPanelSize.xzy) + 0.5, fMaterial);
    }        
}


float GetSceneDistance( out vec4 vOutUVW_Id, const in vec3 vPos )
{
	
	float fOutDist = 10000.0;
    vOutUVW_Id = vec4(vPos.xz, 0.0, 0.0);

    if ( gDrawCar > 0.0 )
    {
        vec4 vCarBodyUVW_Id;
        float fCarBodyDisance = CarBodyDisance( vCarBodyUVW_Id, vPos - g_vCarPos );
        if( fCarBodyDisance < fOutDist )
        {
            fOutDist = fCarBodyDisance;
            vOutUVW_Id = vCarBodyUVW_Id;
        }
    }
    
    if ( fSpeedDisplay > 0.0 )
    {
        GetPanelDist( fOutDist, vOutUVW_Id, vPos, vec3( 0.0, 1.0, 0.0), vec3(0.1, 0.1, 0.1), MAT_SPEED_DISPLAY );
    }
    
    if ( g_fPanelDisplay > 0.0 )
    {
        GetPanelDist( fOutDist, vOutUVW_Id, vPos, vec3( 0.0, 1.0, 0.0), vec3(1.0, 1.0, 0.2), MAT_BLACK_PLASTIC );
        GetPanelDist( fOutDist, vOutUVW_Id, vPos, vec3( 0.25, 1.0, 0.0), vec3(0.15, 0.1, 0.3), MAT_CHARGE_DISPLAY );
        GetPanelDist( fOutDist, vOutUVW_Id, vPos, vec3( -0.25, 1.0, 0.0), vec3(0.1, 0.1, 0.3), MAT_FLUX_CAPACITOR );
    }
    
	return fOutDist;
}

vec3 GetSceneNormal(const in vec3 vPos)
{
    const float fDelta = 0.001;

    vec3 vDir1 = vec3( 1.0, -1.0, -1.0);
    vec3 vDir2 = vec3(-1.0, -1.0,  1.0);
    vec3 vDir3 = vec3(-1.0,  1.0, -1.0);
    vec3 vDir4 = vec3( 1.0,  1.0,  1.0);
	
    vec3 vOffset1 = vDir1 * fDelta;
    vec3 vOffset2 = vDir2 * fDelta;
    vec3 vOffset3 = vDir3 * fDelta;
    vec3 vOffset4 = vDir4 * fDelta;

	vec4 vUnused;
    float f1 = GetSceneDistance( vUnused, vPos + vOffset1 );
    float f2 = GetSceneDistance( vUnused, vPos + vOffset2 );
    float f3 = GetSceneDistance( vUnused, vPos + vOffset3 );
    float f4 = GetSceneDistance( vUnused, vPos + vOffset4 );
	
    vec3 vNormal = vDir1 * f1 + vDir2 * f2 + vDir3 * f3 + vDir4 * f4;	
		
    return normalize( vNormal );
}


void TraceFloor( inout C_Intersection inoutIntersection, const in vec3 vRayOrigin, const in vec3 vRayDir, const in float fFloorHeight, const in float fObjectId )
{
	float fDh = fFloorHeight - vRayOrigin.y;
	float t = fDh / vRayDir.y;
	
	if(vRayDir.y < 0.0)
	{
		if((t > 0.0) && (t < inoutIntersection.fDist))
		{
			inoutIntersection.fDist = t;
			inoutIntersection.vPos = vRayOrigin + vRayDir * t;
			inoutIntersection.vNormal = vec3(0.0, 1.0, 0.0);
			inoutIntersection.vUVW = vec3(inoutIntersection.vPos.xz, 0.0);
			inoutIntersection.fObjectId = fObjectId;
		}	
	}
}

void RaymarchScene( out C_Intersection outIntersection, const in vec3 vOrigin, const in vec3 vDir )
{
	vec4 vUVW_Id = vec4(0.0);		
	vec3 vPos = vec3(0.0);
    
	float t = 0.01;
	for(int i=0; i<kRaymarchMaxIter; i++)
	{
		vPos = vOrigin + vDir * t;
		float fDist = GetSceneDistance(vUVW_Id, vPos);		
		t += fDist;
		if(abs(fDist) < 0.001)
		{
			break;
		}		
		if(t > 100.0)
		{
			t = kFarClip;
			vPos = vOrigin + vDir * t;
			vUVW_Id = vec4(0.0);
			break;
		}
	}
	
	outIntersection.fDist = t;
	outIntersection.vPos = vPos;
	outIntersection.vNormal = GetSceneNormal(vPos);
	outIntersection.vUVW = vUVW_Id.xyz;
	outIntersection.fObjectId = vUVW_Id.w;
}


void TraceScene( out C_Intersection outIntersection, const in vec3 vOrigin, const in vec3 vDir )
{	
    RaymarchScene( outIntersection, vOrigin, vDir );
    
    TraceFloor( outIntersection, vOrigin, vDir, 0.0, MAT_ROAD );
}


float TraceShadow( const in vec3 vOrigin, const in vec3 vDir, const in float fDist )
{
    C_Intersection shadowIntersection;
	RaymarchScene(shadowIntersection, vOrigin, vDir);
	if(shadowIntersection.fDist < fDist) 
	{
		return 0.0;		
	}
	
	return 1.0;
}

// LIGHTING

float GIV( float dotNV, float k)
{
	return 1.0 / ((dotNV + 0.0001) * (1.0 - k)+k);
}

void AddLighting(inout vec3 vDiffuseLight, inout vec3 vSpecularLight, const in vec3 vViewDir, const in vec3 vLightDir, const in vec3 vNormal, const in float fSmoothness, const in vec3 vLightColour)
{
	vec3 vH = normalize( -vViewDir + vLightDir );
	float fNDotL = clamp(dot(vLightDir, vNormal), 0.0, 1.0);
	float fNDotV = clamp(dot(-vViewDir, vNormal), 0.0, 1.0);
	float fNDotH = clamp(dot(vNormal, vH), 0.0, 1.0);
	
	float alpha = 1.0 - fSmoothness;
	alpha = alpha * alpha;
	// D

	float alphaSqr = alpha * alpha;
	float pi = 3.14159;
	float denom = fNDotH * fNDotH * (alphaSqr - 1.0) + 1.0;
	float d = alphaSqr / (pi * denom * denom);

	float k = alpha / 2.0;
	float vis = GIV(fNDotL, k) * GIV(fNDotV, k);

	float fSpecularIntensity = d * vis * fNDotL;
	vSpecularLight += vLightColour * fSpecularIntensity;

	vDiffuseLight += vLightColour * fNDotL;
}

void AddPointLight(inout vec3 vDiffuseLight, inout vec3 vSpecularLight, const in vec3 vViewDir, const in vec3 vPos, const in vec3 vNormal, const in float fSmoothness, const in vec3 vLightPos, const in vec3 vLightColour)
{
	vec3 vToLight = vLightPos - vPos;	
	float fDistance2 = dot(vToLight, vToLight);
	float fAttenuation = 100.0 / (fDistance2);
	vec3 vLightDir = normalize(vToLight);
	
	vec3 vShadowRayDir = vLightDir;
	vec3 vShadowRayOrigin = vPos + vShadowRayDir * 0.01;
	float fShadowFactor = TraceShadow(vShadowRayOrigin, vShadowRayDir, length(vToLight));
	
	AddLighting(vDiffuseLight, vSpecularLight, vViewDir, vLightDir, vNormal, fSmoothness, vLightColour * fShadowFactor * fAttenuation);
}

float AddDirectionalLight(inout vec3 vDiffuseLight, inout vec3 vSpecularLight, const in vec3 vViewDir, const in vec3 vPos, const in vec3 vNormal, const in float fSmoothness, const in vec3 vLightDir, const in vec3 vLightColour)
{	
	float fAttenuation = 1.0;

	vec3 vShadowRayDir = -vLightDir;
	vec3 vShadowRayOrigin = vPos + vShadowRayDir * 0.01;
	float fShadowFactor = TraceShadow(vShadowRayOrigin, vShadowRayDir, 10.0);
	
	AddLighting(vDiffuseLight, vSpecularLight, vViewDir, -vLightDir, vNormal, fSmoothness, vLightColour * fShadowFactor * fAttenuation);	
    
    return fShadowFactor;
}

// SCENE MATERIALS

vec3 GetChargeDisplayColor( vec2 vUV, float fTime )
{
    float fAmount = clamp( (fTime - 0.25) * 2.5, 0.0, 1.0 );
    
    vec2 vSegmentUV = vUV * vec2(20.0, 16.0);
    vec2 vSegmentPos = fract(vSegmentUV - 0.1);
    vec2 vSegmentID = floor(vSegmentUV);
    
    vec2 vIsSegment= step(vSegmentPos, vec2(0.8));
    float fIsSegment = vIsSegment.x * vIsSegment.y;
    
    vec3 vCol = vec3(0.01, 1.0, 0.01) * 2.0;
    
    if ( vSegmentID.y > 10.0 )
    {
        vCol = vec3(1.0, 0.01, 0.01) * 2.0;
    }
    
    float fLit = 0.0;
    
    float threshold = sin(vSegmentID.x * 0.2) * 0.3 + 0.2;
    threshold = mix(threshold, 1.0, fAmount);
    if( (vSegmentID.y / 16.0) < threshold )
    {
        fLit = 1.0;
    }
    
    return fLit * vCol * fIsSegment + 0.01;
}

vec3 GetFluxCapacitorColor( vec2 vUV, float fTime )
{
    float fAmount = clamp( (fTime - 0.25) * 2.5, 0.0, 1.0 );
    
    vec2 vOffsetUV = vUV * 2.0 - 1.0;
    float theta = atan(vOffsetUV.x, vOffsetUV.y);
    
    float segAngle = 3.0 * (theta / radians(360.0));
    float segment = abs(fract(segAngle) - 0.5);
    //float isSegment = step(segment, 0.1);
    
    float isSegment = clamp(1.0 - (segment / 0.1), 0.0, 1.0);
    
    float len = length(vOffsetUV);
    
    if ( len > 0.8 )
    {
        isSegment = 0.0;
    }
    if ( len < 0.2 )
    {
        isSegment = 1.0;
    }
    
    vec3 vLightCol = vec3(0.4, 0.2, 0.001);
    vec3 vPulseCol = vLightCol * (1.0 + fAmount * 3.0);
    
    float fPulseTime = gTimeDither * (1.0 + fAmount * 10.0);
    
    float pulse = abs(sin( (len - fPulseTime) * 10.0 ) * 0.4 + 0.6);
	return vec3(0.1) + vPulseCol * pulse * isSegment * fAmount + fAmount * vLightCol * (1.0 - len * 0.5) * 3.0;
}

void GetSurfaceInfo(out vec3 vOutAlbedo, out vec3 vOutR0, out float fOutSmoothness, out vec3 vOutBumpNormal, const in C_Intersection intersection )
{
	vOutBumpNormal = intersection.vNormal;
	
	if(intersection.fObjectId == MAT_ROAD)
	{
		vec2 vUV = intersection.vUVW.xy * 0.5;
        //vUV.y += gTimeDither * 10.0;
		vOutAlbedo = texture2D(iChannel0, vUV).rgb;
		
        float fBumpScale = -10.0;
		
		vec2 vRes = iChannelResolution[0].xy;
		vec2 vDU = vec2(1.0, 0.0) / vRes;
		vec2 vDV = vec2(0.0, 1.0) / vRes;
		
		float fSampleW = texture2D(iChannel0, vUV - vDU).r;
		float fSampleE = texture2D(iChannel0, vUV + vDU).r;
		float fSampleN = texture2D(iChannel0, vUV - vDV).r;
		float fSampleS = texture2D(iChannel0, vUV + vDV).r;
		
		vec3 vNormalDelta = vec3(0.0);
		vNormalDelta.x += 
			( fSampleW * fSampleW
			 - fSampleE * fSampleE) * fBumpScale;
		vNormalDelta.z += 
			(fSampleN * fSampleN
			 - fSampleS * fSampleS) * fBumpScale;
		
		vOutBumpNormal = normalize(vOutBumpNormal + vNormalDelta);
		
		vOutAlbedo = vOutAlbedo * vOutAlbedo;	
		fOutSmoothness = clamp((0.5 - vOutAlbedo.r * 4.0), 0.0, 1.0);
		
		vOutR0 = vec3(0.01) * vOutAlbedo.g;
	}
	else if(intersection.fObjectId == MAT_CAR_BODY)
	{
		vOutAlbedo = vec3(0.1, 0.1, 0.1);
		fOutSmoothness = 0.4;
		vOutR0 = vec3(0.3);
        
        // hack the normal for a rougher looking car body
        vec3 vRandom = normalize( vec3( sin(pixelRandom*10.0), sin(pixelRandom * 20.0), sin(pixelRandom * 25.0)));
        vOutBumpNormal += vRandom * 0.025;
        vOutBumpNormal = normalize(vOutBumpNormal);
        
        if( abs((intersection.vUVW.y) - 0.5) < 0.01 )
        {
            vOutR0 = vec3(0.0);
            fOutSmoothness = 0.1;
        }

        if( abs(intersection.vUVW.z - intersection.vUVW.y * 0.3 - 0.5) < 0.01 )
        {
            vOutR0 = vec3(0.0);
            fOutSmoothness = 0.1;
        }

        if( abs(intersection.vUVW.z + sqrt(intersection.vUVW.y ) * 0.5 + 0.3) < 0.01 )
        {
            vOutR0 = vec3(0.0);
            fOutSmoothness = 0.1;
        }

        if( intersection.vUVW.z > 2.0 && intersection.vUVW.y > 0.35)
        {
            vOutR0 = vec3(0.0);
            fOutSmoothness = 0.1;
        }
	}
	else if(intersection.fObjectId == MAT_CAR_WINDOW)
	{
		vOutAlbedo = vec3(0.1, 0.15, 0.15);
		fOutSmoothness = 1.0;
		vOutR0 = vec3(0.01);
	}
	else if(intersection.fObjectId == MAT_CAR_HEADLIGHT)
	{
		vOutAlbedo = vec3(1.0, 1.0, 0.6) * 100.0;
		fOutSmoothness = 1.0;
		vOutR0 = vec3(0.01);
	}
    else if(intersection.fObjectId == MAT_CHROME)
    {
		vOutAlbedo = vec3(0.01);
		fOutSmoothness = 1.0;
		vOutR0 = vec3(1.0);
    }
    else if(intersection.fObjectId == MAT_BLACK_PLASTIC)
    {
		vOutAlbedo = vec3(0.05);
		fOutSmoothness = 0.3;
		vOutR0 = vec3(0.01);
    }
    else if(intersection.fObjectId == MAT_GRILL)
    {
		vOutAlbedo = vec3(0.05);
		fOutSmoothness = 0.3;
		vOutR0 = vec3(0.01);
        
        float fStripe = step( fract(intersection.vUVW.y * 2.0), 0.5);
        vOutAlbedo *= fStripe;
        
        if( abs(intersection.vUVW.x) < 0.1 && abs(intersection.vUVW.y) < 0.2)
        {
            vOutR0 = vec3(0.9);
        }
    }
	else if(intersection.fObjectId == MAT_CAR_WHEEL)
	{
		vOutAlbedo = vec3(0.01, 0.01, 0.01);
		fOutSmoothness = 0.0;
		vOutR0 = vec3(0.01);
        
        float r= length( intersection.vUVW.xy );
        float theta = atan( intersection.vUVW.x, intersection.vUVW.y );
        theta -= gWheelRotation;
        
        if( r < 0.15 )
        {
            fOutSmoothness = 0.9;
            vOutR0 = vec3(0.8);
            
            if( r < 0.13 && r > 0.04)
            {
                float alternate = theta * 16.0 / radians(360.0);
                if( fract(alternate) < 0.5 )
                {
                    vOutAlbedo = vec3(0.0);
                    fOutSmoothness = 0.0;
                    vOutR0 = vec3(0.0);
                }
            }
        }
        else
        {
            vOutAlbedo = texture2D( iChannel0, vec2(r, theta / 3.14) ).rgb;
            vOutAlbedo = vOutAlbedo * vOutAlbedo * 0.2 + 0.015;
        }
	}
	else if(intersection.fObjectId == MAT_SPEED_DISPLAY)
    {
		vOutAlbedo = vec3(0.4, 0.2, 0.1) * 2.0;
		fOutSmoothness = 0.0;
		vOutR0 = vec3(0.01);
        
        vec2 vUV = intersection.vUVW.xy;
        vUV.x = 0.95 - vUV.x;
        vUV.y = 1.0 - vUV.y;
        vUV.y -= 0.25;
        
        vec3 vDigitCol = vec3(1.0, 0.3, 0.05) * 8.0;
        vOutAlbedo += vDigitCol * Debug_PrintFloatApprox( vUV, vec2(0.3, 0.5), fSpeedDisplay, 2.0, 1.0 );
    }
    else if(intersection.fObjectId == MAT_CHARGE_DISPLAY)
    {
		vOutAlbedo = GetChargeDisplayColor(intersection.vUVW.xz, g_fPanelDisplay);
		fOutSmoothness = 0.0;
		vOutR0 = vec3(0.01);
    }
    else if(intersection.fObjectId == MAT_FLUX_CAPACITOR)
    {
		vOutAlbedo = GetFluxCapacitorColor(intersection.vUVW.xz, g_fPanelDisplay);
		fOutSmoothness = 0.0;
		vOutR0 = vec3(0.01);
    }            
}

vec3 GetSkyLightDir(const in vec3 vDir)
{
    float fBackdropAngle = atan( vDir.x, vDir.z ) / radians(360.0);

    float fBackdropLightAngle = (floor(fBackdropAngle * 16.0) + 0.5) / 16.0 * radians(360.0);
    
    //float fBackdropLightAngle = fBackdropAngle;
    fBackdropLightAngle = fBackdropLightAngle + 3.14;
    
    vec3 vBackdropLightPos = vec3(sin(fBackdropLightAngle), -0.2 -0.1 * sin(fBackdropLightAngle * 12.345), cos(fBackdropLightAngle));
    
    vBackdropLightPos = normalize(vBackdropLightPos);    
    return vBackdropLightPos;
}

vec3 GetSkyColour( const in vec3 vDir )
{	
	//vec3 vResult = mix(vec3(0.02, 0.04, 0.06), vec3(0.1, 0.5, 0.8), abs(vDir.y));
    
    vec3 vResult = textureCube( iChannel1, vDir ).rgb;
    
    vResult = vResult * vResult;
    
    return vResult * 0.25;
    
}


vec3 GetSkyLight( const in vec3 vDir, float fSpread )
{
 	vec3 vBackdropLightPos = GetSkyLightDir(vDir);
    
    //vBackdropLightPos = vec3(0.0, 0.0, 1.0);
    /*
    vec2 vBackdropUV = vDir.xy / vDir.z;
    vBackdropUV.y -= 0.25;

    vec2 vBackdropLightUV = floor(vBackdropUV) + 0.5;
    vBackdropLightUV.y += 0.25;
    
    vec3 vBackdropLightPos = normalize(vec3(vBackdropLightUV, sign(vDir.z)));
*/
	
    float fDist = dot(vBackdropLightPos, vDir) + 1.0;
    //float fDist = length(vBackdropUV - vBackdropLightPos);

    float r = fSpread * 0.001; 
    
    float fShade = 0.0;//clamp( (r - fDist) / r, 0.0, 1.0);
    
    fShade = clamp( 1.0 - fDist / r, 0.0, 1.0 );
        
    fShade = (1.0 - pow(1.0 - fShade, 4.0));
    
    
	return vec3(fShade) * vec3(0.5, 0.8, 1.0);	
   
}

vec3 vSunLightColour = vec3(0.1, 0.2, 0.3) * 5.0;
vec3 vSunLightDir = normalize(vec3(0.4, -0.3, -0.5));
	
void ApplyAtmosphere(inout vec3 vColour, const in float fDist, const in vec3 vRayOrigin, const in vec3 vRayDir)
{		
    vec3 vSkyColor = GetSkyColour(vRayDir);
        vColour = mix( vColour, vSkyColor, 1.0 - exp(fDist * -gFogCoeff));
    
    //vColour *= 1.0 - exp(fDist * -10.0);
}

#ifndef EFFECTS_DISABLED
vec4 EffectColDensity( vec3 vPos )
{
    vec3 vCol;
    float fDensity = 0.0;
    vec3 vNoisePos = vPos;
    vec3 vCarDomain = vPos - g_vCarPos;
    
    if( fSmoke > 0.0 )
    {
        //vNoisePos.z -= 1.6;
        //vNoisePos.z = vNoisePos.z * vNoisePos.z ;
        vNoisePos *= 16.0;
        vNoisePos.x -= gTimeDither * sign(vPos.x) * 4.0;
        vNoisePos.z += gTimeDither * 6.0;// + vNoisePos.x ;
    }
    
    if( fGlowEffect > 0.0 )
    {                
        if( fGlowEffect < 1.0 )
        {
        }
    	else
        {
            vNoisePos = vCarDomain;
            //vNoisePos.z = sqrt(max(vNoisePos.z + 2.0, 0.0) / 6.0) * 2.0 + 2.0;
            vNoisePos.z /= 1.0 + vNoisePos.z * 0.15;
            vNoisePos *= 4.0;
            vNoisePos.z += gTimeDither * 20.0;
        }
    }
    
    if( gFlameEffect > 0.0 )
    {
        vNoisePos *= 10.0;
        vNoisePos.y -= gTimeDither * 10.0 + (vPos.y * 0.01);
    }
    
    float fNoise = noise(vNoisePos);
    
    if( fSmoke > 0.0 )
    {
        float fShade = clamp( (fNoise - noise(vNoisePos + 0.1)), 0.0, 1.0);
        vCol = vSunLightColour * fShade * 4.0 + vec3(0.25);
        
        vec3 vDensityDomain = vPos;
        vDensityDomain.y *= 4.0;
        vDensityDomain.x = abs( vDensityDomain.x );
         
        vDensityDomain -= vec3(1.4, 0.0, -1.8);
        fDensity = clamp( 1.0 - length(vDensityDomain), 0.0, 1.0 );
        fDensity *= fNoise * 4.0 * fSmoke;
    }
    
    if( gFlameEffect > 0.0 )
    {
        vec3 vFlameDomain = vPos - g_vFlamePos;
        vFlameDomain.x -= vFlameDomain.y * 0.1;
        float fColBlend= clamp(1.0 - vFlameDomain.y * 2.0, 0.0, 1.0);
        fColBlend = fColBlend * fColBlend;
        vCol = mix(vec3(1.0, 0.5, 0.1) * 80.0,
                         vec3(0.0, 0.0, 1.0) * 10.0,
                        fColBlend);
        
        float fHeightFade = clamp( 0.5 - vFlameDomain.y, 0.0, 1.0);    
        
        float fTyreDomain = abs(vFlameDomain.x) - 0.8;
        float fTyreTrackPosDensity = clamp( gFlameWidth - abs(fTyreDomain) * 2.0, 0.0, 1.0) ;

        float fEndFade = gFlameEffectEnd - vFlameDomain.z;
        float fBeginFade = vFlameDomain.z;
        float fLengthFade = clamp( min(fBeginFade, fEndFade), 0.0, 1.0 );
        
        fDensity = fTyreTrackPosDensity * fHeightFade * fLengthFade- fNoise * 0.1;
    }
    
    if( fGlowEffect > 0.0 )
    {                

        float fTopGlow = clamp( fGlowEffect, 0.0, 1.0 );
        if( fTopGlow > 0.0 )
        {
            fTopGlow = fTopGlow * fTopGlow;
            {
                vec3 vGlowDomain = vCarDomain - vec3(0.0, 0.95, 0.2);
                vec3 vClampedPos = vec3(clamp(vGlowDomain.x, -0.6, 0.6), 0.0, 0.0);
                float fGlowDist = length(vGlowDomain - vClampedPos);

                float fInvRadius = 1.0 / 0.2;
                float fGlowDensity = clamp(1.0 - fGlowDist * fInvRadius, 0.0, 1.0);               
                fGlowDensity *= fTopGlow;
                fDensity = max( fDensity, fGlowDensity);

                if( fGlowDensity > 0.0)
                {
                    vCol = vec3(1.0, 4.0, 4.0) * 4.0; 
                }
            }
            {
                vec3 vGlowDomain = vCarDomain - vec3(0.0, 0.5, 2.2);
                vec3 vClampedPos = vec3(clamp(vGlowDomain.x, -0.9, 0.9), 0.0, 0.0);
                float fGlowDist = length(vGlowDomain - vClampedPos);

                float fInvRadius = 1.0 / 0.1;
                float fGlowDensity = clamp(1.0 - fGlowDist * fInvRadius, 0.0, 1.0);               
                fGlowDensity *= fTopGlow;
                fDensity = max( fDensity, fGlowDensity);

                if( fGlowDensity > 0.0)
                {
                    vCol = vec3(1.0, 4.0, 4.0) * 4.0; 
                }
            }
        }      
        
        float fBolt = clamp( (fGlowEffect - 1.25) / 0.4, 0.0, 1.0 );
        
        if( fBolt >= 1.0 )
        {
        	fBolt = clamp( (fGlowEffect - 1.6) / 0.4, 0.0, 1.0 );
        }
        
        if ( fBolt > 0.0 && fBolt < 1.0 )
        {
            float fStartMoveTime = 0.2;
            float fTravelTime = 0.6;

            float fTravel = clamp( (fBolt - fStartMoveTime) / fTravelTime, 0.0, 1.0);
            vec3 vBoltPos = mix( vec3( 0.0, 1.2, 0.3), vec3( 0.0, 0.7, 2.5), fTravel );

            float fFadeInA = fBolt / fStartMoveTime;
            float fFadeInB = (1.0 - fBolt) / fStartMoveTime;
            float fFadeIn = clamp( min(fFadeInA, fFadeInB), 0.0, 1.0);
            float fBoltSize = 0.1 + (1.0 - fFadeIn) * 1.0;
            
            float fBoltDensity = clamp(1.0 - length(vCarDomain - vBoltPos) / fBoltSize, 0.0, 1.0);
			fBoltDensity *= fFadeIn * fFadeIn * fFadeIn;
            
            fDensity = max( fDensity, fBoltDensity);

            if( fBoltDensity > 0.0)
            {
                vCol = vec3(1.0, 4.0, 4.0) * 4.0; 
            }
        }
        
        if( fGlowEffect > 1.9 )
        {              
            float fCurveFadein = clamp( (fGlowEffect - 1.9) * 0.5, 0.0, 1.0);
            vec3 vCurveGlowDomain = vCarDomain;
            vCurveGlowDomain.z *= 0.7;
            vCurveGlowDomain.y *= 1.5;
            vCurveGlowDomain.y -= 0.5;

            float d = length(vCurveGlowDomain);
            float fCurveGlowDensity = max(0.0, 1.0 - abs(d - 2.0) * 5.0);

            fCurveGlowDensity -= fNoise * (clamp( 2.0-vCurveGlowDomain.z, 0.0, 1.0)) * 5.0;        
            fCurveGlowDensity *= fCurveFadein;

            fDensity = max(fDensity, fCurveGlowDensity);
            if ( fCurveGlowDensity > 0.0 )
            {
	            vCol = vec3(4.0, 2.5, 4.0) * 8.0;
            	vCol += fCurveGlowDensity;
            }
        }        
    }  
    
    if ( gExplode > 0.0 )
    {
        vec3 vExplodePos = g_vFlamePos + vec3(0.0, 2.0, 0.0);
        vec3 vExplodeDomain = vPos - vExplodePos;
        
        float fSize = max( gExplode / 0.1, 0.0) * 6.0;       

        float fExplodeDensity = clamp(1.0 - length(vExplodeDomain) / fSize, 0.0, 1.0);
        
        float fFade = max( (0.2 - gExplode) / 0.2, 0.0);       
        
        fExplodeDensity = fExplodeDensity * fFade;
        
        fDensity = max(fDensity, fExplodeDensity);
		if( fExplodeDensity > 0.0 )
        {
            vCol = vec3(1.0, 1.0, 1.0) * 8.0;
        }
    }
    
    fDensity = clamp(fDensity, 0.0, 1.0);
    return vec4( vCol, fDensity );
}
#endif // EFFECTS_DISABLED

void ApplyEffects( inout vec3 vColour, const in vec3 vRayOrigin, vec3 vRayDir, float fDist )
{
   #ifndef EFFECTS_DISABLED
    float t= gEffectBegin + pixelRandom * 0.03;
    float f = 1.0;
    for(int iter=0; iter<kEffectMaxIter; iter++)
    {
        if( t > fDist )
        {
            break;
        }
        
        vec3 p = vRayOrigin + vRayDir * t;
        vec4 vEffect = EffectColDensity( p );
        
        vColour = mix(vColour, vEffect.rgb, f * vEffect.w);
        f = f * (1.0 - vEffect.w);
        
		t += (0.04+t*0.012);        
    }
    #endif // EFFECTS_DISABLED
}

// TRACING LOOP

	
vec3 GetSceneColour( in vec3 _vRayOrigin,  in vec3 _vRayDir )
{
    vec3 vRayOrigin = _vRayOrigin;
    vec3 vRayDir = _vRayDir;
	vec3 vColour = vec3(0.0);
	vec3 vRemaining = vec3(1.0);
	
    float fLastShadow = 1.0;
    
    float firstHitDist = kFarClip;
    bool hitSomething = false;
    
	for(int i=0; i<kBounceCount; i++)
	{	
		vec3 vCurrRemaining = vRemaining;
		float fShouldApply = 1.0;
		
		C_Intersection intersection;				
		TraceScene( intersection, vRayOrigin, vRayDir );

		vec3 vResult = vec3(0.0);
		vec3 vBlendFactor = vec3(0.0);
						
		if(intersection.fObjectId == 0.0)
		{
			vBlendFactor = vec3(1.0);
			fShouldApply = 0.0;
		}
		else
		{		
			vec3 vAlbedo;
			vec3 vR0;
			float fSmoothness;
			vec3 vBumpNormal;
			
			GetSurfaceInfo( vAlbedo, vR0, fSmoothness, vBumpNormal, intersection );			
		
			vec3 vDiffuseLight = vec3(0.0);
			vec3 vSpecularLight = vec3(0.0);

            fLastShadow = AddDirectionalLight(vDiffuseLight, vSpecularLight, vRayDir, intersection.vPos, vBumpNormal, fSmoothness, vSunLightDir, vSunLightColour);								

            vec3 vReflectDir = normalize(reflect(vRayDir, vBumpNormal));
            
            AddDirectionalLight(vDiffuseLight, vSpecularLight, vRayDir, intersection.vPos, vBumpNormal, fSmoothness * 0.5 + 0.5, GetSkyLightDir(vReflectDir), vSunLightColour);								
            

            /*
            vec3 vPointLightPos = vLightPos;           
            
			AddPointLight(vDiffuseLight, vSpecularLight, vRayDir, intersection.vPos, vBumpNormal, fSmoothness, vPointLightPos, vLightColour);								

            vec3 vToLight = vPointLightPos - intersection.vPos;
            float fNdotL = dot(normalize(vToLight), vBumpNormal) * 0.5 + 0.5;
            vDiffuseLight += max(0.0, 1.0 - length(vToLight)/5.0) * vLightColour * fNdotL;                
			*/

			float fSmoothFactor = fSmoothness * 0.9 + 0.1;
            float fFresnelClamp = 0.25; // too much fresnel produces sparkly artefacts
            float fNdotD = clamp(dot(vBumpNormal, -vRayDir), fFresnelClamp, 1.0);
			vec3 vFresnel = vR0 + (1.0 - vR0) * pow(1.0 - fNdotD, 5.0) * fSmoothFactor;

			vResult = mix(vAlbedo * vDiffuseLight, vSpecularLight, vFresnel);		
			vBlendFactor = vFresnel;

			ApplyAtmosphere(vResult, intersection.fDist, vRayOrigin, vRayDir);		

#ifdef REFLECT_EFFECTS
            ApplyEffects( vResult, vRayOrigin, vRayDir, intersection.fDist );
#endif
            
			vRemaining *= vBlendFactor;				
			vRayDir = vReflectDir;
			vRayOrigin = intersection.vPos;
            
            hitSomething = true;
            if( i== 0)
            {
            	firstHitDist = intersection.fDist;
            }
		}			

		vColour += vResult * vCurrRemaining * fShouldApply;	
	}

    if(!hitSomething)
    {        
       vColour = GetSkyColour(_vRayDir)+ GetSkyLight(_vRayDir, 2.0);        
    }

    
#ifdef REFLECT_EFFECTS
    if(!hitSomething)
#endif
    ApplyEffects( vColour, _vRayOrigin, _vRayDir, firstHitDist );
    
	return vColour;
}

// ---- 8< -------- 8< -------- 8< -------- 8< ----

float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy) + f.xy;
	return texture2D( iChannel2, (uv+ 0.5)/256.0, -100.0 ).x;
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel2, (uv+ 0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

// ---- 8< -------- 8< -------- 8< -------- 8< ----

#define float2 vec2
#define frac fract
#define fmod mod
#define ddx dFdx
#define ddy dFdy

float Debug_SevenSegmentSegment( const in float2 inUV, const in float segmentLength, const in float segmentWidth )
{
    float2 clampedUV = inUV;
    clampedUV.x -= clamp(clampedUV.x, 0.0, segmentLength);
    
    float2 absUV = abs(clampedUV);
    float dist = absUV.y + absUV.x;
    
    float result = (1.0 - (dist /  segmentWidth)) * segmentWidth;

    float2 deltas = max( ddx(inUV.xy), ddy(inUV.xy) );            
    result = result / max(deltas.x, deltas.y);
    
    return clamp(result, 0.0, 1.0);
}


float Debug_SevenSegmentDecimalPoint( const in float2 inUV, const float size )
{
    float dist = length( inUV );
                        
    float result = (1.0 - (dist / size)) * size;

    float2 deltas = max( ddx(inUV.xy), ddy(inUV.xy) );    
    result = result / max(deltas.x, deltas.y);
    
    return clamp(result, 0.0, 1.0);
}

#define DEBUG_SEGMENT_A  0x01
#define DEBUG_SEGMENT_B  0x02
#define DEBUG_SEGMENT_C  0x04
#define DEBUG_SEGMENT_D  0x08
#define DEBUG_SEGMENT_E  0x10
#define DEBUG_SEGMENT_F  0x20
#define DEBUG_SEGMENT_G  0x40

#define DEBUG_7SEGMENT_CODE_BLANK 	0
#define DEBUG_7SEGMENT_CODE_MINUS 	DEBUG_SEGMENT_G

#define DEBUG_7SEGMENT_CODE_0 (DEBUG_SEGMENT_A + DEBUG_SEGMENT_B + DEBUG_SEGMENT_C + DEBUG_SEGMENT_D + DEBUG_SEGMENT_E + DEBUG_SEGMENT_F)
#define DEBUG_7SEGMENT_CODE_1 (DEBUG_SEGMENT_B + DEBUG_SEGMENT_C)
#define DEBUG_7SEGMENT_CODE_2 (DEBUG_SEGMENT_A + DEBUG_SEGMENT_B + DEBUG_SEGMENT_D +  DEBUG_SEGMENT_E + DEBUG_SEGMENT_G)
#define DEBUG_7SEGMENT_CODE_3 (DEBUG_SEGMENT_A + DEBUG_SEGMENT_B + DEBUG_SEGMENT_C + DEBUG_SEGMENT_D + DEBUG_SEGMENT_G)
#define DEBUG_7SEGMENT_CODE_4 (DEBUG_SEGMENT_B + DEBUG_SEGMENT_C + DEBUG_SEGMENT_F + DEBUG_SEGMENT_G)
#define DEBUG_7SEGMENT_CODE_5 (DEBUG_SEGMENT_A + DEBUG_SEGMENT_C + DEBUG_SEGMENT_D +  DEBUG_SEGMENT_F + DEBUG_SEGMENT_G)
#define DEBUG_7SEGMENT_CODE_6 (DEBUG_SEGMENT_A + DEBUG_SEGMENT_C + DEBUG_SEGMENT_D + DEBUG_SEGMENT_E + DEBUG_SEGMENT_F + DEBUG_SEGMENT_G)
#define DEBUG_7SEGMENT_CODE_7 (DEBUG_SEGMENT_A + DEBUG_SEGMENT_B + DEBUG_SEGMENT_C)
#define DEBUG_7SEGMENT_CODE_8 (DEBUG_SEGMENT_A + DEBUG_SEGMENT_B + DEBUG_SEGMENT_C + DEBUG_SEGMENT_D + DEBUG_SEGMENT_E + DEBUG_SEGMENT_F + DEBUG_SEGMENT_G)
#define DEBUG_7SEGMENT_CODE_9 (DEBUG_SEGMENT_A + DEBUG_SEGMENT_B + DEBUG_SEGMENT_C + DEBUG_SEGMENT_D + DEBUG_SEGMENT_F + DEBUG_SEGMENT_G)


int Debug_DigitCode(const in int x)
{
    return 	x==0?DEBUG_7SEGMENT_CODE_0
    :x==1?DEBUG_7SEGMENT_CODE_1
    :x==2?DEBUG_7SEGMENT_CODE_2
    :x==3?DEBUG_7SEGMENT_CODE_3
    :x==4?DEBUG_7SEGMENT_CODE_4
    :x==5?DEBUG_7SEGMENT_CODE_5
    :x==6?DEBUG_7SEGMENT_CODE_6
    :x==7?DEBUG_7SEGMENT_CODE_7
    :x==8?DEBUG_7SEGMENT_CODE_8
    :x==9?DEBUG_7SEGMENT_CODE_9:
    DEBUG_7SEGMENT_CODE_BLANK;
}


bool TestBin( int a, int b )
{
    float fa = float(a);
    float fb = float(b);
    return fmod( floor(fa / fb), 2.0 ) > 0.0;
}


float SegmentBrightness( bool enabled )
{
    if( enabled ) return 1.0;
    else 
        return 0.0;
}


float Debug_PrintDigit( const in float2 inUV, int digit, bool decimalPoint )
{
    const float fThickness = 0.06;    
    const float fSegSize = 0.2;
    const float fSpacing = 0.075;
    const float decimalPointThickness = 0.095;    
    
    float fShade = 0.0;
    
    float2 uv = inUV * float2(0.7, 1.0);
    uv.x += uv.y * -0.2;
    
    fShade += Debug_SevenSegmentSegment( ( uv - float2(fSpacing * 2.0, fSpacing * 5.0 + fSegSize * 2.0) ), fSegSize, fThickness) * SegmentBrightness( TestBin(digit, DEBUG_SEGMENT_A) );
    fShade += Debug_SevenSegmentSegment( ( uv - float2(fSpacing * 3.0 + fSegSize, fSpacing * 4.0 + fSegSize) ).yx, fSegSize, fThickness) * SegmentBrightness( TestBin(digit, DEBUG_SEGMENT_B) );
    fShade += Debug_SevenSegmentSegment( ( uv - float2(fSpacing * 3.0 + fSegSize, fSpacing * 2.0) ).yx, fSegSize, fThickness) * SegmentBrightness( TestBin(digit, DEBUG_SEGMENT_C) );    
    fShade += Debug_SevenSegmentSegment( ( uv - float2(fSpacing * 2.0, fSpacing) ), fSegSize, fThickness) * SegmentBrightness( TestBin(digit, DEBUG_SEGMENT_D) );
    fShade += Debug_SevenSegmentSegment( ( uv - float2(fSpacing, fSpacing * 2.0) ).yx, fSegSize, fThickness) * SegmentBrightness( TestBin(digit, DEBUG_SEGMENT_E) );
    fShade += Debug_SevenSegmentSegment( ( uv - float2(fSpacing, fSpacing * 4.0 + fSegSize ) ).yx, fSegSize, fThickness) * SegmentBrightness( TestBin(digit, DEBUG_SEGMENT_F) );    
    fShade += Debug_SevenSegmentSegment( ( uv - float2(fSpacing * 2.0, fSpacing * 3.0 + fSegSize) ), fSegSize, fThickness) * SegmentBrightness( TestBin(digit, DEBUG_SEGMENT_G) );
    fShade += Debug_SevenSegmentDecimalPoint( inUV - float2(0.9, 0.1), decimalPointThickness) * SegmentBrightness( decimalPoint );
    
    fShade = clamp(fShade, 0.0, 1.0);
    return sqrt(fShade);
}


float Debug_PrintInteger( const in float2 uv, const in float2 fontSize, const in float value, const in float maxDigits )
{
    float2 stringCharCoords = uv / fontSize;
    if ((stringCharCoords.y < 0.0) || (stringCharCoords.y >= 1.0)) return 0.0;
    
	float fLog10Value = log2(abs(value)) / log2(10.0);
	float fBiggestIndex = max(floor(fLog10Value), 0.0);
	float fDigitIndex = maxDigits - ceil(stringCharCoords.x);
	int charCode = 0;

    if(fDigitIndex < 0.0) 
    {
    	return 0.0;
    }

    if(fDigitIndex > (fBiggestIndex + ((value < 0.0) ? 1.0 : 0.0)) ) 
    {
        return 0.0;
    }

    if(fDigitIndex > fBiggestIndex) 
    {
        if ((value < 0.0) && (fDigitIndex < (fBiggestIndex+1.5)))
        {
            charCode = DEBUG_7SEGMENT_CODE_MINUS;
        }
    }
    else 
    {		
        float fDigitValue = (abs(value / (pow(10.0, fDigitIndex))));
        float kFix = 0.0001;
        charCode = Debug_DigitCode(int(floor(fmod(kFix+fDigitValue, 10.0))));
    }
    
    float result = Debug_PrintDigit( frac(stringCharCoords), charCode, false );

    return result;
    
}

float Debug_PrintFloatApprox( const in float2 uv, const in float2 fontSize, const in float value, const in float maxDigits, const in float decimalPlaces )
{
    float2 stringCharCoords = uv / fontSize;
    if ((stringCharCoords.y < 0.0) || (stringCharCoords.y >= 1.0)) return 0.0;
    
	float fLog10Value = log2(abs(value)) / log2(10.0);
	float fBiggestIndex = max(floor(fLog10Value), 0.0);
	float fDigitIndex = maxDigits - ceil(stringCharCoords.x);
	int charCode = 0;
    bool decimalPoint = false;
	if(fDigitIndex <= (-decimalPlaces - 0.5)) 
    {
    	return 0.0;
    }

    if(fDigitIndex > (fBiggestIndex + ((value < 0.0) ? 1.0 : 0.0)) ) 
    {
        return 0.0;
    }

    if(fDigitIndex > fBiggestIndex) 
    {
        if ((value < 0.0) && (fDigitIndex < (fBiggestIndex+1.5)))
        {
            charCode = DEBUG_7SEGMENT_CODE_MINUS;
        }
    }
    else 
    {		
        if(fDigitIndex == 0.0 && decimalPlaces > 0.0 ) 
        {
            decimalPoint = true;
        }
        float fDigitValue = (abs(value / (pow(10.0, fDigitIndex))));
        float kFix = 0.0001;
        charCode = Debug_DigitCode(int(floor(fmod(kFix+fDigitValue, 10.0))));
    }
    
    float result = Debug_PrintDigit( frac(stringCharCoords), charCode, decimalPoint );

    return result;
}

