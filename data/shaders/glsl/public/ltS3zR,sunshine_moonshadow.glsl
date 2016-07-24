// Shader downloaded from https://www.shadertoy.com/view/ltS3zR
// written by shadertoy user macbooktall
//
// Name: sunshine moonshadow
// Description: 2
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
    float i = fragCoord.x / iResolution.x;
    float j = fragCoord.y / iResolution.y;

    vec2 v1 = vec2(200.0*abs(0.5-i)*abs(0.5-j)+iGlobalTime, j);
    vec2 v2 = vec2(200.0*abs(0.5-i)*abs(0.5-j)+iGlobalTime, j);
    
    float b = noise(v1);
    float r = noise(v2);

    fragColor = vec4(r, (1.0+sin(iGlobalTime)/(2.0-j)) - (r+b), r, 1.0);
}