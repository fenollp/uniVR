// Shader downloaded from https://www.shadertoy.com/view/Mtl3RB
// written by shadertoy user aiekick
//
// Name: Weird Fractal 3
// Description: Colored version of Weird Fractal 2
//based on shader from coyote => https://www.shadertoy.com/view/ltfGzS

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime,c=0.;
    vec4 p=vec4(fragCoord,0.,1.)/iResolution.x-.5,r=p-p,q=r;p.y+=.25;
   	q.zw-=t*0.7;
    
    for (float i=1.; i>0.; i-=.01) 
    {
        float d=0.,s=1.;

        for (int j = 0; j < 4 ; j++)
            r=max(r*=r*=r=mod(q*s+1.,2.)-1.,r.yzxw),
            d=max(d,( .27 -length(r)*.6)/s),
            s*=1.+(0.5*sin(iGlobalTime*0.0005)+0.5);

        q+=p*d;
        
        c = i;

        if(d<1e-5) break;
    }
    
    float r1 = c, r2 = dot(r,r);
    float rxy = mix(r1, r2, sin(t));
    float rr = mix(min(r1, r2), dot(rxy,r1), 0.5);
    float gg = mix(rr, dot(rxy,r2), 0.5);
    float bb = mix(gg, rxy, 0.5);
    fragColor = vec4(rr,gg,bb,1);
    
}