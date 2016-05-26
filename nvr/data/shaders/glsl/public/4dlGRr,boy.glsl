// Shader downloaded from https://www.shadertoy.com/view/4dlGRr
// written by shadertoy user iq
//
// Name: Boy
// Description: A boy that likes light. Move the mouse over the screen
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = -1.0 + 2.0*fragCoord.xy / iResolution.xy;
	uv.x *= iResolution.x/iResolution.y;

    vec2 mo = -1.0 + 2.0*iMouse.xy / iResolution.xy;
	mo.x *= iResolution.x/iResolution.y;
	
    vec3 col = vec3( 0.0 );

	float pa = smoothstep( -0.1, 0.1, sin(128.0*uv.x + 2.0*sin(32.0*uv.y)) );
	float la = 1.0 - smoothstep( 0.0, 0.90, length(mo-uv) );
	
	float r = length( uv );
	col = mix( col, vec3(0.3,0.4,0.5), 1.0 - smoothstep( 0.2, 0.21, r ) );

	r = length( vec2(abs(uv.x),uv.y)-vec2(0.2,0.0) );
	col = mix( col, vec3(0.3,0.4,0.5), 1.0 - smoothstep( 0.05, 0.06, r ) );

	
	float bl = sin(5.0*iGlobalTime) + sin(8.61*iGlobalTime);
    bl = smoothstep( 1.3, 1.4, bl );

	float gi = sin(10.0*iGlobalTime);
	gi = gi*gi*gi; gi = gi*gi*gi; gi *= 0.0015;
	
	r = length( (uv-vec2(0.1,0.05))*vec2(1.0,1.0+bl*12.0) );
	float e = 1.0 - smoothstep( 0.04, 0.05, r );
	col = mix( col, vec3(1.0), e );
	r = length( uv-vec2(gi+0.1 + 0.025*mo.x,0.05+0.025*mo.y) );
	col = mix( col, vec3(0.0), e*(1.0 - smoothstep( 0.01, 0.02, r )) );

	
	r = length( (uv-vec2(-0.1,0.05))*vec2(1.0,1.0+bl*12.0) );
	e = 1.0 - smoothstep( 0.04, 0.05, r );
	col = mix( col, vec3(1.0), e );
	r = length( uv-vec2(-0.1+gi+ 0.025*mo.x,0.05+0.025*mo.y) );
	col = mix( col, vec3(0.0), e*(1.0 - smoothstep( 0.01, 0.02, r )) );

	
	float smb = 1.0-smoothstep(0.18,0.22,length(mo));
	r = length( (uv-vec2(0.0,-0.07))-smb*vec2(0.0,0.5)*abs(uv.x) );
	float sm = 1.0 - smoothstep( 0.04, 0.05, r*(2.0-smb) );
	col = mix( col, vec3(0.0), sm );
	

	r = length( (uv-vec2(0.1,-0.4))-vec2(0.0,0.5)*abs(uv.x-0.1) );
	float be = 2.0 - 1.0*pow(0.5 + 0.5*sin(iGlobalTime*5.0),2.0);
	float he = 1.0 - smoothstep( 0.05, 0.06, r*be );
	float li = 1.0 - smoothstep( 0.05, 0.20, length(mo-vec2(0.1,-0.4)) );
	col = mix( col, vec3(1.0,0.0,0.0), he*clamp(li+smb,0.0,1.0) );

	
	float ls = 0.05 + 0.5*length(mo);
	r = length( uv - mo );
	col += 0.5*vec3(1.0,0.8,0.5) * (1.0-smoothstep(0.0,ls,r) );

	
	fragColor = vec4(col,1.0);
}