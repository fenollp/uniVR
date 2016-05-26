// Shader downloaded from https://www.shadertoy.com/view/ldc3zH
// written by shadertoy user Izokina
//
// Name: Movement game
// Description: Just try to stay in circle as long as possible. Also, path functions are welcome :)
vec3 getCircle() {
    float r = .3 * pow(iGlobalTime + .001, -.8);
    float t = iGlobalTime * .5;
    vec2 pos = vec2(sin(t), cos(t)) / 2. + vec2(.5); // let's play a game
    return vec3(pos, r * r);
}

float min(const in vec2 v) {
    return min(v.x, v.y);
}

float max(const in vec2 v) {
    return max(v.x, v.y);
}

vec2 getPos(const in vec2 xy) {
    vec2 size = vec2(min(iResolution.xy));
    vec2 off = (iResolution.xy - size) / 2.;
    return (xy - off) / size;
}

bool isInside(const in vec3 circle, const in vec2 pos) {
    vec2 off = circle.xy - pos;
    return dot(off, off) < circle.z;
}

float getIntensity(const in vec2 pos) {
    vec3 circle = getCircle();
    if (!isInside(circle, pos))
        return 0.;
    float visible = 0.;
    vec2 mouse = getPos(iMouse.xy);
    if (isInside(circle, mouse))
        visible = 1.;
    return max(visible, 1. - iGlobalTime * .3);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 pos = getPos(fragCoord);
    fragColor = vec4(1., vec2(1. - getIntensity(pos)), 1.);
}