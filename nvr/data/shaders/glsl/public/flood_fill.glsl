// Shader downloaded from https://www.shadertoy.com/view/Xd3SWX
// written by shadertoy user denilsonsa
//
// Name: Flood Fill
// Description: Flood Fill algorithm implemented in a fragment shader.
//    
//    How to use: just click, and watch.
//    
//    Optionally change the constants, or change the source image.
// Implements a "Flood Fill" algorithm in a fragment shader.
//
// Most of the logic is inside "Buf A" code.
// The main code only copies from Buffer A onto the screen.
//
// 1. Grab a frame from SOURCE and store it at BUFFER.
//    In this implementation, it happens at the very beginning, and also when clicking.
// 2. IF this pixel is the clicked one
//    THEN paint it.
// 3. IF this pixel is neighbor to a painted pixel.
//    AND its color is very similar to the clicked pixel.
//    THEN paint it.
// 4. Repeat these steps forever.
//
// In this case, the painting is done on the alpha channel.
// A value of 1.0 is opaque/unpainted.
// A value of 0.0 is transparent/painted.


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

    vec4 pixel = texture2D(iChannel0, uv);
    vec3 blinking = vec3(0.5 + 0.5 * sin(-iGlobalTime * 2.0 * 3.1415 + fragCoord.x - fragCoord.y));

    fragColor.xyz = (pixel.w * pixel.xyz) + (1.0 - pixel.w) * blinking;
    fragColor.w = 1.0;

    // Debugging:
    if (false) {
        fragColor.x += 5.0 / distance(iMouse.xy, fragCoord);
        fragColor.y += 5.0 / distance(iMouse.zw, fragCoord);
        fragColor.z += 5.0 / distance(-iMouse.zw, fragCoord);
    }
}