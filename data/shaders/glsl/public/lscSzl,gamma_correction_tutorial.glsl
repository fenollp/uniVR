// Shader downloaded from https://www.shadertoy.com/view/lscSzl
// written by shadertoy user finalman
//
// Name: Gamma Correction Tutorial
// Description: Right part of screen is correctly converted to sRGB before outputting and left part is not. More info at the top of the shader.
/*

A common misconception among new computer graphics programmers is that RGB values are mapped
linearly to brightness when displayed on the screen. However, this is actually not true.
A well calibrated computer monitor does not use the linear RGB colorspace, but instead use the
slightly wonky sRGB colorspace. Being aware of this is key to writing good looking shaders with
natural shading and colors.

In sRGB higher resolution is given to darker colors with RGB values close to zero. 
This is a good thing, since our eyes are more sensitive to differences in brighness in dark colors
than in bright ones. A computer monitor using linear RGB would make dark images look really shitty.

In coder terms: In sRGB myColor * 2.0 is not twice as bright as myColor, and it may even have
a different hue. 

Shadertoy does not automatically convert colors from linear RGB to sRGB for us. We must do it
ourselves. In this shader the right part of the screen is correctly converted to sRGB before outputting,
and the left part is not. Apart from making the picture brighter overall, it also removes some artifacts
that can be seen in the left part.

In the topmost pattern the three primary colors are linearly blended together. If we don't convert 
to sRGB dark fringes will be seen where two colors are blended halfway, like around the green blobs.

The bottom pattern has some very high frequency content. Here we can see a lower frequency pattern
appearing when the color is not converted to sRGB. It looks just like aliasing, but it's actually an
artifact of not being in the correct colorspace and wrongly expecting 0.5 to be half as bright as 1.0,
when it actually comes out a lot darker than that on the screen. The right part should have a uniform
brightness if your monitor is correcly calibrated.

Working in sRGB all the time is a huge hassle, however. What we typically do is to write our shader
in linear RGB and then convert it to sRGB once before writing to fragColor. Care must be taken when
sampling textures for their color values, however. Textures are also stored in sRGB rather than linear
RGB, so when using them in our linear RGB based shader we must convert the color value from sRGB to
linear RGB before using it. 

This still leaves a slight problem, though, since your graphics card will perform filtering and
interpolation of the texture as if it was linear RGB rather than sRGB. This can be solved by informing
OpenGL that the color space of the texture is sRGB. Having an option for this for all textures and
buffers (including the framebuffer) is something I personally would like to see in a future update
of Shadertoy.

In practice, instead of using the sRGB colorspace as is, we often use a gamma curve of 2.2 as a very good
approximation, which saves us a few cycles. Holding your mouse button down on the shader will use
gamma 2.2 instead of sRGB. (Spoiler alert: the difference is imperceptible).

Here is a lighthearted youtube video that may explain this whole thing better than I can:
  https://www.youtube.com/watch?v=LKnqECcg6Gw

And some further reading on Wikipedia:
  https://en.wikipedia.org/wiki/SRGB
  https://en.wikipedia.org/wiki/Gamma_correction

Happy shading!

*/

const float GAMMA = 2.2;

const float PI = 3.1415926535897932384626433832795;

vec3 encodeSRGB(vec3 linearRGB)
{
    vec3 a = 12.92 * linearRGB;
    vec3 b = 1.055 * pow(linearRGB, vec3(1.0 / 2.4)) - 0.055;
    vec3 c = step(vec3(0.0031308), linearRGB);
    return mix(a, b, c);
}

vec3 decodeSRGB(vec3 screenRGB)
{
    vec3 a = screenRGB / 12.92;
    vec3 b = pow((screenRGB + 0.055) / 1.055, vec3(2.4));
    vec3 c = step(vec3(0.04045), screenRGB);
    return mix(a, b, c);
}

vec3 gamma(vec3 color, float g)
{
    return pow(color, vec3(g));
}

vec3 linearToScreen(vec3 linearRGB)
{
    return (iMouse.z < 0.5) ? encodeSRGB(linearRGB) : gamma(linearRGB, 1.0 / GAMMA);
}

vec3 screenToLinear(vec3 screenRGB)
{
    return (iMouse.z < 0.5) ? decodeSRGB(screenRGB) : gamma(screenRGB, GAMMA);
}

mat2 rotate2D(float a)
{
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

vec3 pattern1(vec2 fragCoord)
{
	vec2 uv = 2.0 * (fragCoord.xy - iResolution.xy * 0.5) / iResolution.y;
    vec2 a = (uv * 10.0) + iGlobalTime;
    vec2 b = (uv * 12.0) + iGlobalTime;
    float r = clamp(sin(a.x) * cos(a.y) + 0.4, 0.0, 1.0);
    float g = clamp(sin(b.x) * cos(b.y) * 1.2 - 0.1, 0.0, 1.0);
    
    return mix(mix(vec3(0,0,1), vec3(1,0,0), r), vec3(0,1,0), g);
}

vec3 pattern2(vec2 fragCoord)
{
    fragCoord = fragCoord - iResolution.xy * vec2(0.5, 0.25);
    fragCoord *= rotate2D(sin(iGlobalTime) * 0.01);
    
    vec2 uv = fragCoord * PI * 0.99;
    
    return vec3((sin(uv.x) + cos(uv.y)) * 0.25 + 0.5);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec3 color = vec3(0.0);
    
    if (fragCoord.y > iResolution.y * 0.5 + 2.0 && fragCoord.y < iResolution.y - 4.0)
    {
        color = pattern1(fragCoord);
    }
    else if (fragCoord.y < iResolution.y * 0.5 - 2.0 && fragCoord.y > 4.0)
    {
        color = pattern2(fragCoord);
    }
    
    if (fragCoord.x > iResolution.x * 0.5)
    {
        color = linearToScreen(color);
    }
        
	fragColor = vec4(color, 1.0);
}