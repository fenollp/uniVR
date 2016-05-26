// Shader downloaded from https://www.shadertoy.com/view/Mdl3W7
// written by shadertoy user BeRo
//
// Name: Club disco sphere
// Description: Just something what I did originally in my own 64k tool .marchfabrik with different input uniforms, so these are mapped here (example: rp =&gt; ((gl_FragCoord.xy/iResolution.xy)-vec2(0.5))*2.0 ).
#define PI 3.14159265358979323846264
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float tcz=iGlobalTime*70.0;
	vec2 rp=((fragCoord.xy/iResolution.xy)-vec2(0.5))*2.0;
    vec2 p=(rp.xy*vec2(iResolution.x/iResolution.y,1.0))*1.25;  
	vec2 n=p;
	float lp=length(p*0.5);
	float ln=length(n);
	float r=(lp>0.5)?(1.0/(ln*ln)):(2.0*asin(ln)/PI);
	float phi=atan(n.y,n.x);
	vec2 coord=(vec2(r*cos(phi),r*sin(phi))*0.5)+vec2(0.5);
	vec2 tp=vec2(fract(coord.x),fract(coord.y));
	vec2 cp=(tp-vec2(0.5))*2.0;
    vec3 c=vec3((sin(tcz*PI/(3.0*80.0))*0.5)+0.5,(sin(tcz*PI/(3.0*40.0))*0.5)+0.5,(sin(tcz*PI/(3.0*20.0))*0.5)+0.5);
	vec2 t=vec2((sin(tcz*PI/(3.0*128.0))*8.0)+(tcz/(3.0*2.0)),(sin(tcz*PI/(3.0*64.0))*8.0)-(tcz/(3.0*1.0)));
	c*=abs(sin(((cp.x*16.0)-(t.y/(3.0*2.0)))*PI))*abs(sin(((cp.y*16.0)+(t.x/(3.0*4.0)))*PI))*vec3(1.0,1.0,1.0);
	c*=(abs(sin(((cp.x*4.0)-(t.x/(3.0*2.0)))*PI))*abs(sin(((cp.y*4.0)+(t.y/(3.0*4.0)))*PI))*abs(sin((tcz/(3.0*16.0))*PI)))+
	   (abs(sin(((cp.x*2.0)-(t.x/(3.0*2.0)))*PI))*abs(sin(((cp.y*2.0)+(t.y/(3.0*4.0)))*PI))*abs(sin((tcz/(3.0*8.7))*PI)))+
	   (abs(sin(((cp.x*1.0)-(t.x/(3.0*2.0)))*PI))*abs(sin(((cp.y*1.0)+(t.y/(3.0*4.0)))*PI))*abs(sin((tcz/(3.0*5.3))*PI)));
	c*=texture2D(iChannel0, tp).xyz;
	fragColor=vec4(clamp(c,0.0,1.0)*((lp>0.5)?(lp*0.5):1.0),1.0);
}