// Shader downloaded from https://www.shadertoy.com/view/Ml2Gzt
// written by shadertoy user elliotfiske
//
// Name: Ghost Vision
// Description: Makin' a sweet game where you're a ghost! This is what it looks like when you're invisible.
//    
//    Forked (stolen??) from JESTERRRRRR at https://www.shadertoy.com/view/MsS3RV
const float PI = 3.1415926535897932;

const float speed = 0.1;
const float emboss = 0.70;
const float intensity = 0.6;
const int steps = 8;
const float frequency = 9.0;
const int angle = 7;

const float delta = 200.;

float time = iGlobalTime;//*1.3;

float col(vec2 coord) {
    float delta_theta = 2.0 * PI / float(angle);
    float col = 0.0;
    float theta = 0.0;
    
    for (int i = 0; i < steps; i++) {
        vec2 adjc = coord;
        theta = delta_theta*float(i);
        adjc.x += cos(theta)*time*speed;
        adjc.y -= sin(theta)*time*speed;
        col = col + cos( (adjc.x*cos(theta) - adjc.y*sin(theta))*frequency)*intensity;
    }

    return cos(col);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 p = (fragCoord.xy) / iResolution.xy;
    vec2 c1 = p;
    vec2 c2 = p;
    float cc1 = col(c1);

    c2.x += iResolution.x/delta;
    float dx = emboss*(cc1-col(c2))/delta;

    c2.x = p.x;
    c2.y += iResolution.y/delta;
    float dy = emboss*(cc1-col(c2))/delta;
    
    vec2 center = vec2(iResolution.x / 2.0, iResolution.y / 2.0);
    float distToCenter = distance(center, fragCoord.xy);
    dx *= distToCenter / 600.;
    dy *= distToCenter / 600.;

    c1.x += dx*2.;
    c1.y = -(c1.y+dy*2.);

    vec4 col = texture2D(iChannel0,c1);
    
    // Make everything lighter and blue
    col.z = (col.x + col.y + col.z) / 3.0 * 1.6;
    col.x /= 1.2;
    col.y /= 1.2;
    fragColor = col;
}