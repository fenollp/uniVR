// Shader downloaded from https://www.shadertoy.com/view/MtXXRH
// written by shadertoy user GregRostami
//
// Name: 251 chars Ray Marcher
// Description: A modification of coyote's [2TC 15] Fractal Complex shader: https://www.shadertoy.com/view/ltfGzS
//    I'm trying to size optimize this shader as much as I can. Any help would be greatly appreciated. Thank you.
#define X r = abs(mod(q*s+1.,2.)-1.), d = max(d,(cos(q.y)-min(r.x,min(r.y,r.z)))/s), s *= 8.;
void mainImage(out vec4 o, vec2 n )
{
    o-=o;
    vec4 p=o,r=p,q=r;
    p.xy=n/iResolution.x;
    p-=.4;
    q.z = iDate.w;
    for (float i=1.; i>0.; i-=.01)
    {
        float d=0.,s=1.;
		X X
        d>.01 ?
        q -= p*d,
        o = p+i
        : o;
    }
}