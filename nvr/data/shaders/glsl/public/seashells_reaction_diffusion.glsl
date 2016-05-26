// Shader downloaded from https://www.shadertoy.com/view/MdGGRD
// written by shadertoy user FabriceNeyret2
//
// Name: Seashells reaction-diffusion
// Description: trying to reproduce Fig.11-&gt;15 of Sig'92 paper http://algorithmicbotany.org/papers/shells.sig92.pdf
//    NB: a lot of details were missing in the paper   (init values, dx,dt, ranges,  values-to-display... )
void mainImage( out vec4 O, vec2 U ) { O = texture2D(iChannel0,U/iResolution.xy).r*vec4(1,.3,.1,0); }