// Shader downloaded from https://www.shadertoy.com/view/lstXzs
// written by shadertoy user cornusammonis
//
// Name: Parallel Reduction
// Description: Counts the number of red pixels on screen using parallel reduction. Draw with the mouse to add pixels.
/*
	Parallel Reduction

	Buffers A, B, and C count the number of red pixels in Buffer D by parallel reduction.
	Works up to a resolution of 4096x4096. The default brush size, 1 pixel, can be 
    changed in Buffer D.
*/



/* 
	Begin 7-seg display code by Andrew Wild
	See: https://www.shadertoy.com/view/MdtSzs
*/

// Created by Andrew Wild - akohdr/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define BLK vec4(.0,.0,.0,1.)
#define WHT vec4(1.,1.,1.,1.)

// tweaked 7 seg decoder originally from dr2 @ https://www.shadertoy.com/view/MddXRl
#define HSEG(a,b,c) (1.-smoothstep(a,b,abs(c)))
#define SEG(q) HSEG(.13,.17,q.x)*HSEG(.5,.57,q.y)
#define CHK b=a/2;if(b*2!=a)d+= 
float Seg7(vec2 q, int v)
{
  float d;
  int a, b;
  const vec2 vp = vec2 (.5,.5), 
             vm = vec2 (-.5,.5), 
             vo = vec2 (1,0);
  if (v < 5) {
    if (v == -1) a = 8;
    else if (v == 0) a = 119;
    else if (v == 1) a = 36;
    else if (v == 2) a = 93;
    else if (v == 3) a = 109;
    else a = 46;
  } else {
    if (v == 5) a = 107;
    else if (v == 6) a = 123;
    else if (v == 7) a = 37;
    else if (v == 8) a = 127;
    else a = 111;
  }
  q = (q-.5) * vec2(1.7,2.3);
  d = 0.; CHK SEG(vec2(q.yx - vo));
  a = b;  CHK SEG(vec2(q.xy - vp));
  a = b;  CHK SEG(vec2(q.xy - vm));
  a = b;  CHK SEG(vec2(q.yx));
  a = b;  CHK SEG(vec2(q.xy + vm));
  a = b;  CHK SEG(vec2(q.xy + vp));
  a = b;  CHK SEG(vec2(q.yx + vo));
  return d;
}

int decDigit(lowp float v, int i) {
    float f = float(i), 
          p1 = pow(10.,f-1.);
    return int((mod(v,pow(10.,f))-mod(v,p1))/p1);
}

vec4 drawDigits(vec2 fragCoord, float count)
{
	vec2 uv = fragCoord.xy / iResolution.xy,
         left = vec2(-1,0),
         home=24.*(fragCoord*vec2(-1,1))/iResolution.xy;
    
    vec4 col = vec4(0);
    
#define DIGITS(l) for(int i=1;i<=l;i++){xy+=left;col+=vec4(Seg7(xy,decDigit(v,i) ));}
    
    float v = count; 
    vec2 xy = home + vec2(12.,-20);
    DIGITS(8);
    
    return col;

}

/* 
	End 7-seg display code by Andrew Wild
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float count = texture2D(iChannel0, vec2(0.0)).w;
    float brush = texture2D(iChannel1, uv).x;
    fragColor = vec4(brush, 0.0, 0.0, 0.0) + drawDigits(fragCoord, count);
}