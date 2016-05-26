// Shader downloaded from https://www.shadertoy.com/view/4dK3R3
// written by shadertoy user 834144373
//
// Name: 恬纳微晰
// Description: It's just a public name,and have been studying chinese for 2 years. the pinyin is  &quot;ti&aacute;n n&agrave; wēi xī &quot;
//    i like chinese culture so much,like food,chinese characters,Chinese Painting,Chinese people........and The Chinese people are never old
//恬纳微晰.glsl
//License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//Created by 834144373  2015/2/16
////Tags: 2d, font, chinese, distancefont, string,unicode
//Original: https://www.shadertoy.com/view/4dK3R3
///////////////////////////////////////////////////////////////////////////////////////
vec2 uv;

float line( in vec2 a, in vec2 b ,float r)
{
    vec2 p = uv - a;
    vec2 ab = b - a; // ->ab
    return length(p-ab*clamp(dot(p,ab)/dot(ab,ab),0.,1.))-r;
}

float e(vec2 a,vec2 b,float r){
	return distance(uv,a)+distance(uv,b)-distance(a,b)*r;
}


float o(vec2 where,float r,float R){
	float d  = distance(uv,where);
	float d1 = d - r;
	float d2 = d - R;
	return max(-d1,d2);
}

float box(vec2 where,vec2 ab){
	return length(max(abs(uv-where)-ab,0.)) - 1e-10;
}

float edge_box(vec2 where,vec2 ab,float r){
	float b1 = box(where,vec2(ab.x-r,ab.y-r));
	float b2 = box(where,ab);
	return max(-b1,b2);
}

//-----------------------------------
//恬 6x4
//忄 2x4
const vec2 s = vec2(12,8); //size
float su(vec2 where){
	
	float d1 = line(vec2(0.)-where,vec2(0.,4.)/s-where,0.02);
	float d2 = line(vec2(-1.,2.)/s-where,vec2(-0.86,3.)/s-where,0.02);
	float d3 = line(vec2(0.54,3.2)/s-where,vec2(.8,2.4)/s-where,0.02);
	d1 = min(d1,d2);
	d1 = min(d1,d3);
	return d1;
}
//舌 4x4
float she(vec2 where){
	//const vec2 s = vec2(12,8);//size
	float d = line(vec2(-1.8,3.5)/s-where,vec2(1.5,3.9)/s-where,0.02);
	float d1 = line(vec2(-2.,2.68)/s-where,vec2(2.,2.68)/s-where,0.02);
	float d2 = line(vec2(0.,1.8)/s-where,vec2(0.,3.5)/s-where,0.02);
	//float d3 = edge_box(vec2(0.,-0.02)-where,vec2(1.7,1.5)/s-where,0.048)-0.02;
	float d3 = line(vec2(-1.5,0.)/s-where,vec2(-1.5,1.7)/s-where,0.02);
	float d4 = line(vec2(-1.3,1.66)/s-where,vec2(1.3,1.66)/s-where,0.02);
	float d5 = line(vec2(1.5,0.)/s-where,vec2(1.5,1.7)/s-where,0.02);
	float d6 = line(vec2(-1.3,0.24)/s-where,vec2(1.3,0.24)/s-where,0.02);
	d = min(d,d1);
	d = min(d,d2);
	d = min(d,d3);
	d = min(d,d4);
	d = min(d,d5);
	d = min(d,d6);
	return d;
}
//恬
float tian(vec2 where){
	//const vec2 s = vec2(12,8);
	return min(su(vec2(2.,0.)/s-where),she(vec2(-1.4,0.)/s-where));
} 
//-----------------------------------
//纳 6x4
//纟2x4
//const vec2 s = vec2(12,8);
float si(vec2 where){
	float d  = line(vec2(-1.,2.5)/s-where,vec2(0.5,4.)/s-where,0.02);
	float d1 = line(vec2(-1.,2.4)/s-where,vec2(0.47,2.55)/s-where,0.02);
	float d2 = line(vec2(-0.9,1.2)/s-where,vec2(1.06,3.)/s-where,0.02);
	float d3 = line(vec2(-0.9,1.12)/s-where,vec2(1.06,1.3)/s-where,0.02);
	float d4 = line(vec2(-1.,0.)/s-where,vec2(1.,0.4)/s-where,0.02);
	d = min(d,d1);
	d = min(d,d2);
	d = min(d,d3);
	d = min(d,d4);
	return d;
}
//内 4x4
float nei(vec2 where){
	float d  = line(vec2(-1.2,0.)/s-where,vec2(-1.2,3.1)/s-where,0.02);
	float d1 = line(vec2(-1.2,3.1)/s-where,vec2(1.8,3.1)/s-where,0.02);
	float d2 = line(vec2(1.8,3.1)/s-where,vec2(1.8,0.07)/s-where,0.02);
	float d3 = line(vec2(1.7,0.0)/s-where,vec2(1.2,0.05)/s-where,0.02);
	float d4 = line(vec2(0.24,4.)/s-where,vec2(0.15,2.4)/s-where,0.02);
	float d5 = line(vec2(0.1,2.5)/s-where,vec2(-0.6,1.3)/s-where,0.02);
	float d6 = line(vec2(0.2,2.5)/s-where,vec2(1.2,1.4)/s-where,0.02);
	d = min(d,d1);
	d = min(d,d2);
	d = min(d,d3);
	d = min(d,d4);
	d = min(d,d5);
	d = min(d,d6);
	return d;
}
//纳
float na(vec2 where){
	return min(si(vec2(1.,0.)/s-where),nei(vec2(-2.,0.)/s-where));
}

//微 7x4 ss
//彳 2x4
const vec2 ss = vec2(13.4,8); //size
float xing(vec2 where){
	float d  = line(vec2(-1.,3.01) /ss-where,vec2(0.2 ,3.86)/ss-where,0.02);
	float d1 = line(vec2(-1.,1.7)/ss-where,vec2(.4,2.8)/ss-where,0.02);
	float d2 = line(vec2(-0.1,0.)/ss-where,vec2(-0.1,2.35)/ss-where,0.02);
	
	d = min(d,d1);
	d = min(d,d2);
	//d = min(d,d3)
	return d;
}
//山 一 几 3x4
float SYJ(vec2 where){
	float d  = line(vec2(-0.9,2.7)/ss-where,vec2(-0.9,3.46)/ss-where,0.02);
	float d1 = line(vec2(0.,2.7)/ss-where,vec2(0.,3.88)/ss-where,0.02);
	float d2 = line(vec2(0.9,2.7)/ss-where,vec2(0.9,3.46)/ss-where,0.02);
	float d3 = line(vec2(-0.9,2.7)/ss-where,vec2(0.9,2.7)/ss-where,0.02);
	float d4 = line(vec2(-0.97,2.15)/ss-where,vec2(0.72,2.15)/ss-where,0.02);
	float d5 = line(vec2(-0.66,1.6)/ss-where,vec2(0.56,1.6)/ss-where,0.02);
	float d6 = line(vec2(-0.66,1.6)/ss-where,vec2(-0.7,0.8)/ss-where,0.02);
	float d7 = line(vec2(-0.7,.8)/ss-where,vec2(-1.,0.3)/ss-where,0.0206);
	float d8 = line(vec2(0.56,1.6)/ss-where,vec2(0.56,0.7)/ss-where,0.02);
	float d9 = line(vec2(0.56,0.58)/ss-where,vec2(1.2,1.)/ss-where,0.02);
	
	
	d = min(d,d1);
	d = min(d,d2);
	d = min(d,d3);
	d = min(d,d4);
	d = min(d,d5);
	d = min(d,d6);
	d = min(d,d7);
	d = min(d,d8);
	d = min(d,d9);
	
	
	return d;
}
//攵 4x4
float mei(vec2 where){
	float d  = line(vec2(-0.6,2.20)/ss-where,vec2(0.4,3.88)/ss-where,0.02);
	float d1 = line(vec2(0.,3.)/ss-where,vec2(2.28,3.)/ss-where,0.02);
	float d2 = line(vec2(1.2,3.)/ss-where,vec2(1.08,2.)/ss-where,0.02);
	float d3 = line(vec2(1.08,2.)/ss-where,vec2(0.5,1.1)/ss-where,0.02);
	float d4 = line(vec2(0.5,1.1)/ss-where,vec2(-1.1,0.)/ss-where,0.02);
	float d5 = line(vec2(-0.1,2.)/ss-where,vec2(.3,1.)/ss-where,0.02);
	float d6 = line(vec2(0.3,1.)/ss-where,vec2(1.,0.5)/ss-where,0.02);
	float d7 = line(vec2(01.,0.5)/ss-where,vec2(2.,0.)/ss-where,0.02);
	
	d = min(d,d1);
	d = min(d,d2);
	d = min(d,d3);
	d = min(d,d4);
	d = min(d,d5);
	d = min(d,d6);
	d = min(d,d7);
	
	return d;
}
//微
float wei(vec2 where){
	return min(xing(vec2(1.8,0.)/ss-where),min(SYJ(vec2(0.)/ss-where),mei(vec2(-2.,0.)/ss-where)));
}
//------------------------------------
//晰  7x4 ss
//日 2x4
float ri(vec2 where){
	float d  = line(vec2(-1.,0.2)/ss-where,vec2(-1.,3.77)/ss-where,0.02);
	float d1 = line(vec2(-1.,3.67)/ss-where,vec2(0.6,3.67)/ss-where,0.02);
	float d2 = line(vec2(0.6,3.77)/ss-where,vec2(0.6,0.5)/ss-where,0.02);
	float d3 = line(vec2(-1.,2.25)/ss-where,vec2(0.6,2.25)/ss-where,0.02);
	float d4 = line(vec2(-1.,0.8)/ss-where,vec2(0.6,0.8)/ss-where,0.02);
	
	d = min(d,d1);
	d = min(d,d2);
	d = min(d,d3);
	d = min(d,d4);

	return d;
}
//木 2x4
float mu(vec2 where){
	float d  = line(vec2(-0.88,2.88)/ss-where,vec2(1.,2.88)/ss-where,0.02);
	float d1 = line(vec2(0.,4.)/ss-where,vec2(0.,0.)/ss-where,0.02);
	float d2 = line(vec2(-0.88,1.1)/ss-where,vec2(0.,2.7)/ss-where,0.02);
	float d3 = line(vec2(0.56,2.1)/ss-where,vec2(1.1,1.58)/ss-where,0.02);
	
	d = min(d,d1);
	d = min(d,d2);
	d = min(d,d3);
	
	return d;
}
//斤 4x4 
float jing(vec2 where){
	float d  = line(vec2(-0.1,3.5)/ss-where,vec2(-0.1,2.0)/ss-where,0.02);
	float d1 = line(vec2(-0.1,2.0)/ss-where,vec2(-0.38,1.0)/ss-where,0.02);
	float d2 = line(vec2(-0.38,1.)/ss-where,vec2(-1.0,0.086)/ss-where,0.02);
	float d3 = line(vec2(-0.12,3.5)/ss-where,vec2(1.88,3.86)/ss-where,0.02);
	float d4 = line(vec2(0.,2.6)/ss-where,vec2(2.,2.6)/ss-where,0.02);
	float d5 = line(vec2(1.1,2.5)/ss-where,vec2(1.1,0.)/ss-where,0.02);
	
	d = min(d,d1);
	d = min(d,d2);
	d = min(d,d3);
	d = min(d,d4);
	d = min(d,d5);
	
	return d;
}
//晰	mu vec2(0.)
float xi(vec2 where){
	return min(ri(vec2(2.,0.)/ss-where),min(mu(vec2(0.)/ss-where),jing(vec2(-2.,0.)/ss-where)));
}
//------------------------------------
//恬纳微晰 function
float TNWX(vec2 where){
	float Tian = tian(vec2(0.)-where);
	float Na   = na(vec2(0.5,0.)-where);
	float Wei  = wei(vec2(1.08,0.)-where);
	float Xi   = xi(vec2(1.68,0.)-where);
	
	return min(min(Tian,Na),min(Wei,Xi));
}
//------------------------------------
#define PI 3.141592653
#define time iGlobalTime
float rand(){
    float Dot = dot(uv+vec2(sin(time),0), vec2(12.9898, 78.233));
	return fract(sin(mod(Dot, PI / 2.0)) * 43758.5453);
}
bool inside(float d){
	return d < 0.;
}
bool font_effect_inside(float d,float r){
	return abs(d)<r;
}
bool font_super_inside(float d,float r1,float r2,float r3){
    //e.g
    //abs(abs(abs(d)-0.01)-0.006)-0.0026
	return abs(abs(abs(d)-r1)-r2)-r3 < 0.;
}
vec3 color_effect(vec2 u){
	return vec3(sin(1.-u/iResolution.xy+time),sin(time))/1.2+.3;
}
void mainImage( out vec4 o, in vec2 u)
{
	uv = (u+u-iResolution.xy) / iResolution.y;
    float d = TNWX(vec2(0.86,0.2));
    vec3 c = vec3(0.);
    if(font_effect_inside(d,0.01)/*font_super_inside(d,0.01,0.006,0.0026)*/){
    	c = vec3(0.4,0.6,0.5)*color_effect(u)/1.1;
        //c = pow(c,vec3(.7));
    }
    else {
    	c.rgb = vec3(1.-length(uv)/2.4);
        c.rgb *= vec3(0.6,0.7,0.5)*1.7;
        c.rgb = pow(c.rgb,vec3(1./2.2))/2.6;
    }
	o = vec4(c,1.);
    o = mix(o,vec4(rand()/4.),0.4)*1.6;
    //o += texture2D(iChannel0,u/iResolution.xy);
}