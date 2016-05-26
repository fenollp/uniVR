// Shader downloaded from https://www.shadertoy.com/view/Xt23D1
// written by shadertoy user GregRostami
//
// Name: Rollers (2TC)
// Description: This shader is a modification of Trisomie21's  2TC shader:
//    https://www.shadertoy.com/view/4lf3zS
// Thanks to the help of coyote, I got my shader down to two tweets (280 chars)

void mainImage( out vec4 f, vec2 w ) 
{
    vec4 p = vec4(w,0,0)/iResolution.x-.55, d=p, t, c;
    float T = iGlobalTime, C = cos(T), S = sin(T);
    p.z -= T+T;
    for(float i = 2.; i >0.; i-=.01)
    {
        t = mod(p, 8.)-4.;
        t.zy *= mat2(C,S,-S,C);
		c = textureCube(iChannel0, t.xyz);
        t = c + length(t.xyz)-2.7;
        if(t.x<.01) break;
        p -= d*t.x*.2;
        f = c*i;
    }
}

/* Here's my original shader for reference.

void mainImage( out vec4 f, vec2 w ) 
{
    vec4 p = vec4(w,0,0)/iResolution.x-.55, d=p, t, c;
    float T = iGlobalTime, C = cos(T), S = sin(T);
    p.z -= T+T;
    for(float i = 2.; i >0.; i-=.01)
    {
        t = mod(p, 8.)-4.;
        c = textureCube(iChannel0, mat3(0,1,0, C,0,S, -S,0,C) * t.xyz);
        t = c + length(t.xyz)-2.7;
        if(t.x<.01) break;
        p -= d*t.x*.2;
        f = c*i;
    }
}
*/
