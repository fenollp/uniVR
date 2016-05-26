// Shader downloaded from https://www.shadertoy.com/view/4lBGDW
// written by shadertoy user antonOTI
//
// Name: Mic to the heart
// Description: trying the new microphone feature. I've plugged the audio into the microphone so I can experiment with whatever pass on my computer.
//    I don't have notion in sound so I still don't really understand how frequency differentiate from the sound wave
float f(vec2 a, vec2 b)
{
    return 1.- smoothstep(.25,.35,length((a + b) - vec2(.75, .5)));
}

void mainImage( out vec4 o, vec2 i )
{
	vec2 u = i / iResolution.y;
	u.y += -abs(u.x - .75)*.55;
	vec4 n = texture2D(iChannel1,u) - .5 ;
	n *= texture2D(iChannel0,vec2(.45,.25)).x *.7;
	o += vec4(f(u,n.xy), f(u,n.xz), f(u,n.zy),1);
}