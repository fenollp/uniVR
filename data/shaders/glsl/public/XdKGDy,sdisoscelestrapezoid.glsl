// Shader downloaded from https://www.shadertoy.com/view/XdKGDy
// written by shadertoy user paniq
//
// Name: sdIsoscelesTrapezoid
// Description: long name, sound math

float dot2( in vec2 v ) { 
    return dot(v,v);
}
// bottom width, top width, height
float sdIsoscelesTrapezoid (vec2 p, vec3 s) {
    p.x = abs(p.x);
    vec2 ba = vec2(s.x - s.y, -2.0*s.z);
    vec2 pa = vec2(p.x - s.y, p.y - s.z);
    
    vec2 d = pa - ba * clamp(dot(pa,ba) / dot(ba,ba),0.0,1.0);
    vec2 h0 = vec2(max(p.x - s.x,0.0),p.y + s.z);
    vec2 h1 = vec2(max(p.x - s.y,0.0),p.y - s.z);
    
    return sqrt(min(dot2(d),min(dot2(h0),dot2(h1))))
        * sign(max(dot(pa,vec2(-ba.y, ba.x)), abs(p.y) - s.z));
}

float map (vec2 p) {
    
    float w1 = mix(0.0,1.0,sin(iGlobalTime*0.1)*0.5+0.5);
    float w2 = mix(0.0,1.5,sin(-0.7 + iGlobalTime*0.13)*0.5+0.5);
    float h = mix(0.1,0.7,sin(0.4 + iGlobalTime*0.27)*0.5+0.5);
    
    return sdIsoscelesTrapezoid(p, vec3(w1,w2,h));
}

//-------------------------------------------------------

float circle (vec2 p, float r) {
    return length(p) - r;
}

float outline (float d) {
    return 1.0 - smoothstep(0.0, 3.0 / iResolution.y, abs(d));
}
float isolines (float d) {
    return abs(mod(d, 0.1)/0.1 - 0.5) + outline(d) + 0.3 * step(d,0.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = uv * 2. - 1.;
    p.x *= iResolution.x / iResolution.y;
    
    vec2 m = (iMouse.xy / iResolution.xy)*2.0-1.0;
    m.x *= iResolution.x / iResolution.y;

    float d = map(p);

    float d2 = abs(map(m));
    
	fragColor = vec4(((iMouse.z > 0.5)?outline(circle(p-m,d2)):0.0)+vec3(isolines(d)),1.0);
}