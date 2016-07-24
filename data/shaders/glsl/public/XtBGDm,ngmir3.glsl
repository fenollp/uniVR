// Shader downloaded from https://www.shadertoy.com/view/XtBGDm
// written by shadertoy user netgrind
//
// Name: ngMir3
// Description: far in
#define PI 3.14159265359
#define count 3.0
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy-.5;
    vec4 c = vec4(0.0);
    float d = length(uv);
    float a = atan(uv.y,uv.x);
    float i = iGlobalTime;
    float f = floor(iMouse.y*.1);
    float amp = iMouse.x/iResolution.x;
    for(float j = 0.; j<=PI*2.;j+=PI/count*2.){
        uv.x = cos(a)*(d+d*amp*sin(a*f+i+j));
        uv.y = sin(a)*(d+d*amp*cos(a*f+i+j));

        c+=texture2D(iChannel0,abs(mod(uv-.5,2.0)-1.0));
    }
	fragColor = (c*3.0/c.a);
}