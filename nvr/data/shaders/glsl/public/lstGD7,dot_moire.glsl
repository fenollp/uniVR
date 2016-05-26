// Shader downloaded from https://www.shadertoy.com/view/lstGD7
// written by shadertoy user masaki
//
// Name: dot moire
// Description: dot moire
#define PI 3.141592
#define ALT  0.48


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv =( fragCoord.xy / iResolution.xy) - .5;
    float t = iGlobalTime;
    float vib = .4 * cos(t * .5) + .4;
    uv.x *= iResolution.x / iResolution.y;
    float holozontal = .5 *cos(uv.x * 2. * PI * 500. * vib) + .5;
    float vertiacl =  .5*cos(uv.y * 2. * PI *500. * vib)+ .5;
    fragColor = vec4(vec3(holozontal*vertiacl), 1.);
}