// Shader downloaded from https://www.shadertoy.com/view/XstSDj
// written by shadertoy user eiffie
//
// Name: Music no ifs
// Description: Just trying to make something that sounds like music without any if statements.
#define PI 3.14159
#define bps 6.0
float nofs(float n){//the song's "random" ring
    return floor(sin(mod(n,8.0)*4.0)*5.0);
}

float scale(float note){//throws out dissonant tones
   float n2=mod(note,12.0);
   //n2=mod(n2,5.0);n2=mod(n2,3.0);n2=mod(n2,2.0);return note*step(0.5,n2);//minor
   n2=mod(n2,5.0);n2=mod(n2,2.0);return note*step(0.5,n2);//blues
   //if((n2==1.0)||(n2==3.0)||(n2==6.0)||(n2==8.0)||(n2==10.0))note=-100.0;//major
   //if((n2==1.0)||(n2==4.0)||(n2==6.0)||(n2==9.0)||(n2==11.0))note=-100.0;//minor
   //return note;
}
// note number to frequency  from https://www.shadertoy.com/view/ldfSW2
float ntof(float n){return (n>0.0)?440.0 * pow(2.0, (n - 67.0) / 12.0):0.0;}

float Saw(float t,float s){s*=0.5;return smoothstep(0.0,s,fract(t))*smoothstep(1.0,s,fract(t))*2.0-1.0;}
float Sin(float t){return sin(t*PI);}
float Square(float t,float s){s*=0.25;return smoothstep(0.25-s,0.25+s,fract(t))*smoothstep(0.75+s,0.75-s,fract(t))*2.0-1.0;}
float Env(float t,float s){s*=0.5;return smoothstep(0.0,s,t)*smoothstep(1.0,s,t);}
float Env(float t,float s,float e){return smoothstep(0.0,s,t)*smoothstep(e,s,t);}
float rand(float t){return fract(sin(mod(t,4321.123)*4321.123)*4321.123);}
float noise(float t){float f=fract(t);t=floor(t);return mix(rand(t),rand(t+1.0),f);}
float snoise(float t){float f=fract(t);t=floor(t);return mix(rand(t),rand(t+1.0),f*f*(3.0-2.0*f));}
float drive(float a, float d){return a*d/(1.0+abs(a*d));}
float spow(float a, float p){return sign(a)*pow(abs(a),p);}

#define TAU 6.283185
#define wav cosine
vec2 cosine(vec2 t){return cos(TAU*t);}

float I(float tf, float c, float s){// taken from jnorberg https://www.shadertoy.com/view/lt2GRy
   float wf=c*24.0;//# of harmonics to simulate, s is smoothing
   vec2 w=vec2(0.125,1.125)+vec2(floor(wf));w*=2.0;
   float p=fract(tf),sw=1.0-2.0*p,ip=1.0-p;
   vec2 sinc=-wav(w*p)/(1.0+s*p)+wav(w*ip)/(1.0+s*ip);
   return (sw+mix(sinc.x,sinc.y,fract(wf)))*0.5;
}
float hihat(float t, float o, float n){
   float bt=fract(fract(t-o));
   return Env(bt*2.0,0.1)*n*(1.0-fract(t*0.5));
}
float tamb(float t, float o, float n){
   float bt=fract(fract(t-o)*1.5);
   float f=t*3500.0+bt*75.0*n-noise(bt*75.0*(1.0-0.9*bt))*7.0;
   float a2=Square(f,bt);
   return a2*Env(bt*(2.0+2.0*n),0.01)*Sin(1.0/(0.02+2.0*bt*bt));
}
float flute(float bt,float t,float f){
   float e=Env(bt,0.1,0.5),m=(1.0-e)*sin(t*40.0)*0.08;
   return Env(bt,0.4)*(snoise(t*1000.0)*e*0.15+m+0.5)*Square(t*f+m,0.3+bt*0.5);
}
float strings(float bt,float t,float f){
   float e=Env(bt,0.1,0.5),m=(1.0-e)*sin(t*50.0)*0.0001*f;
   return Env(bt,0.5)*(m+0.5)*I(t*f+m,0.1-bt*0.2,0.9);
}
float drum(float t, float o, float b, float f, float fd){
   float bt=fract(fract(t-o)*b),n=snoise(bt*f*(1.0-bt));
   return Env(bt*fd,0.1)*(n*sin(exp(-bt * 100.0) * 60.0));
}
float sound(float time){
   float tim=time*bps;
   float b=floor(tim);
   float n=nofs(b*0.0078125),n0=n+nofs(b*0.0625),n1=n0+nofs(b*0.25),n2=n1+nofs(b);
   float bt=fract(tim);
   n0=scale(n0+32.0);if(n0<1.0)n0=scale(nofs(b*0.0625)+33.0);//keep base going
   float a=strings(fract(tim*0.25),time,ntof(n0));
   a=spow(a,0.25+fract(tim*0.5))*48.0/max(1.0,n0);
   float vol=0.5/max(0.25*n1,1.0);
   a+=strings(fract(tim*0.5),time,ntof(scale(n1+72.0)))*vol;
   a+=strings(fract(tim*0.5),time,ntof(scale(n1+75.0)))*vol;
   a+=strings(fract(tim*0.5),time,ntof(scale(n1+79.0)))*vol;
   a+=flute(fract(tim),time,ntof(scale(n2+60.0)))*0.8;
   a+=hihat(tim,0.125,rand(mod(time,10.0)))*0.5;
   a+=drum(tim*0.125,0.5,1.5,8000.0,4.0);
   a+=drum(tim*0.125,0.0,1.125,500.0,6.0)*0.75;
   a=clamp(a*0.25,-1.0,1.0);
   return a;
}
vec2 mainSound(float time){
   vec2 v=vec2(sound(time));
   return v;
}
#define iSampleRate 44100.
void mainImage(out vec4 fragColor, in vec2 fragCoord){
   float tym=2.0*(fragCoord.x+fragCoord.y*iResolution.x)/iSampleRate;
   if(abs(tym-iGlobalTime)<0.01){fragColor=vec4(1.0,0.0,0.0,1.0);return;}
   fragColor=vec4(mainSound(tym)*0.5+0.5,0.0,1.0);//mainSound(tym+1.0/iSampleRate)*0.5+0.5);
}