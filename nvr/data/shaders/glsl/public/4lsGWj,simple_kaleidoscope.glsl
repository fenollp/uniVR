// Shader downloaded from https://www.shadertoy.com/view/4lsGWj
// written by shadertoy user TekF
//
// Name: Simple Kaleidoscope
// Description: Looks nice fullscreen. Change the texture for different results.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy-.5*iResolution.xy) * 7.2 / iResolution.y;

    float r = 1.0;
    float a = iGlobalTime*.1;
    float c = cos(a)*r;
    float s = sin(a)*r;
    for ( int i=0; i<32; i++ )
    {
    	uv = abs(uv);
        uv -= .25;
        uv = uv*c + s*uv.yx*vec2(1,-1);
    }
        
    fragColor = .5+.5*sin(iGlobalTime+vec4(13,17,23,1)*texture2D( iChannel0, uv*vec2(1,-1)+.5, -1.0 ));
}