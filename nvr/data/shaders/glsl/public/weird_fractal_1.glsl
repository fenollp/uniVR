// Shader downloaded from https://www.shadertoy.com/view/llX3zB
// written by shadertoy user aiekick
//
// Name: Weird Fractal 1
// Description: //based on shader from coyote =&gt; https://www.shadertoy.com/view/ltfGzS
//based on shader from coyote => https://www.shadertoy.com/view/ltfGzS

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime*.3;
    vec4 p=vec4(fragCoord,0.,1.)/iResolution.x-.5,r=p-p,q=r;p.y+=.25;
   	q.x=1.5*cos(t*0.3);
    q.y=1.5*sin(t*0.3);
    q.zw-=t*0.7;
    
    for (float i=1.; i>0.; i-=.01) {

        float d=0.,s=1.;

        for (int j = 0; j < 4 ; j++)
            r=max(r*=r*=r=mod(q*s+1.,2.)-1.,r.yzxw),
            d=max(d,( .27 -length(r)*.3)/s),
            s*=3.1;

        q+=p*d;
        
        fragColor = p-p+i;

        if(d<1e-5) break;
    }
}

/* first version

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 p=fragCoord/iResolution.x-.5,r=p-p,q=r;p.y+=.25;
    q.zw-=iGlobalTime*0.05;
    
    for (float i=1.; i>0.; i-=.01) {

        float d=0.,s=1.;

        for (int j = 0; j < 6; j++)
            r=max(r=abs(mod(q*s+1.,2.)-1.),r.yzxw),
            d=max(d,(.3-length(r*0.95)*.3)/s),
            s*=3.;

        q+=p*d;
        
        fragColor = p-p+i;

        if(d<1e-5) break;
    }
}
*/