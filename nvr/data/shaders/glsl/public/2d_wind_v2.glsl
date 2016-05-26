// Shader downloaded from https://www.shadertoy.com/view/lt2SWD
// written by shadertoy user aiekick
//
// Name: 2D Wind v2
// Description: 2D Wind v2
void mainImage( out vec4 fragColor, in vec2 g )
{
	vec2 s = iResolution.xy;
	vec2 v = (2.*g-s)/s.y;
	float t = iGlobalTime;
    float c = 5.;
	float tc = t * c;
	vec4 bg = texture2D(iChannel0, g/s*2., 0.);
    
	g /= s * vec2(12.,1.2);
    g.x -= tc * 0.0225;
	g.y += sin(g.x * 46.5 + tc) * .12;
	vec4 tex = texture2D(iChannel1, g, 3.5);
    
	v /= 5.;
	v.x /= 2.;
	v.x -= tc * 0.0225;
	v.y += sin(g.x * 46.5 + tc) * .12;
	tex += texture2D(iChannel1, v, 2.75)*.7;
	tex = smoothstep(tex+0.5, tex, vec4(.71));
    tex.rgb = vec3((tex.r + tex.g + tex.b) / 3.); // col to nb
    
	fragColor = mix(bg, tex, tex.r);
}