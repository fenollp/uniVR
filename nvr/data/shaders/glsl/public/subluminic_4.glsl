// Shader downloaded from https://www.shadertoy.com/view/XsV3DK
// written by shadertoy user aiekick
//
// Name: Subluminic 4
// Description: Subluminic 4
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

// by shane
float Voronesque( in vec3 p )
{
    vec3 i  = floor(p + dot(p, vec3(0.333333)) );  p -= i - dot(i, vec3(0.166666)) ;
    vec3 i1 = step(0., p-p.yzx), i2 = max(i1, 1.0-i1.zxy); i1 = min(i1, 1.0-i1.zxy);    
    vec3 p1 = p - i1 + 0.166666, p2 = p - i2 + 0.333333, p3 = p - 0.5;
    vec3 rnd = vec3(7, 157, 113); 
    vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.);
    vec4 d = vec4( dot(i, rnd), dot(i + i1, rnd), dot(i + i2, rnd), dot(i + 1., rnd) ); 
    d = fract(sin(d)*262144.)*v*2.; 
    v.x = max(d.x, d.y), v.y = max(d.z, d.w); 
    return max(v.x, v.y);
}

vec2 path(vec3 p)
{
	p.x = sin(p.z*0.1)*20.;
	p.y = cos(p.z*0.05)*20.;
	return p.xy;
}

float df(vec3 p)
{
	p.xy += path(p);
	p *= Voronesque(p/2.);//p *= Voronesque(p.zzz/2.);
	return 2. - length(p.xy);
}

vec3 march(vec3 f, vec3 ro, vec3 rd, float st)
{
	vec3 s = vec3(1), h = vec3(0.055,0.028,0.022), w = vec3(0);
	float d=1.,dl=0., td=0.;
	vec3 p = ro;
	for(float i=0.;i<60.;i++)
	{      
		if(s.x<0.0025*d||d>30.||td>.95) break;
        s = df(p) * .1 * i/vec3(6.42,16,12.96);
		w = (1.-td) * (h-s) * i/vec3(74.42,50.22,31.32) * step(s,h);
		f += w;
		td += w.x + .01;
		dl += 1. - exp(-0.0042 * log(d));;	
		s = max(s, st);
		d +=s.x; 
		p =  ro+rd*d;	
   	}
	dl += 0.4;
	f /= dl/1.1264;
	
	float stars = pow(fract( cos(rd.y * 8. + rd.x *800.) * 5000.), 50.);
	f.rgb = mix( f.rgb, vec3(stars), 1. - exp( -0.004*d*d) );
	return f;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = vec4(0);
    
	vec2 si = iResolution.xy;
	vec2 uv = (fragCoord*2.-si.xy) / min(si.x, si.y);

	float t = iGlobalTime * 12.;
	vec3 ro = vec3(0,-.5,t);
	ro.xy -= path(ro);
	
	vec3 co = ro + vec3(0,0,1);
	vec3 cu = vec3(0,1,0);
	
	float fov = 5.;
	vec3 z = normalize(co - ro);
	vec3 x = normalize(cross(cu, z));
	vec3 y = normalize(cross(z, x));
	vec3 rd = normalize(z + fov * uv.x * x + fov * uv.y * y);

	fragColor.rgb = march(fragColor.rgb, ro, rd, 0.135);
}
