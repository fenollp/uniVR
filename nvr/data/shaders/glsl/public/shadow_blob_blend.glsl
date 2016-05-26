// Shader downloaded from https://www.shadertoy.com/view/XljXzd
// written by shadertoy user Donzanoid
//
// Name: Shadow Blob Blend
// Description: Min-blending for shadow blobs with discontinuity


float Blob(vec2 pos, vec2 uv, float r)
{
    return max(length(pos - uv) - r, 0.0);
}

float smin(float a, float b, float k)
{
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

float Mix(float a, float b)
{
    // Smoothly blends but darkens with each blend
    //return a * b;
    
    // Distance field union
    // Maintains correct intensity regardless of blend count
    // Blends with visual discontinuity
    // My intuition is telling me I shouldn't see the discontinuity!
    return min(a, b);
    
    // Smooth min
    //return smin(a, b, 0.07);
    
    // Looks good but variable under number of blends
    // Effectively "steals" detail from previous blends
    //return sqrt(a * b);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float i = 1.0;
    i = Mix(i, Blob(vec2(0.25, 0.5), uv, 0.1));
    i = Mix(i, Blob(vec2(0.75, 0.5), uv, 0.1));
    i = Mix(i, Blob(vec2(0.5, 0.25), uv, 0.1));
    i = Mix(i, Blob(vec2(0.5, 0.75), uv, 0.1));
    
    i = Mix(i, Blob(vec2(fract(iGlobalTime*0.25), 0.25), uv, 0.15));
    
    // Better contrast
    i = pow(i, 0.5);
    
    // Highlight discontinuities
    //i = abs(dFdx(i)*100.0)+abs(dFdy(i)*100.0);
    
    fragColor = vec4(i, i, i, i);
}