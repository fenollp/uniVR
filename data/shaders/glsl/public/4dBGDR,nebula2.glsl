// Shader downloaded from https://www.shadertoy.com/view/4dBGDR
// written by shadertoy user FabriceNeyret2
//
// Name: nebula2
// Description: rendering of a nebula.
//    SPACE: toggle volume cut.
//    B: toggle blue center 
//    O:  toggle shadowing
// --- adapted from 3D noise of inigo quilez 
// https://www.shadertoy.com/view/XslGRr

//#define FULL_PROCEDURAL
#ifdef FULL_PROCEDURAL

// hash based 3d value noise
float hash( float n )
{
    return fract(sin(n)*43758.5453);
}
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
}
#else

// LUT based 3d value noise
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}
#endif

#define mynoise(q) (1.-abs(2.*noise(q)-1.))

float fbm( in vec3 q )
{
	float f;
    f  = 0.5000*mynoise( q ); q = q*2.02;
    f += 0.2500*mynoise( q ); q = q*2.03;
    f += 0.1250*mynoise( q ); q = q*2.01;
    f += 0.0625*mynoise( q );
	return f;
}

bool key_toggle(float ascii) { 
	return (texture2D(iChannel1,vec2((ascii+.5)/256.,0.75)).x > 0.); 
}

// shape
vec4 map( in vec3 p )
{
	
	float l = length(p);
	
	// profile: 
	//    dens max on sphere shell l = 1
	//    density slope stiffer inside (shockwave)
	float d = 1. - l;
    if (d>0.) d = -3.*d;
	// d = -sqrt(-d);
	
	// add noise to profile.
	// noise = supercondensed "fire" fbm 
	float n = pow(fbm(p),4.);
	d += 2.5 * n;

	// volume cut, for debug
	if (key_toggle(32.))  if (p.x>0.) d = 0.;
	
	vec4 res;
	res.w = clamp(d, 0., 1. ); // density
	// color: orange on the shell then darkening red
	res.xyz = vec3(1./pow(l*1.,1.),.6/pow(l,3.),0.); 
	// transparent blue inside
	if (!key_toggle(66.)) 
		if ((l<1.) && (res.w==0.)) res += vec4(0.,0.,1.,.1);
	
	return clamp(res, 0.0, 1.0 );;
}



vec4 raymarch( in vec3 ro, in vec3 rd )
{
	vec4 sum = vec4(0, 0, 0, 0);

	float t = 0.0;
	for(int i=0; i<64; i++)
	{
		if( sum.a > 0.99 ) continue;

		vec3 pos = ro + t*rd;
		vec4 col = map( pos ); // .w = density
		
	if (key_toggle(79.))  // Ombrage
	{
		vec3 sundir = -normalize(pos); // vec3(-1.0,0.0,0.0);
#define EPS .3	
		float dif = (col.w - map(pos+EPS*sundir).w)/EPS; // grad(dens).L

		col.xyz *= .5+.5*clamp(.5*dif, 0.,1.);
	}
		
		col.a *= 0.35;
		col.rgb *= col.a;

		sum = sum + col*(1.0 - sum.a);	
		t += max(0.1,0.025*t);
	}

	sum.xyz /= (0.001+sum.w);

	return clamp( sum, 0.0, 1.0 );
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = 2.*(fragCoord.xy / iResolution.y -vec2(.8,.7));
    vec2 mo = -1.0 + 2.0*iMouse.xy / iResolution.xy;
    
    // camera
    vec3 ro = 4.0*normalize(vec3(cos(2.75-3.0*mo.x), 0.7+(mo.y+1.0), sin(2.75-3.0*mo.x)));
	vec3 ta = vec3(0.0, 1.0, 0.0);
    vec3 ww = normalize( ta - ro);
    vec3 uu = normalize(cross( vec3(0.0,1.0,0.0), ww ));
    vec3 vv = normalize(cross(ww,uu));
    vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

	
    vec4 col = raymarch( ro, rd );

	vec4 sky;
	//sky = vec4(1.,1.,1.,1.); 
	sky = vec4(.1,.0,.0,1.);
    fragColor = mix(sky,col,col.w);
}
