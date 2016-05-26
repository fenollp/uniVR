// Shader downloaded from https://www.shadertoy.com/view/4lsXWs
// written by shadertoy user Slayman
//
// Name: Imba
// Description: mind blown

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    vec2 uv = fragCoord.xy/iResolution.xy;

    float time = iGlobalTime;
	float power = 400.0;

    vec4 tex = texture2D(iChannel1, uv);

    float offset = 0.018;

    if(tex.y < tex.x +offset && tex.y  < tex.z + offset)
    {
        tex = vec4(sin(uv.x * power), 
                   cos(uv.y * power), 
                   mod(time, 8.),
                   1);
    }
    else if(tex.y > tex.x +offset && tex.y  > tex.z + offset)
    {
        vec4 bg = vec4(0.0,0.0,0.0,0.0);
        
        bg.x = sin(uv.x / mod(time, 1.0) * 5.0) + 0.2;
        bg.y = sin(uv.y / mod(time, 1.5) * 1.0) + 0.2;
        bg.z = sin((uv.y*uv.x) / mod(time, 0.5) * 100.0) + 0.2;
        
        tex = bg;
    }

    fragColor = tex;  
}