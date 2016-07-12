// Shader downloaded from https://www.shadertoy.com/view/4dX3zj
// written by shadertoy user iq
//
// Name: Texture flow I
// Description: Integrating uv coordinates across gradient and iso lines (giving rise to voronoi-like and curl-like features respectively)
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy;
	
	vec2 uv = p*0.15 + 0.25;
	
	vec2 e = 1.0/iChannelResolution[0].xy;
	
	
	float am1 = 0.5 + 0.5*sin( iGlobalTime );
	float am2 = 0.5 + 0.5*cos( iGlobalTime );
	
	for( int i=0; i<50; i++ )
	{
		float h  = dot( texture2D(iChannel0, uv,               -100.0).xyz, vec3(0.333) );
		float h1 = dot( texture2D(iChannel0, uv+vec2(e.x,0.0), -100.0).xyz, vec3(0.333) );
		float h2 = dot( texture2D(iChannel0, uv+vec2(0.0,e.y), -100.0).xyz, vec3(0.333) );
        // gradient
		vec2 g = 0.001*vec2( (h1-h), (h2-h) )/e;
        // isoline		
		vec2 f = g.yx*vec2(-1.0,1.0);
		
		g = mix( g, f, am1 );
		
		uv -= 0.01*g*am2;
	}
	
	vec3 col = texture2D(iChannel0, uv).xyz;
	
    col *= 2.0;
		
	fragColor = vec4(col, 1.0);
}
