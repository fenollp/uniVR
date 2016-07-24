// Shader downloaded from https://www.shadertoy.com/view/XtX3zl
// written by shadertoy user jherico
//
// Name: AudioToy
// Description: Working on a potential audio meter for voice.
const float PI = 3.1415926;
const vec3 COLOR = vec3(0xEE, 0x94, 0x02) / vec3(255);
const vec3 HIGHLIGHT = vec3(0xFC, 0xCD, 0x81) / vec3(255);
const vec3 BG = vec3(0x3D) / vec3(255);

/* 
 * This fragment shader is intented to produce a ring with varying color around
 * its circumference.  It has two modes.  
 
 * The first is the 'waveform' state, where the highlighted
 * amount of the ring is determined by the incoming uniform iAudio, which is 
 * presumably being driven by an audio level from hardware.  In this mode 
 * the ring displays bilateral symmetry, with the highlight color starting 
 * at the bottom and going up both sides as the value of iAudio increases   
 *
 * The second mode is a 'wait' state which is selected whenever the iAudio value 
 * falls below zero.  In this mode, the ring displays three-way axial symmetry
 * and slowly rotates the three regions of highlighting around the axis over time.
 * 
 * This code relies heavily on the GLSL function smoothstep to create transitions 
 * between the highlight color and the 'background' color as well as to control the 
 * alpha value at the edge of the ring to provide antialiasing
 * 
 * In order to test or modify this code without having to deal with an android build and
 * debug cycle between every change, you can use the website Shadertoy.com to test changes.
 * Simply copy the entire contents of this file to a new shader on Shadertoy.com and 
 * uncomment the '#define SHADERTOY' line below.  If you wish to test responsiveness to audio
 * input, you should set the iChannel0 input on Shadertoy to an audio file, and populate 
 * iAudio with a value from that channel, as seen in the main function below. 
 */

#define SHADERTOY 

#ifdef SHADERTOY
float iAudio;
vec4 bg;
#else
uniform float iAudio;
uniform vec2 iResolution;
uniform float iGlobalTime;
#endif

float aastep(float threshold, float dist) {
    float afwidth = 0.7 * length(vec2(dFdx(dist), dFdy(dist)));
    return smoothstep(threshold - afwidth, threshold + afwidth, dist);
}

vec2 waveform(float theta) {
    // Controls the minimum amount of the waveform to show 
    const float MIN_ACTIVE = 0.3;
    // Controls the width of the gradient from the active to the passive color
    const float TRANSITION_WIDTH = 0.1;

    theta = abs(theta);

    float level = max(iAudio, MIN_ACTIVE); 
    float color = smoothstep(level, level - TRANSITION_WIDTH, 1.0 - theta);
    level = pow(level, 1.6);
    float highlight = smoothstep(level, level - TRANSITION_WIDTH * 4.0, 1.0 - theta);
    return vec2(color, highlight);
}


vec2 waitOld(float theta) {
    // Controls the width of the spinners in wait mode
    const float WAIT_CENTER = 0.5;
    const float WAIT_WIDTH = 0.1;
    const float WAIT_MIN = WAIT_CENTER - WAIT_WIDTH;
    const float WAIT_MAX = WAIT_CENTER + WAIT_WIDTH;
    // Controls the width of the gradient from the active to the passive color
    const float TRANSITION_WIDTH = 0.02;

    // How fast will we spin the circle (revolutions per second)
    const float ANIMATION_SPEED = 0.33;

    // Animate the circle
    theta = fract(theta + iGlobalTime * ANIMATION_SPEED);

    float level = smoothstep(WAIT_MAX, WAIT_MAX - TRANSITION_WIDTH, theta) * 
        smoothstep(WAIT_MIN, WAIT_MIN + TRANSITION_WIDTH, theta);
    
    return vec2(level, 1.0);
}


float smoothsteprange(float max, float min, float transition, float value) {
    return smoothstep(max, max - transition, value) * 
        smoothstep(min, min + transition, value);
}

vec2 circle(vec2 ndc) {
    // The inner radius of the ring
    const float INNER_RADIUS = 0.8;
    // The outer radius of the ring
    const float OUTER_RADIUS = 1.0;
    // The width of the transition from the edge of the ring to the background (for anti-aliasing)
    const float TRANSITION_WIDTH = 0.02;
    const float CIRCLE_SMOOTH = 0.05;
    const float CENTER = (OUTER_RADIUS + INNER_RADIUS) / 2.0;
    const float HALF_WIDTH = (OUTER_RADIUS - INNER_RADIUS) / 2.0;
    

    float r = length(ndc);
    if (r < INNER_RADIUS || r > OUTER_RADIUS) {
        // If we're not in the circle, just return 0, so the caller will discard the pixel
        return vec2(0.0);
    }
    
    

    // Calculate the alpha value via smoothstep.  
    // float alpha = aastep(INNER_RADIUS, r) * (1.0 - aastep(OUTER_RADIUS, r));
    float alpha = smoothsteprange(OUTER_RADIUS, INNER_RADIUS, TRANSITION_WIDTH, r);
    float centerDist = abs(CENTER - r) / HALF_WIDTH;
    return vec2(alpha, 0.0) ;
}

vec2 getPixelCoordinate() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 ndc = (uv * 2.0) - 1.0;
    float aspect = iResolution.x / iResolution.y; 
    if (aspect > 1.0) {
        ndc.x *= aspect;
    } else if (aspect < 1.0) {
        ndc.y /= aspect;
    }
    return ndc;
}


float getTheta(vec2 ndc, float symmetry) {
    // Map theta to the range (-1,1), 0.0 is at the top
    float theta = atan(ndc.x, ndc.y) / PI;
    if (2.0 == symmetry) {
        // Bilateral symmetry
        theta = abs(theta);
    } else if (symmetry > 2.0) {
        // Axial symmetry
        theta = theta + 1.0;
        theta /= 2.0;
        theta = fract(theta * symmetry);
    } else if (symmetry < 1.0) {
        // No symmetry, map the whole circle to (0, 1), 0.5 is at the top.
        theta = theta + 1.0;
        theta /= 2.0;
    }
    return theta;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   vec2 ndc = getPixelCoordinate();

#ifdef SHADERTOY
    // Uncomment this to try out the waveform effect with audio input
    iAudio = texture2D(iChannel0, vec2(0.2, 0.25)).r;
    // Uncomment this to try out the wait effect;
    // iAudio = -1.0;
    bg = mix(texture2D(iChannel1, (ndc + 1.0) / 2.0), vec4(0), 1.0 - 0.23);
#endif

    vec2 c = circle(ndc);
    float alpha = c.x;
    if (alpha == 0.0) {
#ifdef SHADERTOY
        fragColor = bg;
        return;
#else
        discard;
#endif
    }

    vec2 smooth = vec2(1.0);
    if (iAudio < 0.0) {
        float theta = getTheta(ndc, 0.0);
        smooth = waitOld(theta);
    } else {
        float theta = getTheta(ndc, 2.0);
        smooth = waveform(theta);
    }
    vec3 outColor = mix(COLOR, HIGHLIGHT, smooth.y * (1.0 - c.y));
    outColor = mix(BG, outColor, smooth.x);

#ifdef SHADERTOY
    if (alpha < 1.0) {
        outColor = mix(bg.rgb, outColor, alpha);
    }
#endif
    
    fragColor = vec4(outColor, alpha);
}


