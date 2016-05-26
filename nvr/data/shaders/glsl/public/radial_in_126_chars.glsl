// Shader downloaded from https://www.shadertoy.com/view/XsK3RD
// written by shadertoy user GregRostami
//
// Name: Radial in 126 chars
// Description: Here's my One Tweet version of aiekick's shader:
//    https://www.shadertoy.com/view/lsG3RW
//Fabrice did his magic to bring it down to 126 chars!!
void mainImage(out vec4 f,vec2 g)
{
	f = texture2D(iChannel0, 
                   ( length(g= g/iResolution.y-.5) + vec2(atan(g.x, g.y),0) ) * .1
                  - iDate.w*.01 );
}

//Original at 139 chars
/*
void mainImage(out vec4 f,vec2 g)
{
    g = g/iResolution.y-.5;
	g = vec2(atan(g.x, g.y),length(g))/.1;
	g.x += g.y;
	f = texture2D(iChannel0,(g - iDate.w)*.01);
}
*/