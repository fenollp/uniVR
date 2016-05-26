// Shader downloaded from https://www.shadertoy.com/view/ldtXR8
// written by shadertoy user aiekick
//
// Name: Radial Maze (178c)
// Description: Based on/ Maze 4 (90 chars) from fabriceneyret2 shader : https://www.shadertoy.com/view/4scGWf&lt;br/&gt;   
void mainImage( out vec4 f, vec2 g )
{  
    f.xyz = iResolution;
    
	g = (g+g-f.xy)/f.y * 9.;
	
	g.x = atan(g.x, g.y) * 1.7 * floor(g.y = length(g));

    f += step(.1/ fract( cos(6e4 * length ( floor(g) )) < -.8 ? g.x: g.y ), .6) -f;
}