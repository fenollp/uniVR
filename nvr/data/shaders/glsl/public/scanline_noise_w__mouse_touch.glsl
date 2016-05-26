// Shader downloaded from https://www.shadertoy.com/view/ltjSDm
// written by shadertoy user Retrotation
//
// Name: Scanline Noise w/ Mouse Touch
// Description: http://www.mattolick.com
//    
//    Clicking the screen will subtly highlight and follow the mouse. 
// defining Blending functions
#define Blend(base, blend, funcf) 		vec4(funcf(base.r, blend.r), funcf(base.g, blend.g), funcf(base.b, blend.b), funcf(base.a, blend.a))
#define BlendOverlayf(base, blend) 	(base < 0.5 ? (1.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)))
#define BlendOverlay(base, blend) 		Blend(base, blend, BlendOverlayf)
#define BlendAddf(base, blend) 		min(base + blend, 1.0)
#define BlendAdd(base, blend) 		min(base + blend, vec4(1.0))


// animated noise function
float snoise(in vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}


// distance calculation between two points
float dist(vec2 p0, vec2 pf){
    return sqrt((pf.x-p0.x)*(pf.x-p0.x)+(pf.y-p0.y)*(pf.y-p0.y));
}

////////////////////////////////////////////////////////////////////////////////////////////////////


// defining extra variables

const float speed     = 10.00; 

vec2  offset = vec2(0.0, iGlobalTime) * speed;


////////////////////////////////////////////////////////////////////////////////////////////////////


// FRAGMENT SHADER

void mainImage( out vec4 color, in vec2 fragCoord )
{
// add some movement
    vec2 pixelCoord = fragCoord + offset;

// basic uv sampling
    vec2 uv = floor(pixelCoord) * 2.0;
 
// solid color for the background  
    vec4 backcolor = vec4(0.22, 0.22, 0.22, 1.0);     
       
// generate scanlines from noise image, by stretching UV coordinates along Y-axis
  	vec4 scanlines = texture2D(iChannel0, uv  / iResolution.xy * vec2(0.0,1.0));
  
// use an 'Overlay' function similar to Photoshop's, to blend the scanlines and backcolor together  
    vec4 firstpass = BlendOverlay(backcolor, scanlines);

/////////////////////////////    
   

// generate animated noise    
    float n = snoise(vec2(pixelCoord.x*cos(iGlobalTime),pixelCoord.y*tan(iGlobalTime))); 
 
// blend animated noise with the firstpass, using 'Overlay' function defined at the beginning of shader-code
    vec4 secondpass = BlendOverlay(firstpass, vec4(n, n, n, 1.0));
    
/////////////////////////////           
  
    
// calculate the distance between: the current pixel location, and the mouse position
    float d = dist(fragCoord.xy,iMouse.xy);
        
// change the size of the gradient-distance over time, multiplied by 
    d = d*(sin(iGlobalTime)+7.0)*0.003;
    
// control the falloff of the gradient with a power/exponent, and multiply 'd' by the animated noise
    d = pow(d*n,0.5);
  
// clamp the values of 'd', so that gradientgen cannot go below a 0.05 value
    d = min(d,1.0);
  
// list the max,min gradient values, and linearly interpolate between the values using 'd' as a scale
    vec4 gradientgen = mix(vec4(0.1, 0.1, 0.1, 1.0), vec4(0.05, 0.05, 0.05, 1.0), d);

// blend the second pass and the mouse-controlled gradient together
    vec4 thirdpass = BlendAdd(secondpass, gradientgen);
  
// final output     
    color = thirdpass;

}

////////////////////////////////////////////////////////////////////////////////////////////////////

