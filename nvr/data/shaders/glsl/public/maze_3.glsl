// Shader downloaded from https://www.shadertoy.com/view/ldc3Dj
// written by shadertoy user FabriceNeyret2
//
// Name: maze 3
// Description: ARROWS to go , SPACE to stop
// inspired from   https://www.shadertoy.com/view/4sSXWR

void mainImage( out vec4 O, vec2 U ){

    vec2 R = iResolution.xy;
    O = texture2D(iChannel0,U/R);  // x = path, y = maze
    
    O = mix( vec4(1.-O.y), vec4(1,0,0,0), O.x)
        -.5*smoothstep(.1,.08,4.*length(U/R.y - vec2(.8,.5)))*sin(20.*iDate.w); // cursor   
}
