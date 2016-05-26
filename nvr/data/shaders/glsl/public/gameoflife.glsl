// Shader downloaded from https://www.shadertoy.com/view/XstGRf
// written by shadertoy user iq
//
// Name: GameOfLife
// Description: Conway's Game of Life [url]http://www.iquilezles.org/www/articles/gameoflife/gameoflife.htm[/url]. Buffer A contains the world and it reads/writes to itself to perform the simulation.
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
	float c = texture2D( iChannel0, uv ).x;
    
    fragColor = vec4(c,c,c,1.0);
}