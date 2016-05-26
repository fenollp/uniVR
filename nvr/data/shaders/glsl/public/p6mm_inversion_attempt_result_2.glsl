// Shader downloaded from https://www.shadertoy.com/view/XddSDX
// written by shadertoy user vox
//
// Name: P6MM Inversion Attempt Result 2
// Description: Figured it out. Just a Mobius transformation. At least it's pretty when used like an IFS... Here's the ugly first attempt: 
//    https://www.shadertoy.com/view/XdtSDX

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875
#define EPS .001

#define time ((saw(float(__LINE__))*.001+1.0)*iGlobalTime)
#define saw(x) (acos(cos(x))/PI)


vec2 cmul(vec2 v1, vec2 v2) {
	return vec2(v1.x * v2.x - v1.y * v2.y, v1.y * v2.x + v1.x * v2.y);
}

vec2 cdiv(vec2 v1, vec2 v2) {
	return vec2(v1.x * v2.x + v1.y * v2.y, v1.y * v2.x - v1.x * v2.y) / dot(v2, v2);
}

vec2 tree(vec2 uv)
{
	float t = sin(iGlobalTime) * 6.0;
	vec2 a = sin(vec2(time*.1, time*.2));
	vec2 b = sin(vec2(time*.3, time*.4));
	vec2 c = sin(vec2(time*.5, time*.6));
	vec2 d = sin(vec2(time*.7, time*.8));
	return cdiv(cmul(uv, a) + b, cmul(uv, c) + d);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy*2.0-1.0;
    uv = saw(tree(uv)*2.0*PI)*2.0-1.0; 
    uv = saw(tree(uv)*2.0*PI)*2.0-1.0; 
    uv = saw(tree(uv)*2.0*PI); 

    fragColor = vec4(uv, 0.0, 1.0);
}