// Shader downloaded from https://www.shadertoy.com/view/Mt2SzW
// written by shadertoy user d1kkop
//
// Name: hypnotize
// Description: hypnotize
const float c_ringSize = 0.05;

bool isEven(int val)
{
    return val - (val/2)*2 == 0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 c = vec2(0.5);
    float dist = distance(uv, c);
    dist += iGlobalTime / 10.0;
    if (isEven(int(dist / c_ringSize)))
        fragColor = vec4(1, 1,1,1);
    else
        fragColor = vec4(0, 0, 0,1);
}


