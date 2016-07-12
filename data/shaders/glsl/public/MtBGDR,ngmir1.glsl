// Shader downloaded from https://www.shadertoy.com/view/MtBGDR
// written by shadertoy user netgrind
//
// Name: ngMir1
// Description: feeling blue
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 c = texture2D(iChannel0,uv);
    c = sin(uv.x*10.+c*cos(c*6.28+iGlobalTime+uv.x)*sin(c+uv.y+iGlobalTime)*6.28)*.5+.5;
    c.b+=length(c.rg);
	fragColor = c;
}