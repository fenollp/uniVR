// Shader downloaded from https://www.shadertoy.com/view/ldK3zc
// written by shadertoy user demofox
//
// Name: Buffer Upsizing
// Description: testing upsizing an off screen buffer.  Press 1 for nearest neighbor, 2 for bilinear, 3 for bilinear smoothstepped, 4 for bicubic. Note that the buffer is set to &quot;nearest&quot; filtering, not the default of &quot;linear&quot; which does hardware bilinear sampling.
// keys
const float KEY_1 = 49.5/256.0;
const float KEY_2 = 50.5/256.0;
const float KEY_3 = 51.5/256.0;
const float KEY_4 = 52.5/256.0;

//=======================================================================================
vec4 CubicHermite (vec4 A, vec4 B, vec4 C, vec4 D, float t)
{
	float t2 = t*t;
    float t3 = t*t*t;
    vec4 a = -A/2.0 + (3.0*B)/2.0 - (3.0*C)/2.0 + D/2.0;
    vec4 b = A - (5.0*B)/2.0 + 2.0*C - D / 2.0;
    vec4 c = -A/2.0 + C/2.0;
   	vec4 d = B;
    
    return a*t3 + b*t2 + c*t + d;
}

//============================================================
vec4 SampleNearest (in vec2 adjustedFragCoord)
{
	vec2 uv = adjustedFragCoord / iResolution.xy;
    return texture2D(iChannel0, uv);
}

//============================================================
vec4 SampleBilinear (in vec2 adjustedFragCoord)
{
    adjustedFragCoord-= 0.5;
    vec2 fragFract = fract(adjustedFragCoord);
    
    // get the four data points
    vec2 uvMin = adjustedFragCoord / iResolution.xy;
    vec2 uvMax = (adjustedFragCoord + vec2(1.0)) / iResolution.xy;
    vec4 data00 = texture2D(iChannel0, uvMin);
    vec4 data10 = texture2D(iChannel0, vec2(uvMax.x, uvMin.y));
    vec4 data01 = texture2D(iChannel0, vec2(uvMin.x, uvMax.y));
    vec4 data11 = texture2D(iChannel0, uvMax);
    
    // bilinear interpolate
    vec4 datax0 = mix(data00, data10, fragFract.x);
    vec4 datax1 = mix(data01, data11, fragFract.x);
    return mix(datax0, datax1, fragFract.y);
}

//============================================================
// More info about this technique here:
// http://iquilezles.org/www/articles/texture/texture.htm
vec4 SampleBilinearSmoothstep (in vec2 adjustedFragCoord)
{
    adjustedFragCoord-= 0.5;
    vec2 fragFract = fract(adjustedFragCoord);
    fragFract = smoothstep(0.0, 1.0, fragFract);
    
    // get the four data points
    vec2 uvMin = adjustedFragCoord / iResolution.xy;
    vec2 uvMax = (adjustedFragCoord + vec2(1.0)) / iResolution.xy;
    vec4 data00 = texture2D(iChannel0, uvMin);
    vec4 data10 = texture2D(iChannel0, vec2(uvMax.x, uvMin.y));
    vec4 data01 = texture2D(iChannel0, vec2(uvMin.x, uvMax.y));
    vec4 data11 = texture2D(iChannel0, uvMax);
    
    // bilinear interpolate
    vec4 datax0 = mix(data00, data10, fragFract.x);
    vec4 datax1 = mix(data01, data11, fragFract.x);
    return mix(datax0, datax1, fragFract.y);    
}

//============================================================
vec4 SampleBicubic (in vec2 adjustedFragCoord)
{
    adjustedFragCoord-= 0.5;    
    vec2 fragFract = fract(adjustedFragCoord);
    
    // get the 16 data points
    vec4 dataNN = texture2D(iChannel0, (adjustedFragCoord + vec2(-1.0, -1.0)) / iResolution.xy);
    vec4 data0N = texture2D(iChannel0, (adjustedFragCoord + vec2( 0.0, -1.0)) / iResolution.xy);
    vec4 data1N = texture2D(iChannel0, (adjustedFragCoord + vec2( 1.0, -1.0)) / iResolution.xy);
    vec4 data2N = texture2D(iChannel0, (adjustedFragCoord + vec2( 2.0, -1.0)) / iResolution.xy);
    
    vec4 dataN0 = texture2D(iChannel0, (adjustedFragCoord + vec2(-1.0,  0.0)) / iResolution.xy);
    vec4 data00 = texture2D(iChannel0, (adjustedFragCoord + vec2( 0.0,  0.0)) / iResolution.xy);
    vec4 data10 = texture2D(iChannel0, (adjustedFragCoord + vec2( 1.0,  0.0)) / iResolution.xy);
    vec4 data20 = texture2D(iChannel0, (adjustedFragCoord + vec2( 2.0,  0.0)) / iResolution.xy);    
    
    vec4 dataN1 = texture2D(iChannel0, (adjustedFragCoord + vec2(-1.0,  1.0)) / iResolution.xy);
    vec4 data01 = texture2D(iChannel0, (adjustedFragCoord + vec2( 0.0,  1.0)) / iResolution.xy);
    vec4 data11 = texture2D(iChannel0, (adjustedFragCoord + vec2( 1.0,  1.0)) / iResolution.xy);
    vec4 data21 = texture2D(iChannel0, (adjustedFragCoord + vec2( 2.0,  1.0)) / iResolution.xy);     
    
    vec4 dataN2 = texture2D(iChannel0, (adjustedFragCoord + vec2(-1.0,  2.0)) / iResolution.xy);
    vec4 data02 = texture2D(iChannel0, (adjustedFragCoord + vec2( 0.0,  2.0)) / iResolution.xy);
    vec4 data12 = texture2D(iChannel0, (adjustedFragCoord + vec2( 1.0,  2.0)) / iResolution.xy);
    vec4 data22 = texture2D(iChannel0, (adjustedFragCoord + vec2( 2.0,  2.0)) / iResolution.xy);     
    
    // bicubic interpolate
    vec4 dataxN = CubicHermite(dataNN, data0N, data1N, data2N, fragFract.x);
    vec4 datax0 = CubicHermite(dataN0, data00, data10, data20, fragFract.x);
    vec4 datax1 = CubicHermite(dataN1, data01, data11, data21, fragFract.x);
    vec4 datax2 = CubicHermite(dataN2, data02, data12, data22, fragFract.x);
    return CubicHermite(dataxN, datax0, datax1, datax2, fragFract.y);
}

//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 adjustedFragCoord = (fragCoord / 32.0);
    
    int mode = int(mod(iGlobalTime, 4.0));
    
    if (texture2D(iChannel1, vec2(KEY_1,0.25)).x > 0.1)
    	mode = 0;
    else if (texture2D(iChannel1, vec2(KEY_2,0.25)).x > 0.1)
        mode = 1;
    else if (texture2D(iChannel1, vec2(KEY_3,0.25)).x > 0.1)
        mode = 2;        
    else if (texture2D(iChannel1, vec2(KEY_4,0.25)).x > 0.1)
        mode = 3;        
        
    if (mode == 0)
    	fragColor = SampleNearest(adjustedFragCoord);        
    else if (mode == 1)
        fragColor = SampleBilinear(adjustedFragCoord);
    else if (mode == 2)
        fragColor = SampleBilinearSmoothstep(adjustedFragCoord);        
    else
        fragColor = SampleBicubic(adjustedFragCoord);
}