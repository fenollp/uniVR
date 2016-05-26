// Shader downloaded from https://www.shadertoy.com/view/MtsGzB
// written by shadertoy user aiekick
//
// Name: Weird Fractal 4
// Description: Weird Fractal 4
//based on shader from coyote => https://www.shadertoy.com/view/ltfGzS

// matrix op
mat3 getRotYMat(float a){return mat3(cos(a),0.,sin(a),0.,1.,0.,-sin(a),0.,cos(a));}
//mat3 getRotZMat(float a){return mat3(cos(a),-sin(a),0.,sin(a),cos(a),0.,0.,0.,1.);}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 s = iResolution.xy;
    float t = iDate.w*.2, c,d,m;
    vec3 p=vec3((2.*fragCoord.xy-s)/s.x,1.),r=p-p,q=r;
    //p*=getRotZMat(-t);
    p*=getRotYMat(-t);
   	q.zx += 10.+vec2(sin(t),cos(t))*3.;
    for (float i=1.; i>0.; i-=.01) {
        c=d=0.,m=1.;
		for (int j = 0; j < 3 ; j++)
            r=max(r*=r*=r*=r=mod(q*m+1.,2.)-1.,r.yzx),
            d=max(d,( .29 -length(r)*.6)/m)*.8,
            m*=1.1;

        q+=p*d;
        
        c = i;
	    
        if(d<1e-5) break;
    }
    
    float k = dot(r,r+.15);
    fragColor.rgb = vec3(1.,k,k/c)-.8;
    
}