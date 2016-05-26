// Shader downloaded from https://www.shadertoy.com/view/MllXzj
// written by shadertoy user FabriceNeyret2
//
// Name: swirl 2
// Description: trying various swirling functions.
void mainImage( out vec4 o, vec2 u )
{
    vec2 R=iResolution.xy;
    float l=length(u+=u-R)/R.y, a=atan(u.y,u.x), t=iGlobalTime;
    
    a += sin(t/l);
    //a += t*sin(l*10.);
    //a += sin(t*l);
    //a += t*l;
    //a += t/l;

	o = texture2D(iChannel0,l*sin(a+1.6*o.wx));
}