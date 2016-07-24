// Shader downloaded from https://www.shadertoy.com/view/MstGzn
// written by shadertoy user PLS
//
// Name: Water Microwave
// Description: Blue effect with transverse wave
//    ~350 chars
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
    float dt = sin(mod(length((uv - vec2(0.7, 0.5)) * 5.) - iGlobalTime, 3.14));
    float circle = (cos(mod(uv.x * 32.0, 3.14) - 1.58) *0.5) *(sin(mod(uv.y * 32.0, 3.14)) *0.5) * (1.-dt);
	//fragColor = vec4(2.0, 1.0, 0.0,1.0) * circle;
	fragColor = vec4(1,4,12,1) * circle;
}