// Shader downloaded from https://www.shadertoy.com/view/Mts3D7
// written by shadertoy user SmartPointer
//
// Name: CheckerBoard3000
// Description: test
precision highp float;

#define BG_COLOR     vec4(1.0, 0.4313, 0.3411, 1.0)
#define FILL_COLOR   vec4(0.3804, 0.7647, 1.0, 1.0)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    vec2 v = fragCoord.xy;
    v.x += sin(iGlobalTime * 10.0) * 30.0;
    v.y += cos(iGlobalTime * 10.0) * 30.0;
    //v.y += cos(v.x) * 2000.0;
    
    fragColor = BG_COLOR;
    
    if (mod(v.y, 32.0) < 16.0) {
        if (mod(v.x, 32.0) > 16.0)
            fragColor = FILL_COLOR;
    } else {
        if (mod(v.x, 32.0) < 16.0)
            fragColor = FILL_COLOR;
    }
}
