// Shader downloaded from https://www.shadertoy.com/view/Mtj3W1
// written by shadertoy user mu6k
//
// Name: Revision 2015 Livecoding Round 2
// Description: Written under 25 minutes at Revision 2015 live-coding semifinals. I tried to adapt it by making as less modifications as possible. Put some music into iChannel0.
//original at: ftp://ftp.scene.org/pub/parties/2015/revision15/shadershowdown/02a-musk.glsl
//#define LIGHT_REACT_TO_MUSIC

#define v2Resolution iResolution.xy
#define texFFTSmoothed iChannel0
#define texFFT iChannel0
#define fGlobalTime iGlobalTime
#define out_color fragColor

#define bt (texture2D(texFFTSmoothed, vec2(.01,.0)).x*1.0)

#define time fGlobalTime

//layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

float rbox(vec3 p, vec3 b, float r)
{
  return length(max(abs(p)-b,.0))-r;
}

vec4 plas( vec2 v, float time )
{
  float c = 0.5 + sin( v.x * 10.0 ) + cos( sin( time + v.y ) * 20.0 );
  return vec4( sin(c * 0.2 + cos(time)), c * 0.15, cos( c * 0.1 + time / .4 ) * .25, 1.0 );
}

float dft(vec3 p)
{
  
  float a=time,cs=cos(a),ss=sin(a);
  mat3 r0 = mat3(cs,ss,0,-ss,cs,0,0,0,1);


  a=time,cs=cos(a),ss=sin(a);
  mat3 r1 = mat3(cs,0,ss,0,1,0,-ss,0,cs);

  p*=r0*r1;

  p*=(1.0+bt*.1);
  vec3 q = p;
  p.x = abs(p.x)-.6;
  p.x = abs(p.x)-.6;
  //return rbox(q,vec3(.5),.1);
  return min(rbox(p,vec3(.5),.1),rbox(q+vec3(0,1.2,0),vec3(.5),.1));
  return length(p)-1.0-bt*.1;
}

vec3 nft(vec3 p)
{
  vec2 e = vec2(.0,.001);
  float d= dft(p);
  return normalize(vec3(d+dft(p+e.yxx), d+dft(p+e.xyx), d+dft(p+e.xxy)));
}

float dfb(vec3 p)
{
  float d =1000.0;
  p.x+=time*16.0;
  p = mod(p+8.0,vec3(16.0))-8.0;
  d = min(d, -(length(p)-9.1));
 
  p = mod(p+4.0,vec3(8.0))-4.0;
  d = max(d,
 -(length(p)-5.1)+sin(time)*.1);
  return d;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = vec2(gl_FragCoord.x / v2Resolution.x, gl_FragCoord.y / v2Resolution.y);
  uv -= 0.5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);

  vec2 m;
  m.x = atan(uv.x / uv.y) / 3.14;
  m.y = 1.0 / length(uv) * .2;
  float d = m.y;

  float a=time*.6,cs=cos(a),ss=sin(a);
  mat3 r0 = mat3(cs,ss,0,-ss,cs,0,0,0,1);


  a=time*.4,cs=cos(a),ss=sin(a);
  mat3 r1 = mat3(cs,0,ss,0,1,0,-ss,0,cs);


  vec3 p = vec3(.0,.0,-8.0);
  vec3 dir = normalize(vec3(uv,1.0));

  p*=r0*r1;
  dir*=r0*r1;
  float i=0.0;

  float td = 0.0;

  for (int i=0; i<50; i++)
  {
    float d = min(dft(p),dfb(p));
    td +=d;
    p+=dir*d; 
  }

  vec3 l = normalize(vec3(1,2,3));
  vec3 col = (vec3(dft(p+l*.1)*2.5+.5));

  if (dft(p)>dfb(p)){
    col = vec3(i*.04)*.0;
    col = (vec3(dfb(p+l*.1)*2.5+.5));
    col *=4.0;
    col *= mix(vec3(.3,.4,.9),vec3(.2,.4,.7), (uv.x-.5)*.5);
  }
  else
  {
    col*=vec3(9.0,3.0,1.0);
    //col *= bt*vec3(.5,4.0,.5);
  }
  
  col /= td;

  col += length(col)*.5;
  col -= length(uv)*.5;

  float f = texture2D( texFFTSmoothed, vec2((uv.x-.5)*.5,.0) ).r * 5.0;
  m.x += sin( fGlobalTime ) * 0.1;
  m.y += fGlobalTime * 0.25;

  vec4 t = plas( m * 3.14, fGlobalTime ) / d;
  t = clamp( t, 0.0, 1.0 );

  
  out_color = vec4(col,1.0)+f*.1;
}
