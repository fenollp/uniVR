// Shader downloaded from https://www.shadertoy.com/view/lsVXR1
// written by shadertoy user jimbo00000
//
// Name: Khronos logo remixed
// Description: Unauthorized remix of the Khronos logo.
// Join or start your local Khronos chapter!

#define PI 3.1415926535897932384

// Trefoil shape from iq
// http://www.iquilezles.org/www/articles/distance/distance.htm
float dFunc( in float r, in float a )
{
    a -= .54;
    if (a > 2.2)
        return 9999.0;
    a -= 2.;
    
	float num = .5;
	float sweep = -.05;
	float pointy = 2.5+.1*sin(4.*iGlobalTime);
    float phase = .5+PI*.85*(1.-PI*.45*fract(.25*iGlobalTime));
        //.5+.25*sin(1.*iGlobalTime)
    float amp = .1*(1.+(sin(2.*iGlobalTime)));
    r += //amp*(3.+2.)*
        clamp(1.-.5*abs(3.*(5.*a+4.*(
		phase
    	))),0., 1.);
	return r - 1.0 - pointy*sin( num*a + 1.-sweep*(r) );
}

float polarFunc(in vec2 pt, in vec2 cent)
{
	float r = 2.7 * length( pt - cent );
	float a = atan( pt.y, pt.x );
	float d = dFunc( r, a );
    return smoothstep( 0.19, 0.22, abs(d) );
}

// Convert {uv, center} pair to polar coords {r, theta}
// and pass them on to dist func
float getDist( in vec2 pt, in vec2 cent )
{
    pt *= vec2(.45, -.8);
    float t = 2.*iGlobalTime;
    vec2 shift = vec2(.2,-.38) + vec2(.03,.01)*vec2(sin(t), cos(t));
    return min(
        polarFunc(pt-shift, cent),
        polarFunc(-pt-shift, cent)
        );
}


// Ripped off from: https://www.shadertoy.com/view/XsXXRN
float rand(vec2 n) {
    return fract(cos(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 n) {
    const vec2 d = vec2(0.0, 1.0);
    vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
    return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}

float fbm(vec2 n) {
    float total = 0.0, amplitude = 1.0;
    for (int i = 0; i < 4; i++) {
        total += noise(n) * amplitude;
        n += n;
        amplitude *= 0.5;
    }
    return total;
}

void fire301( out vec4 fragColor, in vec2 fragCoord ) {
    const vec3 c1 = vec3(0.5, 0.0, 0.1);
    const vec3 c2 = vec3(0.9, 0.0, 0.0);
    const vec3 c3 = vec3(0.2, 0.0, 0.0);
    const vec3 c4 = vec3(1.0, 0.9, 0.0);
    const vec3 c5 = vec3(0.1);
    const vec3 c6 = vec3(0.9);

    vec2 speed = vec2(0.7, 0.4);
    float shift = 1.6;
    float alpha = 1.0;

    vec2 p = fragCoord.xy * 8.0 / iResolution.xx;
    float q = fbm(p - iGlobalTime * 0.1);
    vec2 r = vec2(fbm(p + q + iGlobalTime * speed.x - p.x - p.y), fbm(p + q - iGlobalTime * speed.y));
    vec3 c = mix(c1, c2, fbm(p + r)) + mix(c3, c4, r.x) - mix(c5, c6, r.y);
    fragColor = vec4(c * cos(shift * fragCoord.y / iResolution.y), alpha);
}

// Simple thresholding
float color( in vec2 x, in vec2 cent )
{
    float v = getDist( x, cent );
    return v;//smoothstep( 0.19, 0.24, abs(v) );
}

vec3 getColorFromUV( in vec2 rawuv, in vec2 uv11 )
{
    vec4 fireColor;
    fire301(fireColor, rawuv);    
    vec3 fgCol = fireColor.rgb;//vec3(1.,0.,0.);
    fgCol.r *= 1.8;
    fgCol = mix(fgCol,vec3(1.,0.,0.),.25);
    //return fgCol;
	return mix(fgCol, vec3(1.), color( uv11, vec2(0.0, 0.0)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

	// Fit [-1,1] into screen and expand for aspect ratio
	vec2 uv11 = 2.0*uv - vec2(1.0,1.0);
	float aspect = iResolution.x / iResolution.y;
	if (aspect > 1.0)
	{
		uv11.x *= aspect;
	}
	else
	{
		uv11.y /= aspect;
	}
	
	fragColor = vec4(getColorFromUV(fragCoord, uv11), 1.0);
}
