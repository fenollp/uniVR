// Shader downloaded from https://www.shadertoy.com/view/MdtXWX
// written by shadertoy user Reedbeta
//
// Name: Pulse effect
// Description: Simple demo of how to use a shader to make an expanding pulse effect
float saturate(float x)
{
    return clamp(x, 0.0, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Set the center point and thickness in pixels of the pulse effect
    vec2 center = vec2(0.7, 0.5) * iResolution.xy;
    float thickness = 12.0;
    
    // Calculate distance from effect center, in pixels
    vec2 vecFromCenter = fragCoord - center;
    float radius = sqrt(dot(vecFromCenter, vecFromCenter));

    // Calculate current size of the pulse
    float outerRadius = 300.0 * fract(iGlobalTime / 3.0);
    float innerRadius = outerRadius - thickness;

    // Calculate a function that will be 1.0 inside the pulse, 0.0 outside,
    // with a 1px-wide falloff to antialias the edges
    float pulse = saturate(radius - innerRadius) * saturate(outerRadius - radius);

    // Lerp between the pulse color and background color based on this
    vec4 pulseColor = vec4(0.25, 1.0, 0.8, 1.0);
    vec4 backgroundColor = vec4(0.0, 0.0, 0.0, 1.0);
    fragColor = mix(backgroundColor, pulseColor, pulse);

    // Approximate linear-to-sRGB conversion (improves antialiasing quality)
    fragColor.rgb = sqrt(fragColor.rgb);
}
