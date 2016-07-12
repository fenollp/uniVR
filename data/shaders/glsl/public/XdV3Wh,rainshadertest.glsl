// Shader downloaded from https://www.shadertoy.com/view/XdV3Wh
// written by shadertoy user yasuo
//
// Name: RainShaderTest
// Description: It's just rain experiment.
const float PI = 3.14159265359;
const float DEG_TO_RAD = PI / 180.0;

// from iq
float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
    vec2 pa = p-a, ba = b-a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h );
}

vec2 rot(vec2 p, float a) {
    return vec2(
        cos(a) * p.x - sin(a) * p.y,
        sin(a) * p.x + cos(a) * p.y);
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec3 cl = vec3(0.0);
	float time = iGlobalTime;
	int numrain = 10;
    float speed = 0.1;
    if(mod(time,10.0) >= 2.0 && mod(time,10.0) < 5.0) {
        numrain = 20;
        speed = 0.2;
    } else if(mod(time,10.0) >= 5.0 && mod(time,10.0) < 8.0) {
        numrain = 30;
        speed = 0.25;
    } else if(mod(time,10.0) >= 8.0 && mod(time,10.0) <= 10.0) {
        numrain = 40;
        speed = 0.4;
    }

    float l;
    for(int i = 0; i<40; i++) {
        if(i<numrain){
            float dir = 1.0;
            if (mod(float(i),2.0) == 1.0){
                dir = -1.0;
            }

            float temp = rand(vec2(1.02,1.0+float(i)));
            float temp2 = rand(vec2(1.02+float(i),1.01+float(i)*dir));

            vec2 p0 = rot(vec2(-0.1+temp,0.1+temp2-tan(time*float(i)*speed)),DEG_TO_RAD*-15.0);
            vec2 p1 = rot(vec2(-0.1+temp,0.4+temp2-tan(time*float(i)*speed)),DEG_TO_RAD*-15.0);

            l = sdSegment(uv, p0, p1);
            cl = mix( cl, vec3(1.0), 1.0-smoothstep( 0.001, 0.003, l ) );
        }
    }


    fragColor = vec4( vec3( cl ), 1.0 );
}