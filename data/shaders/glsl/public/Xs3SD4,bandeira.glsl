// Shader downloaded from https://www.shadertoy.com/view/Xs3SD4
// written by shadertoy user guerreiro
//
// Name: Bandeira
// Description: Music visualization
#define TAU 6.283185307

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 position = fragCoord.xy / iResolution.xy;
    vec2 flagPosition = (fragCoord.xy - iResolution.xy / 2.0) / min(iResolution.x / 22.0, iResolution.y / 16.0);
    float ande = dot(flagPosition, vec2(1.0, 0.5)) - iGlobalTime * 2.0;
    flagPosition += vec2(-0.2, 0.2) * sin(ande);
    
    float angle = atan(flagPosition.y, flagPosition.x) / TAU + 0.5;
    
	float wave = texture2D(iChannel0, vec2(angle, 1.0)).x;
	float freqs = texture2D(iChannel0, vec2(position.x, 0.0)).x;
    
    vec3 color;
    if(abs(flagPosition.x) < 10.0 && abs(flagPosition.y) < 7.0) {
        if(length(flagPosition) < 3.0 + 1.0 * wave) {
            float d = length(flagPosition - vec2(-2.0, -7.0));
            color = 8.0 <= d && d < 8.5 ? vec3(1.0) : vec3(0.243, 0.251, 0.584);
        } else if(abs(dot(flagPosition, vec2(5.3, 8.3))) < 43.99 && abs(dot(flagPosition, vec2(5.3, -8.3))) < 43.99) {
            color = vec3(1.0, 0.8, 0.161);
        } else {
            color = vec3(0.0, 0.659, 0.349);
        }
        color *= 0.9 + 0.1 * cos(ande);
    } else {
        color = vec3(freqs < position.y ? 0.25 : 0.0);
    }
    
    fragColor = vec4(color, 1.0);
}