// Shader downloaded from https://www.shadertoy.com/view/Ml2XWt
// written by shadertoy user aiekick
//
// Name: Sound Experiment 3
// Description: based on shader // https://www.shadertoy.com/view/4ljSDt from gilesruscoe 
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

// based on https://www.shadertoy.com/view/4ljSDt from gilesruscoe 

vec4 freqs;

float map(vec3 p)
{
    
    p.z += cos(p.y) * freqs.y * 3.;
    float xz = length(fract(p.xz)*2.-1.);
	
   	p.y += cos(p.z/2.) * freqs.z * 2.;
	float xy = length(fract(p.xy/1.2)*2.-1.);
	   
   	float zy = max(length(fract(p.zy+vec2(.5))*2.-1.), 
                   max(min(cos(p.z) * freqs.x * 2.,cos(p.z) * freqs.y),.2) - abs(p.x));
	
    return min(xz, min(xy, zy)) - 0.1;
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
    freqs.x = texture2D( iChannel0, vec2( 0.01, 0.25 ) ).x;
	freqs.y = texture2D( iChannel0, vec2( 0.1, 0.25 ) ).x;
	freqs.z = texture2D( iChannel0, vec2( 0.2, 0.25 ) ).x;
	freqs.w = texture2D( iChannel0, vec2( 0.3, 0.25 ) ).x;
    
    freqs.x = (freqs.x * 1. + freqs.y * 2. + freqs.z *3. + freqs.w * 4.)/5.;
   	freqs.y = (freqs.y * 1. + freqs.z * 2. + freqs.w *3.)/5.;
   	freqs.z = (freqs.z * 1. + freqs.w * 2.)/6.;
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    uv = uv * 2.0 - 1.0;
    
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 r = normalize(vec3(uv, 2.0));
    
    vec3 o = vec3(0.0, -cos( freqs.y ) * freqs.z * 2., iGlobalTime * 2.);
    
    float t = trace(o, r * clamp(freqs.w, 1., 2.));
    
    float fog = 2. / (1. + t * t * 0.1);
    
    vec3 col = (.5 + freqs.yzx) * fog;
    
	fragColor = vec4(col, 1.0);
}

