// Shader downloaded from https://www.shadertoy.com/view/XsX3Rn
// written by shadertoy user iq
//
// Name: Deform - fly
// Description: Two raytraced infinite planes
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = -1.0+2.0*fragCoord.xy/iResolution.y;
    
    float an = iGlobalTime*0.1;
    
    p = mat2(cos(an),-sin(an),sin(an),cos(an)) * p;
     
    vec2 uv = vec2(p.x,1.0)/abs(p.y) + iGlobalTime;
	
	fragColor = vec4( texture2D(iChannel0, 0.2*uv).xyz*abs(p.y), 1.0);
}