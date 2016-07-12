// Shader downloaded from https://www.shadertoy.com/view/llsXRr
// written by shadertoy user coyote
//
// Name: Surfing 139 chars
// Description: Finally managed to fit it in 1 tweet! :)
//139
//sorry iapafoto, your coloring had to go...
void mainImage( out vec4 o, vec2 i )
{
    i/=iResolution.y;
    float a=atan(i.y,i.x-=.9),
          L=length(i+i)/a;
    o=texture2D(iChannel0, vec2( L, L*a-iDate.w) )/L;
}


//157
//colors by iapafoto
/*
void mainImage( out vec4 o, vec2 i )
{
    i = (i+i-(o.xy=iResolution.xy))/o.y;
    float a=atan(++i.y,i.x),
          L=length(i)/a;
    o.garb=texture2D(iChannel0, vec2( L, L*a-iDate.w) )/L;
}
*/