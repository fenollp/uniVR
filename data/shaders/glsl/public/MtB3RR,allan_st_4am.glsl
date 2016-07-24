// Shader downloaded from https://www.shadertoy.com/view/MtB3RR
// written by shadertoy user macbooktall
//
// Name: Allan St 4am
// Description: dunno
//    noise function by iq https://www.shadertoy.com/view/MsXGWr
float hash( float n )
{
    return fract(sin(n)*43758.5453123);
}

float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*157.0;

    return mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
               mix( hash(n+157.0), hash(n+158.0),f.x),f.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float x = fragCoord.x / iResolution.x;
    float y = fragCoord.y / iResolution.y;
    x = abs(x*2.0-1.0);
    y = abs(y*2.0-1.0) ;

    vec2 v1 = vec2(((sin(x)*y*8.0)-sin(iGlobalTime)), ((sin(x)*8.0)-iGlobalTime));
    vec2 v2 = vec2(((x*sin(y)*8.0)-cos(iGlobalTime)), ((sin(x)*8.0)-iGlobalTime));
    
    float b = noise(v1);
    float r = noise(v2);

    fragColor = vec4(r/b-b*y, 1.0 - r*b, b*2.0/x-r, 1.0);
}
