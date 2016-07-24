// Shader downloaded from https://www.shadertoy.com/view/XsfGWB
// written by shadertoy user iq
//
// Name: Loading...
// Description: Loading...
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec3 col = vec3(.2,.2,.2);
	
	vec2 p = (-1.0+2.0*fragCoord.xy / iResolution.xy)*vec2(iResolution.x/iResolution.y,1.0);
	vec2 q = p + 0.1;

    q *= 1.0 + 0.3*q.x;	
	float r = length(q);
	float a = atan(q.y,q.x) + 1.0*iGlobalTime;
	col = mix( col, vec3(0.1), (1.0-smoothstep( 0.0,0.24,abs(r-0.5)))*smoothstep(-1.0,1.0,sin(17.0*a))   );

    p *= 1.0 + 0.3*p.x;	
	r = length(p);
	a = atan(p.y,p.x) + 1.0*iGlobalTime;
	col = mix( col, vec3(1.0,1.0,1.0), (1.0-smoothstep( 0.10,0.14,abs(r-0.5)))*smoothstep(0.4,1.0,sin(17.0*a))   );
	
	float gl = 0.6 + 0.4*sin(0.5*6.2831*iGlobalTime);
	col += gl * vec3(1.0,0.5,0.2) * (1.0-smoothstep( 0.10,0.20,abs(r-0.5)))*smoothstep(-1.0,0.5,sin(17.0*a))   ;	
	
	fragColor = vec4(col,1.0);
}