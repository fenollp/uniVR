// Shader downloaded from https://www.shadertoy.com/view/4d3Gzn
// written by shadertoy user aiekick
//
// Name: Sound Experiment 5
// Description: An attempt to colorize the [url=https://www.shadertoy.com/view/XscGRn]Sound Experiment 4[/url]
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// based on https://www.shadertoy.com/view/4ljSDt from gilesruscoe 

vec4 freq1, freq2, freq3;

vec4 map(vec3 p)
{   
    p.xy += vec2(cos(p.z),sin(p.z));
	
    float c = 1.0;

    float cz = p.z, sz = p.z;
    
    cz += freq1.x; sz -= freq2.w;
   	float tube = length(p.xy + vec2(cos(cz),sin(sz))*.5);
    vec4 res = vec4(tube, c, freq1.x, freq2.w);
    
	cz += freq1.y; sz -= freq2.z;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*.4));
    if (tube < res.x) res = vec4(tube, c, freq1.y, freq2.z);
        
	cz += freq1.z; sz -= freq2.y;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*.3));
    if (tube < res.x) res = vec4(tube, c, freq1.z, freq2.y);
    
	cz += freq1.w; sz -= freq2.x;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*.2));
    if (tube < res.x) res = vec4(tube, c, freq1.w, freq2.x);
    
    
    cz += freq3.x; sz -= freq1.w;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*.1));
    if (tube < res.x) res = vec4(tube, c, c, c);
    
	cz += freq3.y; sz -= freq1.z;
	tube = min(tube, length(p.xy/* + vec2(cos(cz),sin(sz))*.0*/));
    if (tube < res.x) res = vec4(tube, c, c, c);
    
	cz += freq3.z; sz -= freq1.y;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*-.1));
    if (tube < res.x) res = vec4(tube, c, c, c);
    
	cz += freq3.w; sz -= freq1.x;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*-.2));
    if (tube < res.x) res = vec4(tube, c, c, c);
    
    
	cz += freq2.x; sz -= freq3.w;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*-.3));
    if (tube < res.x) res = vec4(tube, freq2.x, freq3.w, c);
    
	cz += freq2.y; sz -= freq3.z;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*-.4));
    if (tube < res.x) res = vec4(tube, freq2.y, freq3.z, c);
    
	cz += freq2.z; sz -= freq3.y;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*-.5));
    if (tube < res.x) res = vec4(tube, freq2.z, freq3.y, c);
    
	cz += freq2.w; sz -= freq3.x;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*-.6));
    if (tube < res.x) res = vec4(tube, freq2.w, freq3.x, c);
    
	return vec4(res.x - 0.05, res.yzw);
}

vec4 trace(vec3 o, vec3 r)
{
    float t = 0.0;
    vec4 d;
    for (int i = 0; i < 60; ++i)
    {
        vec3 p = o + r * t;
        d = map(p);
        t += d.x * (d.x>0.05?0.5:0.1);
    }
    return vec4(t, d.yzw);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // from CubeScape : https://www.shadertoy.com/view/Msl3Rr
    freq1.x = texture2D( iChannel0, vec2( 0.075, 0.25 ) ).x;
	freq1.y = texture2D( iChannel0, vec2( 0.15, 0.25 ) ).x;
	freq1.z = texture2D( iChannel0, vec2( 0.225, 0.25 ) ).x;
	freq1.w = texture2D( iChannel0, vec2( 0.3, 0.25 ) ).x;
    
    freq2.x = texture2D( iChannel0, vec2( 0.375, 0.25 ) ).x;
	freq2.y = texture2D( iChannel0, vec2( 0.45, 0.25 ) ).x;
	freq2.z = texture2D( iChannel0, vec2( 0.525, 0.25 ) ).x;
	freq2.w = texture2D( iChannel0, vec2( 0.6, 0.25 ) ).x;
    
    freq3.x = texture2D( iChannel0, vec2( 0.675, 0.25 ) ).x;
    freq3.y = texture2D( iChannel0, vec2( 0.75, 0.25 ) ).x;
    freq3.z = texture2D( iChannel0, vec2( 0.825, 0.25 ) ).x;
    freq3.w = texture2D( iChannel0, vec2( 0.9, 0.25 ) ).x;
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    uv = uv * 2.0 - 1.0;
    
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 r = normalize(vec3(uv, 2.0));
    
    vec3 o = vec3(0.0, 0.0, iGlobalTime * 2.);
    
    vec4 t = trace(o, r);
    
    float fog = 2. / (1. + t.x * t.x * 0.1);
    
	fragColor = vec4(fog * t.yzw, 1.);
}

