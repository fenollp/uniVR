// Shader downloaded from https://www.shadertoy.com/view/MtXSRj
// written by shadertoy user Cubed
//
// Name: City road
// Description: New to raymarching, playing around with stuff. 
//    Credit to I&ntilde;igo Qu&iacute;lez for the distance field functions, which I've mutilated horribly. :)
vec3 opRep(vec3 p, vec3 c) {
    return mod(p,c)-0.5*c;
}

float opU( float d1, float d2 ) {
    return min(d1,d2);
}

float sdBox( vec3 p, vec3 b ) {
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

mat2 rotation(float theta) {
    return mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
}

float map(vec3 p) {
    float res = sdBox(opRep(p, vec3(11.0, 0.0, 11.0)), vec3(3.0, 8.0, 3.0));
    res = opU(res, sdBox(opRep(p + vec3(0.0, -4.0, 5.0), vec3(0.0, 0.0, 10.0)), vec3(1.0, 0.2, 5.0)));
    res = opU(res, sdBox(opRep(p + vec3(0.0, -4.3, 0.0), vec3(0.0, 0.0, 4.0)), vec3(0.1, 0.05, 0.8)));
    res = opU(res, p.y);
    
	return res;
}

float trace(vec3 o, vec3 r) {
    float t = 0.0;
    for (int i = 0; i < 50; i++) {
    	vec3 p = o + r * t;
        float d = map(p);
        t += d;
    }
    return t;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    vec3 r = normalize(vec3(uv, 1.0));
    r.yz *= rotation(0.5);
    r.xy *= rotation(sin(iGlobalTime + 10.0) * 0.5);
    
    float altitude = cos(iGlobalTime * 0.5) * 4.5 + 5.5;
    vec3 o = vec3(sin(iGlobalTime * 0.5) * 1.7, altitude, iGlobalTime * 32.0);
    float t = trace(o, r);
    float fog = 1.0 / (1.0 + t * t * 0.01);  
    vec3 fc = vec3(fog);
	fragColor = vec4(fc ,1.0);
}