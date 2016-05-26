// Shader downloaded from https://www.shadertoy.com/view/Xs3XzN
// written by shadertoy user 834144373
//
// Name: Sound Image(Scret)
// Description: Sound Image by rewind.
//Scret(Sound Image) by 834144373 is licensed under a cc3.0 cc-by-nc-sa Creative Commons License.
void mainImage( out vec4 c, in vec2 u )
{
    vec2 uv = u/iResolution.xy;
    c = texture2D(iChannel0,uv);
}