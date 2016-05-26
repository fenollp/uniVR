// Shader downloaded from https://www.shadertoy.com/view/ldtSR4
// written by shadertoy user antonOTI
//
// Name: Nuclear Throne tunnel
// Description: I'm trying to recreate the intro screen of the game nuclear throne by vlamber.&lt;br/&gt;I've started from aiekick's Subo Glacius 2 : https://www.shadertoy.com/view/MsGGWy#&lt;br/&gt;I'm not good with 3D shaders
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//base shader : https://www.shadertoy.com/view/MsGGWy#
// this shader was made by Anton Roy/ 2016

// missing : 
// - particles
// - lightnings

const float mPi = 3.14159;
const float m2Pi = 6.28318;

vec3 wtexture(vec2 pos)
{
    return mix(vec3(0.211,0.101,0.266),vec3(0.070,0.035,0.090),step(mod(pos.x * 4.38 - pos.y * 12.,1.),.5));
}

vec2 path(vec3 p)
{
    float amplitude = 1.9;
    float speed = 1.5;
	p.x = sin(p.z*speed)*amplitude;
	p.y = cos(p.z*speed)*amplitude;
	return p.xy;
}

float df(vec3 p)
{
	p.xy += path(p);
	return 2. - length(p.xy);
}


vec3 dcol(vec3 p)
{
	p.xy += path(p);
	return wtexture(p.xz/5. * vec2(1.,sign(p.y))) ;
}

void mainImage( out vec4 f, in vec2 g )
{
	f = vec4(0);
	
	
	// params
	vec2 si = iResolution.xy;
	vec2 uv = (g+g-si.xy) / min(si.x, si.y);
    float pixel = 100.;
    uv = floor(uv * pixel)/pixel;
    
	float t = iGlobalTime * .5;
	vec3 ro = vec3(0,-.5,t);
	ro.xy -= path(ro);
	
	vec3 co = ro + vec3(0,0,1);
	vec3 cu = vec3(0,1,0);
	
	float fov = 5.;
	vec3 z = normalize(co - ro);
	vec3 x = normalize(cross(cu, z));
	vec3 y = normalize(cross(z, x));
	vec3 rd = normalize(z + fov * uv.x * x + fov * uv.y * y);

	float md = 50.;
	
	float s = 0.1, d = -0.2;
	vec3 p = ro + rd * d;
    vec3 col;
	for (int i=0;i<100;i++)
	{
		if (s < 0.0005*d  || d > md) break;
		p = ro + rd * d;
		d += s = df(p)*0.3;;
        col = dcol(p) * (2./d) ;
	}
	
	if ( d < md)
	{
        p.xy = path(p);
		p.z = d;
        f.rgb = col ;
	}
}

