// Shader downloaded from https://www.shadertoy.com/view/XtSGRG
// written by shadertoy user netgrind
//
// Name: ngMir5
// Description: glitchy cam
#define PI 3.1415
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
     float i = iGlobalTime;
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec2 p = mod(uv,vec2(1.0)/iChannelResolution[0].xy);
    uv-=.5;
    float r = iMouse.x*.05;
    mat2 m = mat2(1,sin(uv.x*r+i),sin(uv.y*r+i),1);
    vec4 n = texture2D(iChannel0,uv*m- p);
    uv+=.5;
    vec4 c = texture2D(iChannel1,uv);
    float d = length(fragCoord.xy-iResolution.xy*.5)*iMouse.y*.0001;
    c.rgb = sin(cos(mod(c.rgb,n.rgb)*PI*2.0+d)*PI*2.0+i+2.0*d);
    
    fragColor = c;
}