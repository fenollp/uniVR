// Shader downloaded from https://www.shadertoy.com/view/MdG3Wh
// written by shadertoy user fallicory
//
// Name: Overlaid trig patterns 1
// Description: Overlapping coloured layers creating visually disorientating movement


#define PI 3.14159265359

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = vec2(fragCoord.x / iResolution.y, fragCoord.y / iResolution.y);
    
    // Get the coordinates relative to the centre
    vec2 relative = vec2((uv.x * 2.0) - (iResolution.x / iResolution.y), (uv.y * 2.0) - 1.0);
    
    // Convert to polar coords
    float angle = atan(relative.y, relative.x);
    float dist = length(relative);
    
    // Work out individual colour rotations
    float rRotate = angle + sin(iGlobalTime * 0.5) / 10.0;
    float gRotate = angle + sin(iGlobalTime * 0.7) / 10.0;
    float bRotate = angle + sin(iGlobalTime * 1.3) / 10.0;
    
    // Magic!
    float r = (sin(  (dist * PI * 16.0) + iGlobalTime * 4.0 + (sin(rRotate * 3.0 * 24.0) * 1.5) + (sin(rRotate * 3.0 * 4.0) * 10.0) + (sin(rRotate * 3.0 * 3.0)*7.0)   ) + 1.0) / 2.0;
    float g = (sin(  (dist * PI * 16.0) + iGlobalTime * 4.0 + (sin(rRotate * 3.0 * 17.0) * 1.5) + (sin(gRotate * 3.0 * 5.0) * 10.0) + (sin(gRotate * 3.0 * 3.0)*6.0)   ) + 1.0) / 2.0;
    float b = (sin(  (dist * PI * 16.0) + iGlobalTime * 4.0 + (sin(rRotate * 3.0 * 33.0) * 1.5) + (sin(bRotate * 3.0 * 3.0) * 10.0) + (sin(bRotate * 3.0 * 3.0)*8.0)   ) + 1.0) / 2.0;

    // Dull green channel as it's a bit overwhelming as the eye is more sensitive to green
    g = 0.8 * g;
    
    // Brighten near centre
    r = r + (clamp(1.2 - dist, 0.0, 1.0) * 0.4 * 2.0);
    g = g + (clamp(1.2 - dist, 0.0, 1.0) * 0.3 * 2.0);
    b = b + (clamp(1.2 - dist, 0.0, 1.0) * 0.5 * 2.0);
    
    // Dim very centre
    float dimming = (clamp(0.35 - dist, 0.0, 0.35) * 7.0);
    r = r - dimming;
    g = g - dimming;
    b = b - dimming;
     
    // Vingette effect
    float vingette = (1.0 - (dist * 0.5));
    r = r * vingette;
    g = g * vingette;
    b = b * vingette;
    
    fragColor = vec4(r, g, b, 1.0);
}