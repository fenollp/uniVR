// Shader downloaded from https://www.shadertoy.com/view/4t2GDd
// written by shadertoy user dgreensp
//
// Name: Splattered Sphere
// Description: An application of https://www.shadertoy.com/view/4ljGDd
const float MAGIC_BOX_MAGIC = 0.56;

float magicBox(vec3 p) {
    // The fractal lives in a 1x1x1 box with mirrors on all sides.
    // Take p anywhere in space and calculate the corresponding position
    // inside the box, 0<(x,y,z)<1
    p = 1.0 - abs(1.0 - mod(p, 2.0));
    
    float tot = 0.0;
    float L = length(p), L2;
    
    // This is the fractal.  More iterations gives a more detailed
    // fractal at the expense of more computation.
    p = abs(p)/(L*L) - MAGIC_BOX_MAGIC; L2 = length(p); tot += abs(L2-L); L = L2;
    p = abs(p)/(L*L) - MAGIC_BOX_MAGIC; L2 = length(p); tot += abs(L2-L); L = L2;
    p = abs(p)/(L*L) - MAGIC_BOX_MAGIC; L2 = length(p); tot += abs(L2-L); L = L2;
    p = abs(p)/(L*L) - MAGIC_BOX_MAGIC; L2 = length(p); tot += abs(L2-L); L = L2;
    p = abs(p)/(L*L) - MAGIC_BOX_MAGIC; L2 = length(p); tot += abs(L2-L); L = L2;
    p = abs(p)/(L*L) - MAGIC_BOX_MAGIC; L2 = length(p); tot += abs(L2-L); L = L2;
    p = abs(p)/(L*L) - MAGIC_BOX_MAGIC; L2 = length(p); tot += abs(L2-L); L = L2;
    p = abs(p)/(L*L) - MAGIC_BOX_MAGIC; L2 = length(p); tot += abs(L2-L); L = L2;
    p = abs(p)/(L*L) - MAGIC_BOX_MAGIC; L2 = length(p); tot += abs(L2-L); L = L2;
    p = abs(p)/(L*L) - MAGIC_BOX_MAGIC; L2 = length(p); tot += abs(L2-L); L = L2;
    p = abs(p)/(L*L) - MAGIC_BOX_MAGIC; L2 = length(p); tot += abs(L2-L); L = L2;

    
    return tot;
}

// A random 3x3 unitary matrix, used to avoid artifacts from slicing the
// volume along the same axes as the fractal's bounding box.
const mat3 M = mat3(0.28862355854826727, 0.6997227302779844, 0.6535170557707412,
                    0.06997493955670424, 0.6653237235314099, -0.7432683571499161,
                    -0.9548821651308448, 0.26025457467376617, 0.14306504491456504);



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2. * (fragCoord.xy - 0.5*iResolution.xy) / iResolution.yy;
        
    vec3 sph = vec3(uv.x, uv.y, sqrt(1.-dot(uv,uv)));
    float ang = iGlobalTime*1.0;
    mat3 rot = mat3(-sin(ang),0.0,cos(ang),0.,1.,0.,cos(ang),0.,sin(ang));
    mat3 M2 = M*rot;
    float q = magicBox(vec3(0.6,0.3,0.4)+0.2*M2*sph);
    
    float a = 1. - smoothstep(14., 16., q);
    
	fragColor = vec4(vec3(a),1.0) * (vec4(0.3,1.0,0.3,1.0) * (0.3+0.7*dot(sph,normalize(vec3(-1.,1.,1.)))));
    
    if (dot(uv,uv) > 1.) fragColor=vec4(vec3(0.0),1.0);
}