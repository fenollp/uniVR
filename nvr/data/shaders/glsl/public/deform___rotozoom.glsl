// Shader downloaded from https://www.shadertoy.com/view/XdfGzn
// written by shadertoy user iq
//
// Name: Deform - rotozoom
// Description: A 2D rotating and zooming texture
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;

    vec2 cst = vec2( cos(iGlobalTime), sin(iGlobalTime) );
    mat2 rot = (1.0 + 0.5*cst.x)*mat2(cst.x,-cst.y,cst.y,cst.x);

    vec3 col = texture2D( iChannel0, 0.5 + 0.5*rot*p ).xyz;
    fragColor = vec4( col, 1.0 );
}