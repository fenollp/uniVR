// Shader downloaded from https://www.shadertoy.com/view/4dXGzn
// written by shadertoy user iq
//
// Name: Sun
// Description: A 2D procedural smiling sun
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float segm( float a, float b, float c, float x )
{
    return smoothstep(a-c,a,x) - smoothstep(b,b+c,x);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy/iResolution.xy;
	vec2 p = (2.0*fragCoord.xy-iResolution.xy)/min(iResolution.y,iResolution.x);
    
    p *= 0.65; // zoom in

    float a = atan(p.x,p.y);
    float r = length(p);

    float s = 0.2 + 0.5*sin(a*17.0+1.5*iGlobalTime);
    float d = 0.5 + 0.2*pow(s,1.0);
    float h = r/d;
    float f = 1.0-smoothstep(0.92,1.0,h);

    float b = pow(0.5 + 0.5*sin(3.0*iGlobalTime),500.0);
    vec2  e = vec2( abs(p.x)-0.15,(p.y-0.1)*(1.0+10.0*b) );
    float g = 1.0 - (segm(0.06,0.09,0.01,length(e)))*step(0.0,e.y);

    float t = 0.5 + 0.5*sin(12.0*iGlobalTime);
    vec2  m = vec2( p.x, (p.y+0.15)*(1.0+10.0*t) );
    g *= 1.0 - (segm(0.06,0.09,0.01,length(m)));

	vec3 bcol = vec3( 0.2+0.7*q.y,0.6+0.4*q.y,1.0 );
	bcol *= 0.85 + 0.15*q.x*q.y;
	bcol *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.25 );

    fragColor = vec4( mix(bcol,vec3(1.0,0.85,0.0)*g,f), 1.0 );
}