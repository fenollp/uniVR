// Shader downloaded from https://www.shadertoy.com/view/lljXWt
// written by shadertoy user star
//
// Name: Hallo Christopher
// Description: it's something...
vec4 ray(vec2 uv, vec4 color)
{    
    float strokeThickness = 0.04;
    float sine = sin((uv.x+ iGlobalTime/5.0) * 30.0 )/25.0 + 0.5;
    float upper_ = sine+ strokeThickness;
    float lower_ = sine-strokeThickness;
    
    vec4 colorToReturn = vec4(0);
    if (uv.y > lower_  && uv.y < upper_)
    {
        colorToReturn = color;
    }    
    return colorToReturn;
}

vec4 circle(vec2 uv, vec2 center, float radius, vec4 color)
{    
    vec4 colorToReturn = vec4(0);
    
    if(length(uv - center) < radius)    
    {
		colorToReturn= color;   
    }
    
    return colorToReturn;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
    vec4 outputColor = vec4(0,0,0,0);
    outputColor += ray(uv + vec2(0.0, 0), vec4(1,0,0,1));
    outputColor += ray(uv + vec2(1.4, 0), vec4(0,1,0,1));
    outputColor += ray(uv + vec2(3.6, 0), vec4(0,0,1,1));
    
    float floorTime = 5.0 * (iGlobalTime - floor(iGlobalTime));
    
    
    
    int rays = 20;
    
    float stepping = 0.0;
    for(int i=0; i<100; i++)
    {
        int modulo = int(mod(float(i), 3.0));
   
        vec4 color = vec4(1,0,0,1);
        stepping += 0.04;
		if(modulo == 1)
        {
            color = vec4(0,1,0,1);
        }
        else if(modulo == 2)
        {
            color = vec4(0,0,1,1);
        }

        outputColor += circle(uv, vec2(1.0 - (pow(floorTime - stepping, 3.0)/1.0) + pow(stepping,0.5) ,0.5), 0.15 +stepping /8.0, color);
    
    }
    /**/
    if(outputColor.w != 0.0)
    {
        outputColor /= outputColor.w;
    }
    /**/    
    vec4 white = vec4(0);
	if(uv.y > 0.45  && uv.y < 0.55)
    {
        white = vec4(0.5);
    }
    else if(uv.y > 0.4  && uv.y < 0.6)
    {       
        white = vec4(0.3)/ (abs(0.5-uv.y)*17.0);
    }
    
    outputColor+=white;
    /**/
    if(sin(iGlobalTime*1000.0)> 0.9)
    {
        outputColor = vec4(1);
    };
    
	if(cos(iGlobalTime*100.0)> 0.9)
    {
        outputColor = vec4(1,0,0,1);
    };
      
    if(abs(cos(iGlobalTime*100.0))< 0.1)
    {
        outputColor = vec4(0,1,0,1);
    };    
      
    if(abs(sin(iGlobalTime*100.0))< 0.1)
    {
        outputColor = vec4(0,0,1,1);
    };    
    /**/    
    fragColor = outputColor;
}