// Shader downloaded from https://www.shadertoy.com/view/ls33zX
// written by shadertoy user BreakfastBrew
//
// Name: Aqua Bubbles
// Description: Bloop Bloop
float noise(vec3 p) // Based off Las^Mercury and XT95 "Flame" shader I made this Aqua version.
{
	vec3 i = floor(p);
	vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);
	vec3 f = cos((p-i)*acos(-1.))*(-.5)+.5;
	a = mix(tan(a+2.),tan(1.+a), f.x);
	a.xy = mix(a.xz, a.yw, f.y);
	return mix(a.x, a.y, f.z);
}

float sphere(vec3 p, vec4 spr)
{
	return length(spr.xyz-p) - spr.w;
}

float flame(vec3 p)
{
	float d = sphere(p*vec3(1,1,1), vec4(.0,-2.,.0,1.));
	return d + (noise(p+vec3(.2,iGlobalTime*1.,.0)));
}

float scene(vec3 p)
{
	return min(5.-length(p) , abs(flame(p)) );
}

vec4 raymarch(vec3 org, vec3 dir)
{
	float d = 0.0, glow = 0.0, eps = 0.1;
	vec3  p = org;
	bool glowed = false;
	
	for(int i=0; i<64; i++)
	{
		d = scene(p) + eps;
		p += d * dir;
		if( d>eps )
		{
			if(flame(p) < .0)
				glowed=true;
			if(glowed)
       			glow = float(i)/64.;
		}
	}
	return vec4(p,glow);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 v = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
	v.x *= iResolution.x/iResolution.y;
	
	vec3 org = vec3(0., -2., 4.);
	vec3 dir = normalize(vec3(v.x*1.6, -v.y, -1.5));
	
	vec4 p = raymarch(org, dir);
	float glow = p.w;
	
	vec4 col = mix(vec4(1,-1,-1,1), vec4(-1,1,1,-1), p.y*.01+.9);
	
	fragColor = mix(vec4(0.), col, pow(glow*4.,3.1));

}