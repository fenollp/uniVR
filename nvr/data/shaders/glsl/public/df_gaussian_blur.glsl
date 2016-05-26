// Shader downloaded from https://www.shadertoy.com/view/MtlSWj
// written by shadertoy user demofox
//
// Name: DF Gaussian Blur
// Description: Gaussian blur. Use the mouse to control blur
const int   c_samplesX    = 15;  // must be odd
const int   c_samplesY    = 15;  // must be odd
const float c_textureSize = 512.0;

const int   c_halfSamplesX = c_samplesX / 2;
const int   c_halfSamplesY = c_samplesY / 2;
const float c_pixelSize = (1.0 / c_textureSize);

float Gaussian (float sigma, float x)
{
    return exp(-(x*x) / (2.0 * sigma*sigma));
}

vec3 BlurredPixel (in vec2 uv)
{
    float c_sigmaX      = iMouse.z > 0.0 ? 5.0 * iMouse.x / iResolution.x : (sin(iGlobalTime*2.0)*0.5 + 0.5) * 5.0;
	float c_sigmaY      = iMouse.z > 0.0 ? 5.0 * iMouse.y / iResolution.y : c_sigmaX;
    
    float total = 0.0;
    vec3 ret = vec3(0);
        
    for (int iy = 0; iy < c_samplesY; ++iy)
    {
        float fy = Gaussian (c_sigmaY, float(iy) - float(c_halfSamplesY));
        float offsety = float(iy-c_halfSamplesY) * c_pixelSize;
        for (int ix = 0; ix < c_samplesX; ++ix)
        {
            float fx = Gaussian (c_sigmaX, float(ix) - float(c_halfSamplesX));
            float offsetx = float(ix-c_halfSamplesX) * c_pixelSize;
            total += fx * fy;            
            ret += texture2D(iChannel0, uv + vec2(offsetx, offsety)).rgb * fx*fy;
        }
    }
    return ret / total;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy * vec2(1,-1);
	fragColor = vec4(BlurredPixel(uv), 1.0);
}