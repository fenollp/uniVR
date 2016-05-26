// Shader downloaded from https://www.shadertoy.com/view/Xl2SRG
// written by shadertoy user tsone
//
// Name: Sierpinski Carpet 1
// Description: Sierpinski carpet configurations.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy;
    p.x -= 0.5 * (iResolution.x-iResolution.y);
    p *= 3.0 / iResolution.y;
    
    float t = 0.5 * iGlobalTime + 4.0;
    float ti = floor(t);
    vec2 ct = mod(vec2(ti, ti + 1.0), 9.0);
    
    vec2 c = vec2(p.x >= 0.0 && p.x < 3.0);
    for (int i = 0; i < 5; ++i) {
    	vec2 m = floor(p);
        float j = m.y*3.0 + m.x;
   		c *= 0.2 + 0.8 * vec2(j != ct[0], j != ct[1]);
        p = 3.0 * (p-m);
    }

    float x = smoothstep(0.0, 1.0, t - ti);
	fragColor = vec4(vec3(0.1 + 0.9*mix(c[0], c[1], x)), 1.0);
}