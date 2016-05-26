// Shader downloaded from https://www.shadertoy.com/view/Xdf3z4
// written by shadertoy user Eybor
//
// Name: 3D Spheres !
// Description: A fractal composed of spheres with an Anaglyph effect.
//Anaglyph effect !

//Uncoment if you have red glass in your left eye and cyan in your right :p
//#define INVERT_CHANNELS

float scene(vec3 p)
{
	return max(-(length(mod(p,vec3(40.))-.5*vec3(40.))-24.),max(-(length(mod(p,vec3(10.))-.5*vec3(10.))-6.),max(-(length(mod(p,vec3(2.5))-.5*vec3(2.5))-1.5),-(length(mod(p,vec3(.625))-.5*vec3(.625))-.375))));
}

vec3 gn(vec3 p)
{
	vec3 eps = vec3(0.02,0.0,0.0);
	return normalize(vec3(
		scene(p+eps.xyy)-scene(p-eps.xyy),
		scene(p+eps.yxy)-scene(p-eps.yxy),
		scene(p+eps.yyx)-scene(p-eps.yyx)
	));
}

float ao(vec3 p, vec3 n, vec2 a)//Thx to XT95
{
	float dlt = a.x;
	float oc = 0.0, d = a.y;
	for(int i = 0; i<6; i++)
	{
		oc += (float(i) * a.x - scene(p + n * float(i) * a.x)) / d;
		d *= 2.0;
	}
	return clamp(1.0 - oc, 0.0, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec3 o = vec3 (.3, 5.25, 16.-iGlobalTime);
	vec3 rd = normalize(vec3((-1.+2.*fragCoord.xy/iResolution.xy)*vec2(iResolution.x/iResolution.y, 1.), -1.));
	
	#ifdef INVERT_CHANNELS
	float d = -.05;
	#else
	float d = .05;
	#endif
	vec3 pr = o + vec3(d, 0., 0.);
	vec3 pc = o - vec3(d, 0., 0.);
	float d1, d2;
	for(int i = 0; i < 64; i++)
	{
		d1 = scene(pr);
		pr += d1*rd;
		d2 = scene(pc);
		pc += d2*rd;
		if(max(d1, d2) < .001)
			break;
	}
	vec3 nr = gn(pr);
	vec3 nc = gn(pc);
	
	vec3 co;
	co.r = (1.-distance(pr, o)*.01)*ao(pr,nr,vec2(.5,2.))*ao(pr,nr,vec2(1.,4.));
	co.g = (1.-distance(pc, o)*.01)*ao(pc,nc,vec2(.5,2.))*ao(pc,nc,vec2(1.,4.));
	co.b = (1.-distance(pc, o)*.01)*ao(pc,nc,vec2(.5,2.))*ao(pc,nc,vec2(1.,4.));
	
	co = clamp(co ,0. , 1.);
	
	fragColor = vec4(co, 1.0);
}