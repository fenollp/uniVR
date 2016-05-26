// Shader downloaded from https://www.shadertoy.com/view/llX3W2
// written by shadertoy user dzira
//
// Name: chippy noise
// Description: chippy arpeggio noise
vec2 mainSound(float time)
{
    float beat = .85*time;
    float sinbeat = sin(beat);
    float x = 330. + 22.5*sinbeat;
    sinbeat = 8.+ abs(sin(time*.2))*sinbeat;
    
    x = (x + (clamp(floor(fract(beat)*sinbeat)-(9.-sinbeat),0.,9.)*x/sinbeat))*time;
    
    float saw = 2.*fract(x)-1.;

    float square = clamp(floor(saw*100.),-1.,1.);
    
    return vec2( mix(square,saw,.5*fract(sinbeat*sinbeat)));
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = vec2(.03141592,8.)*(fragCoord.xy - iResolution.xy/2.) / iResolution.x;
    float s = uv.x+iGlobalTime;
    s = mainSound(s).x;
    s = clamp(floor(s/uv.y),0.,1.);
	fragColor = vec4(s,s,s,1.0);
}
