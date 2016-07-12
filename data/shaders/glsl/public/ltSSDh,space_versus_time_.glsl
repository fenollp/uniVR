// Shader downloaded from https://www.shadertoy.com/view/ltSSDh
// written by shadertoy user qwert33
//
// Name: Space versus Time.
// Description: Without time, space is nothing

float space;
float time;

// Code made by Dominik Schmid (DominikSchmid93@gmail.com)
// All rights reserved.
// I'm willing to give permission but you need to request it.

//======= configuration ======
const bool stars              = true;  // true or false
const bool antialiasing       = !stars;  // performance / quality tradeoff
const float star_brightness   = 60.0;
const float period_animating  = 7.0;
const float period_paused     = 3.0;  // set to 0.0 for continuous spinning
const float noise_speed       = 0.04;
const float noise_period      = 2.0;
const float symbol_spin_speed = 0.5;
const float symbol_size       = 0.47;
//============================




float semiCircle(float x) {
    x = (2.0 * x - 1.0);
    return sqrt(1.0 - x*x);
}

// ====== GOD-TIER MAGIC NUMBERS BE HERE ======
bool funcTop(vec2 uv) {
    float v = uv.x;
    return uv.y < (
        semiCircle(v) * 1.0572 +
    	v * -2.5859 +
    	v*v * 4.6388 +
    	v*v*v * -3.4358 +
    	v*v*v*v * -0.3645 +
    	v*v*v*v*v * 2.3144 +
        v*v*v*v*v*v * -0.74707
    );
}
bool funcBot(vec2 uv) {
    float v = uv.x;
    return uv.y > (
    	v * 3.6983 +
    	v*v * -15.727 +
    	v*v*v * 37.77 +
    	v*v*v*v * -52.872 +
    	v*v*v*v*v * 39.513 +
        v*v*v*v*v*v * -12.563
    );
}
float arc(vec2 uv) {
    if (uv.x < 0.0) return 0.0;
    if (uv.x > 1.0) return 0.0;
    if (funcTop(uv) && funcBot(uv)) return 1.0;
    return 0.0;
}

// outputs a linearly rising function which is periodically flat
float pauseStep(float x, float d1, float d2) {
    return (
        min(d1, mod(x, d1+d2)) + 
        d1 * floor(x / (d1+d2))
    );
}

float rand(vec2 p){
    p /= iResolution.xy;
    return fract(sin(dot(p.xy, vec2(12.9898, 78.2377))) * 43758.5453);
}

float getNoise(vec2 noiseCoord, float angleOffset, float noiseSeed, float r) {
    float angle = noise_period * time;
    angle += angleOffset;
    r *= space;
    noiseCoord += vec2(
        floor(r * sin(angle)),
        floor(r * cos(angle))
    );
    
    noiseCoord.x += noiseSeed;
    
    return rand(noiseCoord);    
}

// makes a rotation matrix
mat2 rotate(float theta) {
    float s = sin(theta);
    float c = cos(theta);
    return mat2(
        c, -s,
        s,  c
    );
}

// magic function to make a bending curve
float twang(float x, float d) {
    return (
        (x * (d*d*d + d)) /
        (d * (d*d + abs(x)))
    );
}

void isInSymbol(vec2 uv, out float layer) {
    uv /= symbol_size;
    
    //layer += (length(uv) < 0.7)? 1.0 : 0.0;  // a circle in the middle
    float t = time * symbol_spin_speed;
    layer += arc(rotate(t + radians(000.0)) * uv);
    layer += arc(rotate(t + radians(060.0)) * uv);
    layer += arc(rotate(t + radians(120.0)) * uv);
    layer += arc(rotate(t + radians(180.0)) * uv);
    layer += arc(rotate(t + radians(240.0)) * uv);
    layer += arc(rotate(t + radians(300.0)) * uv);
}

// clamps to 0..1
float clamp01(float x) {
    return max(0.0, min(1.0, x));
}

// maps from pixel coordinate frame to UV coordinate frame
vec2 toSpace_uv(vec2 space_pixel) {
    return space_pixel.xy / space;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    space = min(iResolution.x, iResolution.y);
	time = pauseStep(iGlobalTime, period_animating, period_paused);
    
    vec2 pix = fragCoord;
    vec2 uv = toSpace_uv(pix.xy);//(p.xy - iResolution.xy / 2.0) / space;
    uv -= toSpace_uv(iResolution.xy / 2.0);
    // uv += toSpace_uv(vec2(sin(time), 0.0)); // minor wobble to test antialiasing
    
    float layer = 0.0; // in which of the two layers are we? range 0..1
    isInSymbol(uv, layer);
    
    if (antialiasing) {
        const float AA_radius = 0.5;
        isInSymbol(uv + toSpace_uv(AA_radius * vec2( 1.0,  0.0)), layer);
        isInSymbol(uv + toSpace_uv(AA_radius * vec2(-1.0,  0.0)), layer);
        isInSymbol(uv + toSpace_uv(AA_radius * vec2( 0.0, -1.0)), layer);
        isInSymbol(uv + toSpace_uv(AA_radius * vec2( 0.0,  1.0)), layer);
        layer /= 5.0;
    }
    

    float layer0 = !stars? 0.0 : getNoise(pix, radians(  0.0), 0.0, 1.0*noise_speed);
    float layer1 = !stars? 1.0 : getNoise(pix, radians(180.0), 0.5, 1.0*noise_speed);
    float brightness = mix(layer0, layer1, layer);
    if (stars) {
        brightness = 1.0 - twang(1.0 - brightness, star_brightness / space); // make stars less bright if we have more pixels
    }
    fragColor = vec4(brightness);
    
    if (stars) {
        // apply some post-processing
        fragColor *= vec4(0.8, 1.0, 0.9, 1.0);
        //fragColor *= min(1.0, 1.5 / (length(uv) * length(uv)));  // vignette
        fragColor *= pow(1.5, -length(uv));  // subtle vignette
    }
}