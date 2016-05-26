// Shader downloaded from https://www.shadertoy.com/view/4tSXWd
// written by shadertoy user aiekick
//
// Name: Mod Effect (126c)
// Description: Mod Effect
// by FabriceNeuret2
void mainImage(out vec4 f,  vec2 g )
{
	vec2 R = iResolution.xy;
    g =  abs( abs( (g+g -R)/R.y ) + sin(iGlobalTime+vec2(1.6,0)) );	
	f += mod(g.x, g.y);
}

/* original
void mainImage( out vec4 f, in vec2 g )
{
	vec2 uv = (2.* g -iResolution.xy)/iResolution.y;
	
	float m = mod(abs(abs(uv.x)+cos(iGlobalTime)), abs(abs(uv.y)+sin(iGlobalTime)));
	
	f.rgb = vec3(m);
}*/
