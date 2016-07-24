// Shader downloaded from https://www.shadertoy.com/view/Mst3Wr
// written by shadertoy user XT95
//
// Name: La calanque
// Description: Something like &quot;Les calanques&quot; a beautiful place near Marseille, France!
// Created by anatole duprat - XT95/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 bufa = texture2D(iChannel0, uv);
    
    //Lens fresnel
    vec2 offset = (uv*2.-1.)/iResolution.xy*2.;
    vec3 col = vec3(0.);
    col.r = texture2D(iChannel0, uv+offset).r;
    col.g = bufa.g;
    col.b = texture2D(iChannel0, uv-offset).b;
    
    //Vignetting
    col = clamp(col,0.,1.) * (.5 + .5*pow( uv.x*uv.y*(1.-uv.x)*(1.-uv.y)*50., .5));
    
    fragColor = vec4(col*min(iGlobalTime*.25,1.), 1.);
}