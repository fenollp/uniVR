// Shader downloaded from https://www.shadertoy.com/view/4tfXW8
// written by shadertoy user FabriceNeyret2
//
// Name: carpet - 70 chars
// Description: 70 chars without the anim

void mainImage( out vec4 f, vec2 u ) {
//  f += sin( dot(u+=u,u) - max(u.x,u.y) );             // 70 chars
    f = sin( dot(u+=u,u) - max(u.x,u.y) - 4.*iDate.wwww); // anim: + 11 chars
}


