// Shader downloaded from https://www.shadertoy.com/view/Ms33R4
// written by shadertoy user FabriceNeyret2
//
// Name: glsl bug: clamp
// Description: the spec tells that clamp(v,a,b) = min(max(x, a), b), i.e. a lessthan b.
//    on windows  clamp(v,a,b) = clamp(v,b,a), while reversed bounds makes max(a,b) on linux. only Mac ok
//    -So windows see 4 gradient strips, linux will have 2 white strips at the middle.
#define B 1. // .25

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord / iResolution.xy;
    float x=uv.x, y=uv.y,c;
                                    // --- min(max(y, a), b) for y in [0,B]
    c =   x<.25  ? clamp(y,.0,B)    //  y
        : x<.253 ? 0.
        : x<.5   ? clamp(y,B,.0)    //  0   linux: B   Windows: y
        : x<.503 ? 0.
        : x<.75  ? clamp(.0,B, y)   //  y   linux: B
        : x<.753 ? 0.
        :          clamp(B,.0, y);  //  y
    
	fragColor = vec4(c);
}