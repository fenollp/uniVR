// Shader downloaded from https://www.shadertoy.com/view/ldcSW8
// written by shadertoy user FabriceNeyret2
//
// Name: inception zoom
// Description: Have you ever inspected what was it texture pixels ? :-)
//    
//    ( mouse move )
#define S 1.7  // speed of zoom

void mainImage( out vec4 O,  vec2 U )
{
    float t = iGlobalTime, 
          Z = iChannelResolution[0].x, // ./4. to cycle sooner: smaller pseudo-resolution
          T =  log(Z)/log(S);
  // t = mod(t,T); // cycling cause a slight normalization glitch at T (i.e. 11')
                   // since I didn't faded the normalization with zoom.
                   // But not cycling reach precision issues at 2'36 ( ~ 14T)
    t = pow(S,t);

    vec2 R = iResolution.xy;
    U = ( U/R-.5 ) / t;
    if (length(iMouse.xy)>0.) U -= (iMouse.xy/R -.5)/t;
    
    vec4 M = O = vec4(1);
    for (int i=0; i<15; i++) {
	    O *= texture2D(iChannel0,U+.5)/ M; M = texture2D(iChannel0,U+.5,10.); // normalization
        U *= Z;
    }
}