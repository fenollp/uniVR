// Shader downloaded from https://www.shadertoy.com/view/XsdSR2
// written by shadertoy user GregRostami
//
// Name: Normalize and Center
// Description: Since most shaders start with normalizing and centering the coordinate system, here's a reference shader for code golfing that shows the various ways of doing that. Please add to this list other ways of centering and normalizing. Thank you.
// Since most shaders start with normalizing and centering the coordinate system, 
// here's a reference shader for code golfing (size optimization)
// that shows the various ways of normalizing and centering the coordinate system.
// Feel free to copy/paste this code into the first few lines of your shaders.

void mainImage(out vec4 o,vec2 u)
{
float t = fract( .1*iDate.w );
    
    if (t < 1./6.){
    // 16 chars - Square pixels, coordinates centered at lower left of screen
    u /= iResolution.y ;
    }
    
    else if (t < 2./6.){
    // 17 chars - Stretched pixels, coordinates centered at lower left of screen
    u /= iResolution.xy ;
    }

    else if (t < 3./6.){
    // 20 chars - Square pixels, coordinates centered on screen for Y axis only
        u = u / iResolution.y - .5 ;
    }
    
    else if (t < 4./6.){
    // 21 chars - Stretched pixels, coordinates centered on screen for both X and Y axis    
        u = u / iResolution.xy - .5 ;
    }
    
    else if (t < 5./6.){
    // 29 chars - Square pixels, coordinates centered (assumes 16:9 screen ratio)
        u = u / iResolution.y - .5 ; u.x -= .4 ;
    }
    
    else
    // 33 chars - Square pixels, coordinates centered on screen for both X and Y axis
  	 	u = (u+u - (o.xy=iResolution.xy) ) / o.y ;
   
    
    // Draw a circle with a radius of 0.5 (Diameter of 1.0)
	o = vec4 (length(u) < .5); 
}