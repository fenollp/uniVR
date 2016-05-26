// Shader downloaded from https://www.shadertoy.com/view/4lfSzM
// written by shadertoy user gsingh93
//
// Name: Skyline Sunrise
// Description: Based off of https://www.shadertoy.com/view/4tXSRM (which contains a detailed explanation) and inspired by https://www.shadertoy.com/view/MlX3DM.
// Based off of https://www.shadertoy.com/view/4tXSRM, which also contains an explanation

#define MAX_DEPTH 20

float noise(vec2 p) {
	return fract(sin(dot(p.xy ,vec2(12.9898,78.233))) * 456367.5453);
}

vec3 background_col(vec2 p, float sun_y) {
    float b = mix(0.5, 0.6, p.x);
    float g = mix(0.6, 0.7, p.x);
    // Mix black with the normal background color depending on the height of the sun.
    // We have to clamp the sun height because it goes above the screen
   	return mix(vec3(0), vec3(1., g, b), clamp(0., 1., sun_y)); 
}

// The position of the sun varies between .15 and 1.15 (it's offscreen above 1).
float sun_pos(float time) {
    // 0.2 controls the speed of the sun. Dividing by 2 shortens the length of the day.
	return (sin(time * 0.2) + 1.3) / 2.;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 p = fragCoord.xy / iResolution.xy;
    
    float col = 0.;
    float alpha = 0.;
    
    // Note that we create buildings from back to front
	for (int i = 1; i < MAX_DEPTH; i++) {
		float depth = float(i);
		float step = 200. * p.x / depth + 50. * depth + iGlobalTime;
        
		if (p.y < noise(vec2(floor(step))) - depth * .04) {
            // Alpha blend each building
            float dx = 2. * 200. / iResolution.x / depth;
            float loc_alpha = smoothstep(0., dx, fract(step)) * smoothstep(0., dx, 1. - fract(step));
			col = depth / 20. * loc_alpha + (1. - loc_alpha) * col;
            alpha = loc_alpha + (1. - loc_alpha) * alpha;
		}
	}

    float sun_y = sun_pos(iGlobalTime);
    vec3 background_color = background_col(p, sun_y);
    
    // This mixing tints the building color based on the time of day
    fragColor.rgb = mix(background_color * alpha, vec3(col), .7);
    fragColor.a = alpha;

    // We only want to show sunrise, so if the sun is coming down, don't show it
    float gradient = sun_pos(iGlobalTime + 1.) - sun_y;
    
    vec2 center = vec2(1.5, sun_y);
    float radius = 0.1;

    // Correct the aspect ratio when drawing the sun
    vec2 uv = p;
    uv.x = uv.x * iResolution.x / iResolution.y;

    // Add in the sun or the background
    if (gradient >= 0. && length(uv - center) < radius) {
        fragColor += (1. - fragColor.a) * vec4(1, .9, .5, 1.);
    } else {
        fragColor += (1. - fragColor.a) * vec4(background_color, 1.);
    }
}