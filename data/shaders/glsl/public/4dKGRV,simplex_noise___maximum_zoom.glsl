// Shader downloaded from https://www.shadertoy.com/view/4dKGRV
// written by shadertoy user raRaRa
//
// Name: Simplex Noise - Maximum zoom
// Description: Testing maximum zoom before hitting FP32 precision problems. Going to try emulating some FP64 calculations to see if I can improve the zoom. Any suggestions or ideas are more than welcome. Thanks!
//    The mouse x coordinate is used to zoom.
float getHeight(vec2 uv) {
	return texture2D( iChannel0, uv ).r;
}

vec3 getNormalSobel(vec2 uv, float zoom) {
    float vTEXEL_ONE = 1.0 / iResolution.x;
    float tl = getHeight(uv + vTEXEL_ONE * vec2(0, 0));   // top left
    float  l = getHeight(uv + vTEXEL_ONE * vec2(0, 1));   // left

    float bl = getHeight(uv + vTEXEL_ONE * vec2(0, 2));   // bottom left
    float  t = getHeight(uv + vTEXEL_ONE * vec2(1, 0));   // top

    float  b = getHeight(uv + vTEXEL_ONE * vec2(1, 2));   // bottom
    float tr = getHeight(uv + vTEXEL_ONE * vec2(2, 0));   // top right

    float  r = getHeight(uv + vTEXEL_ONE * vec2(2, 1));   // right
    float br = getHeight(uv + vTEXEL_ONE * vec2(2, 2));   // bottom right
 
    // Compute dx using Sobel:
    //           -1 0 1 
    //           -2 0 2
    //           -1 0 1
    float dX = tr + 2.0*r + br -tl - 2.0*l - bl;
 
    // Compute dy using Sobel:
    //           -1 -2 -1 
    //            0  0  0
    //            1  2  1
    float dY = bl + 2.0*b + br -tl - 2.0*t - tr;

    float normalStrength = 0.125 / ( (zoom + 1.0) * (zoom + 1.0) );
 
    // Build the normalized normal
    vec3 normal = normalize(vec3(dX, dY, 2.0 * normalStrength));

   // normal = normal * 0.5 + 0.5;
 
    //convert (-1.0 , 1.0) to (0.0 , 1.0), if needed
    return normal;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float zoom = (iMouse.x / iResolution.x + 0.02) * 250.0;
    
	vec2 uv = fragCoord.xy / iResolution.xx;
    vec3 normal = getNormalSobel(uv, zoom);
    
	fragColor = vec4(normal, 1.0);
}	