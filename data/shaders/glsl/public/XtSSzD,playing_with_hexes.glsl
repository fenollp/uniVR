// Shader downloaded from https://www.shadertoy.com/view/XtSSzD
// written by shadertoy user TarAlacrin
//
// Name: Playing With Hexes
// Description: Just a test making a cool pattern, trying to learn my way around the system.
//    (Use the mouse to deform and push stuff around. Ive found it to be surprisingly entertaining)
//    
#define PI 3.1415926
float round(float a) { return floor(a+0.5); }
float saturate(float a){return clamp(a,0.0,1.0);}

float aIsGreater(float A, float B)
{
   float diff = A-B;
   return 0.5+0.5*abs(diff)/(diff);
}

float sech(float a)
{
    a= abs(a);
    return saturate( 2.0/(exp(a) + 1.0/exp(a)) );
}
float tri(float a)
{    
    return abs(1.0-mod(2.0*a+1.0,2.0));
}

float stp(float a)
{
    return mod(a,2.0) - fract(a);
}

float dispRange = 0.7;
float dispStrength = 0.02;
float dispPow = 1.5;
float numHexWide = 10.0;


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 diff = iMouse.xy / iResolution.xy - uv;
    float dist = length(diff);
    float disp = pow(sech(dist/dispRange), dispPow)*dispStrength;
    uv += normalize(diff)*disp;
    
    vec2 tuv = uv*numHexWide;
    tuv.x += 0.5*stp(uv.y*numHexWide*.5);
    
    vec2 tempuv = floor(tuv)/numHexWide;
    tempuv.y = floor(tuv.y*0.5)/numHexWide;
    
    
    float trimod = aIsGreater(fract(tuv.y), tri(tuv.x));
    vec2 triuv = vec2(tuv.x - (0.5 - stp(tuv.y*0.5+0.5 )) , tuv.y*0.5 + 0.5);
    triuv = floor(triuv)/numHexWide;
    
   	tempuv = mix(tempuv, triuv , trimod*mod(floor(tuv.y), 2.0));
   	
    //UNCOMMENT THIS TO SEE THE ISSUE WITH ASIN(SIN()) :
    //tempuv = asin(sin(uv*2.0*PI));
    
    //Or this: 
    //tempuv = asin(sin(uv*2.0*PI)) + 1000.0;
    
   	fragColor = vec4(tempuv,0.1+0.2*sin(iGlobalTime*0.5),1.0);
}