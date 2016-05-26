// Shader downloaded from https://www.shadertoy.com/view/4sdXRl
// written by shadertoy user aetelani
//
// Name: evilskope
// Description: el kal
// Distributed under CC-BY-NC-SA license (c) 2016 by Anssi Eteläniemi, aetelani(a)live.com 
vec2 uv, z, z1;
#define PI 3.14159
//precision lowp float;
float t;
mat4 R3(vec3 ax, float angle);

// z_n1 = z_n0^2 + constant
vec2 cMul(vec2 a, vec2 b) {            
    //return vec2(sin(b.x), sin(b.y));
    return sin(vec2(a.x * b.x - a.y * b.y,
                    a.x * b.y + a.y * b.x
               ));
}

mat2 R(float a) { // z
    // xyz
    mat4 r3 = R3(vec3(.0, 0., 1.), a);
    // col-major.stpq
    return mat2(r3[0].st, r3[1].st);
//		return mat2(vec2(cos(a), sin(a)), vec2(-sin(a), cos(a)));
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

mat2 Ry(float a) { // y
    mat4 r3 = R3(vec3(0., 1., .0), a);
    return mat2(r3[0].st, r3[1].st);
}

mat2 Rx(float a) { // x
    mat4 r3 = R3(vec3(1., 0., .0), a);
    return mat2(r3[0].st, r3[1].st);
}

mat4 R3(vec3 ax, float angle) {
    vec3 axis = normalize(ax);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
/*
 [Mxx, Mxy, Mxz, Cx],
 [Myx, Myy, Myz, Cy],
 [Mzx, Mzy, Mzz, Cz],
 [Lx,  Ly,  Lz,   W]
*/
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    t = iGlobalTime;
	uv = fragCoord.xy / iResolution.xy;    
    const int depth = 10;
    vec2 a = vec2(uv.x - .5, uv.y - .5);
    vec2 c = vec2(0.6);

    for(int i=0; i < depth; ++i) {
        z =  cMul(z, z) + c * a * R(float(depth)+ float(depth) + t);
        c += sin(t) * 0.6;
	}

    float dist = distance(a, z);
    vec4 col = vec4(0.);

    col.r = length(z);
    col.g = dot(z, z) * .4;
    if (col.g > 0.5) {
        col.b  = length(cross(z.xyx, a.xyx));
    } else if (length(a) > .7) {
        col.r = vec4(1.0).r;
	}
        

    fragColor = col;
}