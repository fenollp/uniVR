// Shader downloaded from https://www.shadertoy.com/view/Msy3WG
// written by shadertoy user Dave_Hoskins
//
// Name: Local slope Erosion
// Description: Height map erosion using local slope values, not as good as moving points but much faster. It has a more corrosive effect. Click to move to new area. It can be a lot faster, but I liked the slow transition.
// Local slope Erosion
// by David Hoskins.
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// #define LIT

//--------------------------------------------------------------------------
float terrain(vec2 p)
{

    vec4 r = texture2D(iChannel0, p / iResolution.xy);
    return r.x*200.-r.w*200.;
}
vec3 getNormal( in vec2 pos)
{
    vec2  eps = vec2( 1., 0 );
    return normalize( vec3( terrain(pos-eps.xy) - terrain(pos+eps.xy),
                           2.*eps.x,
                 		   terrain(pos-eps.yx) - terrain(pos+eps.yx) ));
}
//--------------------------------------------------------------------------
// Tiled noise to make it wrap around for flying...


void mainImage( out vec4 colour, in vec2 coord )
{
    vec2 uv = (coord.xy+.5) / iResolution.xy;
    vec3 ligDir = normalize(vec3(-2., 1., 3.2));
                           
    colour = texture2D(iChannel0, uv);
     colour.xyz = vec3(colour.x-colour.w);
#ifdef LIT
     vec3 nor = getNormal(coord);
     colour = vec4(1.0) * max(dot(nor, ligDir), 0.0);
#endif
 }