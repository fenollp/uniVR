// Shader downloaded from https://www.shadertoy.com/view/4sS3RV
// written by shadertoy user Dave_Hoskins
//
// Name: Voronoi Fireball
// Description: Experiment using a 3D Voronoi distance field.
// Voronoi Fireball
// By David Hoskins

float gTime = 0.0;

//----------------------------------------------------------------------
vec2 Rotate2D(vec2 p, float a)
{
	float si = sin(a);
	float co = cos(a);
	return mat2(si, co, -co, si) * p;
}

//----------------------------------------------------------------------
float Noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

//--------------------------------------------------------------------------
float Voronoi(in vec3 p)
{
	float d = 1.0e10;
	for (int zo = -1; zo <= 1; zo++)
	{
		for (int xo = -1; xo <= 1; xo++)
		{
			for (int yo = -1; yo <= 1; yo++)
			{
				vec3 tp = floor(p) + vec3(xo, yo, zo);
				d = min(d, length(p - tp - Noise(p)));
			}
		}
	}
	return .72 - d*d*d;
}

//--------------------------------------------------------------------------
vec3 FlameColour(float f)
{
	if (f > .999999) return vec3(1.0);
	return  min(vec3(f*5.0, f*f, f*f*.05), 1.0);
}

//--------------------------------------------------------------------------
vec4 Map(in vec3 p)
{
	vec3 col = vec3(0.0);
	float di = length(p)-8.0;

	if (di > 0.0)
	{
		di -= Noise(p * 1.5 + vec3(0.0, 0.0, gTime * 1.5)) * 8.0 + cos(gTime * .5) * 4.0 + 6.0;
		
		vec3 loops = p + vec3(0.0, 0.0, gTime * 5.0);
		loops.xy = Rotate2D(loops.xy, di * .15 - gTime * .15);
		
		float h = Voronoi(loops * .2);
		di = di + pow(h, 12.0)*500.0;
		col = FlameColour(clamp(-di*.13, 0.0, 1.0));
	}else
	{
		col = vec3(1.0);
		di *= 20.0;
	}
	return vec4(col, -di*.006);
}

//--------------------------------------------------------------------------
vec3 Scene(in vec3 rO, in vec3 rD)
{
    float t = 10.0;
	vec3 p = vec3(0.0);
	vec4 sum = vec4(0.0);
	for( int j=0; j < 80; j++ )
	{
		if (sum.a >= 1.0) break;
		p = rO + t*rD;
		vec4 res = Map(p);

		res.rgb *= res.a;
		sum = sum + res * (1.0 - sum.a);	
		
		t += 0.15;
	}
	return clamp(sum.xyz, 0.0, 1.0);
}

//--------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	gTime = iGlobalTime+11.0;
	vec2 uv = (-1.0 + 2.0 * fragCoord.xy / iResolution.xy) * vec2(iResolution.x/iResolution.y,1.0);
	
	vec3 cameraPos = vec3(0.0, 0.0, -25.0);
	//cameraPos.xz = Rotate2D(cameraPos.xz, gTime*.5); // ...Rotate camera if you want

	vec3 cw = normalize(-cameraPos); 	// Look at 0,0,0 target
	vec3 cp = vec3(0.0, 1.0,0.0);		// Y vector
	vec3 cu = cross(cw,cp);				// X vector
	vec3 dir = normalize(uv.x*cu + uv.y*cp + 1.3*cw);
	vec3 col = Scene(cameraPos, dir);

	fragColor=vec4(col,1.0);
}
