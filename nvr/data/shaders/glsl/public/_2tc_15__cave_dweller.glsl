// Shader downloaded from https://www.shadertoy.com/view/MlsGWM
// written by shadertoy user Dave_Hoskins
//
// Name: [2TC 15] Cave dweller
// Description: I've basically nicked Reinder's &quot;Psychodelic Sand Dunes&quot; shader and used a texture instead of sin/cos!!
//    I hope that's OK Reinder?
//    [url]https://www.shadertoy.com/view/MtlGWM#[/url] 
// [2TC 15] Cave dweller
// Dave Hoskins.

void mainImage( out vec4 f, in vec2 w )
{
    vec4 p = vec4(w, 1,1)/iResolution.xyzz-.5, d=p*.1, t;
    p.w += iGlobalTime*8.;
    d.y += sin(p.w)*.001;
	d.y = -abs(d.y);
    
    for( float i = 5.; i > 0.; i-=.005)
    {
        p += d;
        t = texture2D(iChannel0, .2+p.xw / 2e2,-99.);
        t *=texture2D(iChannel1, .2+p.xw / 3e2,-99.);
       	f = t * i;
                        
        if( t.y*13. > p.y+6.) break;
    }
}
