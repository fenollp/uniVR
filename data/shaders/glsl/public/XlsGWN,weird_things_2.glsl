// Shader downloaded from https://www.shadertoy.com/view/XlsGWN
// written by shadertoy user aiekick
//
// Name: Weird Things 2
// Description: used in ray marching experiment 14 : [url]https://www.shadertoy.com/view/Mt23Rm[/url]
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 v = iResolution.xy;
    v = 25.*(2.*fragCoord.xy-v)/v.y;
    
    float s=0.,c=s,a=c;
    for (float i=0.;i<.3;i+=0.2)
    {
        a = (sin(iDate.w)/2.+1.)*.2;
        for (int j=0;j<5;j++)
        {
        	s = mix(c, sin(v.x), a);   
        	c = mix(s, cos(v.y), a);
            a*=.4;
        }
        
        
        v *= mat2(c,-s,s,c);
    }
    
    fragColor = dot(v, v)*vec4(v.x,v.y,4,1);
}