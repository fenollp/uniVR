// Shader downloaded from https://www.shadertoy.com/view/llXXR8
// written by shadertoy user foxhuntd
//
// Name: Mist Ring
// Description: I really don't know how it works....
float hash( float n )
{
    return fract(sin(n)*43758.5453);
}
//mat2 m = mat2( 1.,  0., 0.,  1. );
mat2 m = mat2( 0.8,  0.6, -0.6,  0.8 );
float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0;

    float res = mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                    mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
    return res;
}
float fbm(vec2 p){
    float f = 0.;
    f +=0.50000*abs(noise(p)-1.)*2.;p*=m*2.02;
    f +=0.25000*abs(noise(p)-1.)*2.;p*=m*2.03;
    f +=0.12500*abs(noise(p)-1.)*2.;p*=m*2.01;
    f +=0.06250*abs(noise(p)-1.)*2.;p*=m*2.04;
    f +=0.03125*abs(noise(p)-1.)*2.;
    return f/0.96875;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = 2.*q-1.0;
    float r = length(p);
    p.x *= iResolution.x/iResolution.y;
    float f = fbm(p+iGlobalTime);
    f *= r*3.-0.5;
    f = (1.-f);
    vec3 col = vec3(0.2,0.3,0.5)/f;
	fragColor = vec4(sqrt(abs(col))*0.5,1.0);
}