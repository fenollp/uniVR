// Shader downloaded from https://www.shadertoy.com/view/MdlXDr
// written by shadertoy user FabriceNeyret2
//
// Name: spiral illusion
// Description: Only big circles of small squares here !
//    mouse.x tunes rotation.   mouse.y tunes squares size. 2: toggles 1 every 2 circles.
//    C:  toggles alternate B/W.   E: toggles empty square.   I: toggles inverse rotation at every circle.
// some examples here : http://www.psy.ritsumei.ac.jp/~akitaoka/uzu8e.html

#define N 36. 		 // squares on a circle
#define TEST 4		 // pattern

float  R1=.7;        // square side relative to its cell.
#define R2 (R1-.2)   // optionnal internal circle

#define PI 3.1415927
float  t=iGlobalTime;

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.*(fragCoord.xy / iResolution.y - vec2(.85,.5));
	float v,c, da, s;
	if (iMouse.z<=0.) {
		da = t;
		R1 = .6+.45*sin(t/10.);
		s = (mod(t/(10.*2.*PI),2.)<1.) ? .5 : 1.;  
	} else {
		da = 2.*PI*iMouse.x/iResolution.x;
		R1 = iMouse.y/iResolution.y;
		s = (!keyToggle(50)) ? .5 : 1.;  	   // '2':  toggles 1 every 2 circles.
	}
	
	float r = length(uv), a = atan(uv.y,uv.x); // to polar
		
	// cells in polar
	r = 3.+log(r)*s*N/6. +.5; // r*N+.5;
	a = N*a/(2.*PI)+.5;
	float ix = floor(r),
		  iy = floor(a),
	      x = 2.*(fract(a)-.5),             // -1..1
	      y = 2./s*(fract(r)-.5);  			// -1..1

	r = sqrt(x*x+y*y); a = atan(y,x); // to local polar
#if TEST>= 3						  // rotate local cell
	if (!keyToggle(64+9)&&(mod(ix,2.)<1.)) da = -da;   // 'I':  toggles inverse rotation at every circle.
	x = r*cos(a+da); y = r*sin(a+da);
	v = max(abs(x),abs(y));
#endif
	
	
#if TEST==0
	c = max(abs(x),abs(y));
#elif TEST==1
	c = cos(PI*y)*cos(PI*x);
	
#elif TEST==2
	c = max(abs(x),abs(y)); c = sin(2.*PI*6.*c);

#elif TEST==3 // rotating patterns
	v = 2.*PI*6.*v;
#  if 0
	c = sin(v);
#  else
	vec2 dF=vec2(dFdx(v),dFdy(v)); float d = length(dF); c = -(cos(v+d/2.)-cos(v-d/2.))/d;
#  endif
	
#elif TEST==4 // rotating squares
	c = smoothstep(R1,R1-.1,v);
	if (keyToggle(64+5)) c -= smoothstep(R2,R2-.1,v);
	if ((!keyToggle(64+3)) && (mod(ix+iy,2.)<1.)) c = -c;
	c += .5;
#endif
	fragColor = vec4(c);
}