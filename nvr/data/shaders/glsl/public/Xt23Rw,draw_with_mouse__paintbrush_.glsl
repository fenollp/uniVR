// Shader downloaded from https://www.shadertoy.com/view/Xt23Rw
// written by shadertoy user klk
//
// Name: Draw with mouse (paintbrush)
// Description: If your system support discard (chrome on Linux does), then you can draw something with mouse. Rewind to clear, press LMB and move to draw. Enjoy.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t=iGlobalTime;
    if(t<0.5)
    {
        fragColor=vec4(0.0,0.0,0.0,1.0);
        return;
    }
    if(length(fragCoord.xy-iMouse.xy)>5.0)
        discard;
	fragColor = vec4(1.0,1.0,1.0,1.0);
}