// Shader downloaded from https://www.shadertoy.com/view/4dG3DV
// written by shadertoy user GregRostami
//
// Name: Yin Yang Spin 175 chars
// Description: This is a continuation of the Yin Yang challenge that was started by s23b here:&lt;br/&gt;https://www.shadertoy.com/view/4sKGRG
// 175 chars - Fabrice simplified the rotation matrix by removing the cos
// Fabrice uses black magic to remove a char by removing the "-" in rotation matrix ( -cos(X) = sin(X + PI/2*3) )
/**/
void mainImage(out vec4 o,vec2 i)
{
    float a = dot(i = (i+i-(o.xy=iResolution.xy) )/o.y * mat2(sin(iDate.w+1.57*vec4(3,0,0,1))), i), 
          b = abs(i.y);
    o += (a>1. ? .5 : 9./(b-a-.23)/(b>a ? i.y : i.x))-o;
}
/**/

// 161 chars - smallest version with rotation (not centered, no gray background)
/*
void mainImage(out vec4 o,vec2 i)
{
    float a = dot(i= (2.*i/iResolution.y-1.) * mat2(sin(iDate.w+1.57*vec4(3,0,0,1))), i),
    b = abs(i.y);
    o += 9./(b>a ? (b-a-.23)*i.y : --a*i.x) - o;
}
*/

// 180 chars - Original
/*
void mainImage(out vec4 o,vec2 i)
{
    float t=iDate.w, s=sin(t), c=cos(t),
	a = dot(i = (i + i - (o.xy=iResolution.xy) )/o.y * mat2(-c,s,s,c) , i), b = abs(i.y);
    o += (a>1. ? .5 : 9./(b-a-.23)/(b>a ? i.y : i.x))-o;
}
*/