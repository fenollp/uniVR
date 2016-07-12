// Shader downloaded from https://www.shadertoy.com/view/4tlGD2
// written by shadertoy user TekF
//
// Name: Simple Kaleidoscope 3
// Description: Messing with some more parameters of this. I like the way it explodes after a few seconds.
const float tau = 6.2831853;

float T = iGlobalTime*.3+10.0;
    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy-.5*iResolution.xy) * 7.2 / iResolution.y;

    float r = 1.0;
    float a = T*.1;
    float c = cos(a)*r;
    float s = sin(a)*r;
    float q = T*.2 / tau;
    for ( int i=0; i<30; i++ )
    {
    	//uv = abs(uv);
        
        // higher period symmetry
        float t = atan(uv.x,uv.y);
		t *= q;
        t = abs(fract(t*.5+.5)*2.0-1.0);
        t /= q;
        //q = q+.001;
        uv = length(uv)*vec2(sin(t),cos(t));
        
        uv -= .7;
        uv = uv*c + s*uv.yx*vec2(1,-1);
    }
        
    fragColor = .5+.5*sin(T+vec4(13,17,23,1)*texture2D( iChannel0, uv*vec2(1,-1)+.5, -0.0 ));
}
