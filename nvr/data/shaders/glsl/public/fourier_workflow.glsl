// Shader downloaded from https://www.shadertoy.com/view/4s3GDs
// written by shadertoy user FabriceNeyret2
//
// Name: Fourier workflow
// Description: workflow for all applications working in Fourier domain.  SPACE toggles Fourier depiction.
//    buf B and D do the space transforms, buf C operates in Fourier.
//                                         Adapted from  Flyguy's https://www.shadertoy.com/view/MscGWS#
// adapted from  Flyguy's https://www.shadertoy.com/view/MscGWS#
// see also https://www.shadertoy.com/view/4dGGz1 to play with spectrum.

// set you module and phase in Buf A

#define SIZE 256. //Size must be changed in each tab.

//Display modes
#define MAGNITUDE 0.
#define PHASE 1.
#define COMPONENT 2.

float DISPLAY_MODE = MAGNITUDE;

//Scaling
#define LOG 0
#define LINEAR 1

#define MAG_SCALE LOG

vec2 R = iResolution.xy;
vec4 rainbow(float x)  { return .5 + .5 * cos(6.2832*(x - vec4(0,1,2,0)/3.)); }
vec4 rainbow(vec2 C)   { return rainbow(atan(C.y,C.x)/3.1416 + .5); }

vec4 paintDFT(vec2 F) {
  if (DISPLAY_MODE == MAGNITUDE)
     #if MAG_SCALE == LOG
        return vec4( log(length(F)) / log(SIZE*SIZE) );
     #elif MAG_SCALE == LINEAR
        return vec4( length(F) / SIZE );
     #endif

    else if ( DISPLAY_MODE == PHASE )     return rainbow(F);        
    else /* if ( DISPLAY_MODE == COMPONENT ) */ return vec4(.5 + .5*F/SIZE, 0,0);        
}

float message(vec2 p) {  // the alert function to add to your shader
    int x = int(p.x+1.)-1, y=int(p.y)-10,  i;
    if (x<1||x>32||y<0||y>2) return -1.; 
    i = ( y==2? i=  757737252: y==1? i= 1869043565: y==0? 623593060: 0 )/ int(exp2(float(32-x)));
 	return i==2*(i/2) ? 1. : 0.;
}


void mainImage( out vec4 O,  vec2 uv )
{
    if (iResolution.y<200.) // alert for the icon
        {   float c=message(uv/8.); if(c>=0.){ O=vec4(c,0,0,0);return; } }
        
    vec2 pixel = ( uv - iResolution.xy/2.) / SIZE  + vec2(2,1)/2.,
         tile  = floor(pixel),
         stile = floor(mod(2.*pixel,2.));
         uv = fract(pixel) * SIZE / R ;

    O-=O;
    
    DISPLAY_MODE = floor(texture2D(iChannel3, .5/R).w); // persistant key flag.
    if (tile.y==-1. && abs(tile.x-.5)<1.) {   // buttons displaying current flags value
        for (float i=0.; i<3.; i++) 
            O += smoothstep(.005,.0,abs(length(uv*R/SIZE-vec2(.2+i/7.,.97))-.025));
        float v = DISPLAY_MODE;
        O.b += smoothstep(.03,.02,length(uv*R/SIZE-vec2(.2+v/7.,.97)));
    }
    
    if(tile == vec2(0,0))  //Input + DFT (Left)
        if (stile == vec2(0) )
             O += paintDFT(texture2D(iChannel1, 2.*uv).xy);
        else O += length(texture2D(iChannel0, uv).rgb);

    if(tile == vec2(1,0))  // Output +DFT (Right)
        if (stile == vec2(0) )
             O += paintDFT(texture2D(iChannel3, 2.*uv).xy);
        else 
            O += .5+.5*texture2D(iChannel2, uv).x;
          //O += length(texture2D(iChannel2, uv).xy);

}