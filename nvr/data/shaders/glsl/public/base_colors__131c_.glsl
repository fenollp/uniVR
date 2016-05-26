// Shader downloaded from https://www.shadertoy.com/view/MdG3RK
// written by shadertoy user aiekick
//
// Name: Base Colors (131c)
// Description: Base colors

/* coyote and fabriceneyret2 version of 131c */
#define K length( ( g+g-(f.xy=iResolution.xy) ) / f.y*12. + vec2(0
void mainImage( out vec4 f, vec2 g )
{    f = 6. / vec4(K,-3)),K+4,3)),K-4,3)),1); }

/* 136c
#define K(a,b) length( ( g+g-(f.xy=iResolution.xy) ) / f.y + vec2(a,b+.25) ),
void mainImage( out vec4 f, vec2 g )
{    f = .5 / vec4(K(0,-)K(.3,)K(-.3,)1);    }
*/

/* 153c 
void mainImage( out vec4 f, vec2 g )
{
    f.xyz = iResolution;
 	g = (g+g - f.xy)/f.y;
	g.y -= 0.25;
    f = vec4(.3,.5,-.5,0);   
    f = .5 / vec4(length(g), length(g+f.xy), length(g-f.xz), 1);
}*/

/* orignal 
void mainImage( out vec4 f, in vec2 g )
{
    f.xyz = iResolution;
	g = (g+g - f.xy)/f.y;
	g.y -= 0.25;
	
    vec3 e = vec3(1.6,1,-1);
	float s = .5;
	f.r = s / length(g);
	f.g = s / length(g+s/e.xy);
	f.b = s / length(g-s/e.xz);
} */