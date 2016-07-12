// Shader downloaded from https://www.shadertoy.com/view/lllXR2
// written by shadertoy user GregRostami
//
// Name: Raymarch 196 chars
// Description: I'm trying to shrink my previous shader: https://www.shadertoy.com/view/MtXXRH
//    This was inspired by coyote's [2TC 15] Fractal Complex shader: https://www.shadertoy.com/view/ltfGzS
//    Size optimizing friends (addicts) ... please help! 
//Super Fabrice implemented several size optimizations
//Plus further optimization by 834144373 brings it down to 193 chars!!

void mainImage (out vec4 o, vec2 u )
{
    o-=o;
    o.xy = u/iResolution.x; 
    vec4 r, q = iDate.xyww, p=o+=.6; p--;     
    for (int i=0; i<99; i++)  
    	r = sin(q), r = max(r.y-r,.1*(sin(q*9.)-r.y)),
     	(o.a=max(r.x,r.z)) >.01  ? q -= p*o.a, o -= .01 : o;   
}


//Original Shader at 227 chars:
/*
#define X r = cos(q.xyww*s), d = max(d,(cos(q.y)-min(r.x,min(r.y,r.z)))/s),s*=8.;
void mainImage(out vec4 o, vec2 n )
{
    vec4 r,q=iDate,p=q-q-.4;
    p.xy+=n/iResolution.x;
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
*/