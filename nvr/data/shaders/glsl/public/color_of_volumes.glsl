// Shader downloaded from https://www.shadertoy.com/view/ldlXWM
// written by shadertoy user FabriceNeyret2
//
// Name: color of volumes
// Description: color of water,sky,blood is non-sense.  Blood is yellow in microscope; water is transp to cyan to deep blue. -&gt; Color of volume is defined only for given length, or for 100% opacity. 
//    Here: color for y=exp(3.L)-1 . Chrominance changes, peaks live longer.
#define N 5.
	void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 col = vec3(uv.x,N*mod(uv.x,1./N), N*N*mod(uv.x,1./(N*N)));
	col = pow(col,vec3(exp(3.*uv.y)-1.));
	fragColor = vec4(col,1.0);
}