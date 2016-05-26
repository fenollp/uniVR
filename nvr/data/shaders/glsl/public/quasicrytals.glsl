// Shader downloaded from https://www.shadertoy.com/view/Msc3Rn
// written by shadertoy user charmless
//
// Name: quasicrytals
// Description: As described at http://mainisusuallyafunction.blogspot.ca/2011/10/quasicrystals-as-sums-of-waves-in-plane.html
// try changing LAYERS - 3,5,7 are nice.
// try changing the wrap function (wrap1, wrap2, wrap3) used at the end of quasicrystal()

#define PI 3.14159265359
#define LAYERS 7.

float wave(float theta, vec2 p) {
	return (cos(dot(p,vec2(cos(theta),sin(theta)))) + 1.) / 2.;
}


// triangular wrapping
float wrap1(float val) {
    float v_int = floor(val), 
          v_frac = fract(val);

    bool even = fract(v_int / 2.) < 1e-4;
	return even ? v_frac : 1. - v_frac;
}

// sawtooth wrapping
float wrap2(float val) {
    return fract(val);
}

// sinusoidal wrapping
float wrap3(float val) {
    return (1. + sin(val)) / 2.;
}


float quasicrystal(vec2 p) {
    float sum = 0.;
    for(float theta = 0.; theta < PI; theta += PI/LAYERS) 
        sum += wave(theta, p);

    return wrap1(sum);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	float ratio = iResolution.x/iResolution.y;
	vec2 uv = fragCoord.xy/iResolution.y;
    vec2 target = vec2(mix(-.3, .7, cos(iGlobalTime*.02)),
                       mix(-.2, .4, sin(iGlobalTime*.012)));
    uv -= vec2(target.x * ratio, target.y);
    uv *= mix(128., 180., sin(iGlobalTime*.2));


    fragColor = vec4(quasicrystal(uv));  
}