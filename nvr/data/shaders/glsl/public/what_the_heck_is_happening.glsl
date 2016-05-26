// Shader downloaded from https://www.shadertoy.com/view/Xdc3zn
// written by shadertoy user CaptCM74
//
// Name: What the heck is happening
// Description: Why world ;-;
#define sat 0.0
#define blueness 0.5
#define zoomout 1.0
#define ispan false
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 coord = fragCoord.xy / iResolution.xy;
    vec2 zoom = coord.xy * zoomout;
    vec2 pan = zoom.xy;
    vec4 img = texture2D(iChannel0,pan);
    vec4 aze = texture2D(iChannel1,pan);
    vec4 fin = img;
    
    if (ispan == true)
    {
    vec2 pan = zoom.xy + max(min(sin(iGlobalTime),0.5),0.0);
    }
    else
    {
    vec2 pan = zoom.xy;
    }
    
    if (aze.g > 0.5)
    {
        
      discard;  
    }
   
    fin = aze;
    img.b = blueness;
    float green = aze.g;
    vec4 sated = vec4(mix(img,img*2.0,sat));
    fragColor = vec4(mix(sated,fin,0.5));
   // fragColor = vec4(mix(img,img*2.0,sat));
}