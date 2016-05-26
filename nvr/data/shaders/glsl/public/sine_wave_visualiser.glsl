// Shader downloaded from https://www.shadertoy.com/view/XtSSDV
// written by shadertoy user jackdavenport
//
// Name: Sine Wave Visualiser
// Description: A basic visualisation of a sine wave.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv.x += iGlobalTime / 3.;
    
    float s = sin(uv.x * 16.) / 2. + .5;
    
    fragColor = vec4(smoothstep(0., .3, abs(s-uv.y)));
}