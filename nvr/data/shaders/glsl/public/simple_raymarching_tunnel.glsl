// Shader downloaded from https://www.shadertoy.com/view/XscSzj
// written by shadertoy user flewww
//
// Name: simple raymarching tunnel
// Description: Simple tunnel. using raymarching for rendering
float map(vec3 pos) {
    vec3 tmp = vec3(1.0) - abs(pos);
    return min(tmp.x, tmp.y);
}

vec3 color(vec3 pos) {
    vec3 blue = vec3(0.5, 0.5, 1.0);
    vec3 red  = vec3(1.0, 0.5, 0.5);
    return mix(blue, red, step(0.5, fract(pos.z)));
}

vec3 march(vec2 uv, vec3 cam_pos) {
    vec3 pos = cam_pos;
    vec3 dir = normalize(vec3(uv, 1));
    float d;
    for (int i=0; i<100; i++){
        d = map(pos);
        if (d < 0.01) {
            return color(pos)*exp(-(pos.z-cam_pos.z)*0.6);
        }
        pos += d*dir;
    }
    return vec3(0.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;
    vec3 cam_pos = vec3(sin(iGlobalTime)*0.5, sin(iGlobalTime*10.0)*0.1, iGlobalTime);
    fragColor = vec4(march(uv, cam_pos), 1.0);
}