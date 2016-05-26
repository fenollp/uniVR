// Shader downloaded from https://www.shadertoy.com/view/lsG3Rt
// written by shadertoy user goulart
//
// Name: Cloud Blending
// Description: blends to images using fbm
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#ifdef GL_ES
precision highp float;
#endif

#define EPS		.001
#define PI		3.14159265359
#define RADIAN	180. / PI
#define SPEED	25.

float hash(vec2 p)
{
    return fract(sin(dot(p,vec2(127.1,311.7))) * 43758.5453123);
}

float noise(vec2 p)
{
    vec2 i = floor(p), f = fract(p); 
	f *= f*(3.-2.*f);
    
    vec2 c = vec2(0,1);
    
    return mix(mix(hash(i + c.xx), 
                   hash(i + c.yx), f.x),
               mix(hash(i + c.xy), 
                   hash(i + c.yy), f.x), f.y);
}

float fbm(in vec2 p)
{
	return	.5000 * noise(p)
		   +.2500 * noise(p * 2.)
		   +.1250 * noise(p * 4.)
		   +.0625 * noise(p * 8.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy;

    float cloudVal = (fbm(p+iGlobalTime));
    
    vec3 backPx = texture2D( iChannel0, p ).rgb;
    vec3 frontPx = vec3(0.3, 0.3, 0.3);// = texture2D( iChannel1, p ).rgb;
    float alpha = mod(iGlobalTime, 1.0);
    
    vec3 rPx = mix(backPx, frontPx, cloudVal);
    
    fragColor = vec4( rPx ,1);
}

