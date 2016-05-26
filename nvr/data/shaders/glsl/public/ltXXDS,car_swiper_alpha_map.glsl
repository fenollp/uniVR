// Shader downloaded from https://www.shadertoy.com/view/ltXXDS
// written by shadertoy user kroltan
//
// Name: Car Swiper alpha map
// Description: Concept to demonstrate an alpha map to a friend
#define tau 6.283185307179586476925286766559

#define center vec2(0.5, 0.0)
#define radius 0.5
#define speed 0.5

float timed_angle(vec2 pos, float rawtime) {
    float anglePercent = atan(pos.y, pos.x) / tau + 0.5;
    float time = mod(rawtime, 3.0) - 1.0;
    return mod(anglePercent + time, 1.0);
}

vec4 swiper(vec2 uv) {
    vec2 pos = uv - center;
    
    if (length(pos) < radius && pos.y > 0.0) {
        float t = iGlobalTime * speed;
        float angle = timed_angle(pos, t);
        float antiangle = 1.0 -timed_angle(pos, -t);
        return vec4(1,1,1,1.0) * angle * antiangle;
    } else {
        return vec4(1,1,1,1);
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 tex = texture2D(iChannel0, -uv + vec2(1,1));
    vec4 texN = texture2D(iChannel1, -uv + vec2(1,1));
    fragColor = mix(tex, texN,swiper(uv).w);
}