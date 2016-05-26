// Shader downloaded from https://www.shadertoy.com/view/XsjSzV
// written by shadertoy user iq
//
// Name: Synth - FM
// Description: Not much. FM (well, PM) sound Synthesis
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord.xy/iResolution.xy;
                  
    float im = 0.5 + 0.5*sin(0.21*6.2831*iGlobalTime);

    vec3 col = mix( vec3(0.0), vec3(0.4), 1.0-smoothstep(im,im+0.01,p.y) );
    
	fragColor = vec4( col, 1.0 );
}