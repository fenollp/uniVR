// Shader downloaded from https://www.shadertoy.com/view/XtS3RW
// written by shadertoy user ForestCSharp
//
// Name: CompactCode
// Description: An extremely compact shader. Based off a shader by Guil
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Created by S.Guillitte 


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float k=0.;
    vec3 d =  vec3(fragCoord,1.0)/iResolution-.5, o = d, c=k*d, p;
    d += vec3(texture2D(iChannel0, vec2(0.1, 0.5))) * 0.01;
    
    for( int i=0; i<120; i++ ){
        
        p = o+tan(iGlobalTime*.1) * cos(iGlobalTime) * cos(0.3 * float(texture2D(iChannel0, vec2(0,3))));
		for (int j = 0; j < 10; j++) 
		
        	p = abs(p.zyx-.2) -.7,k += exp(-2. * abs(dot(p,o)));
		
		
		k/=3.;
        o += d *.05*k;
        c = .97*c + .1*k*vec3(k*k*k,k*k,1);
    }
    c =  .4 *log(1.+c);
    fragColor.rgb = c;
}
