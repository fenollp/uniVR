// Shader downloaded from https://www.shadertoy.com/view/MtX3Dl
// written by shadertoy user netgrind
//
// Name: ngSound1
// Description: more shader synths
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    float i = iGlobalTime*.1;
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv*=4.0;
    uv-= 2.0;
    uv = abs(uv)-length(uv);
    
    float time = iGlobalTime+uv.y*.4+uv.x*.4;
    float f = sin(6.2831*240.0*time+sin(6.2831*time)*40.0);
    f *= pow(sin(time*80.0+cos(time*20.0)*50.0)*.5+.5,5.0);
    vec2 s =  vec2(sin(iGlobalTime*2.0),cos(iGlobalTime*2.0))*.1;
    
    uv+=i;
    uv = abs(uv);
    vec4 c1 = texture2D(iChannel0,uv);
    vec4 c2 = texture2D(iChannel1,uv);
    c1.r = s.x;
    c2.g = s.y;
    c2.b = f*.4+.5;
    c1 = normalize(abs(c1-c2));
    c1.b = f*.4+.5;
	fragColor = c1;
}