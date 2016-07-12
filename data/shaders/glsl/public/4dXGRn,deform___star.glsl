// Shader downloaded from https://www.shadertoy.com/view/4dXGRn
// written by shadertoy user iq
//
// Name: Deform - star
// Description: A GLSL version of the oldschool 2D deformation effect
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec3 sqr( vec3 x ) { return x*x; }
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    float a = atan(p.y,p.x);
    float r = sqrt(dot(p,p));
    float s = r * (1.0+0.5*cos(iGlobalTime*0.5));

    vec2 uv = 0.02*p;
    uv.x +=                  .03*cos(-iGlobalTime+a*4.0)/s;
    uv.y += .02*iGlobalTime +.03*sin(-iGlobalTime+a*4.0)/s;
    uv.y += r*r*0.025*sin(2.0*r);
 
    vec3 col = texture2D( iChannel0, 0.5*uv).xyz  * vec3(1.0,0.8,0.6);
    col += sqr(texture2D( iChannel0, 1.0*uv).xxx) * vec3(0.7,1.0,1.0);

    float w = 2.0*r;
	w *= 0.5 + 0.5*pow(clamp(1.0-0.75*r,0.0,1.0),0.5);
	
	fragColor = vec4(col*w,1.0);
}