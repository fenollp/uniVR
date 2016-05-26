// Shader downloaded from https://www.shadertoy.com/view/XdXSWN
// written by shadertoy user paniq
//
// Name: Pseudo-Polar Mapping
// Description: Demonstrating how a pseudo-polar mapping can be derived without atan or other trigonometric functions. Approximation on the left, atan(y,x) on the right.
// pseudopolar mapping
// developed by Leonard Ritter

// public domain

//#define ALTMETHOD

#ifndef ALTMETHOD

float pack_normal(vec2 n) {
    vec2 s = sign(n);
    return (n.y*s.x - s.y*(n.x + s.x - 2.0)) * 0.25;
}

vec2 unpack_normal(float x) {
    float a = x * 2.0;
    vec2 s;
    s.x = sign(a);
    s.y = sign(1.0 - a*s.x);
    vec2 q;
    q.y = fract(a) - 0.5;
    q.x = sqrt(0.5 - q.y*q.y);
    return q*mat2(s.y,-s.x,s.xy);
}

#else

// using a better approximation for cos(x) with normalized x
// cos(x) = 20 / (x*x + 4) - 4
// based on
// https://en.wikipedia.org/wiki/Bhaskara_I%27s_sine_approximation_formula

float pack_normal(vec2 n) {
    vec2 s = sign(n);
    return s.y*(s.x * (sqrt(5.0/(n.x*s.x + 4.0) - 1.0) - 0.5) + 0.5);
}

vec2 unpack_normal(float x) {
    float si = fract(x + 0.5)*2.0 - 1.0;
    float cx = 20.0 / (si*si + 4.0) - 4.0;
    float cy = sqrt(1.0 - cx*cx);
    return vec2(cx,cy) * sign(0.5-fract(vec2(0.25,0.0) + x*0.5));
}

#endif

// returns factors of PI (-1..1) and radius
vec2 pseudopolar(vec2 p) {
	float r = length(p);
    return vec2(pack_normal(p / r), r);
}

vec2 invpseudopolar(vec2 pl) {
    return pl.y*unpack_normal(pl.x);
}

vec3 hue2rgb(float hue) {
    return clamp( 
        abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 
        0.0, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (fragCoord.xy / iResolution.xy)*2.0-1.0;	
	p.x *= iResolution.x/iResolution.y;
	
    vec2 pl = pseudopolar(p);
    
    // compute equivalent normalized (accurate) angle for comparison
    float ra = atan(p.y, p.x) / 3.1415926535898;
    
    float va = (p.x < 0.0)?pl.x:ra;
    
    // logarithmic scaling of radius for zoom effect
    float rs = log(pl.y);
    vec2 uv = vec2(
       abs(mod(va * 3.0 + rs * 1.0,2.0) - 1.0), 
		abs(mod(rs - iGlobalTime * 0.5, 2.0) - 1.0));
    
    vec3 color = texture2D(iChannel0, uv).rgb * min(abs(p.x)*64.0, 1.0);
    // uncomment to see error margin
    //color = vec3(abs(pl.x - ra) * 1000.0, 0.0, 0.0);
    // uncomment for hue spiral
    //color = hue2rgb(pl.x + pl.y*2.0);
    //vec2 unq = invpseudopolar(pl);
    //color = vec3(abs(p - unq)*10000.0, 0.0);
    //color = vec3(unq*0.5+0.5, 0.0);
    //color = hue2rgb(pl.x * 4.0) * (pl.x * 0.5 + 0.5);
    
	fragColor = vec4(color, 1.0);
}
