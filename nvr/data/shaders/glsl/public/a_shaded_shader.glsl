// Shader downloaded from https://www.shadertoy.com/view/4ddSDs
// written by shadertoy user Mr_E
//
// Name: A Shaded Shader
// Description: This is a test for creating a source of light over a plane. I just added the music because it would be cool.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
    float t = mod(iGlobalTime+19.0, 1000.0);  
    
    float ox = sin(t*0.2)+0.5;
    
    float oy = cos(t*0.1)+0.5;
    
    float at = atan(uv.x-0.5,uv.y+0.5)*0.4; 
    
    
    float d1 = distance(uv, vec2(0.45+ox,0.25));
    
    float d2 = distance(uv, vec2(0.15,   0.75+oy));
    
    float c = mod(sin(d1-d2),0.1)*(d2/d1);
    
    c += 2.5*mod(cos(d1-d2-0.05),0.1)*(d2/d1);
    
	fragColor = vec4(c+at,c*0.3,c*0.6, 1.0);
}