// Shader downloaded from https://www.shadertoy.com/view/4tjSW3
// written by shadertoy user FabriceNeyret2
//
// Name: look who's there !
// Description: A very compact algorithm to draw 3D characters. 
//    :-D
//    
vec4 tex(vec3 V, float d, out float s) {
    s = step(abs(V.x+=d),.61);
    V.z *= 6.*sign(d);
    return 3.* max(textureCube(iChannel0,V)*s-.2, 0.);
}

void mainImage( out vec4 o, vec2 U )
{
    vec3 V = vec3(2.*U/iResolution.y-1.,1) - vec3(.8,-1.8,0);
    float u = .85,  s1, s2;
    o  = tex(V,-u, s1)+ tex(V, u, s2)  + (1.-s1-s2)*.82;
    
 	V -= o.x * .03*sin(2.*iGlobalTime+vec3(0,1.6,1));      // comment for still image
    o  = tex(V,-u, s1)+ tex(V, u, s2)  + (1.-s1-s2)*.82;   //
    
}