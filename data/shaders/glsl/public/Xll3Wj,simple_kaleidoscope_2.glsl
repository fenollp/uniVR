// Shader downloaded from https://www.shadertoy.com/view/Xll3Wj
// written by shadertoy user TekF
//
// Name: Simple Kaleidoscope 2
// Description: A stranger symmetry.
const float tau = 6.2831853;
    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy-.5*iResolution.xy) * 7.2 / iResolution.y;

    float r = 1.0;
    float a = iGlobalTime*.1;
    float c = cos(a)*r;
    float s = sin(a)*r;
    for ( int i=0; i<10; i++ )
    {
    	//uv = abs(uv);
        
        // higher period symmetry
        float t = atan(uv.x,uv.y);
        const float q = 7. / tau;
		t *= q;
        t = abs(fract(t*.5+.5)*2.0-1.0);
        t /= q;
        uv = length(uv)*vec2(sin(t),cos(t));
        
        uv -= .7;
        uv = uv*c + s*uv.yx*vec2(1,-1);
    }
        
    fragColor = .5+.5*sin(iGlobalTime+vec4(13,17,23,1)*texture2D( iChannel0, uv*vec2(1,-1)+.5, -1.0 ));
}

/*void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy-.5*iResolution.xy) * 5. / iResolution.y;

    float r = 1.0;
    float a = iGlobalTime*.1;
    float c = cos(a)*r;
    float s = sin(a)*r;
    for ( int i=0; i<32; i++ )
    {
    	uv = abs(uv);
        uv -= exp(float(-2*i))+.1;
        uv = uv*c + s*uv.yx*vec2(1,-1);
    }
        
    fragColor = .5+.5*sin(iGlobalTime+vec4(13,17,23,1)*texture2D( iChannel0, clamp( uv*vec2(1,-1)+.5, .0, 1. ), -1.0 ));
}*/