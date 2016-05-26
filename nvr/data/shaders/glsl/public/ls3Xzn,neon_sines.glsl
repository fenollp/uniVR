// Shader downloaded from https://www.shadertoy.com/view/ls3Xzn
// written by shadertoy user alexpolt
//
// Name: Neon sines
// Description: Some fuzzy neon sines)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float s1 = 0.5+0.5*sin(iGlobalTime+uv.x*3.1415*(sin(iGlobalTime)+4.0));
    float s2 = 0.5+0.25*sin(iGlobalTime+uv.x*3.1415*(sin(iGlobalTime)*2.0+2.0));
    float r = pow(1.0-sqrt( abs(uv.y-s1)),1.5 );
    float g = pow(1.0-sqrt( abs(uv.y-s2)),1.5 );
    float b = 1.5*(r+g);
	fragColor = vec4( r,g,b,1 );
}