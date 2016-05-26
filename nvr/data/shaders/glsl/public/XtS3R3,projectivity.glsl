// Shader downloaded from https://www.shadertoy.com/view/XtS3R3
// written by shadertoy user Doublefresh
//
// Name: projectivity
// Description: shows how to transform a parabola to a circle as the image of a projective transformation.
struct conic_t {
    float a, b, c, d, e, f;
};
    
conic_t newconic(in float a, in float b, in float c, in float d, in float e, in float f) {
    conic_t cs;
    cs.a = a;
    cs.b = b;
    cs.c = c;
    cs.d = d;
    cs.e = e;
    cs.f = f;
    return cs;
}

// Projective coordinate transformation under which the  
// image of a parabola y^2 - xis transformed to the unit circle
vec3 parabola2circle(in vec3 p) {
    vec3 q;
    
    q.y = p.z - p.y;
    q.z = p.z + p.y;
    q.x = p.x;
    
    return q; 
}
    
// ax^2 + by^2 + cxy + dx + ey + f 
float conic(in vec3 p, in conic_t z) {
    float Z = p.z;
    p /=  p.z;
    float v = z.a*p.x*p.x + z.b*p.y*p.y + z.c*p.y*p.x + z.d*p.x + z.e*p.y + p.z * z.f;
    
    // technique from iq: divide by gradient:
    vec3 grad;
    grad.x = 2.0*z.a*p.x + p.y*z.c + z.d;
    grad.y = 2.0*z.b*p.y + p.x*z.c + z.e;
    grad.z = p.z;
    v /= dot(grad, grad) / max(Z, 0.35);
    
    return smoothstep(0.01, 0.00, abs(v));
}

float gridlines(vec3 p) {
    float Z = p.z;
    float th = 0.3;
    p /= p.z;
    
    vec2 l = mod( p.xy, th );
    
    l = vec2(l.x > 0.5*th ? th - l.x : l.x,
             l.y > 0.5*th ? th - l.y : l.y);

    float z = 1.0-smoothstep(0.0, 0.08*th, l.x);
    float w = 1.0-smoothstep(0.0, 0.08*th, l.y);
    
    return pow(min(max(z,w), clamp(Z, 0.0, 1.0)), 2.0);
}

conic_t parabola() {
    return newconic(1.0, 0.0, 0.0, 0.0, -1.0, 0.0);
}

conic_t line() {
    return newconic(0.0, 0.0, 0.0, 1.0, -1.0, 0.0);
}

conic_t circle() {
    return newconic(1.0, 1.0, 0.0, 0.0, 0.0, -1.0);
}

conic_t hyperbola() {
    return newconic(1.0, -1.0, 0.0, 0.0, 0.0, -1.0);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uva = fragCoord.xy / iResolution.xy;
    vec3 col, col_h;
    
    uva = 2.0 * uva - 1.0;
    uva.x *= iResolution.x / iResolution.y;
    vec3 uv = vec3(uva.xy*2.5, 1.0);
    
        
    col = vec3(0.3+ 0.1*uv.y, 0.3 + 0.1*uv.y, 0.3 + 0.1*uv.y);
    
    uv = mix(uv, parabola2circle(uv), 0.5 + 0.5*sin(iGlobalTime));
 
    col = mix(col, vec3(0.7), gridlines(uv));
    col = mix(col, vec3(0.8, 0.4, 1.0), conic(uv, parabola()));
    col = mix(col, vec3(0.4, 0.8, 1.0), conic(uv, line()));
    col = mix(col, vec3(0.0, 0.8, 0.0), conic(uv, circle()));
    //col = mix(col, vec3(1.0, 0.0, 0.0), conic(uv, hyperbola()));
    
     
    fragColor = vec4(col, 1.0);
}