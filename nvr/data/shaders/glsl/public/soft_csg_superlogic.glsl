// Shader downloaded from https://www.shadertoy.com/view/Msy3zw
// written by shadertoy user paniq
//
// Name: Soft CSG Superlogic
// Description: A design for a function that unifies hard and soft and/or/sub CSG operations
// a, b: input distances
// s.x,s.y: -1/1 signs to switch comparison polarity
// s.z,s.w: radius & scaling factor, as returned by soft_coeffs()
float csg_op (float a, float b, vec4 s) {
    b *= s.y;
    float d = abs(a - b);
    float q = max(s.z - d, 0.0);
    return 0.5*(a + b + s.x*(d + s.w*q*q));
}

vec2 soft_coeffs(float r) {
    return vec2(r, (r > 0.0)?(0.5/r):0.0);
}

vec4 csg_and (float r) {
    return vec4(1.0,1.0,soft_coeffs(r));
}

vec4 csg_sub (float r) {
    return vec4(1.0,-1.0,soft_coeffs(r));
}

vec4 csg_or (float r) {
    return vec4(-1.0,1.0,soft_coeffs(r));
}

vec4 getfactor (int i) {
	#define OP_COUNT 6.0
    if (i == 0) { // or
        return csg_or(0.0);
    } else if (i == 1) { // soft or 
        return csg_or(0.2);
    } else if (i == 2) { // soft sub 
        return csg_sub(0.2);
    } else if (i == 3) { // sub 
        return csg_sub(0.0);
    } else if (i == 4) { // soft and
        return csg_and(0.0);
    } else { // soft and
        return csg_and(0.2);
	}
}

//-------------------------------------------------------

float circle (vec2 p, float r) {
    return length(p) - r;
}

float square (vec2 p, float r) {
    p = abs(p) - r;
    return length(max(p,0.0)) + min(0.0,max(p.x,p.y));
}

vec2 circles (vec2 p) {
    float r = 0.6;
    return vec2(
        square(p - vec2(-r*0.7, 0.0), r), 
        circle(p - vec2(r*0.4, 0.0), r*0.7));
}

//-------------------------------------------------------

float outline (float d) {
    return 1.0 - smoothstep(0.0, 3.0 / iResolution.y, abs(d));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = uv * 2. - 1.;
    p.x *= iResolution.x / iResolution.y;
    
    vec2 m = (iMouse.xy / iResolution.xy)*2.0-1.0;
    m.x *= iResolution.x / iResolution.y;

    float k = iGlobalTime*0.5;
    float u = smoothstep(0.0,1.0,smoothstep(0.0,1.0,fract(k)));
    int s1 = int(mod(k,OP_COUNT));
    int s2 = int(mod(k+1.0,OP_COUNT));
    vec4 op1 = getfactor(s1);
    vec4 op2 = getfactor(s2);
    vec4 args = mix(op1,op2,u);

    vec2 c = circles(p);
    float d = csg_op(c.x, c.y, args);

    vec2 c2 = circles(m);
    float d2 = abs(csg_op(c2.x, c2.y, args));
    
    float s = abs(mod(d, 0.1)/0.1 - 0.5);    
	fragColor = vec4(((iMouse.z > 0.5)?outline(circle(p-m,d2)):0.0)+s+vec3(outline(d) + 0.3 * step(d,0.0)),1.0);
}