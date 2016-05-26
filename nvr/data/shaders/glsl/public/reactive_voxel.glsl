// Shader downloaded from https://www.shadertoy.com/view/4lfSW4
// written by shadertoy user glk7
//
// Name: Reactive Voxel
// Description: 3D noise displayed on a voxelized cube. Reacts to the change in the lowest frequency playing on iChannel1. The cube can be rotated with the mouse.
// Created by genis sole - 2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define EPS 0.001


// Taken from http://iquilezles.org/www/articles/palettes/palettes.htm
vec3 ColorPalette(in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

// From https://www.shadertoy.com/view/XsX3RB (iq's Volcanic)
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

bool map(in vec3 p, out float v) 
{
    p += iGlobalTime*0.3 - texture2D(iChannel1, vec2(0.0, 0.0)).r*1.2;
    
    float d = noise(p*vec3(0.2));
    v = mix(0.4, 0.7, (d - 0.3)*3.33);
    return d < 0.6 && d > 0.3;
}

bool IRayAABox(in vec3 ro, in vec3 rd, in vec3 invrd, in vec3 bmin, in vec3 bmax, out vec3 p0, out vec3 p1) 
{
    vec3 t0 = (bmin - ro) * invrd;
    vec3 t1 = (bmax - ro) * invrd;

    vec3 tmin = min(t0, t1);
    vec3 tmax = max(t0, t1);
    
    float fmin = max(max(tmin.x, tmin.y), tmin.z);
    float fmax = min(min(tmax.x, tmax.y), tmax.z);
    
    p0 = ro + rd*fmin;
    p1 = ro + rd*fmax;
    return fmax >= fmin;   
}

vec3 AABoxNormal(vec3 bmin, vec3 bmax, vec3 p) 
{
    vec3 n1 = -(1.0 - smoothstep(0.0, 0.1, p - bmin));
    vec3 n2 = (1.0 -  smoothstep(0.0, 0.1, bmax - p));
    
    return normalize(n1 + n2);
}

bool Voxels(in vec3 ro, in vec3 rd, in vec3 invrd, in vec3 bmin, in vec3 bmax, out vec3 n, out vec3 p, out float v)
{
    n = vec3(0.0);
    p = vec3(0.0);
    v = 0.0;
    
    vec3 re = vec3(0.0);
    vec3 pa = vec3(0.0);
    if (!IRayAABox(ro, rd, invrd, bmin, bmax, ro, re)) return false;
    
    if (length(re - ro) <= EPS) return false;
    vec3 ep = floor(ro + rd*EPS);

    bool ret = false;
    for (int i = 0; i < 100; ++i) {
        if (map(ep, v)) {
            ret = true;
            break;
        }

        IRayAABox(ro - rd*2.0, rd, invrd, ep, ep+1.0, pa, ro);
        ep = floor(ro + rd*EPS);

        if (length(re - ro) <= EPS) {
            ret = false;
            break;
        }

    }
    
    if (ret) {
    	n = AABoxNormal(ep, ep+1.0, ro);
        p = ro;   
    }
    return ret;
}

float ShadowFactor(in vec3 ro, in vec3 rd, in vec3 invrd, in vec3 bmin, in vec3 bmax) 
{
    vec3 re = vec3(0.0);
    vec3 pa = vec3(0.0);
    
    IRayAABox(ro + rd*((length(bmin - bmax) + EPS)), -rd, -invrd, bmin, bmax, re, pa);
    if (length(re - ro) <= EPS) return 1.0;
    
    vec3 ep = floor(ro + rd*EPS);
    float v = 0.0;
    float ret = 1.0;
    for (float i = 0.0; i < 100.0; ++i) {
        if (map(ep, v)) {
            ret = -i;
        	break;
        }
        
        IRayAABox(ro - rd*2.0, rd, invrd, ep, ep+1.0, pa, ro);
        ep = floor(ro + rd*EPS);
        
        if (length(re - ro) <= EPS) {
            ret = 1.0;
            break;
        }
    }
    
    return ret;
}

float AOFactor(in vec3 ro, in vec3 n, in vec3 rd, in vec3 invrd, in vec3 bmin, in vec3 bmax) 
{
    float t = ShadowFactor(ro, rd, invrd, bmin, bmax);
    return (1.0 - step(0.0, t)) * clamp(-t * 0.3, 0.0, 1.0) + (step(0.0, t)) * t;
}

float AmbientOcclusion(in vec3 ro, in vec3 n, in vec3 bmin, in vec3 bmax) 
{   
    const float nf = 0.707;
    const vec3 v0 = (vec3(1.0, 1.0, 0.0) * nf) + EPS;
    const vec3 v1 = (vec3(-1.0, 1.0, 0.0) * nf) + EPS;
    const vec3 v2 = (vec3(0.0, 1.0, 1.0) * nf) + EPS;
    const vec3 v3 = (vec3(0.0, 1.0, -1.0) * nf) + EPS;
    
    const vec3 v4 = -v0;
    const vec3 v5 = -v1;
    const vec3 v6 = -v2;
    const vec3 v7 = -v3;
    
    const vec3 invv0 = 1.0/v0;
    const vec3 invv1 = 1.0/v1;
    const vec3 invv2 = 1.0/v2;
    const vec3 invv3 = 1.0/v3;
    const vec3 invv4 = 1.0/v4;
    const vec3 invv5 = 1.0/v5; 
    const vec3 invv6 = 1.0/v6;
    const vec3 invv7 = 1.0/v7;
    vec3 invn = 1.0/(n);
    
    float r = 0.0;
    r += AOFactor(ro, n, n, invn, bmin, bmax);
	r += AOFactor(ro, n, v0, invv0, bmin, bmax);
    r += AOFactor(ro, n, v1, invv1, bmin, bmax);
    r += AOFactor(ro, n, v2, invv2, bmin, bmax);
    r += AOFactor(ro, n, v3, invv3, bmin, bmax);
    r += AOFactor(ro, n, v4, invv4, bmin, bmax);
    r += AOFactor(ro, n, v5, invv5, bmin, bmax);
	r += AOFactor(ro, n, v6, invv6, bmin, bmax);
    r += AOFactor(ro, n, v7, invv7, bmin, bmax);
    
    return clamp(r * 0.2, 0.0, 1.0);
}


vec3 GetColor(float v) 
{
    //return vec3(1.0);
	return ColorPalette(v, vec3(0.5, 0.5, 0.5), 
                           vec3(0.5), 
                           vec3(0.6, 0.4, 0.3), 
                           vec3(0.6, 0.4, 0.3));  
}

void CameraOrbitRay(in vec2 fragCoord, in float n, in vec3 c, in float d, 
                    out vec3 ro, out vec3 rd, out mat3 t) 
{
    float a = 1.0/max(iResolution.x, iResolution.y);
    rd = normalize(vec3((fragCoord - iResolution.xy*0.5)*a, n));
 
    ro = vec3(0.0, 0.0, -d);
    
    float mxc = clamp(-((iMouse.x / iResolution.x)*2.0 - 1.0), -1.0, 1.0);
    float mxs = sqrt(1.0-(mxc*mxc));
    
	float myc = clamp((iMouse.y / iResolution.y)*2.0 - 1.0, -1.0, 1.0);
    float mys = sqrt(1.0-(myc*myc));
    
    t = mat3(mxc, mxs, 0, -mxs*myc, mxc*myc, mys, mxs*mys, -mxc*mys, myc);
        
    ro = t * ro;
    ro = c + ro;

    rd = t * rd;
    
    rd = normalize(rd);
}

vec3 LightDir(in mat3 t) 
{
    vec3 l = normalize(vec3(-1.0, -1.0, 1.0));
    return t * l;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
   	vec3 bpos = vec3(-5.0);
    
   	vec3 bmin = vec3(10.0, 10.0, 10.0) + bpos;
    vec3 bmax = vec3(0.0, 0.0, 0.0) + bpos;
    
    vec3 ro = vec3(0.0);
    vec3 rd = vec3(0.0);
    mat3 t = mat3(1.0);
    CameraOrbitRay(fragCoord, 0.5, bpos+vec3(5.0), 20.0, ro, rd, t);
    
    vec3 l = LightDir(t);
    
    vec3 invrd = 1.0 / rd;
    vec3 invl = 1.0 / l;
    
    vec3 p = vec3(0.0);
    vec3 n = vec3(0.0);
    float v = 0.0;
    
    vec3 color = vec3(0.03, 0.03, 0.03);
 
    if (Voxels(ro, rd, invrd, bmin, bmax, n, p, v)) {
    	color = GetColor(v);
        vec3 diff = color * max(dot(-l, n), 0.0);
        diff *= clamp(ShadowFactor(p, -l, -invl, bmin, bmax), 0.0, 1.0);
        vec3 amb = color * AmbientOcclusion(p, n, bmin, bmax) * 0.7 + color * 0.3;
        color = diff*0.8 + amb*0.2;
    }
   
    color = pow(color, vec3(0.55));
    fragColor = vec4(color, 1.0);
}