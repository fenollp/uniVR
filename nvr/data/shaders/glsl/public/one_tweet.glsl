// Shader downloaded from https://www.shadertoy.com/view/ltf3zj
// written by shadertoy user dzira
//
// Name: one tweet
// Description: one tweet shader
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 u=fragCoord.xy/iResolution.y-.6;
    fragColor=texture2D(iChannel0,u+normalize(u)*vec2(sin(2.*length(u)-iGlobalTime)));
}