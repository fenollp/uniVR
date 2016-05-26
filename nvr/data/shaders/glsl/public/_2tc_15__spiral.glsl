// Shader downloaded from https://www.shadertoy.com/view/lllGW8
// written by shadertoy user aiekick
//
// Name: [2TC 15] Spiral
// Description: [2TC 15] Spiral
void mainImage( out vec4 f, in vec2 w )
{
    vec2 v = iResolution.xy; 
    v = (2.*w - v)/v.y;
    
    float 
        t = iGlobalTime*5., 
        a = t*2e-4, 
        k = length(v)*t/25.,
        c = cos(t),
        s = sin(t),
    	r;
        
    v += vec2(
        cos(k),
        sin(k)*cos(v.x*((0.5*sin(a)+0.5)+a))
    );
    
    v *= mat2(c,-s,s,c);
    
    r = dot(v,v.yx);
    
    f = 
        vec4(
        	r,
        	r/t/5e-4,
        	r*r/t/0.5,
        	1
        );

}