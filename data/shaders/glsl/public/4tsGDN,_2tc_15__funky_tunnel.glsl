// Shader downloaded from https://www.shadertoy.com/view/4tsGDN
// written by shadertoy user elias
//
// Name: [2TC 15] Funky Tunnel
// Description: .
void mainImage( out vec4 f, in vec2 w )
{
    vec2 z = 8.*(2.*w.xy-iResolution.xy)/iResolution.xx;
    float t = iDate.w, d = 1./dot(z,z);
   
    f =
        // color
        vec4(d*3.,.5,0,0)*
        // stripes
        sin(atan(z.y,z.x)*30.+d*99.+4.*t)*
        // rings
        sin(length(z*d)*20.+2.*t)*
        // depth
        max(dot(z,z)*.4-.4,0.);
}