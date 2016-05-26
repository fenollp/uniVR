// Shader downloaded from https://www.shadertoy.com/view/ltf3Dl
// written by shadertoy user netgrind
//
// Name: lsdSheetGenerator
// Description: sexy blending via https://twitter.com/Titouan_Millet/status/575722640570191872
#define TAU 6.28
const int loops = 3;

vec4 hue(vec4 color, float shift) {

    const vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
    const vec4  kRGBToI     = vec4 (0.596, -0.275, -0.321, 0.0);
    const vec4  kRGBToQ     = vec4 (0.212, -0.523, 0.311, 0.0);

    const vec4  kYIQToR   = vec4 (1.0, 0.956, 0.621, 0.0);
    const vec4  kYIQToG   = vec4 (1.0, -0.272, -0.647, 0.0);
    const vec4  kYIQToB   = vec4 (1.0, -1.107, 1.704, 0.0);

    // Convert to YIQ
    float   YPrime  = dot (color, kRGBToYPrime);
    float   I      = dot (color, kRGBToI);
    float   Q      = dot (color, kRGBToQ);

    // Calculate the hue and chroma
    float   hue     = atan (Q, I);
    float   chroma  = sqrt (I * I + Q * Q);

    // Make the user's adjustments
    hue += shift;

    // Convert back to YIQ
    Q = chroma * sin (hue);
    I = chroma * cos (hue);

    // Convert back to RGB
    vec4    yIQ   = vec4 (YPrime, I, Q, 0.0);
    color.r = dot (yIQ, kYIQToR);
    color.g = dot (yIQ, kYIQToG);
    color.b = dot (yIQ, kYIQToB);

    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 tex0 = vec4(1.0);//texture2D(iChannel0,uv);
    
    for(int j = 0; j<loops;j++){
        uv*=2.0;
    	uv-= 1.0;
        uv = abs(uv);
    	tex0 = (cos(abs(tex0-texture2D(iChannel0,mod(uv,1.0)))*TAU)+1.0)/2.0;   
    }
    tex0.a = 1.0;
	fragColor =  hue(tex0,iGlobalTime);
}