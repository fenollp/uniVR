// Shader downloaded from https://www.shadertoy.com/view/4dGGz1
// written by shadertoy user FabriceNeyret2
//
// Name: Fourier Gabor noise
// Description: Draw your spectrum profile in BufA.   Space to tune display mode (click left or right window)&lt;br/&gt;application of https://www.shadertoy.com/view/4s3GDs
// application of https://www.shadertoy.com/view/4s3GDs

// set you module and phase in Buf A

#define SIZE (iResolution.x/2.-30.) //Size must be changed in each tab.

//Display modes.     Tuned by pressing SPACE after clicking left or right window
#define MAGNITUDE 0.
#define PHASE     1.
#define COMPONENT 2.
#define REAL      3.
#define IMAG      4.

//Scaling
#define LOG 0
#define LINEAR 1

#define MAG_SCALE LINEAR

vec2 R = iResolution.xy;

vec4 rainbow(float x)  { return .5 + .5 * cos(6.2832*(x - vec4(0,1,2,0)/3.)); }
vec4 rainbow(vec2 C)   { return rainbow(atan(C.y,C.x)/3.1416 + .5); }

vec4 paintDFT(vec2 F, float mode) {
    // F /= SIZE;
    return 
         mode == MAGNITUDE 
     #if   MAG_SCALE == LOG
                           ?  vec4(log(length(F)))
     #elif MAG_SCALE == LINEAR
                           ?  vec4(length(F))
     #endif
       : mode == PHASE     ?  rainbow(F)        
       : mode == COMPONENT ?  .5+.5*vec4(F, 0,0)
       : mode == REAL      ?  .5+.5*vec4(F.x)
       : mode == IMAG      ?  .5+.5*vec4(F.y)
       : vec4(-1); // error
}

/*
float message(vec2 p) {  // the alert function to add to your shader : "click to see"
    int x = int(p.x+1.)-1, y=int(p.y)-10,  i;
    if (x<1||x>32||y<0||y>2) return -1.; 
    i = ( y==2? i=  757737252: y==1? i= 1869043565: y==0? 623593060: 0 )/ int(exp2(float(32-x)));
 	return i==2*(i/2) ? 1. : 0.;
}
*/

void mainImage( out vec4 O,  vec2 uv )
{
    //if (iResolution.y<200.) // alert for the icon: "click to see"
    //    {   float c=message(uv/8.); if(c>=0.){ O=vec4(c,0,0,0);return; } }
    
        
    vec2 pixel = ( uv - R/2.) / SIZE  + vec2(2,1)/2.,
         tile  = floor(pixel),
         stile = floor(mod(2.*pixel,2.));    
	     uv = fract(pixel) * SIZE / R;
    O-=O;

    vec2 DISPLAY_MODE = floor(texture2D(iChannel3, .5/R).zw); // persistant key flag.
    if (tile.y==-1. && abs(tile.x-.5)<1.) {   // buttons displaying current flags value
        for (float i=0.; i<5.; i++) 
            O += smoothstep(.005,.0,abs(length(uv*R/SIZE-vec2(.2+i/7.,.97))-.025));
        float v = tile.x==0. ? DISPLAY_MODE[0] : DISPLAY_MODE[1];
        O.b += smoothstep(.03,.02,length(uv*R/SIZE-vec2(.2+v/7.,.97)));
    }
      
    if(tile == vec2(0,0))  // Input spectrum (Left)
        O += paintDFT(texture2D(iChannel3, uv).xy, DISPLAY_MODE[0]);

    if(tile == vec2(1,0))  // Output DFT (Right)
        O += paintDFT(texture2D(iChannel2, uv).xy, DISPLAY_MODE[1]);
}