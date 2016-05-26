// Shader downloaded from https://www.shadertoy.com/view/Mt23zz
// written by shadertoy user netgrind
//
// Name: ngPsy1
// Description: #woah
// Made into third eye tye-dye by Cale Bradbury - @netgrind 2015
// Edited version of https://www.shadertoy.com/view/MsfGzM Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define MIC
//comment out the line above to disable mic

//#define GREY
//uncomment out above to make grey

float f(vec3 p) 
{ 
    p.z-=iGlobalTime*.5;
    return length(cos(p)-.1*cos(9.*(p.z+.1*p.x-p.y)+iGlobalTime*2.0))-(0.9+sin(iGlobalTime)*.1); 
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float i = iGlobalTime;
    vec3 d = .5-vec3(fragCoord,1.)/iResolution.x;
    d.y-=0.2;
    d.x = abs(d.x);
    vec3 o=d;
    float l = length(d.xyz)*10.0;
    float a = atan(d.y,d.x);
    o.xy*= mat2(cos(i+sin(a+i))+10.0, sin(i*.5+a*l)*2.0, -sin(i+a),cos(i*d.z+l)+10.0);
    for(int i=0;i<40;i++){
    	float m = 0.0;
        #ifdef MIC
        m = texture2D(iChannel0,vec2(.5,float(i/40))).r;
        #endif
        o+=f(o+m)*(d);
    }
    o.z = length(o*d);
    vec4 c = vec4(sin(i+abs((o-d)+length(o.xy*step(o.z,700.0))))*.3+.7,1.0);
    #ifdef GREY
    c.r = c.b+c.g+c.r;
    c.r/=3.0;
    c.r = pow(c.r,2.0);
    c.rgb = c.rrr;
    #endif
    fragColor=c;
}