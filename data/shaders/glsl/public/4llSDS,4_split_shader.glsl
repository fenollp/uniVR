// Shader downloaded from https://www.shadertoy.com/view/4llSDS
// written by shadertoy user kroltan
//
// Name: 4-split shader
// Description: Composites 4 textures on the diagonal quadrants (triangulants?) of the image.
//    In Unity, feed Render-to-Texture cameras into the channels and you got yourself a hologram projector!
#define center vec2(0.25,0.25)

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pos = uv / 2.0 - center;
    
    float ax = abs(pos.x);
    float ay = abs(pos.y);
    float omx = 1.0 - uv.x;
    float omy = 1.0 - uv.y;
    if (pos.x > 0.0 && ax > ay) {
        fragColor = texture2D(iChannel0, vec2(omy, omx*2.0));
    } else if (pos.y < 0.0 && ax < ay) {
        fragColor = texture2D(iChannel1, vec2(omx, uv.y*2.0));
    } else if (pos.x < 0.0 && ax > ay) {
        fragColor = texture2D(iChannel2, vec2(omy, uv.x*2.0));
    } else {
        fragColor = texture2D(iChannel3, vec2(uv.x, omy*2.0));
    }
}