// Shader downloaded from https://www.shadertoy.com/view/XlB3Rt
// written by shadertoy user dzira
//
// Name: hash chaos
// Description: just an experiment. made a small change to a hash to see what the patterns would be like.
float hash( float n )
{
    return fract(n*n*iGlobalTime*.02);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.0*fragCoord.xy-iResolution.xy)/iResolution.y;
    uv = floor(uv*40.+40.*vec2(sin(iGlobalTime/2.),cos(iGlobalTime/2.)));
    float x = hash(fract(hash(.213*uv.x+.5*uv.y)+hash(.73*uv.y+7.)));
    
	fragColor = vec4(x,x,x,1.0);
}