// Shader downloaded from https://www.shadertoy.com/view/lsX3Rr
// written by shadertoy user iq
//
// Name: Nyan Cat
// Description: Nyan Cat shader!

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy / iResolution.xy;

	vec2 uv = vec2( p.x+mod(iGlobalTime,2.0), p.y );	
	vec3 bg = vec3(0.0,51.0/255.0,102.0/255.0);
    float f = texture2D( iChannel1, uv ).x;
	f = f*f;
	bg = mix( bg, vec3(1.0), f );
	
	float a = 0.01*sin(40.0*p.x + 40.0*iGlobalTime);
	float h = (a+p.y-0.3)/(0.7-0.3);
    if( p.x<0.65 && h>0.0 && h<1.0 )
	{
	    h = floor( h*6.0 );
	    bg = mix( bg, vec3(1.0,0.0,0.0), 1.0 - smoothstep( 0.0, 0.1, abs(h-5.0) ) );
	    bg = mix( bg, vec3(1.0,0.6,0.0), 1.0 - smoothstep( 0.0, 0.1, abs(h-4.0) ) );
	    bg = mix( bg, vec3(1.0,1.0,0.0), 1.0 - smoothstep( 0.0, 0.1, abs(h-3.0) ) );
	    bg = mix( bg, vec3(0.2,1.0,0.0), 1.0 - smoothstep( 0.0, 0.1, abs(h-2.0) ) );
	    bg = mix( bg, vec3(0.0,0.6,1.0), 1.0 - smoothstep( 0.0, 0.1, abs(h-1.0) ) );
	    bg = mix( bg, vec3(0.4,0.2,1.0), 1.0 - smoothstep( 0.0, 0.1, abs(h-0.0) ) );
	}

	uv = (p - vec2(0.5,0.15)) / (vec2(1.02,0.9) - vec2(0.5,0.15));
							  
	uv = clamp( uv, 0.0, 1.0 );
	
	float ofx = floor( mod( iGlobalTime*10.0*2.0, 6.0 ) );

	float ww = 40.0/256.0;
	uv.y = 1.0-uv.y;
	uv.x = clamp( uv.x*ww + ofx*ww, 0.0, 1.0 );
	vec4 fg = texture2D( iChannel0, uv );
	
	vec3 col = mix( bg, fg.xyz, fg.w );
	
    fragColor = vec4( col, 1.0 );
}