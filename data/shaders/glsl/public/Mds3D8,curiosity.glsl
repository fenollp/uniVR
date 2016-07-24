// Shader downloaded from https://www.shadertoy.com/view/Mds3D8
// written by shadertoy user movAX13h
//
// Name: Curiosity
// Description: ... brought you here; composition.
// Curiosity, fragment shader by filip.sound@gmail.com, May 2013
// Inspired by a picture that I saw and a song that I heard.

float time = iGlobalTime*0.3;

vec3 grain(vec2 p)
{
	vec3 t = texture2D(iChannel0, p).rgb;
	float v = t.r * 0.12 * length(t.rgb)*0.9;
	return vec3(v);
}

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float slice(int id)
{
	//return 16777215.0;
	if (id == 0) return 8658952.0;
	if (id == 1) return 9200144.0;
	if (id == 2) return 10274353.0;
	if (id == 3) return 3788535.0;
	if (id == 4) return 4331719.0;
	if (id == 5) return 12988808.0;
	return 536.0;
}

float sprite(vec2 p)
{
	p = floor(p);
	
	if (p.x >= 0.0 && p.x < 5.0 && p.y < 31.0)
	{
		if (p.y >= 0.0)
		{
			float k = p.x + p.y*5.0;
			float n = slice(int(floor(k/24.0)));
			k = mod(floor(k), 24.0);
			if (int(mod(n/(pow(2.0,k)),2.0)) == 1) return 1.0;
		}
	}
	return 0.0;
}

float signation(vec2 p)
{
	p.x += 2.5;
	p = floor(p);
	float d = 0.0;
	if (clamp(p.x, 0.0, 4.0) == p.x && clamp(p.y, 0.0, 3.0) == p.y)
	{
		float k = p.x + p.y*5.0;
		if (int(mod(480942.0/(pow(2.0,k)),2.0)) == 1) d = 1.0*smoothstep(0.0, 0.4, sin(iGlobalTime));
		if (int(mod(710628.0/(pow(2.0,k)),2.0)) == 1) d = max(d, 1.0*smoothstep(0.0, 0.4, cos(iGlobalTime)));
	}
	return d;
}

vec3 scene(vec2 p, float i)
{
	vec3 col = vec3(0.6, 0.6, 0.6)*i;
	vec3 lcol = vec3(1.0, 1.0, 0.86)*(0.1+i);

	// textures	
	vec2 uv = p*0.0016;
	col = mix(col, grain(vec2(uv.x+0.2, uv.y+0.5)), step(max(-p.y,p.x+1.0), 0.0)); // left
	col = mix(col, grain(vec2(uv.x-0.6, uv.y)), step(0.0, min(p.y,p.x-1.0))); // right
	col = mix(col, grain(vec2(uv.x*uv.y*1.1, uv.y*5.0-0.1)), step(p.y, 0.0)); // floor

	// lights	
	vec2 q = p / iResolution.xy;
	col = mix(col*1.2, lcol, smoothstep(0.8, -0.9, length(vec2(q.x, 2.4*(q.y-0.02)))));
	col = mix(col, lcol, smoothstep(1.0, -1.6, length(vec2(q.x*3.0, 1.7*(q.y-0.2)))));

	if (max(q.x,-q.y) < 0.0)
	{
		col = mix(col, lcol,smoothstep(1.0, -0.4, length(vec2(q.x*12.0, 4.3*(q.y-0.06)))));
		col += lcol*smoothstep(1.0, -0.7, length(vec2(q.x*32.0-0.4, 7.0*(q.y-0.08))));
	}
	else
	{
		col = mix(col, lcol,smoothstep(1.0, -1.1, length(vec2(q.x*12.0, 4.3*(q.y-0.06)))));
		col = mix(col , lcol*(5.0+21.0*q.y), smoothstep(1.0, -1.6, length(vec2((q.x+q.y*0.01)*46.0+0.15, 2.0*(q.y+0.4)))));
	}
	
	// humanoid
	col = mix(col, vec3(0.4), sprite(p*vec2(0.5, 1.0)+vec2(3.0, -3.0)));

	// more grain
	q.y *= 1.2;
    col *= clamp(-0.01 + (1.0 - q.x*q.x)*(1.0 - q.y*q.y) + rand(p*0.1)*0.2, 0.0, 1.0);
	
	return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy - iResolution.xy * 0.5;
	p.x *= iResolution.x/iResolution.y;
	p.y += 0.25*iResolution.y;
	
	vec3 col = scene(p, 0.8 + 0.2*sin(time));
	
	col += 0.08 * signation((fragCoord.xy - vec2(iResolution.x-40.0, 20.0) )*0.15);
	fragColor = vec4(col, 1.0);
}
