// Shader downloaded from https://www.shadertoy.com/view/Mll3z8
// written by shadertoy user aiekick
//
// Name: Meta Experiment 6
// Description: Meta Experiment 6
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec2 uv;
vec2 mo;
float ratio;

float metaline(vec2 p, vec2 o, float thick, vec2 l)
{
    vec2 po = 2.*p+o;
    return thick / dot(po,vec2(l.x,l.y));
}

float metaball(vec2 p, vec2 o, float thick)
{
    vec2 po = p-o;
    return thick / dot(po,po);
}

float metacurve(vec2 p, vec2 o, float i, float thick, vec2 l)
{
   	float mu = metaline(p,vec2(o.x,o.y-i), thick, l);
    float md = metaline(p,vec2(o.x,o.y+i), thick, vec2(l.x,l.y*-1.));
    return mu+md;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    ratio=iResolution.x/iResolution.y;
    uv=(fragCoord.xy/iResolution.xy*2.-1.)*vec2(ratio,1.);
    //mo=(iMouse.xy/iResolution.xy*2.-1.)*vec2(ratio,1.);
    
    float t = iGlobalTime*5.;
    float t2 = sin(t*0.1);
    float t3 = 0.5*t2+0.5;
    
    float ampl=0.2;
    float phase=4.;
    vec2 uvSin=vec2(uv.x,uv.y+sin(uv.x*phase-t)*ampl);
   
    float inv=t2;
	float bottom = metaline(uv,vec2(0.,2.), 0.1, vec2(0.0,1.*inv));
	float top = metaline(uv,vec2(0.,-2.), 0.1, vec2(0.0,-1.*inv));
	float left = metaline(uv,vec2(2.*ratio,0.), 0.1, vec2(1.*inv,0.0));
	float right = metaline(uv,vec2(-2.*ratio,0.), 0.1, vec2(-1.*inv,0.0));
	
    float coef=50.;
    float mcs=0.;
    float st=0.4;
    for (int i=0;i<6;i++)
    {
        mcs+= metacurve(uvSin, vec2(0.,st*float(i)), 0.00001, coef, vec2(0.,1.*inv));
        mcs+= metacurve(uvSin, vec2(0.,-st*float(i)), 0.00001, coef, vec2(0.,1.*inv));
    }
             
	float rad=0.8;
    float refa = 1.570796+t*0.2;
    float oa = 6.2831853/3.;
    float rm0 = metaball(uv, vec2(cos(refa),sin(refa))*rad, 0.05);
	float rm1 = metaball(uv, vec2(cos(refa+oa),sin(refa+oa))*rad, 0.05);
	float rm2 = metaball(uv, vec2(cos(refa+oa*2.),sin(refa+oa*2.))*rad, 0.05);
	
    float rect = bottom+top+left+right;
    float rms = rm0+rm1+rm2;
    float os = rect+rms+mcs;
    
    float r = mix(1./os, os, 1.);
    float g = mix(1./os, os, 3.);
    float b = mix(1./os, os, 5.);
    vec3 c = vec3(r,g,b);
	fragColor.rgb = c;
}