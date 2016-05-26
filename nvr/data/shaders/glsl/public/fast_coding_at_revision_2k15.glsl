// Shader downloaded from https://www.shadertoy.com/view/lt2GDh
// written by shadertoy user XT95
//
// Name: Fast coding at Revision 2k15
// Description: My first entry at Shadershowdown competition, Revision 2015.
//    I really enjoyed this compo, I will participate next year for sure ! But i will learn english before.. ;)
//    Thank you to organizers and all participants!
float rubban( vec3 p)
{
  return length( p.xy+vec2(cos(p.z),sin(p.z)) ) - .1;
}

float rubban1( vec3 p)
{
  return length( p.xy+vec2(cos(p.z+2.),sin(p.z+2.)) ) - .1;
}

float rubban2( vec3 p)
{
  return length( p.xy+vec2(cos(p.z+4.),sin(p.z+4.)) ) - .1;
}

float map( in vec3 p)
{
  float d = p.y+1.;
  d = min(d, -p.y+2.);
  d = min(d, cos(p.x)+cos(p.y)+cos(p.z)+cos(p.y*20.)*texture2D(iChannel0,vec2(0.05,0.)).r*.1);
  p.x += 3.;
  p.x = mod(p.x, 6.)-3.;
  d = min(d, rubban(p));
  d = min(d, rubban1(p));
  d = min(d, rubban2(p));
  d = max(d, p.z-iGlobalTime*3.-6.);
  return d;
}

vec2 rotate( vec2 v, float a)
{
  return vec2( v.y*cos(a) - v.x*sin(a), v.x*cos(a) + v.y*sin(a));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = vec2(fragCoord.x / iResolution.x, fragCoord.y / iResolution.y);
  uv -= 0.5;
  uv /= vec2(iResolution.y / iResolution.x, 1);
  vec2 uv2 = uv;
  uv.x += texture2D(iChannel0, vec2(uv.y*.5+.5,0.)).r*.05;
  vec3 col = vec3(0.);

  vec3 org = vec3(cos(iGlobalTime*10.)*texture2D(iChannel0,vec2(0.1,0.)).r*.2, cos(iGlobalTime*20.)*texture2D(iChannel0,vec2(0.1,0.)).r*.2,iGlobalTime*3.);
  vec3 dir = normalize(vec3(uv, 1.-length(uv)*1.));
  dir.xy = rotate(dir.xy, iGlobalTime*.25);
  dir.xz = rotate(dir.xz, iGlobalTime*.1);
  vec4 p =vec4(org,0.);

  for(int i=0; i<128; i++)
  {
    float d = map(p.xyz);
    p += vec4( dir*d, 1./64.);
    if(d<0.01)
      break;
  }

  col += vec3(.1,.1,1.0)*p.w *p.w;

  p.x += 3.;
  p.x = mod(p.x, 6.)-3.;
  float coef = 0.;
  for(float i=0.; i<.02; i+=1./100.)
  {
    coef += texture2D( iChannel0, vec2(i,0.0)).r;
  }
  col += vec3(1.,.3,.0) / (.1 + pow( rubban(p.xyz), 2.) ) * coef*.01;

  coef = 0.;
  for(float i=.1; i<.25; i+=1./100.)
  {
    coef += texture2D( iChannel0, vec2(i,0.)).r;
  }
  col += vec3(.1,1.,.1) / (.1 + pow( rubban1(p.xyz), 2.) ) * coef*.01;

  coef = 0.;
  for(float i=.25; i<.5; i+=1./100.)
  {
    coef += texture2D( iChannel0, vec2(i,0.)).r;
  }
  col += vec3(.5,.1,1.) / (.1 + pow( rubban2(p.xyz), 2.) ) * coef*.01;
  
  col *= vec3(3.);

  col = pow(col, vec3(1.2));
  //col += texture(texFFT, length(uv)).rgb*100;
  //col = mix( col.rgb, col.bgr, texture2D(iChannel0, vec2(uv.y*.5+.5,0.)).r*1.);
  
  col *= exp(-length(p.xyz-org)*.25);

  uv = uv2;
  uv.y -= texture2D(iChannel0, vec2(0.05,0.)).r*.2;
  uv += vec2(.6,.25);
  if( uv.x < .2 && uv.x > -.2 && uv.y < -abs(uv.x) && uv.y > -.2 && !( uv.x < .1 && uv.x > -.1 && uv.y+.2 > abs(uv.x) && uv.y < -.1 ))
    col = vec3(1.,.8,.2);


  fragColor = vec4(col,1.);
}
