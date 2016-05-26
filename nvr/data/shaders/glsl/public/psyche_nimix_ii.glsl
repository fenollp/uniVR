// Shader downloaded from https://www.shadertoy.com/view/XtBGzK
// written by shadertoy user xbe
//
// Name: Psyche Nimix II
// Description: Same as previous &quot;Pysche Nimix&quot; but using a set of presets and a shutter to cycle between preset change.
//    
//    Credits: &quot;Overly Satisfying&quot; by Nimitz, also reusing adapted part of &quot;The power of sin&quot; by antonOTI.
//    
// Xavier Benech
// Psyche Nimix II
//
// Credits:
// "Overly Satisfying" from Nimitz: https://www.shadertoy.com/view/Mts3zM
// "The power of sin" by antonOTI: https://www.shadertoy.com/view/XdlSzB
//
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define PI 3.14159265
#define NUM 10.
#define PALETTE vec3(1.5, 2.9, 3.5)

#define MIRROR
#define SHUTTERED

float aspect = iResolution.x/iResolution.y;
float delta = 0.01 + 0.0625*exp(-0.00325*iResolution.x);

mat2 rotate(in float a)
{
    float c = cos(a), s = sin(a);
    return mat2(c,-s,s,c);
}

float tri(in float x)
{
    return abs(fract(x)-.5);
}

vec2 tri2(in vec2 p)
{
    return vec2(tri(p.x+tri(p.y*2.)),tri(p.y+tri(p.x*2.)));
}

mat2 trinoisemat = mat2( 0.970,  0.242, -0.242,  0.970 );

float triangleNoise(in vec2 p)
{
    float z=1.5;
    float z2=1.5;
	float rz = 0.;
    vec2 bp = p;
	for (float i=0.; i<=3.; i++ )
	{
        vec2 dg = tri2(bp*2.)*.8;
        dg *= rotate(iGlobalTime*.8);
        p += dg/z2;

        bp *= 1.6;
        z2 *= .6;
		z *= 1.8;
		p *= 1.2;
        p*= trinoisemat;
        
        rz+= (tri(p.x+tri(p.y)))/z;
	}
	return rz;
}

float arc(in vec2 plr, in float radius, in float thickness, in float la, in float ha)
{
    // clamp arc start/end
    float res = step(la, plr.y) * step(plr.y, ha);
    // smooth outside
    res *= smoothstep(plr.x, plr.x+delta,radius+thickness);
    // smooth inside
    float f = radius - thickness;
    res *= smoothstep( f, f+delta, plr.x);
    // smooth start
    res *= smoothstep( la, la+delta, plr.y);
    // smooth end
    res *= 1. - smoothstep( ha-delta, ha, plr.y);
    return res;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
 	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 q = uv*2.-1.;
	q.x *= aspect;

#ifdef MIRROR
    vec2 p = 1.85*q;
    p.x = abs(p.x);
    p.y = abs(p.y);
#else
    vec2 p = 1.23*q;
#endif
    
#ifdef SHUTTERED
    float k = clamp(exp(1.-abs(sin(0.5*iGlobalTime)))-exp(0.5), 0., 1.);
    float shutter = 1.0 - smoothstep( 0., 1., 10.*(k-0.75) );
#endif
    
#ifdef SHUTTERED
    k = clamp(fract(iGlobalTime/(10.*PI)), 0.,1.);
    float sum = step(k, 0.2)+step(k, 0.4)+step(k, 0.6)+step(k, 0.8);
    float k0 = 60. + 90.*sum;
    float k1 = 15.*sum;
    float k2 = 2.-sum;
    if (k2==0.) {
        k2 = 1.;
        k0 = 120.;
    }
    p *= rotate(PI*(k0 + k1*cos(0.5*iGlobalTime + texture2D( iChannel0, vec2(0.123, 0.0015*iGlobalTime)).x))/180.);
    p.y = 2. - ( 0.2 + k2 )*(1.-exp(-abs(p.y)));
#else
    p *= rotate(2.*PI*cos(0.1*iGlobalTime + texture2D( iChannel0, vec2(0.123, 0.0015*iGlobalTime)).x));
    p.y = 2. - ( 0.2 + 2.0 * sin(0.5*iGlobalTime) )*(1.-exp(-abs(p.y)));
#endif
    
    float lp = length(p);
    float id = floor(lp*NUM+.5)/NUM;
    vec4 n = texture2D( iChannel0, vec2(id, 0.0025*iGlobalTime));
            
    p *= rotate(2.72 * PI * n.x);
    p.y = abs(p.y); 
    
    //polar coords
    vec2 plr = vec2(lp, atan(p.y, p.x));
    
    //Draw concentric arcs
    float rz = arc(plr, id, clamp(1.2*n.w, 0.,1.)*0.5/NUM, 0., PI*n.y);
    
    rz *= step(1./NUM, id);
    
    float m = rz;
    rz *= (triangleNoise(p)*0.9+0.4);
    vec3 col = (sin(PALETTE+id*10.+5.*iGlobalTime)*0.5+0.65)*rz;
        
    // Background
	vec3 bkg = vec3(0.32,0.36,0.4) + q.y*0.1;
	col += 0.5*bkg*(1.-m);
	// Vignetting
	vec2 r = -1.0 + 2.0*(uv);
	float vb = max(abs(r.x), abs(r.y));
	col *= (0.15 + 0.85*(1.0-exp(-(1.0-vb)*30.0)));
    
    col *= 1.2;
#ifdef SHUTTERED
    col *= shutter;
#endif
	fragColor = vec4(col,1.0);
}
