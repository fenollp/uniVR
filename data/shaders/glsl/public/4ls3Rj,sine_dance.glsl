// Shader downloaded from https://www.shadertoy.com/view/4ls3Rj
// written by shadertoy user hamoid
//
// Name: Sine Dance
// Description: Learning...
/*
	Attempt to port http://hamoid.tumblr.com/post/103908919889/sine-dance
	to glsl. One of my first shader experiments.
*/
#define PI 3.1415926535897932384626433832795

float psin(float a, float e) {
  float b = (sin(a) + 1.0) / 2.0;
  return pow(b, e) * 2.0 - 1.0;
}
float thing(float arms, vec2 p, float rot, float sz, float k1, float k2, float k3) {
    float fa = iGlobalTime * 4.0;
    float a = atan(p.y, p.x);
    float d = sz * sin(a * arms) * 7.0;
    d = d + 0.02 * sin(5.4 + d * 16.0 + a * arms);
    d = d + 0.045 * psin(fa + k1 * a + k2 * psin(a, 5.0) + k3, 5.0);
    return smoothstep(d, d+0.30, length(p));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 p = fragCoord.xy / iResolution.xy;
    
    vec3 c = vec3(0.1059, 0.0824, 0.1294);
    
    if(thing(5.0, p - vec2(0.52, 0.26), -0.08, 0.01, 0.0, 1.0, 4.1) < 0.5) {
        c = vec3(0.8314, 0.1176, 0.2706);
    }
    if(thing(5.0, p - vec2(0.70, 0.70), -0.10, 0.011, 1.0, 0.0, 0.1) < 0.5) {
        c = vec3(0.7098, 0.6745, 0.0039);
    }
    if(thing(5.0, p - vec2(0.26, 0.67),  0.20, 0.009, 1.0, 0.0, PI/2.0) < 0.5) {
        c = vec3(0.9255, 0.7294, 0.0353);
    }
    
	fragColor = vec4(c, 1.0);
}