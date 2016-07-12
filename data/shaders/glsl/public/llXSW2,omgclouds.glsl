// Shader downloaded from https://www.shadertoy.com/view/llXSW2
// written by shadertoy user OMGparticles
//
// Name: OMGclouds
// Description: My first contribution to ShaderToy after following the tutorial at SIGGRAPH 2015. Most of this shader code is taken directly from iq's &quot;Clouds&quot; (shadertoy.com/view/XslGRr). I just added some turbulence/movement in the clouds, and a day/night cycle.
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

float map5( in vec3 p )
{
	vec3 q = p - vec3(0.0,0.1,1.0)*iGlobalTime;
	float f;
    f  = 0.50000*noise( q ); q = q*2.02 + iGlobalTime * fTurbulence * 1.0;
    f += 0.25000*noise( q ); q = q*2.03 + iGlobalTime * fTurbulence * 2.0;
    f += 0.12500*noise( q ); q = q*2.01 + iGlobalTime * fTurbulence * 4.0;
    f += 0.06250*noise( q ); q = q*2.02 + iGlobalTime * fTurbulence * 8.0;
    f += 0.03125*noise( q );
	return clamp( 1.5 - p.y - 2.0 + 1.75*f, 0.0, 1.0 );
}

float map4( in vec3 p )
{
	vec3 q = p - vec3(0.0,0.1,1.0)*iGlobalTime;
	float f;
    f  = 0.50000*noise( q ); q = q*2.02 + iGlobalTime * fTurbulence * 1.0;
    f += 0.25000*noise( q ); q = q*2.03 + iGlobalTime * fTurbulence * 2.0;
    f += 0.12500*noise( q ); q = q*2.01 + iGlobalTime * fTurbulence * 4.0;
    f += 0.06250*noise( q );
	return clamp( 1.5 - p.y - 2.0 + 1.75*f, 0.0, 1.0 );
}
float map3( in vec3 p )
{
	vec3 q = p - vec3(0.0,0.1,1.0)*iGlobalTime;
	float f;
    f  = 0.50000*noise( q ); q = q*2.02 + iGlobalTime * fTurbulence * 1.0;
    f += 0.25000*noise( q ); q = q*2.03 + iGlobalTime * fTurbulence * 2.0;
    f += 0.12500*noise( q );
	return clamp( 1.5 - p.y - 2.0 + 1.75*f, 0.0, 1.0 );
}
float map2( in vec3 p )
{
	vec3 q = p - vec3(0.0,0.1,1.0)*iGlobalTime;
	float f;
    f  = 0.50000*noise( q ); q = q*2.02 + iGlobalTime * fTurbulence * 1.0;
    f += 0.25000*noise( q );
	return clamp( 1.5 - p.y - 2.0 + 1.75*f, 0.0, 1.0 );
}

vec3 sundir = normalize( vec3(cos(fSunSpeed),sin(fSunSpeed),0.0) );

vec4 integrate( in vec4 sum, in float dif, in float den, in vec3 bgcol, in float t )
{
    // lighting
    vec3 lin = vec3(0.9,0.95,1.0) + 0.5*vec3(0.7, 0.5, 0.3)*dif * smoothstep(-0.3, 0.3, sundir.y);
    vec4 col = vec4( mix( 1.15*vec3(1.0,0.95,0.8), vec3(0.65), den ), den );
    col.xyz *= lin;
    //col.xyz = mix( col.xyz, bgcol, 1.0-exp(-0.003*t*t) );
    // front to back blending    
    col.a *= 0.4;
    col.rgb *= col.a;
    return sum + col*(1.0-sum.a);
}

#define MARCH(STEPS,MAPLOD) for(int i=0; i<STEPS; i++) { vec3  pos = ro + t*rd; if( pos.y<-3.0 || pos.y>2.0 || sum.a > 0.99 ) break; float den = MAPLOD( pos ); if( den>0.01 ) { float dif =  clamp((den - MAPLOD(pos+0.3*sundir))/0.6, 0.0, 1.0 ); sum = integrate( sum, dif, den, bgcol, t ); } t += max(0.01*float(i),0.02*t); }

vec4 raymarch( in vec3 ro, in vec3 rd, in vec3 bgcol )
{
	vec4 sum = vec4(0.0);

	float t = 0.0;

    MARCH(20,map5);
    MARCH(30,map4);
    MARCH(40,map3);
    MARCH(50,map2);

    return clamp( sum, 0.0, 1.0 );
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

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

    // raymarch clouds
    vec4 res = raymarch( ro, rd, col );
    
    // partially tint clouds to match sky color
    res *= vec4(pow(vSkyColor, vec3(0.25)), 1.0);
        
    col = col*(1.0-res.w) + res.xyz;

    return vec4( col, 1.0 );
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