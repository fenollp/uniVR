// Shader downloaded from https://www.shadertoy.com/view/llBXzc
// written by shadertoy user pfeodrippe
//
// Name: Circle_PF
// Description: Simple circle
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    uv -= vec2(0.5, 0.5);
    uv.y *= 9./16.;
   
    float mult = 1.;
    float timeInc = 0.1;
    
    uv.x += sin(iGlobalTime*0.1)*sin(iGlobalTime*1.2)*sin(iGlobalTime*1.2)*0.2;
    uv.y -= sin(iGlobalTime*1.2)*sin(iGlobalTime)*sin(iGlobalTime*1.2)*0.1;
    
    float o = dot(uv,uv);
    
    if(o < (0.01*sin(iGlobalTime*(2.))+0.04)) {
        fragColor = vec4(0.42, 0.2, 0.4,1.0);
        if(o < (0.012*sin(iGlobalTime*(4.))+0.016)) {
        	fragColor = vec4(0.3, 0.3, 0.4,1.0);
    	} 
        if(o < (0.008*sin(iGlobalTime*(4.+timeInc*1.)+mult*1.)+0.011)) {
        	fragColor = vec4(0.3, 0.7, 0.4,1.0);
    	} 
        if(o < (0.004*sin(iGlobalTime*(4.+timeInc*2.)+mult*2.)+0.006)) {
        	fragColor = vec4(0.1, 0.7, 0.7,1.0);
    	} 
        if(o < (0.0005*sin(iGlobalTime*(4.+timeInc*3.)+mult*3.)+0.001)) {
            fragColor = vec4(0.3, 0.4, 0.7,1.0);
        }
    }
	else
        fragColor = vec4(vec2(0.3,0.2),0.2,1.0);
}