// Shader downloaded from https://www.shadertoy.com/view/4s3XDH
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 12 : Morphing
// Description: 232c
//* FabriceNeyret2 version 230c
void mainImage( out vec4 f, vec2 z )
{
    f.xyz=iResolution;
    z = (z+z-f.xy)/f.y * 1.4;
    vec2 g = z*(.5+.5*sin(iDate.w/2.));
    
   	z -= g;
    
    for (int i=0;i<12;i++)
    {	z = (f.w = dot(z,z)) < 4. 
        ? mat2(z,-z.y,z.x) * z +  g - vec2(1,.3) : z;}
 
	f = vec4(.15,.1,.1,1)/f.w + sqrt(f.w)*log(f.w);
}/**/

/* original 281c
void mainImage( out vec4 f, vec2 z )
{
	f.xyz = iResolution;
    vec2 g = (z+z-f.xy)/f.y * 1.4;
    
	float t = sin(iGlobalTime * .5)*.5+.5;
   	z = mix(g,g-g,t);
    for (int i=0;i<12;i++)
		if ((f.w = dot(z,z)) < 4.)
			z = vec2(z.x * z.x - z.y * z.y,2. * z.x * z.y) 
            	+ mix(g-g, g, t)
            	- vec2(1,.3);

    f.rgb = vec3(.15,.1,.1);
	f += f/f.w+sqrt(f.w)*log(f.w)-f;
}/**/