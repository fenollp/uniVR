// Shader downloaded from https://www.shadertoy.com/view/MlsSDH
// written by shadertoy user ap
//
// Name: Visualizing YUV
// Description: Just trying to understand color spaces. Using BT.709
//    
//    Luma is X axis
//    U is Y axis
//    V is time
float square(float x)
{
    return x*x;
}

float LinearToSRGB(const float LinearValue)
{
		if (LinearValue <= 0.0031308)
				return LinearValue * 12.92;
		else 
				return pow(LinearValue, (1.0/2.4)) * (1.055) - 0.055;
}

vec3 LinearToSRGB(const vec3 LinearColor)
{
	return vec3(
		LinearToSRGB(LinearColor.x), 
		LinearToSRGB(LinearColor.y), 
		LinearToSRGB(LinearColor.z));
}

vec3 YUVToRGB(vec3 YUVColor)
{
	vec3 ret;

	ret.x = dot(YUVColor, vec3(1.0,  0.0,      1.28033));
	ret.y = dot(YUVColor, vec3(1.0, -0.21482, -0.38059));
	ret.z = dot(YUVColor, vec3(1.0,  2.12798,  0.0));

	return ret;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor.xyz = (YUVToRGB(vec3(uv, square(sin(iGlobalTime)))));
}