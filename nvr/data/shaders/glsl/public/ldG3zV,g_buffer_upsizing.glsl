// Shader downloaded from https://www.shadertoy.com/view/ldG3zV
// written by shadertoy user demofox
//
// Name: G-Buffer Upsizing
// Description: Seeing what happens if you use a smaller than full resolution gbuffer to render.  Using two buffers to simulate having a larger format buffer to store more data.
/*============================================================

Blog post with more details:
http://blog.demofox.org/2016/02/21/g-buffer-upsizing/


This shader reads in the ray vs world info and shades the pixel
based on that information.  This shader does image upsizing
if needed.

============================================================*/

const float c_gamma = 2.2;

#define AA_AMOUNT 7.0 / iResolution.x

//============================================================
// SHARED CODE BEGIN
//============================================================

const float c_pi = 3.14159265359;

// Distance from the camera to the near plane
const float c_cameraDistance = 2.0; 

// The vertical field of view of the camera in radians
// Horizontal is defined by accounting for aspect ratio
const float c_camera_FOV = c_pi / 2.0;  

// camera orientation
vec3 c_cameraPos   = vec3(0.0);
vec3 c_cameraRight = vec3(1.0, 0.0, 0.0);    
vec3 c_cameraUp    = vec3(0.0, 1.0, 0.0);
vec3 c_cameraFwd   = vec3(0.0, 0.0, 1.0);    

const float c_buttonSize = 0.075;      // size on x and y
const float c_buttonPadding = 0.025; // between buttons

const vec2 txState = vec2(0.0,0.0);
// x = size mode
// y = interpolation mode
// z = interpolate image instead of data (1.0)
// w = unused

//============================================================
void GetRayInfo (in vec2 adjustedFragCoord, out vec3 rayOrigin, out vec3 rayDirection)
{
    // calculate a uv of the pixel such that:
    // * the top of the screen is y = 0.5, 
    // * the bottom of the screen in y = -0.5
    // * the left and right sides of the screen are extended based on aspect ratio.
    // * left is -x, right is +x
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = (adjustedFragCoord / iResolution.xy) - vec2(0.5);
    uv.x *= aspectRatio;
    
    // set up the ray for this pixel.
    // It starts from the near plane, going in the direction from the camera to the spot on the near plane.
    vec3 rayLocalDir = vec3(uv * sin(c_camera_FOV), c_cameraDistance);
    rayOrigin =
        c_cameraPos +
        rayLocalDir.x * c_cameraRight * c_cameraDistance +
        rayLocalDir.y * c_cameraUp * c_cameraDistance +
        rayLocalDir.z * c_cameraFwd * c_cameraDistance;
    rayDirection = normalize(rayOrigin - c_cameraPos);      
}

//============================================================
vec3 MaterialDiffuseColor (int materialIndex)
{
    if (materialIndex == 0)
        return vec3(0.2, 0.4, 0.8);
    else if (materialIndex == 1)
        return vec3(1.0, 0.0, 0.0);
    else if (materialIndex == 2)
        return vec3(0.0, 1.0, 0.0);
    else if (materialIndex == 3)
        return vec3(0.9, 0.3, 0.0);    
    else if (materialIndex == 4)
        return vec3(0.0, 0.0, 1.0);     
    else if (materialIndex == 5)
        return vec3(0.1, 0.1, 0.1);        
    else
        return vec3(1.0);
}

//============================================================
float MaterialSpecularPower (int materialIndex)
{
    if (materialIndex == 3)
        return 80.0;
    else if (materialIndex == 5)
        return 100.0;
    else
    	return 10.0;
}

//============================================================
// SHARED CODE END
//============================================================

//============================================================
// save/load code from IQ's shader: https://www.shadertoy.com/view/MddGzf
vec4 loadValue( in vec2 re )
{
    return texture2D( iChannel1, (0.5+re) / iChannelResolution[1].xy, -100.0 );
}

//============================================================
// Signed Distance Functions taken/adapted/inspired by from:
// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm

//============================================================
float UDAARectangle (in vec2 coords, in vec2 pos, in vec2 halfSize)
{        
	// make coords relative to pos
    coords -= pos;

    // calculate closest point
    vec2 closestPoint;
    closestPoint.x = clamp(coords.x, -halfSize.x, halfSize.x);
    closestPoint.y = clamp(coords.y, -halfSize.y, halfSize.y);
    
    // return length to closest point
    return length(coords - closestPoint);
}


//=======================================================================================
float CubicHermite (float A, float B, float C, float D, float t)
{
	float t2 = t*t;
    float t3 = t*t*t;
    float a = -A/2.0 + (3.0*B)/2.0 - (3.0*C)/2.0 + D/2.0;
    float b = A - (5.0*B)/2.0 + 2.0*C - D / 2.0;
    float c = -A/2.0 + C/2.0;
   	float d = B;
    
    return a*t3 + b*t2 + c*t + d;
}

//=======================================================================================
vec2 CubicHermite (vec2 A, vec2 B, vec2 C, vec2 D, float t)
{
	float t2 = t*t;
    float t3 = t*t*t;
    vec2 a = -A/2.0 + (3.0*B)/2.0 - (3.0*C)/2.0 + D/2.0;
    vec2 b = A - (5.0*B)/2.0 + 2.0*C - D / 2.0;
    vec2 c = -A/2.0 + C/2.0;
   	vec2 d = B;
    
    return a*t3 + b*t2 + c*t + d;
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
vec3 SampleInterpolationTexturePixel (vec2 pixel)
{
    pixel = mod(pixel, 2.0);
    
    // Used only for the interpolation buttons!
    return vec3(
        pixel.x / 3.0,
    	pixel.y / 3.0,
        mod(pixel.x + pixel.y, 2.0)
    );    
}

//============================================================
vec3 SampleInterpolationTextureNearest (vec2 uv)
{
    vec2 pixel = clamp(floor(uv*2.0), 0.0, 1.0);
	return SampleInterpolationTexturePixel(pixel);
}

//============================================================
vec3 SampleInterpolationTextureBilinear (vec2 uv)
{
    vec2 pixel = uv * 2.0 - 0.5;
    vec2 pixelFract = fract(pixel);
    
    vec3 pixel00 = SampleInterpolationTexturePixel(floor(pixel) + vec2(0.0, 0.0));
    vec3 pixel10 = SampleInterpolationTexturePixel(floor(pixel) + vec2(1.0, 0.0));
    vec3 pixel01 = SampleInterpolationTexturePixel(floor(pixel) + vec2(0.0, 1.0));
    vec3 pixel11 = SampleInterpolationTexturePixel(floor(pixel) + vec2(1.0, 1.0));
    
    vec3 row0 = mix(pixel00, pixel10, pixelFract.x);
    vec3 row1 = mix(pixel01, pixel11, pixelFract.x);
    
    return mix(row0, row1, pixelFract.y);
}

//============================================================
vec3 SampleInterpolationTextureBicubic (vec2 uv)
{
    vec2 pixel = uv * 2.0 - 0.5;
    vec2 pixelFract = fract(pixel);
    
    vec3 pixelNN = SampleInterpolationTexturePixel(floor(pixel) + vec2(-1.0, -1.0));
    vec3 pixel0N = SampleInterpolationTexturePixel(floor(pixel) + vec2( 0.0, -1.0));
    vec3 pixel1N = SampleInterpolationTexturePixel(floor(pixel) + vec2( 1.0, -1.0));
    vec3 pixel2N = SampleInterpolationTexturePixel(floor(pixel) + vec2( 2.0, -1.0));
    
    vec3 pixelN0 = SampleInterpolationTexturePixel(floor(pixel) + vec2(-1.0,  0.0));
    vec3 pixel00 = SampleInterpolationTexturePixel(floor(pixel) + vec2( 0.0,  0.0));
    vec3 pixel10 = SampleInterpolationTexturePixel(floor(pixel) + vec2( 1.0,  0.0));
    vec3 pixel20 = SampleInterpolationTexturePixel(floor(pixel) + vec2( 2.0,  0.0));   
    
    vec3 pixelN1 = SampleInterpolationTexturePixel(floor(pixel) + vec2(-1.0,  1.0));
    vec3 pixel01 = SampleInterpolationTexturePixel(floor(pixel) + vec2( 0.0,  1.0));
    vec3 pixel11 = SampleInterpolationTexturePixel(floor(pixel) + vec2( 1.0,  1.0));
    vec3 pixel21 = SampleInterpolationTexturePixel(floor(pixel) + vec2( 2.0,  1.0));     
    
    vec3 pixelN2 = SampleInterpolationTexturePixel(floor(pixel) + vec2(-1.0,  2.0));
    vec3 pixel02 = SampleInterpolationTexturePixel(floor(pixel) + vec2( 0.0,  2.0));
    vec3 pixel12 = SampleInterpolationTexturePixel(floor(pixel) + vec2( 1.0,  2.0));
    vec3 pixel22 = SampleInterpolationTexturePixel(floor(pixel) + vec2( 2.0,  2.0));     
    
    vec3 rowN = CubicHermite(pixelNN, pixel0N, pixel1N, pixel2N, pixelFract.x);
    vec3 row0 = CubicHermite(pixelN0, pixel00, pixel10, pixel20, pixelFract.x);
    vec3 row1 = CubicHermite(pixelN1, pixel01, pixel11, pixel21, pixelFract.x);
    vec3 row2 = CubicHermite(pixelN2, pixel02, pixel12, pixel22, pixelFract.x);
    
    return CubicHermite(rowN, row0, row1, row2, pixelFract.y);
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
void DrawUI (in vec2 fragCoord, inout vec3 pixelColor, int sizeMode, int interpolationMode, bool upsizeImage)
{
    float aspectRatio = iResolution.x / iResolution.y;
    vec2 uv = (fragCoord / iResolution.xy);
    uv.x *= aspectRatio;
    uv.y = 1.0 - uv.y;
    
    vec2 buttonClickRelative = mod(uv, c_buttonSize+c_buttonPadding);
    vec2 buttonIndex = floor(uv / (c_buttonSize+c_buttonPadding));
    
    const float c_darkTint = 1.0 / 10.0;
    
    // draw the size mode buttons
    
    // full size
    {
        float tint = (sizeMode == 0) ? 1.0 : c_darkTint;
        vec2 center = vec2(c_buttonSize*0.5 + c_buttonPadding);
        center += vec2(0.0, 0.0) * (c_buttonSize+c_buttonPadding);
        float dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.5));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, vec3(tint), dist); 
    }
    
    // half size horizontally
    {
        float tint = (sizeMode == 1) ? 1.0 : c_darkTint;
        vec2 center = vec2(c_buttonSize*0.5 + c_buttonPadding);
        center += vec2(1.0, 0.0) * (c_buttonSize+c_buttonPadding);;
        float dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.5));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, vec3(0.0), dist); 
        
        center.x -= c_buttonSize * 0.25;
		dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.25, c_buttonSize*0.5));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, vec3(tint), dist);
    }
    
    // half size vertically
    {
        float tint = (sizeMode == 2) ? 1.0 : c_darkTint;
        vec2 center = vec2(c_buttonSize*0.5 + c_buttonPadding);
        center += vec2(2.0, 0.0) * (c_buttonSize+c_buttonPadding);;
        float dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.5));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, vec3(0.0), dist); 
        
        center.y += c_buttonSize * 0.25;
        dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.5, c_buttonSize*0.25));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, vec3(tint), dist);         
    }      
    
    // quarter size
    {
        float tint = (sizeMode == 3) ? 1.0 : c_darkTint;
        vec2 center = vec2(c_buttonSize*0.5 + c_buttonPadding);
        center += vec2(3.0, 0.0) * (c_buttonSize+c_buttonPadding);;
        float dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.5));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, vec3(0.0), dist);
        
        center -= vec2(c_buttonSize * 0.25, -c_buttonSize * 0.25);
        dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.25, c_buttonSize*0.25));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, vec3(tint), dist);          
    }     
    
    // eighth size
    {
        float tint = (sizeMode == 4) ? 1.0 : c_darkTint;
        vec2 center = vec2(c_buttonSize*0.5 + c_buttonPadding);
        center += vec2(4.0, 0.0) * (c_buttonSize+c_buttonPadding);
        float dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.5));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, vec3(0.0), dist);
        
        center -= vec2(c_buttonSize * 0.375, -c_buttonSize * 0.375);
        dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.125, c_buttonSize*0.125));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, vec3(tint), dist);
    }    
    
    // draw the blend mode icons
    
    // nearest neighbor
    {
        float tint = (interpolationMode == 0) ? 1.0 : c_darkTint;
        vec2 center = vec2(c_buttonSize*0.5 + c_buttonPadding);
        center += vec2(0.0, 1.0) * (c_buttonSize+c_buttonPadding);  
        
        vec2 percent = (uv - (center - vec2(c_buttonSize*0.5))) / c_buttonSize;
        vec3 buttonColor = vec3(
            clamp(floor(percent.x * 4.0) / 3.0, 0.0, 1.0),
            clamp(floor(percent.y * 4.0) / 3.0, 0.0, 1.0),
			0.0);
        
        buttonColor = SampleInterpolationTextureNearest(percent);
        
        float dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.5));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, buttonColor * tint, dist);        
    }

    // bilinear
    {
        float tint = (interpolationMode == 1) ? 1.0 : c_darkTint;
        vec2 center = vec2(c_buttonSize*0.5 + c_buttonPadding);
        center += vec2(1.0, 1.0) * (c_buttonSize+c_buttonPadding);  
        
        vec2 percent = (uv - (center - vec2(c_buttonSize*0.5))) / c_buttonSize;
        vec3 buttonColor = vec3(
            clamp(floor(percent.x * 4.0) / 3.0, 0.0, 1.0),
            clamp(floor(percent.y * 4.0) / 3.0, 0.0, 1.0),
			0.0);
        
        buttonColor = SampleInterpolationTextureBilinear(percent);
        
        float dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.5));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, buttonColor * tint, dist);       
    }  
    
    // bicubic
    {
        float tint = (interpolationMode == 2) ? 1.0 : c_darkTint;
        vec2 center = vec2(c_buttonSize*0.5 + c_buttonPadding);
        center += vec2(2.0, 1.0) * (c_buttonSize+c_buttonPadding);  
        
        vec2 percent = (uv - (center - vec2(c_buttonSize*0.5))) / c_buttonSize;
        vec3 buttonColor = vec3(
            clamp(floor(percent.x * 4.0) / 3.0, 0.0, 1.0),
            clamp(floor(percent.y * 4.0) / 3.0, 0.0, 1.0),
			0.0);
        
        buttonColor = SampleInterpolationTextureBicubic(percent);
        
        float dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.5));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, buttonColor * tint, dist);       
    }   
    
    // draw the image resample toggle
    
    // data
    {
        float tint = (!upsizeImage) ? 1.0 : c_darkTint;
        vec2 center = vec2(c_buttonSize*0.5 + c_buttonPadding);
        center += vec2(0.0, 2.0) * (c_buttonSize+c_buttonPadding);  
        
        vec2 percent = (uv - (center - vec2(c_buttonSize*0.5))) / c_buttonSize;
        vec3 buttonColor = vec3(
            clamp(floor(percent.x * 4.0) / 3.0, 0.0, 1.0),
            clamp(floor(percent.y * 4.0) / 3.0, 0.0, 1.0),
			0.0);
        
        buttonColor = vec3(1.0);
        
        float dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.5));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, buttonColor * tint, dist);        
    }    
    
    // image
    {
        float tint = (upsizeImage) ? 1.0 : c_darkTint;
        vec2 center = vec2(c_buttonSize*0.5 + c_buttonPadding);
        center += vec2(1.0, 2.0) * (c_buttonSize+c_buttonPadding);  
        
        vec2 percent = (uv - (center - vec2(c_buttonSize*0.5))) / c_buttonSize;
        vec3 buttonColor = vec3(
            clamp(floor(percent.x * 4.0) / 3.0, 0.0, 1.0),
            clamp(floor(percent.y * 4.0) / 3.0, 0.0, 1.0),
			0.0);
        
        buttonColor = vec3(1.0);
        
        float dist = UDAARectangle(uv, center, vec2(c_buttonSize*0.5));
        dist = 1.0 - smoothstep(0.0, AA_AMOUNT, dist);
        pixelColor = mix(pixelColor, buttonColor * tint, dist);        
    }        
}

//============================================================
void mainImage ( out vec4 fragColor, in vec2 fragCoord )
{    
    // get the state from the buffer
    vec4 state = loadValue(txState);
    int sizeMode = int(state.x);
    int interpolationMode = int(state.y);
    bool upsizeImage = state.z == 1.0;
    
    // adjust coordinates based on size mode if we are upsizing data, not the final image
    vec2 adjustedFragCoord = fragCoord;
    if (upsizeImage) {
        if (sizeMode == 1 || sizeMode == 3)
            adjustedFragCoord.x /= 2.0;

        if (sizeMode == 2 || sizeMode == 3)
            adjustedFragCoord.y /= 2.0;

        if (sizeMode == 4)
            adjustedFragCoord /= 4.0;
    }
    else
        interpolationMode = 0;    
    
    // sample texture
    vec3 pixelColor;
    if (interpolationMode == 0)
    	pixelColor = SampleNearest(adjustedFragCoord).rgb;        
    else if (interpolationMode == 1)
        pixelColor = SampleBilinear(adjustedFragCoord).rgb;
    else
        pixelColor = SampleBicubic(adjustedFragCoord).rgb; 
        
    // draw the UI. from the original, restoring interpolationMode since it might have been artifically modified above
    interpolationMode = int(state.y);
    DrawUI(fragCoord, pixelColor, sizeMode, interpolationMode, upsizeImage);
        
    // gamma correct
	pixelColor = pow(pixelColor, vec3(1.0/c_gamma));
    fragColor = vec4(pixelColor, 1.0);
}
