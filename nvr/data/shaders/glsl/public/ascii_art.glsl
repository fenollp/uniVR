// Shader downloaded from https://www.shadertoy.com/view/lssGDj
// written by shadertoy user movAX13h
//
// Name: Ascii Art
// Description: basic bitmap to (mouse clicked ? grayscale : color) ascii (8 characters) art shader
// Bitmap to ASCII (not really) fragment shader by movAX13h, September 2013
// --- This shader is now used in Pixi JS ---

// If you change the input channel texture, disable this:
#define HAS_GREENSCREEN

float character(float n, vec2 p) // some compilers have the word "char" reserved
{
	p = floor(p*vec2(4.0, -4.0) + 2.5);
	if (clamp(p.x, 0.0, 4.0) == p.x && clamp(p.y, 0.0, 4.0) == p.y)
	{
		if (int(mod(n/exp2(p.x + 5.0*p.y), 2.0)) == 1) return 1.0;
	}	
	return 0.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy;
	vec3 col = texture2D(iChannel0, floor(uv/8.0)*8.0/iResolution.xy).rgb;	
	
	#ifdef HAS_GREENSCREEN
	float gray = (col.r + col.b)/2.0; // skip green component
	#else
	float gray = (col.r + col.g + col.b)/3.0;
	#endif
	
	float n =  65536.0;             // .
	if (gray > 0.2) n = 65600.0;    // :
	if (gray > 0.3) n = 332772.0;   // *
	if (gray > 0.4) n = 15255086.0; // o 
	if (gray > 0.5) n = 23385164.0; // &
	if (gray > 0.6) n = 15252014.0; // 8
	if (gray > 0.7) n = 13199452.0; // @
	if (gray > 0.8) n = 11512810.0; // #
	
	vec2 p = mod(uv/4.0, 2.0) - vec2(1.0);
	if (iMouse.z > 0.5)	col = gray*vec3(character(n, p));
	else col = col*character(n, p);
	
	fragColor = vec4(col, 1.0);
}