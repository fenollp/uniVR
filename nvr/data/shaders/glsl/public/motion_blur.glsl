// Shader downloaded from https://www.shadertoy.com/view/Xsf3Rn
// written by shadertoy user iq
//
// Name: Motion Blur
// Description: Motion blur on a 2D deformation effect
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec3 deform( vec2 p, float scale )
{
    vec2 uv;
   
	
    float mtime = scale+iGlobalTime;

	p.x += 0.5*sin(1.1*mtime);
	p.y += 0.5*sin(1.3*mtime);

	float a = atan(p.y,p.x);
    float r = sqrt(dot(p,p));
    float s = r * (1.0+0.5*cos(mtime*1.7));

    uv.x = .1*mtime +.05*p.y+.05*cos(mtime+a*2.0)/s;
    uv.y = .1*mtime +.05*p.x+.05*sin(mtime+a*2.0)/s;

    float w = 0.8-0.2*cos(mtime+3.0*a);

    vec3 res = texture2D( iChannel0, 0.5*uv ).xyz*w;
    return res;

}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    vec3 total = vec3(0.0);
    float w = 0.0;
    for( int i=0; i<20; i++ )
    {
        vec3 res = deform(p,w);
        total += res;
        w += 0.01;
    }
    total /= 20.0;

	w = 2.0*(0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.25 ));
    fragColor = vec4( total*w,1.0);
}