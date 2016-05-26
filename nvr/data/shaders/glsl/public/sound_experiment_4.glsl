// Shader downloaded from https://www.shadertoy.com/view/XscGRn
// written by shadertoy user aiekick
//
// Name: Sound Experiment 4
// Description: Sound Experiment 4
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// based on https://www.shadertoy.com/view/4ljSDt from gilesruscoe 

vec4 freq1, freq2, freq3;

float map(vec3 p)
{
    p.xy += vec2(cos(p.z),sin(p.z));
	
    float tube = 10.;
    
    float cz = p.z, sz = p.z;
    
    cz += freq1.x; sz -= freq3.w;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*.5));
	cz += freq1.y; sz -= freq3.z;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*.4));
	cz += freq1.z; sz -= freq3.y;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*.3));
	cz += freq1.w; sz -= freq3.x;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*.2));
	cz += freq2.x; sz -= freq2.w;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*.1));
	cz += freq2.y; sz -= freq2.z;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*.0));
	cz += freq2.z; sz -= freq2.y;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*-.1));
	cz += freq2.w; sz -= freq2.x;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*-.2));
	cz += freq3.x; sz -= freq1.w;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*-.3));
	cz += freq3.y; sz -= freq1.z;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*-.4));
	cz += freq3.z; sz -= freq1.y;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*-.5));
	cz += freq3.w; sz -= freq1.x;
	tube = min(tube, length(p.xy + vec2(cos(cz),sin(sz))*-.6));
    
	return tube - 0.01;
}

float trace(vec3 o, vec3 r)
{
    float t = 0.0;
    for (int i = 0; i < 40; ++i)
    {
        vec3 p = o + r * t;
        float d = map(p);
        t += d * 0.5;
    }
    return t;
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
    
    float t = trace(o, r);
    
    float fog = 2. / (1. + t * t * 0.1);
    
	fragColor = vec4(fog);
}

