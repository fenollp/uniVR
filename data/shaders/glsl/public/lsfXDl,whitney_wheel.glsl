// Shader downloaded from https://www.shadertoy.com/view/lsfXDl
// written by shadertoy user lost4468
//
// Name: Whitney wheel
// Description: Based on http://whitneymusicbox.org/
#define PI 3.14159265359
#define PI2 PI*2.0

const int numBalls = 25;
const float cycleTime = 50.0;
const float sphereSize = 1.0 / float(numBalls);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.0 * (fragCoord.xy / iResolution.xy - vec2(0.5, 0.5));
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 colour = vec3(0.0, 0.0, 0.0);
    
    float r = sqrt(uv.x*uv.x + uv.y*uv.y);
    float phi = atan(uv.x, uv.y) + PI;
    float sphereNum = floor(r / sphereSize + 0.5);

    if(sphereNum > 1.0 / sphereSize)
        return;
    
    float sphereP = iGlobalTime * sphereNum * PI2 / cycleTime;
    
    colour.r = 1.0 - mod(sphereP - phi, PI2) / 0.5;
    colour.b = 1.0 - mod(sphereP, PI2) / 0.5;

    vec2 dp = 1.005 / iResolution.xy;
    
    if(uv.x >= -dp.x && uv.x <= dp.y && uv.y <= 0.0)
        colour = vec3(1.0, 1.0, 1.0);
    
    fragColor = vec4(colour, 1.0);
}