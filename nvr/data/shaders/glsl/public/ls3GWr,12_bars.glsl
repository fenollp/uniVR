// Shader downloaded from https://www.shadertoy.com/view/ls3GWr
// written by shadertoy user bendecoste
//
// Name: 12 Bars
// Description: 12 horizontal bars .. shift colors over time
const int bars = 12;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    for (int i = 0; i < bars; i += 1) {
        float val = float(i) / float(bars);
        if (uv.x > val) {
            
            float s = abs(sin(iGlobalTime * val));
            float u = abs(cos(iGlobalTime * val));
            float v = abs(sin(iGlobalTime));
            
            
            fragColor = vec4(s, u, v, 1.0);
        }
    }
}