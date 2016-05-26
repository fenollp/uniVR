// Shader downloaded from https://www.shadertoy.com/view/4dyGRW
// written by shadertoy user jackdavenport
//
// Name: Bouncing Rectangle
// Description: A basic 2D physics simulation using the new framebuffers. Click the mouse to change the square's velocity.
//#define SHOW_BUF_A

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv  = fragCoord.xy / iResolution.xy;
    vec2 pos = texture2D(iChannel0, uv).xy;
    
    fragColor = texture2D(iChannel1, uv);
    
    if(uv.x < pos.x + .05 && uv.y < pos.y + .05 && uv.x > pos.x - .05 && uv.y > pos.y - .05) {
     
        fragColor = vec4(1.);
        
    }
    
    #ifdef SHOW_BUF_A
    if(uv.x < .1 && uv.y < .1) {
     
        fragColor = texture2D(iChannel0, uv / .1);
        
    }
    #endif
}