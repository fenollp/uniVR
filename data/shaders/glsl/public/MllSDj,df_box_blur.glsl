// Shader downloaded from https://www.shadertoy.com/view/MllSDj
// written by shadertoy user demofox
//
// Name: DF Box Blur
// Description: Box blur. Use the mouse to control blur.
//    More information at: http://blog.demofox.org/2015/08/18/box-blur/
/*

For more information check out my blog:
http://blog.demofox.org/2015/08/18/box-blur/

*/

const int   c_samplesX    = 15;  // must be odd
const int   c_samplesY    = 15;  // must be odd
const float c_textureSize = 512.0;


const float c_pixelSize = (1.0 / c_textureSize);
const int   c_halfSamplesX = c_samplesX / 2;
const int   c_halfSamplesY = c_samplesY / 2;

vec3 BlurredPixel (in vec2 uv)
{   
    int c_distX = iMouse.z > 0.0
        ? int(float(c_halfSamplesX+1) * iMouse.x / iResolution.x)
        : int((sin(iGlobalTime*2.0)*0.5 + 0.5) * float(c_halfSamplesX+1));
    
	int c_distY = iMouse.z > 0.0
        ? int(float(c_halfSamplesY+1) * iMouse.y / iResolution.y)
        : int((sin(iGlobalTime*2.0)*0.5 + 0.5) * float(c_halfSamplesY+1));
    
    float c_pixelWeight = 1.0 / float((c_distX*2+1)*(c_distY*2+1));
    
    vec3 ret = vec3(0);        
    for (int iy = -c_halfSamplesY; iy <= c_halfSamplesY; ++iy)
    {
        for (int ix = -c_halfSamplesX; ix <= c_halfSamplesX; ++ix)
        {
            if (abs(float(iy)) <= float(c_distY) && abs(float(ix)) <= float(c_distX))
            {
                vec2 offset = vec2(ix, iy) * c_pixelSize;
            	ret += texture2D(iChannel0, uv + offset).rgb * c_pixelWeight;
            }
        }
    }
    return ret;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy * vec2(1,-1);
	fragColor = vec4(BlurredPixel(uv), 1.0);
}