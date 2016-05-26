// Shader downloaded from https://www.shadertoy.com/view/XlSGzd
// written by shadertoy user SmartPointer
//
// Name: ConvolutionMatrices
// Description: Convolution matrices - You can change the strength in line 1 and the kernel in line 62.
const float strength = 50.0;

const mat3 sharpenKernel = mat3(
    vec3( 0, -1,  0),
    vec3(-1,  5, -1),
    vec3( 0, -1,  0)
);

const mat3 edgeKernel = mat3(
    vec3(-1, -1, -1),
    vec3(-1,  8, -1),
    vec3(-1, -1, -1)
);

const mat3 blurKernel = mat3(
    vec3(1.0/9.0, 1.0/9.0, 1.0/9.0),
    vec3(1.0/9.0, 1.0/9.0, 1.0/9.0),
    vec3(1.0/9.0, 1.0/9.0, 1.0/9.0)
);

const mat3 embossKernel = mat3(
    vec3(-2, -1, 0),
    vec3(-1,  1, 1),
    vec3( 0,  1, 2)
);

const mat3 gradientKernel = mat3(
    vec3(-1, 0, 1),
    vec3(-1, 0, 1),
    vec3(-1, 0, 1)
);

const mat3 weirdKernel = mat3(
    vec3(-1, -2, -1),
    vec3( 0,  0,  0),
    vec3( 1,  2,  1)
);

vec3 conv(mat3 h, mat3 imgVal[3]);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv.y *= -1.0;
    vec3 texture = texture2D(iChannel0, uv).rgb;
    
    mat3 imgVal[3];
    for (float x = -1.0; x < 2.0; x++)
    {
        mat3 val;
        for (float y = -1.0; y < 2.0; y++)
        {
            vec2 pos = vec2(fragCoord.x + x, fragCoord.y + y);
            vec3 pixelVal = texture2D(iChannel0, pos.xy / iResolution.xy).rgb;
            
            val[int(y) + 1] = pixelVal;
        }
        
        imgVal[int(x) + 1] = val;
    }
    
    fragColor = vec4(conv(edgeKernel, imgVal), 1.0);
}

vec3 conv(mat3 h, mat3 imgVal[3])
{
    vec3 result;
    for (int x = 0; x < 3; x++)
        for (int y = 0; y < 3; y++)
            result += (h[x][y] * imgVal[x][y]) * strength;
    
    return result;
}
