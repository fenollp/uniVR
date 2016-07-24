// Shader downloaded from https://www.shadertoy.com/view/4tX3R4
// written by shadertoy user aiekick
//
// Name: Meta Experiment 7
// Description: Meta Experiment 7
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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float speed = 0.3;
    float t0 = iGlobalTime*speed;
    float t1 = sin(t0);
    float t2 = 0.5*t1+0.5;
    float zoom=25.;
    float ratio = iResolution.x/iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.xy*2.-1.;uv.x*=ratio;uv*=zoom;
    //vec2 mo = iMouse.xy / iResolution.xy*2.-1.;mo.x*=ratio;mo*=zoom;

	// cadre
    float thick=0.5;
    float inv=1.;
	float bottom = metaline(uv,vec2(0.,2.)*zoom, thick, vec2(0.0,1.*inv));
	float top = metaline(uv,vec2(0.,-2.)*zoom, thick, vec2(0.0,-1.*inv));
	float left = metaline(uv,vec2(2.*ratio,0.)*zoom, 0.5, vec2(1.*inv,0.0));
	float right = metaline(uv,vec2(-2.*ratio,0.)*zoom, 0.5, vec2(-1.*inv,0.0));
	float rect=bottom+top+left+right;
    
    // uv / mo
    vec2 uvo = uv;//-mo;
    float phase=1.1;
    float tho = length(uvo)*phase+t1;
    float thop = t0*20.;
    
    // map spiral
   	uvo+=vec2(tho*cos(tho-1.25*thop),tho*sin(tho-1.15*thop));
    
    // metaball
    float mbr = 8.;
    float mb = mbr / dot(uvo,uvo);

	//display
    float d0 = mb+rect;
    
    float d = smoothstep(d0-2.,d0+1.2,1.);
    
	float r = mix(1./d, d, 1.);
    float g = mix(1./d, d, 3.);
    float b = mix(1./d, d, 5.);
    vec3 c = vec3(r,g,b);
    
    fragColor.rgb = c;
}