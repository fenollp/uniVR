// Shader downloaded from https://www.shadertoy.com/view/4ddGDB
// written by shadertoy user Flyguy
//
// Name: N-Body Gravity (Optimised)
// Description: An optimised version of my other n-body shader.
//    This version breaks up the process of summing up the net acceleration into a bunch of small parallel &quot;chunks&quot; which are then summed up in another pass to integrate the position.
//#define VIEW_POSITION_BUFFER
//#define VIEW_CHUNK_BUFFER

//NUM_BODIES must be less than or equal to iResolution.x and must be changed in all tabs.
#define NUM_BODIES 768

#define BODY_RADIUS 3.0

vec4 getBody(int id)
{
    return texture2D(iChannel1, vec2(id,0.0)/iResolution.xy);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.y;
    
    float d = 1e6;
    
    for(int i = 0;i < NUM_BODIES;i++)
    {
        vec2 body = getBody(i).xy - uv;
		d = min(d, dot(body,body));
    }
    
    d = sqrt(d);
    
    float px = 1.0/iResolution.y;
    
    float c = smoothstep(BODY_RADIUS*px - px, BODY_RADIUS*px, d);
    
	fragColor = vec4(vec3(c),1.0);
    
    #ifdef VIEW_POSITION_BUFFER
    	fragColor = texture2D(iChannel1, uv / res / vec2(1,64));
    #endif
    #ifdef VIEW_CHUNK_BUFFER
    	fragColor = texture2D(iChannel0, uv / res) / 16.0;
    #endif
}