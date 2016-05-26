// Shader downloaded from https://www.shadertoy.com/view/4tfGWl
// written by shadertoy user Impossible
//
// Name: Valve Noise
// Description: Quick implementation of noise from valve's vr talk. Subtle but it actually does reduce the banding if you look closely.
//    http://media.steampowered.com/apps/valve/2015/Alex_Vlachos_Advanced_VR_Rendering_GDC2015.pdf
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy/iResolution.xy;
    vec3 vDither = vec3(dot(vec2(171.0,231.0),fragCoord.xy + vec2(iGlobalTime)));
    vDither.rgb = fract(vDither.rgb/vec3(103.0,71.0,97.0))-vec3(0.5,0.5,0.5);
	fragColor = (uv.x>0.5?vec4((vDither.rgb/255.0),1.0):vec4(0.0)) + pow(vec4(uv.y,uv.y,uv.y,0.0),vec4(1.));
}