// Shader downloaded from https://www.shadertoy.com/view/4dBGWG
// written by shadertoy user 4rknova
//
// Name: Rotoscoping
// Description: Simple rotoscoping.
//    Use the mouse to position the divider and compare the input with the output.
// by Nikos Papadopoulos, 4rknova / 2014
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// The layers
//#define ENABLE_EDGES
#define ENABLE_COLOR
#define ENABLE_QUANTIZATION

#define EDGE_COEF         7.
#define QUANTIZATION_FULL 6.
#define QUANTIZATION_LOW  1.2

vec3 sample(vec2 uv, float mul)
{
	return texture2D(iChannel0, uv).xyz * mul;
}

float rlum(vec3 col)
{
	return dot(col, vec3(.2126, .7152, .0722));
}

vec3 denoise(inout vec2 uv, float mul)
{
	const float rads = 256., val0 = 1., val1 = .125;
    float dx, dy;

	vec3 acc = vec3(0);

	for (int i = 1; i < 16; ++i)
  	{
    	dx = dy = 1. / rads;
    	acc += sample(uv + vec2(-dx, -dy), mul) * val1;
    	acc += sample(uv + vec2( 0., -dy), mul) * val1;
    	acc += sample(uv + vec2(-dx,  0.), mul) * val1;
    	acc += sample(uv + vec2( dx,  0.), mul) * val1;
    	acc += sample(uv + vec2( 0.,  dy), mul) * val1;
    	acc += sample(uv + vec2( dx,  dy), mul) * val1;
    	acc += sample(uv + vec2(-dx,  dy), mul) * val1;
    	acc += sample(uv + vec2( dx, -dy), mul) * val1;
  	}
	
  	return acc / 16.;
}

vec3 rotoscope_full(vec2 uv)
{
	vec3 cl = denoise(uv, 3.5) / QUANTIZATION_FULL;
	
	// Quantize
	vec3 rc = vec3(0);
	float lm = rlum(cl);
	for (int l = 1; l <= int(QUANTIZATION_FULL); ++l) {
		float coef = 1. / float(l);
		if (lm > coef){
			rc += coef;
		}
	}
	
	return rc;
}

vec3 rotoscope_low(vec2 uv)
{
	vec3 cl = denoise(uv, 3.5) / QUANTIZATION_LOW;
	
	// Quantize
	vec3 rc = vec3(0);
	float lm = rlum(cl);
	for (int l = 1; l <= int(QUANTIZATION_LOW); ++l) {
		float coef = 1. / float(l);
		if (lm > coef){
			rc += coef;
		}
	}
	
	return rc;
}


float edge(vec2 uv)
{
	const float d = 1. / 768.;
	
	vec3 hc =rotoscope_low(uv + vec2(-d,-d)) *  1. + rotoscope_low(uv + vec2( 0,-d)) *  2.
		 	+rotoscope_low(uv + vec2( d,-d)) *  1. + rotoscope_low(uv + vec2(-d, d)) * -1.
		 	+rotoscope_low(uv + vec2( 0, d)) * -2. + rotoscope_low(uv + vec2( d, d)) * -1.;
		
	vec3 vc =rotoscope_low(uv + vec2(-d,-d)) *  1. + rotoscope_low(uv + vec2(-d, 0)) *  2.
		 	+rotoscope_low(uv + vec2(-d, d)) *  1. + rotoscope_low(uv + vec2( d,-d)) * -1.
		 	+rotoscope_low(uv + vec2( d, 0)) * -2. + rotoscope_low(uv + vec2( d, d)) * -1.;
	
	return rlum(vc*vc + hc*hc) / EDGE_COEF;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 ns = sample(uv, 1.);

#ifdef ENABLE_QUANTIZATION
	vec3 cl = rotoscope_full(uv);
#else 	
	vec3 cl = vec3(1);
#endif

	float m = iMouse.x / iResolution.x ;
	
#ifdef ENABLE_EDGES
	float e = edge(uv);
	cl -= vec3(e < .5 ? e : 1.) / float(QUANTIZATION_FULL);
#endif
	
#ifdef ENABLE_COLOR
	cl *= ns;
#endif	
	
	vec3  frs = vec3(
		  (uv.x  < m ? ns : cl)    // Mix the 2 channels
		* smoothstep(0., 1. / iResolution.y, abs(m - uv.x))
	);
	
	fragColor = vec4(frs, 1);
}