// Shader downloaded from https://www.shadertoy.com/view/MtlSzM
// written by shadertoy user EyeOfPython
//
// Name: Nyan Rights Shader
// Description: For the recent events in gay rights.
vec4 getRainbowAt(float f)
{
    f *= 1.2;
    return vec4( ( (1.0-step(0.6,f)) + 0.29*step(1.0,f) ), 
               ( step(0.2,f)/pow(3.14159,(3.0-3.0*step(0.4,f)+4.84409*step(0.6,f))/8.0) - 0.5*step(0.8,f) ),
               ( step(0.8,f)-0.49*step(1.0,f)),
                step(0.0, f)*(1.0-step(1.0,f))
             );
}

vec4 getNyanAt(vec2 p, vec2 nyan_p, float nyan_s)
{
    float nyan_t = floor(mod(iGlobalTime*2.0,1.0)*6.0)/6.4;
    return texture2D(iChannel0, clamp(p+nyan_p, vec2(0,0), vec2(nyan_s-0.01,1))
                    * vec2((1.0/nyan_s)/6.0, -1.0/nyan_s) + vec2(0,1) + vec2(nyan_t,0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 nyanPos = vec2(0.1*sin(iGlobalTime*1.4)-0.1,0.1*sin(iGlobalTime*.6)-0.05);
    fragColor = getRainbowAt(uv.y)*getNyanAt(uv, nyanPos, 0.6);
}