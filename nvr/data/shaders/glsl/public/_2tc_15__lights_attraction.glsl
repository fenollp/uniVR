// Shader downloaded from https://www.shadertoy.com/view/4lf3DM
// written by shadertoy user aiekick
//
// Name: [2TC 15] Lights Attraction
// Description: Lights
void mainImage( out vec4 f, in vec2 p )
{
    float 
        e = iGlobalTime*.3+5.,
        m = 0.,
        y;
    
    vec2 
        s = iResolution.xy,
		v = 2.*(2.*p.xy-s)/s.y;
    
    for(float i=0.;i<3e2;i++)
    {
       	y = 6.28*i/3e2;
        
        s = v - fract((e+492.87)*sin(i*695.58))*e * vec2(cos(y), sin(y));
        
        m += 2e-3/dot(s,s);
        
    }
    
    f = 
            mix(
                vec4(m), 
                texture2D(iChannel0, v/5.), 
                clamp(m, 0., .5)
            );
}