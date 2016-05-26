// Shader downloaded from https://www.shadertoy.com/view/ltfXzH
// written by shadertoy user aiekick
//
// Name: Speed Experiment 1
// Description: Based on shader [url=https://www.shadertoy.com/view/XtXXRH]Metamonolith [/url] from ryk. 
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Based on shader https://www.shadertoy.com/view/XtXXRH Named 'Metamonolith' from ryk. 

float hash(float f){return fract(sin(f*32.34182) * 43758.5453);}
float hash(vec2 p){return fract(sin(dot(p.xy ,vec2(12.9898,78.233))) * 43758.5453);}
void mainImage( out vec4 f, in vec2 g )
{
	float 
        t = iGlobalTime,
        sgn,h,h2,h3,band,ff,df=0.;
    
    vec2 
        s = iResolution.xy,
        uv= (2.*g-s)/s.y;
        
    vec3 
        dir=-normalize(vec3(-8.,2.*sin(t/10.),-4.*sin(t/4.))),
        up = vec3(0.,0.,1.),
        k=vec3(1,2,3)/3.,
        col=k-k;
    
    up=normalize(up-dir*dot(dir,up));
    
    dir=normalize(dir+=cross(dir,up)*uv.x+s.y/s.x*up*uv.y);        
    
    for (float a =0.;a<3.14159; a += 1.152)
    {
        df += 0.05;
        
        dir *= mat3(1.,0.,0.,0.,cos(a),-sin(a),0.,sin(a),cos(a));
		
        vec2 p = dir.zx / max(.001, abs(dir.y))*vec2(3., 0.18);
        
        p.y += t * 12. + a ;
        
        sgn = sign(dir.y);
        h = hash(floor((p+=.5+a)*sgn));
        h2 = hash(floor(p.y/6.));
        h3 = hash(floor(p.y/20.*a)+sgn);
        band = abs(p.x) < 2. + floor(30.*h3*h3) ? 1. : 0.;
        ff = h2 < .5 ? smoothstep(.6, 0.,length( mod(p, vec2(1.)) - .5))*6. : 2.;

        h = h < h2/1.2 + .1 ? 1. : 0.;

        col += .9 * mix(k, clamp(abs(fract(h2/5.+t/30.+k)*6. - 3.) - k, 0., 1.), .9) * h * band * 3. * ff * pow(abs(dir.y),0.5);  
    }
    f.rgb = clamp(col*.25, 0., 1.)+df;
}