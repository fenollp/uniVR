// Shader downloaded from https://www.shadertoy.com/view/Md3XWn
// written by shadertoy user FabriceNeyret2
//
// Name: infinite street
// Description: contrast preserving blend using https://www.shadertoy.com/view/lsKGz3
#define SCALE 2.
#define SWIRL 1

void mainImage( out vec4 O,  vec2 U )
{
    O -= O;
    float s=0., s2=0., t=iGlobalTime; 
	U = U/iResolution.xy -.5;
    U.x += .03*sin(3.14*t);
    float sc = pow(SCALE,-mod(t,2.)-.8);
    U *= sc;
    
    for (int i=0; i<10; i++) {
        vec2 V = abs(U+U); 
        if (max(V.x,V.y)>1.) break;
        V = smoothstep(1.,.5,V);
        float m = V.x*V.y;
	    O = mix(O,texture2D(iChannel0,U+.5),m);
      //O = mix(O,texture2D(iChannel0,U+.5,(sc *= 2.)*.15),m);  // Andre's blurred version
      //O = mix(O,texture2D(iChannel0,U+.5,sqrt((sc *= 2.)*.3)),m); //   ...
        s = mix(s,1.,m); s2 = s2*(1.-m)*(1.-m) + m*m;
        U*=SCALE; 
#if SWIRL
        U.x=-U.x;
#endif
    }
    
    vec4 mean = texture2D(iChannel0,U,10.);
    O = mean + (O-s*mean)/sqrt(s2); 
}