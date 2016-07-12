// Shader downloaded from https://www.shadertoy.com/view/Xdt3R2
// written by shadertoy user DeMaCia
//
// Name: sin cos wave light
// Description: simpleness sin cos wave
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
	vec4 color = vec4(uv,
                      .5+.5*sin(iGlobalTime),
                      1.);
    
    vec4 color2 = vec4(1. - ((uv.x + uv.y) / 2.),
                       uv,
                       1.);
    
    vec2 pos = uv*2.-1.;
    
    color *= abs(1./(sin(pos.y + sin(pos.x + iGlobalTime)*.7)*sin(iGlobalTime*.5)*20.));
    
    color += color2 * abs(1./(sin(pos.y + cos(pos.x*.5 + iGlobalTime)*.8)*10.));
   
    fragColor = color;
}