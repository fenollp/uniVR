// Shader downloaded from https://www.shadertoy.com/view/Mdy3Wz
// written by shadertoy user aiekick
//
// Name: 2D Gears Repeat (273c)
// Description: some work to do for reduce the code length i thnik. waiting the team golf :)
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

//* with help of FabriceNeyret2 tricks 
void mainImage( out vec4 f, vec2 g )
{
    g/=1e2;
    
    f -= f;
    
    vec2 s = sign(mod(floor(g), 2.) - .2),
        c, u;
    
    float w = s.x * s.y * iDate.w * 5., k = 1.5708;
    
    for (float i=0.;i<4.;i++)
    {
        c = sin(i * k + vec2(k,0));
        
        u = fract(mat2(c, -c.y, c.x) * g);
        
        f += step(
            clamp(1.5 * cos(atan(u.x, u.y) * 8. + w + k) + 6., 5., 7.), 
            length(u) * 12.3) / 4.;
            
        w = -w;
    }
}/**/

/* original 418c
// inversion for each range
#define y(a) sign(mod(floor(a), 2.) *.5 - .1)
#define pi 3.14159

// gear quadrant
float k(vec2 g, float a)
{
	float t = iDate.w * y(g.y) * y(g.x) * (a==.5||a==1.5?-5.:5.) + 1.565;
	vec2 cs = vec2(cos(a*pi), sin(a*pi));
    g = abs(fract(g * mat2(cs.x,-cs.y,cs.y,cs.x))) * .123;
	a = min(max(.015*(cos(atan(g.x, g.y)*8.+t))+.06,.05),.07);
	return smoothstep(a, a+0.001, length(g)) * .25;
}

void mainImage( out vec4 f, vec2 g )
{
    g /= iResolution.y * .3;
    f = f - f + k(g, 0.) +  k(g, .5) + k(g, 1.) +k(g, 1.5);
}
/**/