// Shader downloaded from https://www.shadertoy.com/view/Mdy3RR
// written by shadertoy user cornusammonis
//
// Name: Gaussian Pyramid
// Description: 1 color channel gaussian pyramid blur. Mouse X to fade between blur levels.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 vMouse = iMouse.xy / iResolution.xy;

    vec4 one = vec4(1.0);
    vec4 off = vec4(0.1);
    vec4 b0 = vec4(texture2D(iChannel0, uv).yw, texture2D(iChannel1, uv).yw);
    vec4 b1 = vec4(texture2D(iChannel2, uv).yw, texture2D(iChannel3, uv).yw);
    float blurl = 7.0 * vMouse.x;
    float bb = blurl * blurl;
    vec4 d0 = vec4(bb, 1.0 - 2.0 * blurl + bb, 4.0 - 4.0 * blurl + bb, 9.0 - 6.0 * blurl + bb);
    vec4 d1 = vec4(16.0 - 8.0 * blurl + bb, 25.0 - 10.0 * blurl + bb, 36.0 - 12.0 * blurl + bb, 49.0 - 14.0 * blurl + bb);
    float n = dot(b0  / (off + d0), one) + dot(b1  / (off + d1), one);
    float d = dot(one / (off + d0), one) + dot(one / (off + d1), one);
    fragColor = vec4(n / d);
}