// Shader downloaded from https://www.shadertoy.com/view/XtSSWD
// written by shadertoy user vox
//
// Name: Spiral Fractal (?)
// Description: Can someone describe what the hell I've managed to do here? Has anyone seen anything similar? Does anyone know the name for this type of approach? Can it easily be extended to a 3D flower fractal?! Let me know, I'm here to learn!
// Spiral Fractal (?)
// (c) ivan weston 2015

#define PI 3.14159265359
#define E 2.7182818284
//#define iGlobalTime 2.0*tan(1.0*iGlobalTime)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float zoom = cos(iGlobalTime)*5.0+2.5;
    
	vec2 uv = fragCoord.xy / iResolution.xy*zoom-zoom/2.0;
    
    uv.x *= iResolution.x/iResolution.y;
    
    uv = vec2(uv.x*cos(iGlobalTime)-uv.y*sin(iGlobalTime),
                 uv.x*sin(iGlobalTime)+uv.y*cos(iGlobalTime));
    
    //fragColor = 1.0-vec4(1.0-pow(1.0/E,2.0*PI*clamp(length(uv), 0.0, 1.0)));
    
    float r = length(uv);
    
    float sum = 0.0;
    
    
    for(int i = 0 ; i < 64; i++)
    {
        
        if(i < 64+int(sin(iGlobalTime)*64.0))
        {
            
            float theta1 = (7.0*atan(uv.y, uv.x)-r*PI*4.0*cos(float(i)+iGlobalTime))+ cos(iGlobalTime);

            float awesome = pow(clamp(1.0-acos(cos(theta1)), 0.0, 1.0), PI);

            sum += awesome;
        }
    
    }

    fragColor.r = cos(sum*1.0+cos(iGlobalTime*1.0))*.5+.5;
    fragColor.g = cos(sum*1.0+cos(iGlobalTime*2.0))*.5+.5;
    fragColor.b = cos(sum*1.0+cos(iGlobalTime*3.0))*.5+.5;
    
    fragColor.rgb = vec3(fragColor);
    
	//fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
}