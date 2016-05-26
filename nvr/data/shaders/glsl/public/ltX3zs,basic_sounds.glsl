// Shader downloaded from https://www.shadertoy.com/view/ltX3zs
// written by shadertoy user dzira
//
// Name: basic sounds
// Description: I have a better idea of how sounds work now so I made some basic waveforms: sine, saw, pyramid, square
float mainSound(float time)
{
    float saw = 2.*fract(440.*time)-1.;
    
    float sine = sin(6.283185*440.*time);
    
    float pyr = 2.*abs(saw)-1.;
    
    float square = clamp(floor(saw*20.),-1.,1.);
    
    float r = mix(sine,saw,clamp(sin(time),0.,1.));
    
    r = mix(r,pyr,clamp(sin(time-3.14),0.,1.));
    
    r = mix(r,square,clamp(sin(time-4.7123),0.,1.));
    
    return r;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = vec2(.03141592,6.)*(fragCoord.xy - iResolution.xy/2.) / iResolution.x;
    float s = uv.x+iGlobalTime;
    s = mainSound(s);
    s = clamp(floor(s/uv.y),0.,1.);
	fragColor = vec4(s,s,s,1.0);
}