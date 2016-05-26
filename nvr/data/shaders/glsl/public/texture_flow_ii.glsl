// Shader downloaded from https://www.shadertoy.com/view/4djSD3
// written by shadertoy user iq
//
// Name: Texture flow II
// Description: Integrating uv coordinates across texture isolines (giving rise to curl-like features)
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec2 flow( vec2 uv )
{
	vec2 e = 1.0/iChannelResolution[0].xy;
    
    float time = 5.0 * mod( iGlobalTime, 12.0 );
    
	for( int i=0; i<50; i++ )
	{
		float h0 = dot( texture2D(iChannel0, uv              ).xyz, vec3(0.333) );
		float h1 = dot( texture2D(iChannel0, uv+vec2(e.x,0.0)).xyz, vec3(0.333) );
		float h2 = dot( texture2D(iChannel0, uv+vec2(0.0,e.y)).xyz, vec3(0.333) );
        // tangent
		vec2 f = vec2( h2-h0, h0-h1 )/(255.0*e);
        // move        
        uv += 0.0015*f   *clamp( (time-float(i)), 0.0, 1.0 );
	}
    
    return uv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy / iResolution.xy;

    // orbit, distance and distance gradient
    vec2 uva = 0.05*(p + vec2(1.0,0.0)/iResolution.xy);
	vec2 uvb = 0.05*(p + vec2(0.0,1.0)/iResolution.xy);
	vec2 uvc = 0.05*p;
	vec2 nuva = flow( uva  );
	vec2 nuvb = flow( uvb );
	vec2 nuvc = flow( uvc );
    float fa = length(nuva-uva)*64.0;
    float fb = length(nuvb-uvb)*64.0;
    float fc = length(nuvc-uvc)*64.0;
    vec3 nor = normalize( vec3((fa-fc)*iResolution.x,1.0,(fb-fc)*iResolution.y ) );

    // color
  	vec3 col = texture2D(iChannel1, 4.0*nuvc).xyz;
    // ilumination
    vec3 lig = normalize( vec3( 1.0,1.0,-0.4 ) );
    col *= vec3(0.5,0.6,0.7) + vec3(1.0,0.9,0.8) * clamp( dot(nor,lig), 0.0, 1.0 );
    col *= fc;
    // postprocess    
    col = 2.0*pow( col, vec3(0.8,0.8,0.7) );
    col *= 0.75 + 0.25*sqrt( 16.0*p.x*p.y*(1.0-p.x)*(1.0-p.y) );
    
	fragColor = vec4( col, 1.0 );
}