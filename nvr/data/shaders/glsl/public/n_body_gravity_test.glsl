// Shader downloaded from https://www.shadertoy.com/view/Ms3GDS
// written by shadertoy user Flyguy
//
// Name: N-Body Gravity Test
// Description:  A basic gravity simulator thing using a brute-force all pairs approach to calculate the acceleration of each body.
//#define VIEW_POSITION_BUFFER

#define NUM_BODIES 256

#define BODY_RADIUS 3.0

vec4 getBody(int id)
{
    return texture2D(iChannel0, vec2(id,0.0)/iResolution.xy);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.y;
    
    float d = 1e6;
    
    for(int i = 0;i < NUM_BODIES;i++)
    {
        vec4 body = getBody(i);
		d = min(d, distance(body.xy, uv));
    }
    
    float px = 1.0/iResolution.y;
    
    float c = smoothstep(BODY_RADIUS*px - px, BODY_RADIUS*px, d);
    
	fragColor = vec4(vec3(c),1.0);
    
    #ifdef VIEW_POSITION_BUFFER
    fragColor = texture2D(iChannel0, uv / res / vec2(2.0,16.0));
    #endif
}