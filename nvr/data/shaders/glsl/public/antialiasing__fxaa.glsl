// Shader downloaded from https://www.shadertoy.com/view/4tf3D8
// written by shadertoy user 4rknova
//
// Name: Antialiasing: FXAA
// Description: FXAA
//    Fast approXimate Anti-Aliasing
// by Nikos Papadopoulos, 4rknova / 2015
// WTFPL

#define RES iResolution.xy

vec3 sample(vec2 p)
{
    p = p * .008 + vec2(.123,.657);
    vec2 z = vec2(0);  

	for (int i = 0; i < 256; ++i) {  
		z = vec2(z.x * z.x - z.y * z.y, 2. * z.x * z.y) + p; 

		if (dot(z,z) > 4.) {
			float s = .125662 * float(i);
			return vec3(vec3(cos(s + .9), cos(s + .3), cos(s + .2)) * .4 + .6);			
		}  
	}
    return vec3(0);
}

vec3 fxaa(vec2 p)
{
	float FXAA_SPAN_MAX   = 8.0;
    float FXAA_REDUCE_MUL = 1.0 / 8.0;
    float FXAA_REDUCE_MIN = 1.0 / 128.0;

    // 1st stage - Find edge
    vec3 rgbNW = sample(p + (vec2(-1.,-1.) / RES));
    vec3 rgbNE = sample(p + (vec2( 1.,-1.) / RES));
    vec3 rgbSW = sample(p + (vec2(-1., 1.) / RES));
    vec3 rgbSE = sample(p + (vec2( 1., 1.) / RES));
    vec3 rgbM  = sample(p);

    vec3 luma = vec3(0.299, 0.587, 0.114);

    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM  = dot(rgbM,  luma);

    vec2 dir;
    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
    dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
    
    float lumaSum   = lumaNW + lumaNE + lumaSW + lumaSE;
    float dirReduce = max(lumaSum * (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
    float rcpDirMin = 1. / (min(abs(dir.x), abs(dir.y)) + dirReduce);

    dir = min(vec2(FXAA_SPAN_MAX), max(vec2(-FXAA_SPAN_MAX), dir * rcpDirMin)) / RES;

    // 2nd stage - Blur
    vec3 rgbA = .5 * (sample(p + dir * (1./3. - .5)) +
        			  sample(p + dir * (2./3. - .5)));
    vec3 rgbB = rgbA * .5 + .25 * (
        			  sample(p + dir * (0./3. - .5)) +
        			  sample(p + dir * (3./3. - .5)));
    
    float lumaB = dot(rgbB, luma);
    
    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

    return ((lumaB < lumaMin) || (lumaB > lumaMax)) ? rgbA : rgbB;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy * 2. - 1.);
	vec2 nv = uv * vec2(iResolution.x/iResolution.y, 1) * 1.1;
            
    float t = iGlobalTime * .1;
          t = (mod(t, 2.) < 1. ? 1. : -1.) * (fract(t) * 2. - 1.);
    vec3  col = vec3((uv.x < t ? fxaa(nv) : sample(nv)) 
              * smoothstep(0., 1. / iResolution.y, abs(t - uv.x))
	);
    
	fragColor = vec4(col, 1);
}