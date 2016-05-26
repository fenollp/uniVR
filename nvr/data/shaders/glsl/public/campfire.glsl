// Shader downloaded from https://www.shadertoy.com/view/Mdj3zD
// written by shadertoy user Dave_Hoskins
//
// Name: Campfire
// Description: Campfire. Stare into the everlasting fire... but watch out for the wolf! (29:00)   : )
//    Drag mouse to spin and zoom.
//    
// Campfire.	By Dave Hoskins. Nov. 2013

// Video:-  http://youtu.be/VBkYDxfO-7Y

// Using ray-marching to step through the volume around the fire,
// colliding with logs, rocks, and also adding flames as it goes
// with a 3D noise algorithm.

#define TAU 6.28318530718

//=================================================================================================
float Hash( float n )
{
    return fract(sin(n)*43758.5453123);
}

//=================================================================================================
float Noise( in float x )
{
    float p = floor(x);
    float f = fract(x);
    f = f*f*(3.0-2.0*f);
    return mix(Hash(p), Hash(p+1.0), f);
}

//=================================================================================================
float Bump( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy + vec2(37.0, 17.0) * p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5) / 256.0, -100.0).yx;
	return mix(rg.x, rg.y, f.z);
}

//=================================================================================================
float Noise( in vec3 x )
{
	x.y -= iGlobalTime *4.0;	
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy + vec2(37.0, 17.0) * p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5) / 256.0, -100.0).yx;
	return mix(rg.x, rg.y, f.z);
}

//=================================================================================================
float FireLog(vec3 p, vec3 a, vec3 b, float r)
{
	vec3 pa = p - a;
	vec3 ba = b - a;
	p = abs(p);
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h ) - r- Bump(p*6.4)*.03 - Bump(p*2.4)*.3;
}

//=================================================================================================
float RoundBox( vec3 p, vec3 add)
{
	return length(max(abs(p+add)-1.1,0.0)) - Bump(p*vec3(1.3, .1, 1.3))*.5;
}

//=================================================================================================
float DE_Fire(vec3 p)
{
	p.xz += (Noise(p * .8))* p.y * .3;
	vec3 shape = p * vec3(1.5, .35, 1.5);
	if (dot(shape, shape) > 70.0) return 1.0;
	
	p += 2.5 * (Noise( shape * 1.5) -
				Noise(-shape * 0.945) *.5 +
				Noise( shape * 9.6)*.3);
	float f = (length( shape) - (1.+Noise(p)*10.0));

	f -= max(3.4-p.y, 0.0)*3.0;
	f -= pow(abs(Noise(shape*3.9)), 45.0) * 300.0 * pow(abs(Noise(shape*1.1)), 5.0);
	return f;
}

//=================================================================================================
float DE_Stones(vec3 p)
{
	p.xz = abs(p.xz);

	float d =  RoundBox(p, vec3(-7.0, 0.9, 0.0));
	d = min(d, RoundBox(p, vec3(0.0, 0.85, -7.0)));
	d = min(d, RoundBox(p, vec3(-5.5, 0.9, -3.)));
	d = min(d, RoundBox(p, vec3(-3.0, 0.95, -5.5)));
	p.y -= 4.0;
	return max(-(length(p)-7.0 - Bump(p)*.3), d);
}

//=================================================================================================
float DE_Logs(vec3 p)
{
	float  d = FireLog(p, vec3(2.0, 0.3, -4.0),  vec3(-3.0, 0.65, 4.0), .5);
	d = min(d, FireLog(p, vec3(3.0, 0.1, 4.0),  vec3(-4.0, 2.4, 0.5), .5));
	d = min(d, FireLog(p, vec3(-2.2, 0.65, -4.5),  vec3(2.0, 1.5, 3.0), .3));
	d = min(d, FireLog(p, vec3(-2.5, 0.0, -2.0),  vec3(3., 0.0, 1.5), .65));
	d = min(d, FireLog(p, vec3(4.5, 0.0, -0.9),  vec3(-4.0, 3.5, 0.9), .1));
	return d;
}

//=================================================================================================
float MapAll(vec3 p)
{
	float d = DE_Logs(p);
	if (d > .05)
		d = min(d, DE_Stones(p));
	return d;
}
//=================================================================================================
vec3 Normal( in vec3 pos )
{
	vec2 eps = vec2( 0.05, 0.0);
	vec3 nor = vec3(
	    MapAll(pos+eps.xyy) - MapAll(pos-eps.xyy),
	    MapAll(pos+eps.yxy) - MapAll(pos-eps.yxy),
	    MapAll(pos+eps.yyx) - MapAll(pos-eps.yyx) );
	return normalize(nor);
}

//=================================================================================================
vec4 Raymarch( in vec3 ro, in vec3 rd, inout int hit, in vec2 fragCoord)
{
	float sum = 0.0;
	// Starting point plus dither to prevent banding...
	float t = 4.2 + .1 * texture2D(iChannel0, fragCoord.xy / iChannelResolution[0].xy).y;
	vec3 pos = vec3(0.0, 0.0, 0.0);
	float d = 100.0;
	for(int i=0; i < 200; i++)
	{
		if (hit > 0 || pos.y < 0.0)
		{
			// Skip the loop code quickly...
			break;
		}
		pos = ro + t*rd;
		
		vec3 shape = pos * vec3(1.5, .4, 1.5);
		if (dot(shape, shape) < 77.0)
		{
			d = DE_Logs(pos);
			if (d < 0.05)
			{
				pos = ro + (t + d) * rd;
				hit = 1;
			}
			else if (d < 0.45)
			{
				// Glow effect around log...
				sum += (.45-d) * .06;
			}
		}
		else
		{
			d = DE_Stones(pos);
			if (d < 0.05)
			{
				pos = ro + (t + d) * rd;
				hit = 2;
			}
		}
		
		float v = 1.0-DE_Fire( pos );
		v = max(v, 0.0) * .00187;
		sum += v;
		
    	t += max(.075, t*.005);
	}
	
	return vec4(pos, clamp(sum*sum*sum, 0.0, 1.0 ));
}

//=================================================================================================
vec2 RotateCamera(vec2 p, float a)
{
	float si = sin(a);
	float co = cos(a);
	return mat2(si, co, -co, si) * p;
}

//=================================================================================================
vec3 FlameColour(float f)
{
	f = f*f*(3.0-2.0*f);
	return  min(vec3(f+.8, f*f*1.4+.1, f*f*f*.7) * f, 1.0);
}

//=================================================================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 p = -1.0 + 2.0 * uv;
	p.x *= iResolution.x/iResolution.y;

	// Camera...
	vec2 mouse;
	if (iMouse.z <= 0.5)
	{
		float time = iGlobalTime+39.5;
		mouse.x = time * 0.025;
		mouse.y = sin(time*.3)*.5 + .5;
	}
	else
	{
		mouse = iMouse.xy / iResolution.xy;
	}

	vec3 origin = vec3(0., 5.3, -13.0+mouse.y *5.0 );
	vec3 target = vec3( 0.0, 4.3-mouse.y*3.0, 0.0 );
	// Spin it with the mouse X...
	origin.xz = RotateCamera(origin.xz, .4 + (mouse.x * TAU));
	
	// Make camera ray using origin and target positions...
	vec3 cw = normalize( target-origin);
	vec3 cp = vec3(0.0, 1.0, 0.0);
	vec3 cu = normalize( cross(cw, cp) );
	vec3 cv = ( cross(cu,cw) );
	vec3 ray = normalize(p.x*cu + p.y*cv + (1.5+(Noise(iGlobalTime*.5))*.1) * cw );
	
	int hit = 0;
	vec4 ret = Raymarch(origin, ray, hit, fragCoord);
	vec3 col = vec3(0.3);
	float flicker = Noise(iGlobalTime*8.0);
	vec3 light = vec3(0.0, 3.25 + flicker, 0.0);
	vec3 nor, ldir;
	if (hit > 0 && hit < 3)
	{
		nor  = Normal(ret.xyz);
		ldir = normalize(light - ret.xyz);
	}

	if (hit == 1)
	{
		// Logs...
		float bri = max(dot(ldir, nor), .4);
		bri = bri*bri * 7.0;
		float f = Bump(ret.xyz*4.53 - vec3 (0.0, iGlobalTime*.37, 0.0))*.8 + Bump(ret.xyz*17.3)*.4;
		f += Bump(ret.xyz * 1.0);
		f = pow(abs(f), 13.0) * .01  + max(.7-dot(ret.xyz, ret.xyz)*.03, 0.0);
		vec3 mat = f * vec3(.8, .4, 0.);
		col = mat * vec3(.1, .04, 0.0) * bri;
		col *= clamp(1.0-length(ret.xz)*.04, 0.0, 1.0);
	}
	else if (hit == 2)
	{
//		// Stones...
		vec3 ref  = reflect(ray, nor);
		float bri = max(dot(ldir, nor), 0.05);
		float spe = max(dot(ldir, ref), 0.0);
		spe = pow(abs(spe), 10.0);
		vec3 mat = vec3(Bump(ret.xyz * 12.3)*.5+.5) * vec3(1.0, .2+texture2D(iChannel0, ret.xz*.002).x*.5, .12);
		col = mat * bri + vec3(.9, .6, .3) * spe;
	}else
	{
		// Grab the forest texture...
		vec3 frst = textureCube(iChannel1, ray-vec3(0.0, .08, 0.0), -100.0).xyz;
		frst = frst*frst;
		col = frst * vec3(.13, .13, .13);
//		// Is ray looking at ground area?...
		if (ray.y < 0.0)
		{
//			// Dodgy re-projection onto floor...
			vec3 pos = origin+vec3(0.0, -7.0, 0.0) + ray * (-origin.y / ray.y);
			vec3 mat = textureCube(iChannel1, pos, -100.0).xyz;
			// Rudimentary bump map...
			vec2 bmp = texture2D(iChannel0, pos.xz*.02, -100.0).xy;
			
			nor = normalize(vec3(bmp.x-.5, 1.0, bmp.y-.5));
			ldir = normalize(light - pos);
			float bri = max(dot(ldir, nor), 0.0);
			mat = mat * mat * vec3(.25, .55, .47) * bri;

			// Do ground FX with pos location...
			float d = dot(pos, pos);
			bri = max(3.0 - (sqrt(d * .005+flicker)), .01);
			
			vec3 hearth = vec3(0.005, 0.0, 0.0);
			float f = Bump(vec3(pos.x, iGlobalTime*.024, pos.z) * 21.0);
			f += Bump(vec3(pos.x, iGlobalTime*.001, pos.z) * 5.3);
			f = pow(abs(f), 15.0) * .0001;
			
			hearth += f * vec3(.7, .15, 0.) * max(85.-d, 0.0);
			mat = mix(hearth, mat, smoothstep(80.0, 180.0, d));
			
			mat *= vec3(1.0, .3, 0.1) * bri;
			col = mix(col, mat, min((ray.y*ray.y) * 146.0, 1.0));
		}
		else
		{
//			// Wolf eyes...
			float lum  = max(sin(iGlobalTime*.5 - 1.2), 0.0);
			float eye1 = max( dot(normalize(vec3(-.04,  .05, -1.0)), normalize(ray* vec3(1.0, 3.0, 1.0)))-.99994, 0.0);
			float eye2 = max( dot(normalize(vec3(-.085, .05, -1.0)), normalize(ray* vec3(1.0, 3.0, 1.0)))-.99994, 0.0);
			float f = sin(iGlobalTime*.33-1.0);
			eye2 *= smoothstep(0.1, .0, f) + smoothstep(0.1, .2, f);
			col.x = clamp(col.x + (eye1+eye2)*5000.0 * lum, .0, 1.0);
		}
	}
	
	col += FlameColour(ret.w);
	
	// Contrasts...
	col = (1.0-exp(-col*2.0))*1.15;
	col = sqrt(col);	
	
	//col = min(mix(vec3(length(col)),col, 1.1), 1.0);
	// Vignette...
	col *= 0.5 + 0.5 * pow(150.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y), .5 );	
	
	fragColor = vec4(col,1.0);	
}