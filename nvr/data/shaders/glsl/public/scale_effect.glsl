// Shader downloaded from https://www.shadertoy.com/view/MstXWs
// written by shadertoy user Lawliet
//
// Name: Scale Effect
// Description: Scale Effect
vec4 drawRect(float scale, vec2 uv)
{
    vec4 col;
    
    float offset = (1.0 - scale)*0.5;
    
    //offset = 0.2;
    
    mat3 mat = mat3(1.0/scale,0,-offset/scale,
                    0,1.0/scale,-offset/scale,
                    0,0,1);
    
    vec3 uvw = vec3(uv,1);
    
    uvw = uvw * mat;
    
    col = texture2D(iChannel0,uvw.xy);
    
    float c = 0.0;
    
    vec2 cuv;
    
    cuv = step(0.0,- abs(uvw.xy - 0.5) / 0.5 + 1.0);
    
    c = clamp((cuv.x + cuv.y) - 1.0,0.0,1.0);
    
    col = col * c;
    
    col = vec4(c * 0.5,0.0,0.0,1.0);
    
    return col;
}
    

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float t = mod(iGlobalTime,5.0) / 5.0;
    
    float a = 1.1;
    
    float v = 0.2;
    
    float s0 = 0.2;
    
    float s = v * t + 0.5 * a * t * t + s0;
   
    fragColor = drawRect(s,uv);
    
    fragColor = drawRect(0.5,uv);
    
    //fragColor = texture2D(iChannel0,uv);
}