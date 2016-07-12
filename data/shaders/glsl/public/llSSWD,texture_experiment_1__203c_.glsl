// Shader downloaded from https://www.shadertoy.com/view/llSSWD
// written by shadertoy user aiekick
//
// Name: Texture Experiment 1 (203c)
// Description: how remove the tile artifact (dicontinuity) ?
void mainImage( out vec4 f, in vec2 g )
{
    g /= iResolution.xy * vec2(12.,1.2);
	g.y += sin((g.x -= (f.a = iGlobalTime * 1.5) * .015) * 46.5 + f.a) * .12;
	f = texture2D(iChannel0, g, 4.*(sin(f.a)*.5+.5));
	f = smoothstep(f+.5, f, f/f*.71);
}

/* original 209c

void mainImage( inout vec4 f, in vec2 g )
{
    g /= iResolution.xy * vec2(15.,1.5);
	f.a = iGlobalTime * 1.5;
	g.x -= f.a * .015;
	g.y += sin(g.x * 46.5 + f.a) * .12;
	f = texture2D(iChannel0, g, 4.*(sin(f.a)*.5+.5));
	f = smoothstep(f+.5, f, f/f*.71);
}

*/