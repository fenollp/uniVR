// Shader downloaded from https://www.shadertoy.com/view/llX3zs
// written by shadertoy user Glyph
//
// Name: Rainbow Ring Illusion
// Description: I'm very new to shaders. This is the first thing I've created that I would consider even mildly interesting. I am positive that my code is horribly inefficient, so if you can tell me how to make it better please do not hesitate to comment. 
float pi = 3.14159265;//Pi constant


bool ring(vec2 origin,float radius,float width){//Function for drawing ring
    if(length(origin) < radius && length(origin) > radius - width){//Test if current pixel is within ring surface
        return(true);//Return true if the point is within the ring
    }
        return(false);//Return false otherwise
}
bool circle(vec2 origin,float radius){//Function for drawing ring
    if(length(origin) < radius){//Test if current pixel is within ring surface
        return(true);//Return true if the point is within the ring
    }
        return(false);//Return false otherwise
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 finalcol;//Variable to hold the final color for this pixel
    vec2 mpoint = (fragCoord.xy - iResolution.xy/2.0) - (iMouse.xy - iResolution.xy/2.0);//Set's the default ring origin to the mouse coordinate
    
    if(iMouse.xy == vec2(0.0,0.0)){//If the mouse is in the default position set the default origin to the center of the frame
        mpoint = (fragCoord.xy - iResolution.xy/2.0);
    }
    
   	float sec = iGlobalTime*2.0*pi;//time multiplied by 2pi. Using this as sin or cos input makes the function's period 1 second
    float dens = 100.0;//Density of colors, higher values increases the distance between color changes
    float doff = -.5*sec;//Speed at which the colors scroll across the rings
    
    for(float i = 10.0; i < 600.0/*Controls maximum radius*/; i+=10.0/*Controls difference in radius between rings*/){//For loop that creates the many different rings: i value is radius. 
    	if(ring(vec2(mpoint.x + i*.5*cos(sec*.15),mpoint.y + i*.5*sin(sec*.15)),i,2.0+ i*.01) || circle(mpoint,1.0)){//Evaluate rings and offset them using trig functions.
        	finalcol=vec4(sin(i*pi/dens + doff),cos(i*pi/dens + doff),cos(i*pi/dens + pi/1.3 + doff),1.0);//Apply the colors and change each colors balance using trig functions
        	break;
        }else{finalcol = vec4(0.0,0.0,0.0,1.0);}//If not in a ring set color to black
    }
    fragColor=finalcol;
}