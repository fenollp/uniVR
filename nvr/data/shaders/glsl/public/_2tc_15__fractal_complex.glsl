// Shader downloaded from https://www.shadertoy.com/view/ltfGzS
// written by shadertoy user coyote
//
// Name: [2TC 15] Fractal Complex
// Description: Tried to fit https://www.shadertoy.com/view/XslGzl into two tweets. Couldn't do it as I wanted at first, but then fellow shader programmers jumped in, and voila. 280 chars!
//two tweet version of fb39ca4's Menger Tunnel https://www.shadertoy.com/view/XslGzl

//thanks to Fabrice it is again under 2 tweets
//278 chars:


//2015-11-12
//had to change it once again to accomodate new shadertoy framework which prohibits using
//mainImage declaration with "inout vec4 fragColor"
//280 chars:

#define X r = max( r = abs(mod(q*s+1.,2.)-1.) , r.yzxw ), d = max(d, (.29-min(r.x,min(r.y,r.z))) / s ),  s *= 3.
void mainImage( out vec4 o,  vec2 w )
{
    vec4 p = vec4(w,0,1)/iResolution.x-.5, r, q = p-p;
    q.x = .3*sin(q.z=-iGlobalTime);
    o = p/p; //hm, can this fail? for example for w.x == iResolution.x / 2.

    for (int i=0; i < 99; i++) {
        float d=0.,s=1.;
        X; X; X; X; X;
        d > 1e-5 ? q += p*d, o -= .01 : o;
    }
}


//----------------------------------------------------------------------------
//below is the [2TC 15] version
//originally it was 280, but after the last shadertoy interface change it went
//to 295 chars
//----------------------------------------------------------------------------

//an attempt to fit fb39ca4's Menger Tunnel https://www.shadertoy.com/view/XslGzl
//into two tweets
//
//I managed to do it, sort of, but didn't like the too simple coloring, and especailly
//the fact that camera was static
//
//so here it is now, with the camera movement that I wanted (291 chars)
//feel free to add coloring to your liking ;)
//btw, after 200 or so seconds fp errors might kick in...


//UPDATE: Thanks to the great community here at ShaderToy, it is now 280 chars

/*
void mainImage( out vec4 f, vec2 w )
{
    vec4 p=vec4(w,0,1)/iResolution.x-.5,r=p-p,q=r;
    q.x=.3*sin(q.z=-iGlobalTime);

    for (float i=1.; i>0.; i-=.01) {

        float d=0.,s=1.;

        for (int j = 0; j < 5; j++)
            r=max(r=abs(mod(q*s+1.,2.)-1.),r.yzxw),
            d=max(d,(.29-min(r.x,min(r.y,r.z)))/s),
            s*=3.;

        q+=p*d;
        
        f = p-p+i;

        if(d<1e-5) break;
    }
}
*/