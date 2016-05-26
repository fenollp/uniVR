// Shader downloaded from https://www.shadertoy.com/view/MllSzX
// written by shadertoy user demofox
//
// Name: Bicubic Texture Filtering
// Description: Nearest neighbor texture filtering on left, Bilinear texture filtering in left middle, Lagrange Bicubic texture filtering on middle right, cubic hermite on the right.  Use the mouse to control pan / zoom.
//    
float c_textureSize = 64.0;

float c_onePixel = 1.0 / c_textureSize;
float c_twoPixels = 2.0 / c_textureSize;

float c_x0 = -1.0;
float c_x1 =  0.0;
float c_x2 =  1.0;
float c_x3 =  2.0;
    
//=======================================================================================
vec3 CubicLagrange (vec3 A, vec3 B, vec3 C, vec3 D, float t)
{
    return
        A * 
        (
            (t - c_x1) / (c_x0 - c_x1) * 
            (t - c_x2) / (c_x0 - c_x2) *
            (t - c_x3) / (c_x0 - c_x3)
        ) +
        B * 
        (
            (t - c_x0) / (c_x1 - c_x0) * 
            (t - c_x2) / (c_x1 - c_x2) *
            (t - c_x3) / (c_x1 - c_x3)
        ) +
        C * 
        (
            (t - c_x0) / (c_x2 - c_x0) * 
            (t - c_x1) / (c_x2 - c_x1) *
            (t - c_x3) / (c_x2 - c_x3)
        ) +       
        D * 
        (
            (t - c_x0) / (c_x3 - c_x0) * 
            (t - c_x1) / (c_x3 - c_x1) *
            (t - c_x2) / (c_x3 - c_x2)
        );
}

//=======================================================================================
vec3 BicubicLagrangeTextureSample (vec2 P)
{
    vec2 pixel = P * c_textureSize + 0.5;
    
    vec2 frac = fract(pixel);
    pixel = floor(pixel) / c_textureSize - vec2(c_onePixel/2.0);
    
    vec3 C00 = texture2D(iChannel0, pixel + vec2(-c_onePixel ,-c_onePixel)).rgb;
    vec3 C10 = texture2D(iChannel0, pixel + vec2( 0.0        ,-c_onePixel)).rgb;
    vec3 C20 = texture2D(iChannel0, pixel + vec2( c_onePixel ,-c_onePixel)).rgb;
    vec3 C30 = texture2D(iChannel0, pixel + vec2( c_twoPixels,-c_onePixel)).rgb;
    
    vec3 C01 = texture2D(iChannel0, pixel + vec2(-c_onePixel , 0.0)).rgb;
    vec3 C11 = texture2D(iChannel0, pixel + vec2( 0.0        , 0.0)).rgb;
    vec3 C21 = texture2D(iChannel0, pixel + vec2( c_onePixel , 0.0)).rgb;
    vec3 C31 = texture2D(iChannel0, pixel + vec2( c_twoPixels, 0.0)).rgb;    
    
    vec3 C02 = texture2D(iChannel0, pixel + vec2(-c_onePixel , c_onePixel)).rgb;
    vec3 C12 = texture2D(iChannel0, pixel + vec2( 0.0        , c_onePixel)).rgb;
    vec3 C22 = texture2D(iChannel0, pixel + vec2( c_onePixel , c_onePixel)).rgb;
    vec3 C32 = texture2D(iChannel0, pixel + vec2( c_twoPixels, c_onePixel)).rgb;    
    
    vec3 C03 = texture2D(iChannel0, pixel + vec2(-c_onePixel , c_twoPixels)).rgb;
    vec3 C13 = texture2D(iChannel0, pixel + vec2( 0.0        , c_twoPixels)).rgb;
    vec3 C23 = texture2D(iChannel0, pixel + vec2( c_onePixel , c_twoPixels)).rgb;
    vec3 C33 = texture2D(iChannel0, pixel + vec2( c_twoPixels, c_twoPixels)).rgb;    
    
    vec3 CP0X = CubicLagrange(C00, C10, C20, C30, frac.x);
    vec3 CP1X = CubicLagrange(C01, C11, C21, C31, frac.x);
    vec3 CP2X = CubicLagrange(C02, C12, C22, C32, frac.x);
    vec3 CP3X = CubicLagrange(C03, C13, C23, C33, frac.x);
    
    return CubicLagrange(CP0X, CP1X, CP2X, CP3X, frac.y);
}

//=======================================================================================
vec3 CubicHermite (vec3 A, vec3 B, vec3 C, vec3 D, float t)
{
	float t2 = t*t;
    float t3 = t*t*t;
    vec3 a = -A/2.0 + (3.0*B)/2.0 - (3.0*C)/2.0 + D/2.0;
    vec3 b = A - (5.0*B)/2.0 + 2.0*C - D / 2.0;
    vec3 c = -A/2.0 + C/2.0;
   	vec3 d = B;
    
    return a*t3 + b*t2 + c*t + d;
}

//=======================================================================================
vec3 BicubicHermiteTextureSample (vec2 P)
{
    vec2 pixel = P * c_textureSize + 0.5;
    
    vec2 frac = fract(pixel);
    pixel = floor(pixel) / c_textureSize - vec2(c_onePixel/2.0);
    
    vec3 C00 = texture2D(iChannel0, pixel + vec2(-c_onePixel ,-c_onePixel)).rgb;
    vec3 C10 = texture2D(iChannel0, pixel + vec2( 0.0        ,-c_onePixel)).rgb;
    vec3 C20 = texture2D(iChannel0, pixel + vec2( c_onePixel ,-c_onePixel)).rgb;
    vec3 C30 = texture2D(iChannel0, pixel + vec2( c_twoPixels,-c_onePixel)).rgb;
    
    vec3 C01 = texture2D(iChannel0, pixel + vec2(-c_onePixel , 0.0)).rgb;
    vec3 C11 = texture2D(iChannel0, pixel + vec2( 0.0        , 0.0)).rgb;
    vec3 C21 = texture2D(iChannel0, pixel + vec2( c_onePixel , 0.0)).rgb;
    vec3 C31 = texture2D(iChannel0, pixel + vec2( c_twoPixels, 0.0)).rgb;    
    
    vec3 C02 = texture2D(iChannel0, pixel + vec2(-c_onePixel , c_onePixel)).rgb;
    vec3 C12 = texture2D(iChannel0, pixel + vec2( 0.0        , c_onePixel)).rgb;
    vec3 C22 = texture2D(iChannel0, pixel + vec2( c_onePixel , c_onePixel)).rgb;
    vec3 C32 = texture2D(iChannel0, pixel + vec2( c_twoPixels, c_onePixel)).rgb;    
    
    vec3 C03 = texture2D(iChannel0, pixel + vec2(-c_onePixel , c_twoPixels)).rgb;
    vec3 C13 = texture2D(iChannel0, pixel + vec2( 0.0        , c_twoPixels)).rgb;
    vec3 C23 = texture2D(iChannel0, pixel + vec2( c_onePixel , c_twoPixels)).rgb;
    vec3 C33 = texture2D(iChannel0, pixel + vec2( c_twoPixels, c_twoPixels)).rgb;    
    
    vec3 CP0X = CubicHermite(C00, C10, C20, C30, frac.x);
    vec3 CP1X = CubicHermite(C01, C11, C21, C31, frac.x);
    vec3 CP2X = CubicHermite(C02, C12, C22, C32, frac.x);
    vec3 CP3X = CubicHermite(C03, C13, C23, C33, frac.x);
    
    return CubicHermite(CP0X, CP1X, CP2X, CP3X, frac.y);
}

//=======================================================================================
vec3 BilinearTextureSample (vec2 P)
{
    vec2 pixel = P * c_textureSize + 0.5;
    
    vec2 frac = fract(pixel);
    pixel = (floor(pixel) / c_textureSize) - vec2(c_onePixel/2.0);

    vec3 C11 = texture2D(iChannel0, pixel + vec2( 0.0        , 0.0)).rgb;
    vec3 C21 = texture2D(iChannel0, pixel + vec2( c_onePixel , 0.0)).rgb;
    vec3 C12 = texture2D(iChannel0, pixel + vec2( 0.0        , c_onePixel)).rgb;
    vec3 C22 = texture2D(iChannel0, pixel + vec2( c_onePixel , c_onePixel)).rgb;

    vec3 x1 = mix(C11, C21, frac.x);
    vec3 x2 = mix(C12, C22, frac.x);
    return mix(x1, x2, frac.y);
}

//=======================================================================================
vec3 NearestTextureSample (vec2 P)
{
    vec2 pixel = P * c_textureSize;
    
    vec2 frac = fract(pixel);
    pixel = (floor(pixel) / c_textureSize);
    return texture2D(iChannel0, pixel + vec2(c_onePixel/2.0)).rgb;
}

//=======================================================================================
void AnimateUV (inout vec2 uv)
{
    if (iMouse.z > 0.0)
    {
        uv -= vec2(0.0,0.5) * iResolution.y / iResolution.x;;
        uv *= vec2(iMouse.y / iResolution.y);
        uv += vec2(1.5 * iMouse.x / iResolution.x, 0.0);
        
    }
    else
    {    
    	uv += vec2(sin(iGlobalTime * 0.3)*0.5+0.5, sin(iGlobalTime * 0.7)*0.5+0.5);
    	uv *= (sin(iGlobalTime * 0.3)*0.5+0.5)*3.0 + 0.2;
    }
}

//=======================================================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // set up our coordinate system
    float aspectRatio = iResolution.y / iResolution.x;
    vec2 uv = (fragCoord.xy / iResolution.xy);
    uv.y *= aspectRatio;
    
    // do our sampling
    vec3 color;
    if (abs(uv.x - (1.0/4.0)) < 0.0025)
    {
        color = vec3(1.0);
    }   
    else if (abs(uv.x - (2.0/4.0)) < 0.0025)
    {
        color = vec3(1.0);
    }          
    else if (abs(uv.x - (3.0/4.0)) < 0.0025)
    {
        color = vec3(1.0);
    }        
    else if (uv.x < (1.0/4.0))
    {
        AnimateUV(uv);
        color = NearestTextureSample(uv);
    }
    else if (uv.x < (2.0/4.0))
    {
        uv -= vec2((1.0/4.0),0.0);
        AnimateUV(uv);
        color = texture2D(iChannel0, uv).xyz;
        //color = BilinearTextureSample(uv);
    }
    else if (uv.x < (3.0/4.0))
    {
        uv -= vec2((2.0/4.0),0.0);
        AnimateUV(uv);
        color = BicubicLagrangeTextureSample(uv);
    }
    else
    {
        uv -= vec2((3.0/4.0),0.0);
        AnimateUV(uv);
        color = BicubicHermiteTextureSample(uv);
	}
    
    // set the final color
	fragColor = vec4(color,1.0);    
}