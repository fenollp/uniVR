// Shader downloaded from https://www.shadertoy.com/view/MdtGRB
// written by shadertoy user xbe
//
// Name: Alien Swirl
// Description: Playing around with iterative function from sofiane benchaa shader: Illustrated Equations (https://www.shadertoy.com/view/MtBGDW).
/////////////////////////////////////////////////////////////////////////
// Alien Swirl - xbe
//
// Inspired by shader from sofiane benchaa
// https://www.shadertoy.com/view/MtBGDW
//
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define FIELD 10.0
#define ITERATIONMAX 16.
#define TONE1 vec3(0.299,0.787,0.114)
#define TONE2 vec3(0.587,0.299,0.114)


vec2 SwirlEQ(vec3 p, float t, float it){
	vec2 fx = p.xy;
    t *= 0.3;
	p = (abs(p*2.0));
	vec2 ab = vec2(2.0-p.x);
    float i = 0.;
    for(float i=0.; i < ITERATIONMAX; i++) {
		if (i >= it) break;
		ab  += (p.xy) + cos(length(p));
		p.y += sin(ab.x - p.z - 0.5*t) * 0.5;
		p.x += sin(ab.y + t) * 0.5;
		p   -= (p.x+p.y);
		p   += sin(fx.x) * cos(fx.y);
		ab  += vec2(p.y);
	}
	p   /= FIELD;
	fx.x = (p.x+p.x+p.y);
	return fx;
}

////////////////////////////////////////////////////////
vec3 computeColor(vec2 fx){
	vec3 color = vec3(TONE1);
	color -= (fx.x);
    if (color.y < 0.) {
        color *= -vec3(TONE2);
    } else {
		color.b += color.g*1.5;
    }
	return clamp(color,(0.0),(1.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	float time  = iGlobalTime;
	float ratio = iResolution.y / iResolution.x;
	fragCoord.y *= ratio;
	vec2 position = ( fragCoord.xy / iResolution.xy ) - vec2(0.5,0.5 * ratio);
	vec3 p = position.yxy * FIELD;
    vec2 a = SwirlEQ(p,time,8.);
    vec2 b = 0.9 * SwirlEQ(p,time,10.);
    vec2 c = 0.8 * SwirlEQ(p,time,12.);
    float m = sin(0.333 * time);
    vec2 d = mix(b, a, abs(m) - m);
    d = mix(d, c, clamp(m, 0., 1.));
	vec3 color = computeColor(d);
	fragColor = vec4( color, 1.0 );

}