// Shader downloaded from https://www.shadertoy.com/view/4tfSDj
// written by shadertoy user squid
//
// Name: Thumpn' Speakers
// Description: Speakers move with the actual amplitude values from the sound shader, for better or worse.
// many thanks to iq and srtuss as well as all the other small things I copied from other people


//	really fake GI based on picking up the color with AO, 
//		makes the LEDs look like lights and not color changing shapes
#define SILLY_GI

//	get a better frame rate
#define SHADOW_STEPS 40

#define ZOOM 30.
#define CAM_HEIGHT .5
#define TARG_Y 4.

//-- sound synth --

//!! this is the real frame rate drain 	!!
// change this value first if your frame rate is really bad
// (the value is also in the sound shader, but I can't really tell that they are different)
#define NSPC 64
//!!									!!

#define pi2 6.283185307179586476925286766559

// cheap and unrealistic distortion
float dist(float s, float d)
{
	return clamp(s * d, -1.0, 1.0);
}
vec2 dist(vec2 s, float d)
{
	return clamp(s * d, -1.0, 1.0);
}

// quantize
float quan(float s, float c)
{
	return floor(s / c) * c;
}

// a resonant lowpass filter's frequency response
float filter(float h, float cut, float res)
{
	cut -= 20.0;
	float df = max(h - cut, 0.0), df2 = abs(h - cut);
	return exp(-0.005 * df * df) * 0.5 + exp(df2 * df2 * -0.1) * 2.2;
}

// randomize
float nse(float x)
{
	return fract(sin(x * 110.082) * 19871.8972);
	//return fract(sin(x * 110.082) * 13485.8372);
}
float nse_slide(float x)
{
	float fl = floor(x);
	return mix(nse(fl), nse(fl + 1.0), smoothstep(0.0, 1.0, fract(x)));
}

// note number to frequency
float ntof(float n)
{
	return 440.0 * pow(2.0, (n - 69.0) / 12.0);
}

// tb303 core
vec3 synth(float tseq, float t)
{
	vec2 v = vec2(0.0);
	
	float tnote = fract(tseq);
	float dr = 0.26;
	float amp = smoothstep(0.05, 0.0, abs(tnote - dr - 0.05) - dr) * exp(tnote * -1.0);
	float seqn = nse(floor(tseq));
	//float seqn = nse_slide(tseq);
	float n = /*20.0 + floor(seqn * 38.0);*/10.0 + floor(seqn * 60.0);
	float f = ntof(n)+dist(sin((tseq-t)*.1),20.);
	
    float sqr = smoothstep(0.0, 0.01, abs(mod(t * 9.0, 64.0) - 20.0) - 20.0);
    
	float base = f;//50.0 + sin(sin(t * 0.1) * t) * 20.0;
	float flt = exp(tnote * -1.5) * 50.0 + pow(cos(t * 1.0) * 0.5 + 0.5, 4.0) * 80.0 - 0.0;
	for(int i = 0; i < NSPC; i ++)
	{
		float h = float(i + 1);
		float inten = 1.0 / h;
		//inten *= sin((pow(h, sin(t) * 0.5 + 0.5) + t * 0.5) * pi2) * 0.9 + 0.1;
		
		inten = mix(inten, inten * mod(h, 2.0), sqr);
		
		inten *= exp(-1.0 * max(2.0 - h, 0.0));// + exp(abs(h - flt) * -2.0) * 8.0;
		
		inten *= filter(h, flt, 4.0);
		inten += dist(inten, 8.5)*.5;
		
		v.x += inten * sin((pi2 + 0.01) * (t * base * h));
		v.y += inten * sin(pi2 * (t * base * h));
	}
	
	
	float o = v.x * amp;//exp(max(tnote - 0.3, 0.0) * -5.0);
	
	//o = dist(o, 2.5);
	
	return vec3(dist(v * amp, 2.0)*1.2, f);
}

// heavy 909-ish bassdrum
float kick(float tb, float time)
{
	tb = fract(tb / 4.0) * 0.5;
	float aa = 5.0;
	tb = sqrt(tb * aa) / aa;
	
	float amp = exp(max(tb - 0.15, 0.0) * -10.0);
	float v = sin(tb * 100.0 * pi2) * amp;
	v = dist(v, 4.0) * amp;
	v += nse(quan(tb, 0.001)) * nse(quan(tb, 0.00001)) * exp(tb * -20.0) * 2.5;
	return v;
}

// bad 909-ish open hihat
float hat(float tb)
{
	tb = fract(tb / 4.0) * 0.5;
	float aa = 4.0;
	tb = sqrt(tb * aa) / aa;
	return nse(sin(tb * 4000.0) * 0.0001) * smoothstep(0.0, 0.01, tb - 0.25) * exp(tb * -5.0);
}



// oldschool explosion sound fx
float expl(float tb)
{
	//tb = fract(tb / 4.0) * 0.5;
	float aa = 20.0;
	tb = sqrt(tb * aa) / aa;
	
	float amp = exp(max(tb - 0.15, 0.0) * -10.0);
	float v = nse(quan(mod(tb, 0.1), 0.0001));
	v = dist(v, 4.0) * amp;
	return v;
}

vec3 synth1_echo(float tb, float time)
{
    vec3 v;
    v = synth(tb, time) * 0.5;// + synth2(time) * 0.5;
	float ec = 0.6, fb = 0.6, et = 2.0 / 9.0, tm = 2.0 / 9.0;
	v += synth(tb, time - et) * ec * vec3(1.0, 0.5, 1.); ec *= fb; et += tm;
	v += synth(tb, time - et).yxz * ec * vec3(0.5, 1.0, 1.); ec *= fb; et += tm;
	v += synth(tb, time - et) * ec * vec3(1.0, 0.5, 1.); ec *= fb; et += tm;
	v += synth(tb, time - et).yxz * ec * vec3(0.5, 1.0, 1.); ec *= fb; et += tm;
	
    return v;
}
#define _hfqo if(!highfreqonly)

vec2 mainSound(float time, bool highfreqonly)
{
	vec2 mx = vec2(0.0);
	
	float tb = mod(time * 9.0, 16.0);
	
	vec3 s1 = synth1_echo(tb, time) * 0.8;
    if(!highfreqonly && s1.z < 600.) {
    	mx = s1.xy;
    } else if(s1.z > 600.) {
    	mx = s1.xy;
    }
    
    mx += expl(mod(time * 9.0, 64.0) / 4.5) * 0.4;
    
    if(highfreqonly) { mx += vec2(hat(tb) ) + quan(hat(tb), .01)*.4; }
	
	//mx += dist(fract(tb / 16.0) * sin(ntof(77.0 - 36.0) * pi2 * time), 8.0) * 0.2;
	//mx += expl(tb) * 0.5;
	
	float k = kick(tb, time) * 0.6;// - kick(tb, time - 0.004) * 0.5 - kick(tb, time - 0.008) * 0.25);
	
	_hfqo mx += vec2(k);
	
	
	
	mx = dist(mx, 1.2);
	
	return mx*.8;
}
/*vec2 mainSound(float time, bool highfreqonly)
{
	vec2 mx = vec2(0.0);
	
	float tb = mod(time * 9.0, 16.0);
	
	
	vec3 s1 = synth1_echo(tb, time) * 0.8 * smoothstep(0.0, 0.01, abs(mod(time * 9.0, 256.0) + 8.0 - 128.0) - 8.0);
    if(!highfreqonly && s1.z < 600.) {
    	mx = s1.xy;
    } else if(s1.z > 600.) {
    	mx = s1.xy;
    }
    float hi = 1.0;
    float ki = smoothstep(0.01, 0.0, abs(mod(time * 9.0, 256.0) - 64.0 - 128.0) - 64.0);
    float s2i = 1.0 - smoothstep(0.01, 0.0, abs(mod(time * 9.0, 256.0) - 64.0 - 128.0) - 64.0);
    hi = ki;
    
    mx += expl(mod(time * 9.0, 64.0) / 4.5) * 0.4 * s2i;
    
	mx += vec2(hat(tb) * 1.5) * hi;
	
	//mx += dist(fract(tb / 16.0) * sin(ntof(77.0 - 36.0) * pi2 * time), 8.0) * 0.2;
	//mx += expl(tb) * 0.5;
	
	mx += vec2(synth2_echo(time, tb)) * 0.2 * s2i;
	
	
	mx = mix(mx, mx * (1.0 - fract(tb / 4.0) * 0.5), ki);
	float sc = sin(pi2 * tb) * 0.4 + 0.6;
	float k = kick(tb, time) * 0.8 * sc * ki;// - kick(tb, time - 0.004) * 0.5 - kick(tb, time - 0.008) * 0.25);
	
	_hfqo mx += vec2(k, k);
	
	
	
	mx = dist(mx, 1.00);
	
	return vec2(mx.x*cos(time), mx.x*sin(time));
}*/
//-----------------

//------hashes w/o sine
#define MOD2 vec2(443.8975,397.2973)
#define MOD3 vec3(443.8975,397.2973, 491.1871)
#define MOD4 vec4(443.8975,397.2973, 491.1871, 470.7827)

//----------------------------------------------------------------------------------------
///  3 out, 2 in...
vec3 hash32(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3.zxy, p3.yxz+19.19);
    return fract(vec3(p3.x * p3.y, p3.x*p3.z, p3.y*p3.z));
}


//------

float box( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float torus( vec3 p, vec2 t )
{
  return length( vec2(length(p.xz)-t.x,p.y) )-t.y;
}

float cylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float det( vec2 a, vec2 b ) { return a.x*b.y-b.x*a.y; }
vec3 getClosest( vec2 b0, vec2 b1, vec2 b2 ) 
{
	
  float a =     det(b0,b2);
  float b = 2.0*det(b1,b0);
  float d = 2.0*det(b2,b1);
  float f = b*d - a*a;
  vec2  d21 = b2-b1;
  vec2  d10 = b1-b0;
  vec2  d20 = b2-b0;
  vec2  gf = 2.0*(b*d21+d*d10+a*d20); gf = vec2(gf.y,-gf.x);
  vec2  pp = -f*gf/dot(gf,gf);
  vec2  d0p = b0-pp;
  float ap = det(d0p,d20);
  float bp = 2.0*det(d10,d0p);
  float t = clamp( (ap+bp)/(2.0*a+b+d), 0.0 ,1.0 );
  return vec3( mix(mix(b0,b1,t), mix(b1,b2,t),t), t );
}

vec2 _bezier( vec3 a, vec3 b, vec3 c, vec3 p )
{
	vec3 w = normalize( cross( c-b, a-b ) );
	vec3 u = normalize( c-b );
	vec3 v = normalize( cross( w, u ) );

	vec2 a2 = vec2( dot(a-b,u), dot(a-b,v) );
	vec2 b2 = vec2( 0.0 );
	vec2 c2 = vec2( dot(c-b,u), dot(c-b,v) );
	vec3 p3 = vec3( dot(p-b,u), dot(p-b,v), dot(p-b,w) );

	vec3 cp = getClosest( a2-p3.xy, b2-p3.xy, c2-p3.xy );

	return vec2( sqrt(dot(cp.xy,cp.xy)+p3.z*p3.z), cp.z );
}
float bezier1(vec3 p, vec3 a, vec3 b, vec3 c, float r) {
    vec2 h = _bezier(a, b, c, p);
		
	return h.x-r;
}


vec4 u( vec4 d1, vec4 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}
vec4 s( vec4 d1, vec4 d2 )
{
    return -d2.x > d1.x ? d2*vec4(-1.,1.,1.,1.) : d1;
    //return max(-d2,d1); max(a,b) = a > b ? a : b
}
mat3 rotateX(float r)
{
    vec2 cs = vec2(cos(r), sin(r));
    return mat3(1., 0., 0., 0., cs.x, cs.y, 0., -cs.y, cs.x);
}

mat3 rotateY(float r)
{
    vec2 cs = vec2(cos(r), sin(r));
    return mat3(cs.x, 0, cs.y, 0, 1, 0, -cs.y, 0, cs.x);
}

mat3 rotateZ(float r)
{
    vec2 cs = vec2(cos(r), sin(r));
    return mat3(cs.x, cs.y, 0., -cs.y, cs.x, 0., 0., 0., 1.);
}


vec2 Fal = vec2(0.), Fhi = vec2(0.);



vec4 speaker(vec3 p, float lFal, float lFhi) {
    
    vec2 c1 = p.zy-vec2(0., 4.);
	float S1 = log(max(length(c1),0.4)*0.1);
    float disp = S1*lFal*step(length(c1),3.6)*.2;
    
    vec2 c2 = p.zy-vec2(0., 9.75);
	float S2 = log(max(length(c2),0.4)*0.1);
    disp += S2*lFhi*step(length(c2),2.0)*.2;
    disp = clamp(disp, -3., 0.);
        
    vec4 r = 	vec4( box(p-vec3(0., 6., 0.), vec3(3.+disp, 6., 4. )), 3., length(c1), length(c2) );
    r = u(r,	vec4( box(p-vec3(-2., 6., 0.), vec3(1., 6., 4.)), 3., 1000., 1000. ));
    r = u(r,	vec4( torus((p-vec3(3., 4., 0.)).yxz, vec2(3.5, .1)), 2., 0., 0. ));
    r = u(r,	vec4( torus((p-vec3(3., 9.75, 0.)).yxz, vec2(1.9, .1)), 2., 0., 0. ));
    //r = u(r,	vec4( length(p-vec3(2., 4., 0.))-.3, 2., 0., 0. ));
    return r;
}

vec4 synthbox1(vec3 p) {	
    vec4 r = vec4(box(p-vec3(0., 2., 0.), vec3(3., 2., 4.2)), 2., 0., 0.);
    if(abs(p.z)<4. && p.y > 1. && p.y < 3.) { //makes everything more stable
   		vec3 q = p;
    	q.y = mod(q.y, 1.)-.5;
    	q.z = mod(q.z, 1.)-.5;
    	r = u(r, vec4(length(q-vec3(3., 0., 0.))-.3, 6., floor(p.z)-3. , floor(p.y)-2.));
    }
    return r;
}

vec4 knob(vec3 p) {
	vec4 r = vec4(cylinder(p.zxy, vec2(.3, .25)), 2., 0., 0.);
    r = u(r, vec4(box(p-vec3(0., .4, 0.), vec3(.23, .09, .05)), 2., 0., 0.) );
	return r;
}

vec4 synthbox2(vec3 p) {
    vec4 r = vec4(box(p-vec3(0., 2., 0.), vec3(3., 4., 4.)), 2., 0., 0.);
    if(abs(p.z)<4.2) {
    	r = u(r, vec4(length(p-vec3(3., -1.3, 3.5))-.2, 600., 0., 0.)); 
        vec3 kq = p;
        kq.z = mod(clamp(kq.z, -3., 3.), 1.5)-.75;
    	r = u(r, knob( (kq-vec3(3., 0., 0.))*rotateX( floor(p.z/1.5 + 1.)*1.3+.2 ) ));
		vec3 sq = p-vec3(3., 0., 1.);
        sq.y = mod(clamp(sq.y, 1.5, 5.), .7)-.35;
        r = s(r, vec4(box(sq, vec3(.5, .2, 2.)), 9., 0., 0.));
        if(p.y > 1. && p.y < 5. ) {
        	vec3 cq = (p-vec3(3., 0., -2.5));
        	cq.y = mod(cq.y, 1.)-.5;
			r = u(r, vec4(cylinder(cq.zxy, vec2(.25, .2)), 7., floor(p.y), 0.));
        }
    } 
    return r;
}

vec4 synthstack(vec3 p) {
	vec4 r = synthbox1(p*rotateY(-.04));
    r = u(r, synthbox2((p-vec3(0., 6., 0.))*rotateY(.04)));
    r = u(r, vec4(
        bezier1(p, 
                vec3(-3., 1., 0.), 
                vec3(-6., -1.8, 0.), 
				vec3(-3., 6., 0.), .2), 
        	8., 0., 0.));
    return r;
}

vec4 map(vec3 p) {
	vec4 r = vec4(p.y, 1., 0., 0.);
    
    r = u(r, speaker((p-vec3(0., 0., 12.))*rotateY(-.3), Fal.x, Fhi.x ));
    r = u(r, speaker((p-vec3(0., 0., -12.))*rotateY(.3), Fal.y, Fhi.y ));
    
    r = u(r, synthstack(p));
    
    r = u(r, vec4(bezier1(vec3(p.x, p.y, abs(p.z)), 
                          vec3(-3., .5, 2.),
                          vec3(-7., .0, 5.), 
                          vec3(-3.3, .5, 9.), .2), 8., 0., 0.));
    
    return r;
}

float hash( float n ) { return fract(sin(n)*753.5453123); }
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
	
    float n = p.x + p.y*157.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+157.0), hash(n+158.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+270.0), hash(n+271.0),f.x),f.y),f.z);
}
vec3 matcol(vec3 id, vec3 p) {
    if (id.x == 1.) {
        vec2 t = floor(p.xz*.1);
        float xp = exp(-length(p.xz)*.03);
        float mx = pow(noise(vec3(t,iGlobalTime*2.)), 40.)*2.;
        return ( clamp(hash32(t+5.),vec3(0.1), vec3(1.))+mx ) * xp;//vec3(0.8, 0.8, 0.8);
    }
    else if	(id.x == 2.) return vec3(0.1,  0.1, 0.1);
    else if (id.x == 3.) {
        if(id.y < 3.6 || id.z < 2.0) return vec3(0.2, 0.2, 0.22)+noise(p*vec3(5.,5.,30.))*.05;
    	return vec3(0.5, 0.45, 0.4)+noise(p)*.15;
    } else if(id.x == 6.) {
        float idy = abs(id.y);
        float vol = step(abs(id.z) > 0. ? Fal.x*1.2 : Fal.y*1.2 , idy)+.05;
        return clamp(mix(vec3(0.9, .0, 0.), vec3(.2, .8, 0.), floor(idy*.5-.4))*vol,0.,.9)
            #ifdef SILLY_GI
            * 2.
            #endif
            ; 
    } else if(id.x == 7.) {
        float idy = abs(id.y);
        float b = clamp(1.-mod(iGlobalTime*2.5-idy, 4.), .05, .8) 
            #ifdef SILLY_GI
            * 4.
            #endif
            ;
        return vec3(1., .85, 0.2)*b;
    } else if(id.x == 8.) {
        return vec3(0.05, 0., 1.); 
    } else if(id.x == 9.) {
        return vec3(0.3);
    }
    return vec3(3., .0, 0.);
}

float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<SHADOW_STEPS; i++ )
    {
		float h = map( ro + rd*t ).x;
        res = min( res, 8.0*h/t );
        t += clamp( h, 0.02, 0.10 );
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0., 1.0 );

}
float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<10; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}
vec3 calcLGI( in vec3 pos, in vec3 nor )
{
	vec3 occ = vec3(0.0);
    float sca = 1.0;
    for( int i=0; i<10; i++ )
    {
        float hr = 0.01 + 0.2*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        vec4 v = map(aopos);
        occ += -(v.x-hr)*sca*matcol(v.yzw, aopos);
        sca *= 0.9;
    }
    return occ;//clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

vec3 shade(vec3 p, vec3 n, vec4 rs) {
	//return matcol(rs.yzw, p);
    vec3 mc = matcol(rs.yzw, p);
    vec3 ao = mc*.1*calcAO(p,n);
    #ifdef SILLY_GI
    vec3 gi = .1*calcLGI(p,n);
    #endif
    vec3 L1 = normalize(vec3(0.6, .7, .5));
    float S1 = max(0., dot(n, L1)) * softshadow(p, L1, 0.1, 100.);
    
    vec3 L2 = normalize(vec3(0.1, .7, -.5));
    float S2 = max(0., dot(n, L2)) * softshadow(p, L2, 0.1, 100.);
    
    return (S1*vec3(1., .9, .8) + S2*vec3(.8, .8, 1.))*.5*mc + ao 
        #ifdef SILLY_GI
        + gi
        #endif
        ;
}

vec4 rm( in vec3 ro, in vec3 rd )
{
    float tmin = 1.0;
    float tmax = 800.0;
    
    
	float precis = 0.002;
    float t = tmin;
    vec3 m = vec3(-1.0);
    for( int i=0; i<200; i++ )
    {
	    vec4 res = map( ro+rd*t );
        if( res.x<precis || t>tmax ) break;
        t += res.x*.5;
	    m = res.yzw;
    }

    if( t>tmax ) m=vec3(-1.0);
    return vec4( t, m );
}

vec3 normal( in vec3 pos )
{
	vec3 eps = vec3( 0.0001, 0.0, 0.0 );
	vec3 nor = vec3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime;
    Fal = (1.-mainSound(t,false))*2.-.5;
    Fhi = (1.-mainSound(t,true))*2.-.5;
    
	vec2 uv = fragCoord.xy / iResolution.y * 2. - vec2(1.75, 1.);
    vec2 mouse = (iMouse.xy / iResolution.xy);
    float T = -mouse.x*6. + 0.5;
    vec3 ro = vec3(cos(T), CAM_HEIGHT + 2.*mouse.y, sin(T))*ZOOM;
    vec3 ww = normalize(vec3(0., TARG_Y, 0.) - ro);
    vec3 uu = normalize(cross(ww, vec3(0., 1., 0.)));
    vec3 vv = cross(ww, uu);
    vec3 rd = normalize(ww*2.5 + uu*uv.x + vv*-uv.y);
    
    vec4 rs = rm(ro,rd);
    if(rs.y > -1.) {
        vec3 pos = ro+rd*rs.x;
        vec3 nor = normal(pos);
        vec3 col = shade(pos,nor,rs);
        vec2 px = (fragCoord.xy / iResolution.xy);
        float vignette = px.x * px.y * ( 1.0 - px.x ) * ( 1.0 - px.y );
    	vignette = clamp( pow( 8.0 * vignette, 0.3 ), 0.0, 1.0 );
        col *= vignette;
    	fragColor = vec4(pow(col,vec3(1./2.2)),1.);
    } else {
    	fragColor = vec4(0.);
    }
}