// Shader downloaded from https://www.shadertoy.com/view/Mt23Dm
// written by shadertoy user poljere
//
// Name: Reactive Flower
// Description: Shader live-coded during our &quot;Shadertoy @ Zynga&quot; presentation. A simple flower that reacts with the microphone. Based on IQ's flower: https://www.shadertoy.com/view/4dX3Rn
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv -= vec2(0.5);
    uv.x *= iResolution.x / iResolution.y;
    
    // Read the microphone
    float react = texture2D(iChannel0, vec2(0.1, 0.0)).x;
    
    // Draw a circle
    float a = atan(uv.y, uv.x);
    float r = length(uv);
    float ir= 1.0 - r;
    
    ir += 0.1 * sin(a * 5.0 + r * 50.0 * react + iGlobalTime);
    float c = smoothstep(0.8, 0.85, ir);
    
    c += (1.0 - smoothstep(0.01, 0.03, abs(uv.x + 0.1 * sin(uv.y * 9.0)))) * (1.0 - smoothstep(0.01, 0.03, uv.y));
    
    // Draw a background
    vec3 col = mix(vec3(0.8, 0.8, 0.2), vec3(0.8, 0.2, 0.2), uv.y);
    col = mix(col, vec3(0.0), c);
    
    // Draw a tunnel
    //col = r * texture2D(iChannel1, vec2( 1.0 / r, a)).xyz;
    
    fragColor = vec4(col, 1.0);
}