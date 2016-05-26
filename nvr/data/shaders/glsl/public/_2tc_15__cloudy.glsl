// Shader downloaded from https://www.shadertoy.com/view/4tf3WN
// written by shadertoy user TekF
//
// Name: [2TC 15] Cloudy
// Description: Trying to do volumetric clouds in 280 chars
//    For nimitz's 2 tweet contest: https://www.shadertoy.com/view/4tl3W8
// Ben Quantock 2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// These will only save chars if they're used a few times
//#define V vec3
//#define N normalize
//#define O fragColor.rgb
//#define T(a) texture2D(iChannel0,a*.01)

void mainImage( out vec4 f, in vec2 w )
{
    vec3 r = normalize(vec3(w-200.,300))*.2,
         p = vec3(0,0,5)*iGlobalTime;

// better camera
//    vec3 r = normalize(iResolution.xyx-vec3(2.*fragCoord.xy,0))*.2,
//         p = vec3(0,0,iGlobalTime)*5.+sin(iGlobalTime)*3.;

    f*=.0; // my PC doesn't need this, but some might...
    
    float q=30.;
	for(int i=0;i<99;i++)
    {
        vec4 t=texture2D(iChannel0,(p.xy+vec2(37,17)*floor(p.z)+.5)/256.);
        f+=mix(t.y,t.x,fract(p.z))/q;
        q*=1.03;
        p+=r;
    }
}
