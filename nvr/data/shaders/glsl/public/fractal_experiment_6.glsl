// Shader downloaded from https://www.shadertoy.com/view/Mt23Wh
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 6
// Description: Fractal Experiment 6
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
              
void mainImage( out vec4 f, in vec2 g )
{
	float 
        z = 4.,
        t = iGlobalTime,
        t0 = sin(t)*.5+.8,
        t1 = sin(t*.2)*.5+.8,
        r = 0.,
        k = 11.*.02
        ;
    
    vec2 
        s = iResolution.xy,
        u = vec2(t1, -.8*.5/t1),
        d = s-s,
        v = z * (2.*g-s)/s.y * mat2(0,1,-1,0)
        ;
        
   	vec3 
        c = d.xxx,
        a = c
        ;
    
    //vec4 
    //    m = iMouse;
    
   	//if (m.z >0.) u = m.xy/s; 
                
    for(float i=0.;i<1.;i+=.02) //1./50.
    {
        if (i > k ) break;
    	
        if (dot(d,d) > 1e12) 
        {       
        	r = i/k;
            
            a.y = fract(r);
            
            // based iq palette formula  => https://www.shadertoy.com/view/ll2GD3
            c += ( t0 + a*cos( 6.*(t0*t0+a) ) )*r;
            
            break;
        }
        
        d = v + vec2(d.x * d.x - d.y * d.y, d.x * d.y) * u;
    }
    f.rgb = c;
}
