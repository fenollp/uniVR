// Shader downloaded from https://www.shadertoy.com/view/lsVGWG
// written by shadertoy user jherico
//
// Name: OMGSky
// Description: based on OMGClouds, for use as a skybox in interface
// Created by inigo quilez - iq/2013
// Turbulence and Day/Night cycle added by Michael Olson - OMGparticles/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Volumetric clouds. It performs level of detail (LOD) for faster rendering and antialiasing

float fTurbulence = 0.35;

float fSunSpeed = 0.35 * iGlobalTime;

vec3 vNightColor   = vec3(.15, 0.3, 0.6);
vec3 vHorizonColor = vec3(0.6, 0.3, 0.4);
vec3 vDayColor     = vec3(0.7,0.8,1);

vec3 vSunColor     = vec3(1.0,0.8,0.6);
vec3 vSunRimColor  = vec3(1.0,0.66,0.33);

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec4 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 );
	return (-1.0+2.0*mix( rg.g, rg.r, f.z ));
}


vec3 sundir = normalize( vec3(cos(fSunSpeed),sin(fSunSpeed),0.0) );


vec4 render( in vec3 ro, in vec3 rd )
{
	float sun = clamp( dot(sundir,rd), 0.0, 1.0 );
    
    float fSunHeight = sundir.y;
    
    // below this height will be full night color
    float fNightHeight = -0.8;
    // above this height will be full day color
    float fDayHeight   = 0.3;
    
    float fHorizonLength = fDayHeight - fNightHeight;
    float fInverseHL = 1.0 / fHorizonLength;
    float fHalfHorizonLength = fHorizonLength / 2.0;
    float fInverseHHL = 1.0 / fHalfHorizonLength;
    float fMidPoint = fNightHeight + fHalfHorizonLength;
    
    float fNightContrib = clamp((fSunHeight - fMidPoint) * (-fInverseHHL), 0.0, 1.0);
    float fHorizonContrib = -clamp(abs((fSunHeight - fMidPoint) * (-fInverseHHL)), 0.0, 1.0) + 1.0;
    float fDayContrib = clamp((fSunHeight - fMidPoint) * ( fInverseHHL), 0.0, 1.0);
    
    // sky color
    vec3 vSkyColor = vec3(0.0);
    vSkyColor += mix(vec3(0.0),   vNightColor, fNightContrib);   // Night
    vSkyColor += mix(vec3(0.0), vHorizonColor, fHorizonContrib); // Horizon
    vSkyColor += mix(vec3(0.0),     vDayColor, fDayContrib);     // Day
    
	vec3 col = vSkyColor;
    
    // atmosphere brighter near horizon
    col -= clamp(rd.y, 0.0, 0.5);
    
    // draw sun
	col += 0.4 * vSunRimColor * pow( sun,    4.0 );
	col += 1.0 * vSunColor    * pow( sun, 2000.0 );
    
    // stars
    float fStarSpeed = -fSunSpeed * 0.5;
    
    float fStarContrib = clamp((fSunHeight - fDayHeight) * (-fInverseHL), 0.0, 1.0);
    
    vec3 vStarDir = rd * mat3( vec3(cos(fStarSpeed), -sin(fStarSpeed), 0.0),
                               vec3(sin(fStarSpeed),  cos(fStarSpeed), 0.0),
                               vec3(0.0,             0.0,            1.0));
                              
    col += pow((texture2D(iChannel0, vStarDir.xy).r + texture2D(iChannel0, vStarDir.zy).r) * 0.5, 42.0) * fStarContrib * 40.0;
    return vec4( col, 1.0 );
}


mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/ iResolution.y;

    vec2 m = iMouse.xy/iResolution.xy;
    
    // camera
    vec3 ro = 4.0*normalize(vec3(sin(6.28*m.x + 1.5), 0.4 * m.y, cos(6.28*m.x + 1.5)));
	vec3 ta = vec3(0.0, -1.0, 0.0);
    mat3 ca = setCamera( ro, ta, 0.0 );
    // ray
    vec3 rd = ca * normalize( vec3(p.xy,1.5));
    
    fragColor = render( ro, rd );
}

void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 fragRayOri, in vec3 fragRayDir )
{
    fragColor = render( fragRayOri, fragRayDir );
}