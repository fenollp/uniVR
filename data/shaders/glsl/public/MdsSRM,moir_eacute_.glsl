// Shader downloaded from https://www.shadertoy.com/view/MdsSRM
// written by shadertoy user FabriceNeyret2
//
// Name: Moir&eacute;
// Description: A: anti aliasing       C: toggles colors                  M: draw mode = max vs sum
//    mouse: translate.   Z: mouse.y zoom instead.     S: mouse.x tunes wires step instead.

#define PI 3.14159265359
float t = 10.*iGlobalTime;

bool COMB;
bool ANTI_A;
float STEP;

float zoom;

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

float fwidth2(float k) { vec2 dk = vec2(dFdx(k),dFdy(k)); return length(dk); }

float Icos(float k, float S) { // cos with or without antialiasing
	float dk = 1.;
	if (ANTI_A) { // antialiasing: return 1/dk . int( cos(k), k= -dk/2..dk/2 )
		dk = fwidth(k);
		if (dk>0.) dk = 2.*sin(dk/2.)/dk ;
		dk *= 1./S; // *zoom; // scaling should not change intensity
	}
	return cos(k)*dk;
	
}
float rosace(float s, float z, float L, float S, float T, bool clip) { 
	s = S*(s-T); z = S*(z-T); // translation and scaling
	if (clip && ( (z<=0.) || (z>L) || (s-z<0.) || (s-z>L) )) return 0.;
	// canonical:  s = x+y,  z = x
	// <x,y> - <0,k> = <k,L> - <0,k> 
	// => x.(L-k)=k.(y-k) => k2 -k.s + zL = 0 => D = s2-4zL
	float d = 1.-4.*z*L/(s*s); if (d<0.) return 0.;

	d = sqrt(d);
	float k1 = s*(1.+d)/2., k2 = s*(1.-d)/2.;
	
#if 1
	float s1 = Icos(PI*k1/STEP,S) , s2 = Icos(PI*k2/STEP,S);
#else
	float s1 = (clip && ( (k1<0.)||(k1>L) )) ? 0. : Icos(PI*k1/STEP,S),
		  s2 = (clip && ( (k2<0.)||(k2>L) )) ? 0. : Icos(PI*k2/STEP,S);	
#endif

	return .5+.5* ( (COMB) ? max(s1,s2) : (s1+s2) );
}

vec2 tile1(vec2 uv, float L, float S) {
	S=1.;
	float r,g, s = uv.x+uv.y, S2=S*2.,T=L/2.;
	r   = rosace(s, uv.x,  L,S,0., true)   + rosace(s, uv.y,  L,S,0., true);
	r  += rosace(s, uv.x,  L,S2,T, true) + rosace(s, uv.y,  L,S2,T, true);
	
	uv.x = L-uv.x; s = uv.x+uv.y;
	g  = rosace(s, uv.x,  L,S,0., true)   + rosace(s, uv.y,  L,S,0., true);
	g += rosace(s, uv.x,  L,S2,T, true) + rosace(s, uv.y,  L,S2,T, true);

	return vec2(r,g);
}

vec2 tile2(vec2 uv, float L, float S) {
	S=1.;
	float r,g, s = uv.x+uv.y, S2=S*2.,T=L/2.;
	r  = rosace(s, uv.x,  L,S2,T, true) + rosace(s, uv.y,  L,S2,T, true);
	r += rosace(s, mod(uv.x+L/2.,L),  L,S2,T, true) + rosace(s, mod(uv.y+L/2.,L),  L,S2,T, true);

	uv.x = L-uv.x; s = uv.x+uv.y;
	g  = rosace(s, uv.x,  L,S2,T, true) + rosace(s, uv.y,  L,S2,T, true);
	g += rosace(s, mod(uv.x+L/2.,L),  L,S2,T, true) + rosace(s, mod(uv.y+L/2.,L),  L,S2,T, true);

	return vec2(r,g);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float L = iResolution.y;
	vec2 uv = fragCoord.xy-.5-iResolution.xy/2.;
	vec2 trans = vec2(0.);
	
	// --- tuning
	
	vec4 mouse = abs((iMouse-.5)/iResolution.y);
	if (iMouse.z<=0.) {
		zoom = 1.+10.*(1.-cos(.02*t))/2.;
		STEP = 1.+50.*(1.-cos(.1*t))/2.;
		ANTI_A = true;
		COMB = ( mod(.02*t/(2.*PI),1.) > .5 );  
		trans = .5+iResolution.xy/2.*(1.+vec2(cos(.02*t),sin(.03*t))/(1.+zoom));
	}
	else
	{
		ANTI_A = !keyToggle(65);
		COMB   = (! keyToggle(64+13)); // 'M'
	
		trans = iMouse.xy;
		if (!keyToggle(64+26)) { zoom=mouse.y*10.; trans.y=iMouse.w; } 
		else 					 zoom = mouse.w*10.;
		if (keyToggle(64+19)) { STEP = mouse.x*100.; trans.x=abs(iMouse.z); }
		else				    STEP = 4.; // mouse.z*100.;
	}
	
	uv -= 10.*(trans-.5-iResolution.xy/2.);
	uv *= zoom;
	
	// --- display 
	
	vec3 col = vec3(0.); 
	col.rg = tile1(mod(uv,L),L,zoom);

	fragColor = (!keyToggle(67)) ? vec4(col.r+col.g) : vec4(col.r,col.g,0.,1.);
}