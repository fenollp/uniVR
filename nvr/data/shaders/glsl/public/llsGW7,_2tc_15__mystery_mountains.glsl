// Shader downloaded from https://www.shadertoy.com/view/llsGW7
// written by shadertoy user Dave_Hoskins
//
// Name: [2TC 15] Mystery Mountains
// Description: Another fractal mountain, this time in 280 chars.
//// [2TC 15] Mystery Mountains.
// David Hoskins.

#define F +texture2D(iChannel0,.3+p.xz*s/3e3)/(s+=s)
void mainImage( out vec4 c, vec2 w )
{
    vec4 p=vec4(w/iResolution.xy,1,1)-.5,d=p*.5,t;
    p.z += iGlobalTime*20.;d.y-=.2;

    for(float i=1.7;i>0.;i-=.002)
    {
        float s=.5;
        t = F
			F
			F
			F
			F
			F;
        c = vec4(1,.9,.8,9)+d.x-t*i;
        if(t.x>p.y*.01+1.3)break;
        p += d;
    }
}
