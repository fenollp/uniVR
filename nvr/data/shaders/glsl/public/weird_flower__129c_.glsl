// Shader downloaded from https://www.shadertoy.com/view/XlBXWV
// written by shadertoy user aiekick
//
// Name: Weird Flower (129c)
// Description: Weird Flower
//    change the *3. in line 7 for more petals :)
// new by FabriceNeyret2
void mainImage( out vec4 f, vec2 g )
{
    f.xyz = iResolution;
	g += g - f.xy;
    
	g = 2.*g/f.y + cos( (atan(g.x, g.y) + iDate.w) *3.);
	f = f/f - exp(-.005/g/g).x;
}

/* original
void mainImage( inout vec4 f, in vec2 g )
{
    f.xyz = iResolution;
	g = 6.* (g + g - f.xy) / f.y;
	g += cos((atan(g.x, g.y) + iDate.w)*3.) * 2.;
	f = f/f-exp(-.02/g.x/g.x);
}*/