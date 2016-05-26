// Shader downloaded from https://www.shadertoy.com/view/ls3SWf
// written by shadertoy user guachito
//
// Name: Function Testing
// Description: Testing basic function representation. How can I smooth the output?
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   fragColor = vec4(0);
   float amp = 7.0;
   float function = sin(fragCoord.x / amp);
   float y = function * 20.0 + 50.;
   fragColor = vec4(smoothstep(5.,0.,abs(y-fragCoord.y)));
}