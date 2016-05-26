// Shader downloaded from https://www.shadertoy.com/view/XllXWl
// written by shadertoy user kroltan
//
// Name: Multi-level grid
// Description: Creates a 2D grid on the frag space.
#define MainLineWidth 0.05
#define SecondLineWidth 0.02
#define UnitSize 100.0
#define BlurSize 10.0
#define _onLine(f,w) mix(0.0,BlurSize, f - w * 0.5)
#define onLine(f,w) (_onLine(f,w))
#define onLineOffset(f,w,o) (o - _onLine(f,w))

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    
    vec2 xymod = abs(mod(fragCoord, UnitSize) / UnitSize - vec2(.5, .5));
    vec2 lines = xymod;
    if (xymod.y > lines.x) lines = xymod.yx;
    
    fragColor = onLine(lines.y, MainLineWidth) * vec4(1,1,1,1);
    //if (onLineOffset(lines.x, MainLineWidth, 0.5)){
}