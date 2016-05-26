// Shader downloaded from https://www.shadertoy.com/view/ll2XWV
// written by shadertoy user FabriceNeyret2
//
// Name: Moir&eacute; tapestry
// Description: was a bug when optimizing checkboards... ;-)
void mainImage(out vec4 o,  vec2 U)
{

    o+= sin(.314*U.xxxx*U.y)*9.;  // 61
    

    // U = sin(.314*U)*9.; o += U.x*U.y;    // shortest checkboard, see phttps://www.shadertoy.com/view/lt2XWK
}

