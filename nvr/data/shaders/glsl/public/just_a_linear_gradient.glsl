// Shader downloaded from https://www.shadertoy.com/view/lscGDr
// written by shadertoy user tsone
//
// Name: Just A Linear Gradient
// Description: Drag with mouse to move the gradient. Gamma encoding is to correctly linearly interpolate between the colors.

const vec3 color0 = vec3(1.0, 0.0, 0.2);
const vec3 color1 = vec3(0.6, 1.0, 0.1);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 A; // First gradient point.
    vec2 B; // Second gradient point.
    if (iMouse == vec4(0.0)) {
        A = vec2(0.2*iResolution.xy);
        B = vec2(iResolution.xy);
    } else {
        A = abs(iMouse.zw);
        B = iMouse.xy;
    }

    vec2 V = B - A;
    
    float s = dot(fragCoord.xy-A, V) / dot(V, V); // Vector projection.
    s = clamp(s, 0.0, 1.0); // Saturate scaler.
    vec3 color = mix(color0, color1, s); // Gradient color interpolation.
    
    color = pow(color, vec3(1.0/2.2)); // sRGB gamma encode.
    fragColor = vec4(color, 1.0);
}
