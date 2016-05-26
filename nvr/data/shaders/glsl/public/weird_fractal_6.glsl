// Shader downloaded from https://www.shadertoy.com/view/XtlXzn
// written by shadertoy user aiekick
//
// Name: Weird Fractal 6
// Description: Weird Fractal 6
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//another variation of my Weird Fractal 4 : https://www.shadertoy.com/view/MtsGzB

mat3 getRotYMat(float a){return mat3(cos(a),0.,sin(a),0.,1.,0.,-sin(a),0.,cos(a));}

float map(in vec3 p, in vec3 q, inout vec3 r, inout float m)
{
	float d = 0.;
    for (int j = 0; j < 3 ; j++)
    	r=max(r.zyx*=r*=r*=r=mod(q*m+1.,2.)-1.,r.yzx),
        d=max(d,(0.12 -length(r))/m),
        m*=1.1;
    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 s = iResolution.xy;
    float t = iGlobalTime*.2, c,d,m,f=0.;
    vec3 p=vec3((2.*fragCoord.xy-s)/s.x,1.),r=p-p,q=r;
    p*=getRotYMat(-t);
    q.zx += 10.+vec2(sin(t),cos(t))*3.;
    for (float i=1.; i>0.; i-=.001) 
    {
    	c=d=0.,m=1.;
        f+=0.01;
        d = map(p,q,r,m);
        q+=p*d;
        c = i;
        if(d<1e-5) break;
   	}
    
    vec3 eps = vec3( 0.001, 0., 0. );
    vec3 nor = normalize(vec3(
    	map(p,q+eps.xyy,r,m) - map(p,q-eps.xyy,r,m),
        map(p,q+eps.yxy,r,m) - map(p,q-eps.yxy,r,m),
        map(p,q+eps.yyx,r,m) - map(p,q-eps.yyx,r,m) ));

    float k = dot(r,r+.15);
    vec3 col= vec3(1.,k,k/c)-vec3(0.7 ,0.8, 0);
    fragColor.rgb = col/f;
}