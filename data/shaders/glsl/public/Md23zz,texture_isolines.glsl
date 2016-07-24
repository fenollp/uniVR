// Shader downloaded from https://www.shadertoy.com/view/Md23zz
// written by shadertoy user iq
//
// Name: Texture Isolines
// Description: Another test integrating isolines of a texture
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //---------------------------------
    // input
    //---------------------------------
	vec2 p = fragCoord.xy / iResolution.xy;

    //---------------------------------
    // integrate isolines
    //---------------------------------
	float lg = 0.0;
	vec2 uv = 0.2*vec2( p.x, 1.0-p.y );
	vec2 e = 1.0/iChannelResolution[0].xy;
	for( int i=0; i<128; i++ )
	{
		
		float h  = dot( texture2D(iChannel0, uv,               3.5).xyz, vec3(0.333) );
		float h1 = dot( texture2D(iChannel0, uv+vec2(e.x,0.0), 3.5).xyz, vec3(0.333) );
		float h2 = dot( texture2D(iChannel0, uv+vec2(0.0,e.y), 3.5).xyz, vec3(0.333) );
		
        // gradient
		vec2 g = ( vec2( (h1-h), (h2-h) )/e );
		
        // isoline		
		vec2 f = g.yx*vec2(-1.0,1.0);
		
		uv -= 0.004*f/iChannelResolution[0].xy;
		
		lg += (0.5 + 0.5*sin(atan(f.x,f.y)))/128.0;
	}
	vec3 col = texture2D(iChannel0, uv).xyz;

	//---------------------------------
    // color
    //---------------------------------
	col = col*col*(3.0-2.0*col);
	col = col*col*(3.0-2.0*col);
	col = col*col*(3.0-2.0*col);
	
    //---------------------------------
    // lighting
    //---------------------------------
	float f = dot( col, vec3(0.33) );
	vec3 nor = normalize( vec3( dFdx(f), 25.0/iResolution.x, dFdy(f) ) );
	float dif = pow( clamp( dot( nor, vec3(0.57703,0.57703,-0.57703) ), 0.0, 1.0 ), 4.0 );
	col += 0.14*vec3(dif);

	col *= mix( vec3(0.6,0.75,0.6), vec3(1.0,1.1,0.8), lg );
		

	//---------------------------------
    // output
    //---------------------------------
	col *= 0.5 + 0.5*pow( 16.0*p.x*(1.0-p.x)*p.y*(1.0-p.y), 0.2 );
	fragColor = vec4(col, 1.0);
}
