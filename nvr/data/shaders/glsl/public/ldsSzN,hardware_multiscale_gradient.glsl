// Shader downloaded from https://www.shadertoy.com/view/ldsSzN
// written by shadertoy user FabriceNeyret2
//
// Name: Hardware multiscale gradient
// Description: cheap texture gradiant using hardware derivative at each MIPmap level.
//    mouse = parameter tuning. No mouse -&gt; auto-demo.
//    C: add the ultra-lowres image
//    M: uses module(grad) instead
//    SPACE: show base texture
//    G: shows grad at MIPmap level = mouse.x

#define PI 3.14159265359

bool keyToggle(int ascii) 
{	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.); }


// texture, texture gradient and module of gradient

int TEX=0;
vec3 txt(vec2 uv, float n) { 
	uv = vec2(0.,1.)-uv;
	return (TEX==0) ? texture2D(iChannel0,uv,n).rgb
					: texture2D(iChannel1,uv,n).rgb;
}

vec3 txtFs(vec2 uv, vec2 dir, float n) { 
	vec3 t = txt(uv,n); 
	return ( dFdx(t)*dir.x + dFdy(t)*dir.y)  * pow(2.,n); // dx = 2^N / 2^n
}

vec3 txtF(vec2 uv, float n) { 
	return fwidth(txt(uv,n)) * pow(2.,n);  // dx = 2^N / 2^n
}



float showFlag(vec2 p, vec2 uv, float v) {
	float d = length(2.*(uv-p)*iResolution.xy/iResolution.y);
	return 	1.-step(.06*v,d) + smoothstep(0.005,0.,abs(d-.06));
}

float showFlag(vec2 p, vec2 uv, bool flag) {
	return showFlag(p, uv, (flag) ? 1.: 0.);
}

// ---

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	bool auto = (iMouse.z<=0.); // no-mouse : auto-demo
	
	vec2 uv = fragCoord.xy/iResolution.xy;
	vec2 dir; float n,k; vec3 v;

	// --- tunning
	
	bool MOD, TXT, GRAD, COL;
	
	if (!auto) {
		TXT = keyToggle(32);
		COL = keyToggle(67);
		GRAD = keyToggle(71);
		MOD = keyToggle(77);

		vec2 mouse = iMouse.xy/iResolution.xy;
		n = 9.*mouse.x;
		k = 2.*(mouse.x-.5);
		dir = 2.*(mouse-.5);
		dir = normalize(dir);
	} 
	else 
	{
		float t = iGlobalTime/3.;
		
		// set TXT or GRAD or MOD or MOD+COL or (!MOD) or (!MOD)+COL.	
		float t0 = mod(t,10.); int i = int(t0); 
		TXT  = (i==0);
		GRAD = (i==1)||(i==2);
		COL  = (i==3)||(i==4)||(i==7)||(i==8);
     // (!MOD) = (i==5)||(i==6)
		MOD  = (i==7)||(i==8)||(i==9);
		// set each flag then change texture
		TEX = int(mod(t/10.,2.)); 
		
		// varies tuning within each mode
		dir = .5*vec2(cos(3.*t)*(1.+cos(t))/2., sin(3.3*t)*(1.+cos(.7*t))/2.);
		t = PI*mod(t0+1.,2.); // 0..2PI
		n = 7.*(1.-cos(t))/2.;
		k = cos(t);	
	}
	
	float panel = showFlag(vec2(.25,.05),uv, bool(TEX))
				+ showFlag(vec2(.35,.05),uv, TXT)
				+ showFlag(vec2(.45,.05),uv, GRAD)
				+ showFlag(vec2(.55,.05),uv, MOD)
				+ showFlag(vec2(.65,.05),uv, !(MOD||TXT||GRAD))
				+ showFlag(vec2(.75,.05),uv, COL);
		
	
	// --- display
	
	if (TXT) // show base texture instead
		v = txt(uv,0.*floor(n));
	
	else if (GRAD) { // show gradient of MIPmap level n instead ( blue = frac(level) )
		v = txtF(uv,n);
		v.b += showFlag(vec2(.5,.5), uv, fract(n));
	}
		
	else { // draw cumulated gradient pyramid
		
		v = vec3(0.);
		float q=0., s=1.;
		for (int i=0; i<=6; i++) {
			// if (float(i)>n) continue;
			if (MOD) 
				v += txtF(uv,float(i));          // module(grad)
			else
				v += txtFs(uv,dir,float(i));     // grad

			q+=s,s*=.5;
		}
		v *= 2./q; 
		if (MOD)
			if (COL)
				v = (txt(uv,6.)+.5*k*v)/(1.+max(0.,k)); // draw lowresTex + k.mod(grad)
			else
				v = .5*v;                  // draw mod(grad)

		else 
			if (COL)
				v = txt(uv,7.)-v;          // draw lowresTex - grad
			else
				v = .5*(1.+v);             // draw grad

	}
	
	v.b += panel;
	fragColor = vec4(v,1.); 

}