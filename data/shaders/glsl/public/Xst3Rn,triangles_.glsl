// Shader downloaded from https://www.shadertoy.com/view/Xst3Rn
// written by shadertoy user jackdavenport
//
// Name: Triangles!
// Description: A raymarched pair of triangles, forming a quad. Based on the distance functions by iq: http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
vec3 tri1A = vec3(1.0, 1., 0.0);
vec3 tri1B = vec3(-1.0, -1.0, 0.0);
vec3 tri1C = vec3(1.0, -1.0, 0.0);
vec3 tri2A = vec3(-1.,1.,0.);
vec3 tri2B = vec3(1.,1.,0.);
vec3 tri2C = vec3(-1.,-1.,0.);

float dot2( in vec3 v ) { return dot(v,v); }
float distTriangle(vec3 p, vec3 a, vec3 b, vec3 c) {
    
    vec3 ba = b - a; vec3 pa = p - a;
    vec3 cb = c - b; vec3 pb = p - b;
    vec3 ac = a - c; vec3 pc = p - c;
    vec3 nr = cross(ba,ac);
    
    return sqrt(
    (sign(dot(cross(ba,nr),pa)) +
     sign(dot(cross(cb,nr),pb)) +
     sign(dot(cross(ac,nr),pc)) < 2.) ?
     min( min(
     dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
     dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
     dot2(ac*clamp(dot(ac,pc)/dot2(ac),0.0,1.0)-pc) )
     :
     dot(nr,pa)*dot(nr,pa)/dot2(nr));
    
}

float distScene(vec3 p) {
 
    float s = sin(iGlobalTime);
    
    float tri1 = distTriangle(p,tri1A + s,tri1B + s,tri1C + s);
    float tri2 = distTriangle(p,tri2A,tri2B,tri2C);
    
    return min(tri1,tri2);
    
}

vec4 shade(vec3 dir) {
 
    vec3 p = vec3(0.,0.,-3.);
    int id = -1;
    
    for(int i = 0; i < 256; i++) {
        
        float dst = distScene(p);
        p += dir * dst;
        
        if(dst <= .001) {
         
            id = 0;
            break;
            
        }
        
    }
    
    if(id == 0) {
     
        vec3 rd = reflect(dir,vec3(0.,0.,-1.));
        return textureCube(iChannel0,rd) * .5;
        
    }
    
    return textureCube(iChannel0,dir);
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy - iResolution.xy / 2.) / iResolution.y;
    fragColor = shade(vec3(uv,1.));
}