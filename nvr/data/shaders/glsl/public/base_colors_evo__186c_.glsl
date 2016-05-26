// Shader downloaded from https://www.shadertoy.com/view/ldGGzK
// written by shadertoy user aiekick
//
// Name: Base Colors Evo (186c)
// Description: Base Colors Evo
/* coyote and fabriceneryret2 version of 186c */
#define K(a,b) length(pow(abs(g/iResolution.y/.5+vec2(a-.78,b.25)-1.),vec2(sin(iDate.w*.5)*1.5+1.8))),
void mainImage( out vec4 f, vec2 g )
{
    f = smoothstep(1., .4, vec4(K(,-)K(.3,)K(-.3,)1)/.5);
}

/* original 239c 
#define K(a) .5 / length(pow(abs(a),vec2(sin(iDate.w*.5)*.5+.6)*3.))
void mainImage( out vec4 f, in vec2 g )
{
    f.xyz = iResolution;
	g = (g+g - f.xy)/f.y;
	g.y -= 0.25;
	
    vec3 e = vec3(.3,.5,-.5);
	f.r = K(g);
	f.g = K(g+e.xy);
	f.b = K(g-e.xz);
    
    f = smoothstep(f, f * 0.4, vec4(1));
}*/