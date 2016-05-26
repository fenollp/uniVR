// Shader downloaded from https://www.shadertoy.com/view/4dlGW2
// written by shadertoy user Dave_Hoskins
//
// Name: Tileable Noise
// Description: There are all sorts of weird and wonderful noise tiling sources on the Net, including 4D noise creation and cylinder wrapping. So here's my contribution, it should be a lot faster. :)
//    Remove define at the top to see single tile. Mouse to scroll about.
// https://www.shadertoy.com/view/4dlGW2

// Tileable noise, for creating useful textures. By David Hoskins, Sept. 2013.
// It can be extrapolated to other types of randomised texture.

#define SHOW_TILING
#define TILES 2.0 // Use 1.0 for normal tiling across whole texture.

//----------------------------------------------------------------------------------------
float Hash(in vec2 p, in float scale)
{
	// This is tiling part, adjusts with the scale...
	p = mod(p, scale);
	return fract(sin(dot(p, vec2(27.16898, 38.90563))) * 5151.5473453);
}

//----------------------------------------------------------------------------------------
float Noise(in vec2 p, in float scale )
{
	vec2 f;
	
	p *= scale;

	
	f = fract(p);		// Separate integer from fractional
    p = floor(p);
	
    f = f*f*(3.0-2.0*f);	// Cosine interpolation approximation
	
    float res = mix(mix(Hash(p, 				 scale),
						Hash(p + vec2(1.0, 0.0), scale), f.x),
					mix(Hash(p + vec2(0.0, 1.0), scale),
						Hash(p + vec2(1.0, 1.0), scale), f.x), f.y);
    return res;
}

//----------------------------------------------------------------------------------------
float fBm(in vec2 p)
{
    p += vec2(sin(iGlobalTime * .7), cos(iGlobalTime * .45))*(.1) + iMouse.xy*.1/iResolution.xy;
	float f = 0.0;
	// Change starting scale to any integer value...
	float scale = 10.;
    p = mod(p, scale);
	float amp   = 0.6;
	
	for (int i = 0; i < 5; i++)
	{
		f += Noise(p, scale) * amp;
		amp *= .5;
		// Scale must be multiplied by an integer value...
		scale *= 2.;
	}
	// Clamp it just in case....
	return min(f, 1.0);
}

//----------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    	

	#ifdef SHOW_TILING
	uv *= TILES;
	#endif
	
	// Do the noise cloud (fractal Brownian motion)
	float bri = fBm(uv);
	
	bri = pow(bri, 1.2); // ...cranked up the contrast for demo.
	vec3 col = vec3(bri);
	
	#ifdef SHOW_TILING
	// Flash tile borders...
	vec2 pixel = TILES / iResolution.xy;
	if (mod(iGlobalTime-2.0, 4.0) < 2.0)
	{
		vec2 first 		= step(pixel, uv);
		uv  = step(fract(uv), pixel);	// Only add one line of pixels per tile.
		col = mix(col, vec3(1.0, 1.0, 0.0), (uv.x + uv.y) * first.x * first.y);
	}
	#endif

	fragColor = vec4(col,1.0);
}