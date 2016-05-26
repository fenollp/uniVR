// Shader downloaded from https://www.shadertoy.com/view/MtfSWH
// written by shadertoy user FabriceNeyret2
//
// Name: snaky texture - 140 chars
// Description: .
void mainImage(out vec4 f, vec2 u) {
    f = vec4(0.0);
    for (float i=0.; i<=1.; i+=.07)
        f += .1*texture2D(iChannel0,u/iResolution.y+cos(i+iDate.w+vec2(0,1.6)) );  

    f*=f;
} 
