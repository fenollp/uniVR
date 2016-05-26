// Shader downloaded from https://www.shadertoy.com/view/XlX3Rf
// written by shadertoy user ddoodm
//
// Name: Swirly Sampler
// Description: Just a test of swirly texture sampling!
#define TILES 2.0
#define FREQU 2.0
#define SPEED 4.0
#define AMPLI 0.2

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy * TILES;
    uv.x *= iResolution.x/iResolution.y;
        
   	float t = iGlobalTime * SPEED;
    
    uv += vec2(
        AMPLI * sin(t/2.0) * cos(t + uv.y*FREQU),
        AMPLI * cos(t/2.0) * sin(t + uv.x*FREQU) );
    uv += vec2(t*0.1);
    
    // Sample at wavy coordinates, and colour correct!
    vec3 c = texture2D(iChannel0, uv).xyz;
    vec3 dc = vec3(0.57, 0.4, 1.0);
    c = dc * dot(c, vec3(0.9, 0.1, 0.0));
    c = pow(c, vec3(0.9));
    c *= 1.75;
    
    // Specular highlight
    uv *= vec2(4.0);
    c += 0.2 * cos(t + uv.y + uv.x);
    
	fragColor = vec4(c, 1.0);
}