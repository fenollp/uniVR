// Shader downloaded from https://www.shadertoy.com/view/llBGWR
// written by shadertoy user racarate
//
// Name: melty static
// Description: coffee plus shader book:
//    
//    http://patriciogonzalezvivo.com/2015/thebookofshaders/05/
#define PI 3.14159265369
float t = iGlobalTime;



float plot( vec2 st, float pct )
{
 	return smoothstep(pct - 0.02, pct, st.y) - smoothstep(pct, pct + 0.02, st.y);   
}


// f(x) = 0.8 * sin( x^6/sin(x^-6) ) etc.
// feedback loop?
vec3 peacock( vec2 st )
{   
    vec3 color = vec3( 0.0 );
    float y = 0.0;
    
    y = (5.0+5.0*sin(t)) * sin( pow(st.x,6.0*sin(t/18.0)) / sin(pow(st.x,6.0*sin(t/15.0))) );
    
    y = (0.4+0.4*cos(t)) * sin( pow(st.x,y*6.0) / cos(pow(st.y,-y*6.0)) );
    color.r = (1.0 - y);
    
    y = (0.6+0.2*sin(t+20.0*y)) * cos( pow(st.x,3.0*y) / sin(pow(st.x,-y*3.0)) );
    color.g = y;
    
    y = (0.8+0.1*cos(t+10.0*sin(t)*y)) * sin( pow(st.x,y*9.0) / cos(pow(st.y,-y*6.0)) );
    color.b = y;
    
    return color;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 st = fragCoord.xy / iResolution.xy;
    vec3 color = vec3( 0.0 );
                      
    color += (0.1+0.5*sin(t)) * peacock(st.yx);
    color += (0.2+0.1*cos(t*.4)) *peacock(vec2(1.0) - st);
	color += (0.3+0.15*sin(t*2.0)) * peacock(vec2(1.0) - st.yx);
    color += (0.4+0.2*sin(t*3.0)) * peacock(st);
     
    
    fragColor = vec4( color, 1.0 );
}

