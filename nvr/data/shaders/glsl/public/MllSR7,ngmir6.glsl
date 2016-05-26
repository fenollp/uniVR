// Shader downloaded from https://www.shadertoy.com/view/MllSR7
// written by shadertoy user netgrind
//
// Name: ngMir6
// Description: rainbows
#define TESTS 50.0
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float t = iGlobalTime;
    vec4 c = vec4(0.0);
    for(float i = 0.; i< TESTS; i++){
    	c.rgb = max(c.rgb,
                sin(i/40.+
                    6.28*(vec3(0.,.33,.66)+
                       texture2D(
                            iChannel0,vec2(
                                uv.x,uv.y-(i/iResolution.y))
                        ).rgb
                    ))*.5+.5);   
    }
   	c.rgb = sin(( vec3(0.,.33,.66)+c.rgb+uv.y)*6.28)*.5+.5;
    c.a = 1.0;
	fragColor = c;
}