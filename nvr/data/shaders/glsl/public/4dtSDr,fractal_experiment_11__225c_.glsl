// Shader downloaded from https://www.shadertoy.com/view/4dtSDr
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 11 (225c)
// Description: Use Mouse
void mainImage( out vec4 f, vec2 z )
{
	f.xyz = iResolution;
	z =  fract(2.*(z+z-f.xy)/f.y)*2.6 - vec2(.864, 1.28);
    f = iMouse/f*2.;
    
    for (int i=0;i<4;i++)
        z = vec2(f.w = dot(z,z), -5.5 * z.x * z.y) + vec2(-.8,2.2) * f.xy * z;
    
	f = vec4(0,.6,1,1) + sqrt(f.w) * log(f.w);
}

