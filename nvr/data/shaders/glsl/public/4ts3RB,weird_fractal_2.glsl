// Shader downloaded from https://www.shadertoy.com/view/4ts3RB
// written by shadertoy user aiekick
//
// Name: Weird Fractal 2
// Description: Weird Fractal 2
//based on shader from coyote => https://www.shadertoy.com/view/ltfGzS

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = mod(iGlobalTime, 150.);
    vec4 p=vec4(fragCoord,0.,1.0)/iResolution.x-.5,r=p-p,q=r;p.y+=.25;
   	q.zw-=t*0.7;
    
    for (float i=1.; i>0.; i-=.01) {

        float d=0.,s=1.;

        for (int j = 0; j < 4 ; j++)
            r=max(r*=r*=r=mod(q*s+1.,2.)-1.,r.yzxw),
            d=max(d,( .27 -length(r)*.6)/s),
            s*=1.+(0.5*sin(iGlobalTime*0.0005)+0.5);

        q+=p*d;
        
        fragColor = p-p+i;

        if(d<1e-5) break;
    }
}
