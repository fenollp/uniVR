// Shader downloaded from https://www.shadertoy.com/view/lljXzy
// written by shadertoy user Macint
//
// Name: sunburst
// Description: sunburst rays
//More compact code, as suggested by FabriceNeyret2

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 	q = fragCoord.xy / (iResolution.xy) - .5; //vector from center to current.
    float 	l = length(q);
    float 	r = cos(20.*atan(q.y, q.x) + 12.*iDate.w) > 0.
                	? 2.
                	: .1 + .05*cos(10.*iDate.w);
    
    fragColor = 	vec4(1.,.2,0,1.)	//Base color
        			* smoothstep(r,r+1e-3,l)
        			* smoothstep(.9,.3,l);	//Vignette
}



//OLD Code
/*
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 xy = fragCoord.xy / (iResolution.xy);    
    vec2 p = xy; //current point
    vec2 q = p - vec2(0.5,0.5); //vector from center to current point.
    vec4 col = vec4(1.0,0.2,0.0,1.0);
    
    float k = 20.0;
    float ang = cos( k*atan(q.y, q.x) + 12.0*iDate[3] );
    
    float r;
    if (20.0*ang > 0.0) {
        r = 2.0;
    } else {
    	r = 0.1 + 0.05*cos(10.0*iDate[3]);
    }
    
    col *= smoothstep(r,r+0.001,length(q));
    
    col *= smoothstep(0.9,0.3,length(q)); //vignette
    
	fragColor = col;
}
*/