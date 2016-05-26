// Shader downloaded from https://www.shadertoy.com/view/ldjGWc
// written by shadertoy user FabriceNeyret2
//
// Name: Variations on Noise
// Description: variation on https://www.shadertoy.com/view/Xs23D3
//    mouse.x: zoom   S: mouse.x controls lacunarity instead 
//    E:   mouse.y = exponent (=vicinity)
//    N+B: noise type:   00: smooth 10: abs 11: 1-abs 10:1/n
//    T: add or mul 
//    C: toggles colors   G: toggles galaxy
// variations on noise 

#define SCALE_LACUNARITY 8. // when exponent is active
#define NOctaves 12.    	// max scales
#define LimitDetails 2. 	// Anti aliasing
#define ANIM 0				// Manual / Auto
#define ClampLevel 1.		// Colormap


// widgets from https://www.shadertoy.com/view/lsXXzN

float t = iGlobalTime;
vec2 FragCoord;
vec4 FragColor;

// --- key toggles -----------------------------------------------------

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

// --- Digit display ----------------------------------------------------

// all functions return true or seg number if something was drawn -> caller can then exit the shader.

//     ... adapted from Andre in https://www.shadertoy.com/view/MdfGzf

float segment(vec2 uv, bool On) {
	return (On) ?  (1.-smoothstep(0.08,0.09+float(On)*0.02,abs(uv.x)))*
			       (1.-smoothstep(0.46,0.47+float(On)*0.02,abs(uv.y)+abs(uv.x)))
		        : 0.;
}

float sevenSegment(vec2 uv,int num) {
	float seg= 0.;
    seg += segment(uv.yx+vec2(-1., 0.),num!=-1 && num!=1 && num!=4                    );
	seg += segment(uv.xy+vec2(-.5,-.5),num!=-1 && num!=1 && num!=2 && num!=3 && num!=7);
	seg += segment(uv.xy+vec2( .5,-.5),num!=-1 && num!=5 && num!=6                    );
   	seg += segment(uv.yx+vec2( 0., 0.),num!=-1 && num!=0 && num!=1 && num!=7          );
	seg += segment(uv.xy+vec2(-.5, .5),num==0 || num==2 || num==6 || num==8           );
	seg += segment(uv.xy+vec2( .5, .5),num!=-1 && num!=2                              );
    seg += segment(uv.yx+vec2( 1., 0.),num!=-1 && num!=1 && num!=4 && num!=7          );	
	return seg;
}

float showNum(vec2 uv,int nr, bool zeroTrim) { // nr: 2 digits + sgn . zeroTrim: trim leading "0"
	if (abs(uv.x)>2.*1.5 || abs(uv.y)>1.2) return 0.;

	if (nr<0) {
		nr = -nr;
		if (uv.x>1.5) {
			uv.x -= 2.;
			return segment(uv.yx,true); // <<<< signe. bug
		}
	}
	
	if (uv.x>0.) {
		nr /= 10; if (nr==0 && zeroTrim) nr = -1;
		uv -= vec2(.75,0.);
	} else {
		uv += vec2(.75,0.); 
		nr = int(mod(float(nr),10.));
	}

	return sevenSegment(uv,nr);
}

float dots(vec2 uv, int dot) {
	float point0 = float(dot/2),
		  point1 = float(dot)-2.*point0; 
	uv.y -= .5;	float l0 = 1.-point0+length(uv); if (l0<.13) return (1.-smoothstep(.11,.13,l0));
	uv.y += 1.;	float l1 = 1.-point1+length(uv); if (l1<.13) return (1.-smoothstep(.11,.13,l1));
	return 0.;
}
//    ... end of digits adapted from Andre

#define STEPX .875
float _offset=0.; // auto-increment useful for successive "display" call

// 2digit int + sign
bool display(vec2 pos, float scale, float offset, int number, int dot) { // dot: draw separator
	vec2 uv = FragCoord.xy/iResolution.y;
	uv = (uv-pos)/scale*2.; 
    uv.x = .5-uv.x + STEPX*offset;
	uv.y -= 1.;
	
	float seg = showNum(uv,number,false);
	offset += 2.;
	
	if (dot>0) {
		uv.x += STEPX*offset; 
		seg += dots(uv,dot);
		offset += 2.;
	}

	FragColor += seg*vec4(0.,.5,1.,1.);  // change color here
	_offset = offset;
	return (seg>0.);
}

// 2.2 float + sign
bool display(vec2 pos, float scale, float offset, float val) { // dot: draw separator
	if (display( pos, scale, 0., int(val), 1)) return true;
    if (display( pos, scale, _offset, int(fract(val)*100.), 0)) return true;
	return false;
}

// --- noise functions from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec2 hash( vec2 p ) {  						// rand in [-1,1]
	p = vec2( dot(p,vec2(127.1,311.7)),
			  dot(p,vec2(269.5,183.3)) );
	return -1. + 2.*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p ) {                     // noise in [-1,1]
    vec2 i = floor(p), f = fract(p);
	vec2 u = f*f*(3.-2.*f);
    return mix( mix( dot( hash( i + vec2(0.,0.) ), f - vec2(0.,0.) ), 
                     dot( hash( i + vec2(1.,0.) ), f - vec2(1.,0.) ), u.x),
                mix( dot( hash( i + vec2(0.,1.) ), f - vec2(0.,1.) ), 
                     dot( hash( i + vec2(1.,1.) ), f - vec2(1.,1.) ), u.x), u.y);
}


vec3 colormap(float value) {
	float maxv = ClampLevel;
	vec3 c1,c2;
	float t;
	if (value < maxv / 3.) {
		c1 = vec3(0.);   	 c2 = vec3(1.,0.,0.); 	t =  1./3.;
	} else if (value < maxv * 2. / 3.) {
		c1 = vec3(1.,0.,0.); c2 = vec3(1.,1.,.5);	t =  2./3. ;
	} else {
		c1 = vec3(1.,1.,.5); c2 = vec3(1.);      	t =  1.;
	}
	t = (t*maxv-value)/(maxv/3.);
	return t*c1 + (1.-t)*c2;
}

// ===============================================================================

void mainImage( out vec4 fragColor, in vec2 fragCoord ) { 
    vec2 uv = 2.*(fragCoord.xy/ iResolution.y- vec2(.5*iResolution.x/iResolution.y,.5));
	vec4 mouse = iMouse / iResolution.xyxy;
	FragCoord=fragCoord;
    FragColor=fragColor=vec4(0);
    
	// --- tunings ------------------------------

	if (iMouse.x+iMouse.y==0.) mouse = vec4(.5);
	
 #if ANIM
	float cycle = cos(mod(-t,100.)/100.*2.*3.14);
	float zoom = exp(cycle*cycle*20.);
#else
	float zoom = 0.;
	zoom = (keyToggle(83)) ? abs(mouse.z) : mouse.x ;
	zoom = exp(-6. + zoom*9.);
#endif
	
	if (!keyToggle(68)) { // 'D' : switch on/off display mouse.xy
		vec2 pos ; float scale = 0.1;
        pos = vec2(.2,.8); if (display( pos, scale, 0., mouse.x*100.)) { fragColor=FragColor; return; }
        pos.y -= .15;	   if (display( pos, scale, 0., mouse.y*100.)) { fragColor=FragColor; return; }
	}
	
	int TYPE = (keyToggle(84)) ? 0 : 1;	// 0: additive perlin  1: multiplicative perlin


	if (keyToggle(71)) { // 'G' : map on galaxy
		float r = length(uv), a = atan(uv.y,uv.x);  // to polar
		if (!keyToggle(64+25)) { // 'Y'
			r = 1.*log(r/.1); 						    // restore aspect ratio
			a -= r;           							// slight slant
			uv = vec2(a,2.*r-1.);
		} 
		else {
			a -= r;
			uv = vec2(r*cos(a),r*sin(a));
		}
	}
	
	if (keyToggle(64+23)) { // 'W' : gravity waves ( = galaxy spirals)
#define AMP .1
		float phi = 3.*(uv.x-.5*iGlobalTime);
		uv.x -= AMP*sin(phi);
		mouse.y = 6.*AMP*(1.+cos(phi))/2.;
	}
	
	// zoom and centering
	uv *= zoom; 
	
	if (keyToggle(64+26)) { // 'Z'  mapping reference
		uv *= 8.;
		float n = 20.*2.*sign(mod(uv.x,1.)-.5)*sign(mod(uv.y,1.)-.5)-1.;
		fragColor=vec4(n); return;
	}
	
	float theta = 4. + float(ANIM)*.01*t; // some rotations, not compulsory
    mat2 m = 2.*mat2( cos(theta),sin(theta), 
					 -sin(theta),cos(theta) );
		
	// noise type:   0: smooth  1: abs  2: 1-abs  3: 1/(1+x)
	int NOISE = ((keyToggle(78))?1:0) + ((keyToggle(66))?2:0);
	
	
	// --- computation of the noise cascade ----------------------------
	
	float d = (TYPE==0) ? 0.:.5; // density
	float q = zoom;
	
	for (float i = 0.; i < NOctaves; i++) { // cumulates scales from large to small
		
		if (TYPE==1) if(d < 1e-2) continue;
		float crit = iResolution.x/(q*LimitDetails)-1.;
		if (crit < 0.) continue; // otherwise, smaller than pixel
	
		// --- base noise     normalization should ensure constant average
		
		float n = noise(uv + 10.*i*i); // base noise [-1,1]
#define GAIN 1. // 5.*mouse.y // 5.
		// n = clamp(GAIN*n,-1.,1.); // to cancel poor stddev
		if (NOISE == 0)
			n = (1.+n)*.95; // [0.,1.]
		else if (NOISE == 1)
			n = abs(n)*8.5;
		else if (NOISE == 3)
			n = (1.-abs(n)) * 1.1;
		else if (NOISE == 2)
			n = 1./(1.+n)*.9;

			
		// --- lacunarity ( = vicinity at largest scale )
			
		if (keyToggle(69)) // 'E' : mouse.y tune exponent
		{ 
			float P = mouse.y*10.; //  power to control high-scale lacunarity
			// lacunarity fall-off with scale.   'S' : mouse.x tune scales of lacunarity
			float lac = SCALE_LACUNARITY * ( (keyToggle(83)) ? 2.*mouse.x : 1.);
			P = 1. + P*exp(-i/lac);
#define FACTOR 1.5
			n = clamp(n,0.,FACTOR); 
			n = pow(n,P); 
		}
		

		// --- fading zone to avoid aliasing
		if (crit<1.)   
			n = n*crit + (1.-crit); 

		// --- cumulates cascade bands
		if (TYPE==1)
			d *= n; 			// cumulates multiplicatively
		else
			d += .4*n*zoom/q;   // cumulates additively
		
		uv = m*uv; q*= 2.; // go to the next octave
	}

	fragColor.xyz = (keyToggle(67)) ?  vec3(d) : colormap(d) ;
}