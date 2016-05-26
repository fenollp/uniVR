// Shader downloaded from https://www.shadertoy.com/view/XddXRH
// written by shadertoy user konidia
//
// Name: Infinite Stack
// Description: I was thinking about Minecraft and this idea struck me. But I would love to know, how do you make more bottom lines appear at once?
void mainImage( out vec4 O, in vec2 U )
{
	vec2 uv = U.xy / iResolution.xy;
    vec3 color = vec3(0.0);
  	
    //The side lines of the stack cube
   	float y1 =   3.6*uv.x-1.9;
    float y2 =  -3.6*uv.x+1.7;
    float y1o =  3.6*uv.x-1.91;
    float y2o = -3.6*uv.x+1.69;
   	
    float line1 = step(y1o, uv.y) - step(y1, uv.y);
    float line2 = step(y2o, uv.y) - step(y2, uv.y);
    
    //The bottom lines of the stack cube
    float cx = uv.x*2.-1.;

    float corner  = abs(cx)+0.00+ 0.9 - fract(iGlobalTime/5.);
    float cornerO = abs(cx)+0.01+ 0.9 - fract(iGlobalTime/5.);
    
        
    float theCorner = step(corner, uv.y) - step(cornerO, uv.y);
    
    float appearCorner = step(y1,uv.y) * step(y2,uv.y);
    
    color = vec3(line1+line2+theCorner*appearCorner);
    
    float midLine = step(0.498,uv.x) - step(0.502,uv.x);
    
	O = vec4(color+midLine,1.0);
}