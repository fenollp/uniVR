// Shader downloaded from https://www.shadertoy.com/view/4tsGzf
// written by shadertoy user iq
//
// Name: Texture variation I
// Description: Avoiding texture repetition by using [url=https://www.shadertoy.com/view/Xd23Dh]Voronoise[/url]: a small texture can be used to generate infinite variety instead of tiled repetition. t doesn't work with automatic mipmapping though.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// One way to avoid texture tile repetition one using one small texture to cover a huge area.
// Based on Voronoise (https://www.shadertoy.com/view/Xd23Dh), a random offset is applied to
// the texture UVs per Voronoi cell. Distance to the cell is used to smooth the transitions
// between cells.

// It doesn't work with automatic mipmapping - one should compute derivatives by hand.

vec3 hash3( vec2 p ) { return fract(sin(vec3( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)), dot(p,vec2(419.2,371.9)) ))*43758.5453); }

vec3 textureNoTile( in vec2 x, float v )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
	
	vec3 va = vec3(0.0);
	float wt = 0.0;
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec2 g = vec2( float(i),float(j) );
		vec3 o = hash3( p + g );
		vec2 r = g - f + o.xy;
		float d = dot(r,r);
        float w = pow( 1.0 - smoothstep(0.0,2.0,dot(d,d)), 1.0 + 16.0*v );
        vec3 c = texture2D( iChannel0, .2*x + v*o.zy, -16.0 ).xyz;
		va += w*c;
		wt += w;
    }
	
    return va/wt;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xx;
	
	float f = smoothstep( 0.4, 0.6, sin(iGlobalTime    ) );
    float s = smoothstep( 0.4, 0.6, sin(iGlobalTime*0.5) );
        
	vec3 col = textureNoTile( (18.0 + 60.0*s)*uv, f ).zyx;
	
	fragColor = vec4( col, 1.0 );
}