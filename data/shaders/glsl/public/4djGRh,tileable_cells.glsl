// Shader downloaded from https://www.shadertoy.com/view/4djGRh
// written by shadertoy user Dave_Hoskins
//
// Name: Tileable Cells
// Description: A tileable cell texture creator for games, or anything else that needs tiling.
//    Snazzy water caustic animations left out for clarity! ;)
//    
// Tileable Cells. By David Hoskins. 2013.

#define NUM_CELLS	16.0	// Needs to be a multiple of TILES!
#define TILES 		2.0		// Normally set to 1.0 for a creating a tileable texture.

#define SHOW_TILING			// Display yellow lines at tiling locations.
#define ANIMATE			// Basic movement using texture values.

//------------------------------------------------------------------------
vec2 Hash2(vec2 p)
{
	#ifdef ANIMATE
	
	float t = fract(iGlobalTime*.0003);
	return texture2D(iChannel0, p*vec2(.135+t, .2325-t), -100.0).xy;
	
	#else
	
	float r = 523.0*sin(dot(p, vec2(53.3158, 43.6143)));
	return vec2(fract(15.32354 * r), fract(17.25865 * r));
	
	#endif
}

//------------------------------------------------------------------------
float Cells(in vec2 p, in float numCells)
{
	p *= numCells;
	float d = 1.0e10;
	for (int xo = -1; xo <= 1; xo++)
	{
		for (int yo = -1; yo <= 1; yo++)
		{
			vec2 tp = floor(p) + vec2(xo, yo);
			tp = p - tp - Hash2(mod(tp, numCells / TILES));
			d = min(d, dot(tp, tp));
		}
	}
	return sqrt(d);
	//return 1.0 - d;// ...Bubbles.
}

//------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	#ifdef ANIMATE
	float c = Cells(uv+iGlobalTime*.025, NUM_CELLS);
	#else
	float c = Cells(uv, NUM_CELLS);
	#endif

	vec3 col = vec3(c*.83, c, min(c*1.3, 1.0));
	
	#ifdef SHOW_TILING
	// Flash tile borders...
	vec2 pixel = TILES / iResolution.xy;
	uv *= TILES;

	float f = floor(mod(iGlobalTime*.5, 2.0)); 	// Flash value.
	vec2 first = step(pixel, uv) * f;		   	// Rule out first screen pixels and flash.
	uv  = step(fract(uv), pixel);				// Add one line of pixels per tile.
	col = mix(col, vec3(1.0, 1.0, 0.0), (uv.x + uv.y) * first.x * first.y); // Yellow line
	
	#endif

	fragColor = vec4(col, 1.0);
}
