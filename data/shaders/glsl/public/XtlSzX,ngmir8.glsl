// Shader downloaded from https://www.shadertoy.com/view/XtlSzX
// written by shadertoy user netgrind
//
// Name: ngMir8
// Description: what
//    play with the defines
//    mouseX controls amount of fuck
//change the number of taps
#define taps 6.0

//uncomment below to toggle between light and dark
//#define light

//click and drag the mouse too!

#define tau 6.28

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 c  = texture2D(iChannel0,uv);
    float t = iGlobalTime;
    float d = .01+sin(t)*.01+iMouse.x/iResolution.x;
    for(float i = 0.; i<tau;i+=tau/taps){
        float a = i+t;
        vec4 c2 = texture2D(iChannel0,vec2(uv.x+cos(a)*d,uv.y+sin(a)*d));
        #ifdef light
        	c = max(c,c2);
        #else
        	c = min(c,c2);
        #endif
    }
	fragColor = c;
}