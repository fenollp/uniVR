// Shader downloaded from https://www.shadertoy.com/view/MtlXRM
// written by shadertoy user md
//
// Name: bouncing_ball
// Description: bouncing ball!
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy / iResolution.xy;
    float aspect_ratio = iResolution.y / iResolution.x;
    
    vec2 center = vec2(0.5, 0.3*aspect_ratio + 0.2* abs(cos(iGlobalTime)));
    float radius = 0.2*aspect_ratio;
    float val = (p.x - center.x) * (p.x - center.x) + (p.y*aspect_ratio - center.y) * (p.y*aspect_ratio - center.y);
    if (val < radius*radius)
    {
        fragColor = vec4(0.0, 0.0, 0.0, 1);
    }
    else if (p.y > 0.1 && p.y < 0.11) 
    {
        fragColor = vec4(0.5, 0.5, 0.5, 1);
    }
    else
    {
        fragColor = vec4(1.0, 1.0, 1.0, 1);
    }
}