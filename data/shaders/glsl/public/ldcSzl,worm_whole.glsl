// Shader downloaded from https://www.shadertoy.com/view/ldcSzl
// written by shadertoy user Blubor2
//
// Name: worm-whole
// Description: you have to click and drag around a little to make this shader work... any workaround for this?
//    this is my first shader. just playing around with the buffer resulted in this.
//defines
#define radius 0.1
//globals
const vec3 bgColor = vec3(0.0);
const vec3 axesColor = vec3(0.0, 0.0, 1.0);
const vec3 gridColor = vec3(0.5);

//functions first
bool line(float pos, float width)
{
    if (abs(pos) < width) return true;
    return false;
}


vec2 coord(vec2 xy)
{
    //normalize to -1,+1
    vec2 uv = 2.0 * xy.xy / iResolution.xy - 1.0;
    //fix ar such that y=[-1,1], x=[-1*ar,1*ar] (usually >1)
    uv.x = uv.x * iResolution.x / iResolution.y;
    return uv;
}

//main sampler
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 c = texture2D(iChannel0,fragCoord.xy/iResolution.xy);
    
 
    fragColor = 1.2-c;
}

