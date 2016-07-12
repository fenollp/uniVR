// Shader downloaded from https://www.shadertoy.com/view/XtsGWH
// written by shadertoy user aiekick
//
// Name: [2TC 15] Light Wave
// Description: [2TC 15] Light Wave
#define k s.x*3.*sin(t)-t*2.
void mainImage( out vec4 f, in vec2 w )
{
    vec2 s = iResolution.xy;
    float t = iDate.w, i = 1e-6, o;
    
    s = (w/s.xy*2.-1.)*vec2(s.x/s.y,.05);
   
    s.x*=cos(k);
    s.y*=cos(k);
    
    o = 10. / (s.y-i) - 10. / (s.y+i);
    
    f = o*vec4(1,.4,.2,1);
}