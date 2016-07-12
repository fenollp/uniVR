// Shader downloaded from https://www.shadertoy.com/view/XsG3zc
// written by shadertoy user DeMaCia
//
// Name: Heart Broken 
// Description: Heart Broken 



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pos = uv*10. - 5.;
    
    
    pos.y *= 0.8;
    pos.y += 0.2;
    
    //complete
    //float value = 17. * pos.x * pos.x - 
        //16. * abs(pos.x) * pos.y + 
        //17. * pos.y * pos.y  + 100.;
    
    float value = 17. * pos.x * pos.x - 
        16. * abs(pos.x) * pos.y + 
        17. * pos.y * pos.y  + 
        150.*abs(sin(iGlobalTime) + 1.)/(abs(5. * pos.x + sin(5.*pos.y))); 
    
    value = 225. - value;
    
    
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0)*
        smoothstep(0.,10.,value);
    
    
}