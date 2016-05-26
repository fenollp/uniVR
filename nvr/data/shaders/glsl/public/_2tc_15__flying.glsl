// Shader downloaded from https://www.shadertoy.com/view/4ts3DH
// written by shadertoy user iq
//
// Name: [2TC 15] Flying
// Description: My entry for the &quot;2 tweet&quot; challenge 2015, organized by nimitz: [url=https://www.shadertoy.com/view/4tl3W8]4tl3W8[/url]. Raymarched, textured, lit and colored stuff, in exactly 280 characters.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// My entry for the "2 tweet" challenge 2015, organized by nimitz: https://www.shadertoy.com/view/4tl3W8.
//
// Raymarched, textured, lit and colored stuff, in less than 280 characters.
//
// function m() at line 20 is the animated geometry modeling, line 30 is the camera setup, lines 32 amd 33 
// are the raymarching/intersector and line 35 is the shading (texturing, lighting and colored fog).





#define V vec3

V k = V(.4,-.2,.9);

V m( V p )
{
    p -= iGlobalTime;
	for( int i=0; i<16; i++ ) 
        p = reflect( abs(p)-9., k );
    return p* .5;
}

void mainImage( out vec4 c, in vec2 p )
{
    V d = V(p,1)/iResolution, o = d;
    
    for( int i=0; i<99; i++ ) 
        o += d * m(o).x;
    
    c = texture2D( iChannel0, m(o).yz ) * (.5 + 99.*m(o-k*.02).x) * exp(.04*o.yzzz);
}