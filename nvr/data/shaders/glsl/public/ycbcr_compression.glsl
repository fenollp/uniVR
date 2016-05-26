// Shader downloaded from https://www.shadertoy.com/view/MdcGzj
// written by shadertoy user paniq
//
// Name: YCbCr compression
// Description: influence of compressing color channels of YCbCr
const mat3 rgb2ycbcr = mat3(
    0.299, -0.168736, 0.5, 
    0.587, -0.331264, -0.418688,   
    0.114, 0.5, -0.081312
);

const mat3 ycbcr2rgb = mat3(
    1.0, 1.0, 1.0,
    0.0, -0.344136, 1.772, 
    1.402, -0.714136, 0.0
);

// simulating 8:4:4 compression ratio (16bit)
vec3 compress_ycbcr_844 (vec3 rgb) {
    vec3 ycbcr = rgb2ycbcr * rgb;
    ycbcr.r = floor(ycbcr.r * 255.0 + 0.5) / 255.0;
    ycbcr.gb += 0.5;
    ycbcr.gb = floor(ycbcr.gb * 15.0 + 0.5) / 15.0;
    ycbcr.gb -= 0.5;    
    return ycbcr2rgb * ycbcr;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 rgb = vec3(uv,0.5+0.5*sin(iGlobalTime));
    if (uv.x > 0.5)
        rgb = compress_ycbcr_844(rgb);
	fragColor = vec4(rgb,1.0);
}