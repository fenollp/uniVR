// Shader downloaded from https://www.shadertoy.com/view/XtsXz4
// written by shadertoy user GregRostami
//
// Name: Raymarch 157 chars
// Description: This is a continuation of the ONE TWEET ray marching challenge. At 188 chars, I've got a long way to go ...
//    Calling ALL size optimizers (coyote, FabriceNeyret2, Nrx and aiekick)
//    Please help me reduce this shader as much as possible.
//Fabrice does the impossible by shrinking this to almost ONE TWEET, 154 chars!!

void mainImage(out vec4 f,vec2 u)
{
    f-=f;
    vec4 p = iDate, t;
    for(int i=0; i<99; i++)
        f = sin( t = mod( p -= vec4(u/iResolution.y-.8,0,1)*f.x*.3 , 6.).wyxz - 3. )
            -length(t.zy);
     f++;
}


//Fabrice (the master of reduction) replaced the texture function for a 171 char raymarcher!!
/*
void mainImage( inout vec4 f, vec2 u )
{
    vec4 p, t=p=f;
    p.z = iDate.w;
    for(int i=0; i<99; i++)
        t = mod(p+=vec4(u/iResolution.y-.8,1,1)*t.x*.2, 6.)-3.,
        f = sin(t.zyxw),
        t = length(t.xy)-f;
    f -= t;
}
*/

//A big thanks to iq, the shader is now 188 chars:
/*
void mainImage( inout vec4 f, vec2 u )
{
    vec4 p, t=p=f;
    p.z = iDate.w;
    for(int i=0; i<90; i++)
        t = mod(p+=vec4(u/iResolution.y-.8,1,1)*t.x*.2, 6.)-3.,
        f = textureCube(iChannel0,t.zyx),
        t = length(t.xy)-f;
    f -= t;
}
*/

//Original Shader at 191 chars:
/*
void mainImage( out vec4 f, vec2 u )
{
    vec4 p = vec4 (u/iResolution.y-.8,1,1), d=p, t, c;
    p.z = iDate.w;
	for(int i=0; i<90; i++)
        t = mod(p += d*t.z*.2, 6.)-3.,
        c = textureCube(iChannel0,t.zyx),
        t = length(t.xy)-c,
        f = c-t;
}
*/