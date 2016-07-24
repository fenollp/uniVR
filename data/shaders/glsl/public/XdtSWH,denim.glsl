// Shader downloaded from https://www.shadertoy.com/view/XdtSWH
// written by shadertoy user randomekek
//
// Name: denim
// Description: denim
// implements this photoshop texture:
// https://indidesigns.wordpress.com/photoshop-basicstutorials/jeans-texture-seams-tutorial/

const float pi=3.14159;

const float base_scale=4.5;
const float diffuse_scale=2.0;
const float diffuse_level=0.6;
const vec3 denim_dark=vec3(90., 100., 170.)/255.;
const vec3 denim_light=vec3(150.,170.,200.)/255.;
const vec3 thread_color=vec3(130.,150.,180.)/255.;
const vec3 stitch_color=vec3(150.,90.,40.)/255.;
const float thread_angle=-30.0/180.0*pi;
const float thread_size=3.0;
const vec2 thread_a = thread_size * vec2(cos(thread_angle), -sin(thread_angle));
const vec2 thread_b = thread_size * vec2(cos(-thread_angle), -sin(-thread_angle));
const float seam_repeat = 50.0;
const float seam_size = 5.0;
const float stitch_width=0.4;
const float stitch_offset=6.0;
const float stitch_repeat=4.5;
const float stitch_shadow=4.0;

vec4 noise(in vec2 x) {
    vec2 p = floor(x);
    vec2 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = p.xy + f.xy;
	return texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 );
}

float fbm(in vec2 x) {
    return (0.25*noise(x*0.25).x + 0.5*noise(x).x + 0.25*noise(x*2.1).y + 0.125*noise(x*4.1).z)/(0.25+0.5+0.25+0.125);
}

float halftone(in vec2 x) {
    vec2 box = floor(x);
    vec2 inner = -1.0 + 2.0 * fract(x);
    return clamp(1.0 - (mod(box.x + box.y, 2.0) * (1.0 - 0.9 * length(inner))), 0.0, 1.0);
}

float lighten(in float x, in float level) {
    return mix(1.0, x, level);
}

vec2 diffuse(in vec2 x) {
    return x + diffuse_level * (-1.0 + 2.0 * noise(x * diffuse_scale).xy);
}

float seam_pos(in float x) {
    float pos = clamp(mod(x, seam_repeat), 0.0, 2.5*seam_size) / seam_size;
    float valley = 2.0*abs(0.5-pos);
    return mix(pos < 0.5 ? valley : (pos < 1.0 ? 2.0 - valley : 1.0), 1.0, .7);
}

float stitch_pos(in vec2 uv, in float offset) {
    float x = mod(uv.x - offset, seam_repeat);
    float y = fract(uv.y / stitch_repeat);
    return step(0.0, x) * (1.0 - step(stitch_width, x)) * step(0.0, y) * (1.0 - step(0.7, y));
}

float shadow(in float x, in float offset1, in float offset2) {
 	float pos = mod(x, seam_repeat);
    float delta = smoothstep(offset1-stitch_shadow, offset1+stitch_shadow, pos) * (1.0 - smoothstep(offset2-stitch_shadow, offset2+stitch_shadow, pos));
    return 1.0 - mix(0.0, delta, 0.15);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 uv = fragCoord.xy / base_scale;
    vec3 base = mix(denim_light, denim_dark, halftone(diffuse(uv)));
    float stretch = lighten(fbm(uv * vec2(1.9, 0.3)), 0.3);
    vec2 threads = noise(uv*4.0).xy * smoothstep(0.5, 1.0, sin(vec2(dot(thread_a, uv), dot(thread_b, uv))));
    vec3 denim = mix(base*stretch, thread_color, threads.x + 0.3 * threads.y);
    
    float seam = seam_pos(uv.x);
    float stitch = stitch_pos(uv, stitch_offset) + stitch_pos(uv, 4.0+stitch_offset);
    float stitch_shadow = shadow(uv.x, stitch_offset, 4.0+stitch_offset);
	fragColor = vec4(mix(denim * seam * stitch_shadow, stitch_color, stitch), 1.0);
}