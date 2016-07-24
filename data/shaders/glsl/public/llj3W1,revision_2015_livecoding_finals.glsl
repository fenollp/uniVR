// Shader downloaded from https://www.shadertoy.com/view/llj3W1
// written by shadertoy user mu6k
//
// Name: Revision 2015 Livecoding Finals
// Description: Written under 25 minutes at Revision 2015 live-coding finals. I tried to adapt it by making as less modifications as possible. Put some music into iChannel0.
//original at: ftp://ftp.scene.org/pub/parties/2015/revision15/shadershowdown/03-musk.glsl

#define v2Resolution iResolution.xy
#define texFFTSmoothed iChannel0
#define texFFT iChannel0
#define texNoise iChannel1
#define fGlobalTime iGlobalTime
#define out_color fragColor

float time =  fGlobalTime;


float bt = texture2D(texFFTSmoothed, vec2(.01,.0)).x*.2;

vec3 arep(vec3 p, float r)
{
  float a= atan(p.y,p.x);
  float l = length(p.xy);
  a = mod(a+r*.5,r)-r*.5;
  p.xy = vec2(cos(a),sin(a))*l;
  return p;
}

float b2(vec3 p, vec3 b)
{
  
  return length(max(abs(p)-b,.0));
}

float box(vec3 p, vec3 b)
{
  vec3 q = arep(p,.5*355.0/113.0);
  p = arep(p,.25*355.0/113.0);
  return min(max(max(p.x-1.0,
  max(p.x-1.0+p.z*.3,
  max(p.x-1.3+p.z*.5,
  max(p.x-1.6-p.z*.3,p.x-2.5-p.z*.8)))),-2.5-p.z),length(max(abs(p)-vec3(.1,0.1,.1),.0)));
}

float df(vec3 p)
{
  
  //return length(p)-1.0;
  return min(box(p, vec3(.5,.5,.5)),p.y+8.0+texture2D(texNoise,(p.zx+vec2(time*64.0,.0))*.0004).x*2.0
+texture2D(texNoise,(p.zx+vec2(time*64.0,.0))*.0004).x*64.0*bt);
}

vec3 nf(vec3 p)
{
  vec2 e = vec2(.0,.1);
  float c= df(p);
  return normalize(vec3(c+df(p+e.yxx),c+df(p+e.xyx),c+df(p+e.xxy)));
}

vec4 plas( vec2 v, float time )
{
  float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  float a=time*.7, cs=cos(a), ss=sin(a);
  mat3 r0 = mat3(cs,ss,0,-ss,cs,0,0,0,1);

  a=sin(time*.6), cs=cos(a), ss=sin(a);
  mat3 r1 = mat3(cs,0,ss,0,1,0,-ss,0,cs);

  a=time*.4, cs=cos(a), ss=sin(a);
  mat3 r2 = mat3(1,0,0,0,cs,ss,0,-ss,cs);


  vec3 p = vec3(.0,.0,-8.0);
  vec3 dir = normalize(vec3(uv.xy,-length(uv.xy)+0.5));

  p*=r0*r1*r2;
  dir*=r0*r1*r2;

  float tt =.0;

  for (int i=0; i<150; i++)
  {
    float dt = df(p);
  tt += dt;
    p += dir*dt*.5;
    
  }
 
  vec2 m;
  m.x = atan(uv.x / uv.y) / 3.14;
  m.y = 1.0 / length(uv) * .2;
  float d = m.y;

  float f = texture2D( texFFTSmoothed, vec2(d,.0) ).r * 100.0;
  m.x += sin( fGlobalTime ) * 0.1;
  m.y += fGlobalTime * 0.25;

  vec4 t = plas( m * 3.14, fGlobalTime ) / d;
  t = clamp( t, 0.0, 1.0 );
  vec4 c0 = (f + t)*bt*4.0;;

  vec3 col = c0.xyz;
  
  vec3 l = normalize(vec3(1,2,3));

  if (df(p)<.1)
  {
    col = nf(p)*.5+.5;
    col = vec3(dot(nf(p),l)*.5+.5);
  col*=.9;
  }

  if(p.y<-2.1)
  {
    col*=vec3(.2,.5,.2);
  }
  else if (p.z>.75) col*=vec3(.9,.2,.2);

  col = col +  vec3(.2,.4,.6)*tt*.003;

  col += length(col);
  col -=.4;
  out_color = vec4(col,1.0)*(bt+.2)*2.0;

}
