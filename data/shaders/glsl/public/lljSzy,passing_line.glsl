// Shader downloaded from https://www.shadertoy.com/view/lljSzy
// written by shadertoy user xaphere
//
// Name: Passing line
// Description: playing with shaders
//    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv = 2.*uv-1.;
    float y = uv.y;
    
    float x = mod(iGlobalTime,2.)-1.;
    
    float r=.2;
    
    float f = 1.-22.*abs(y-uv.y);
    float rf = 1.-10.*length(uv-vec2(x,y))-r;
    
    vec3 col = vec3(f);
    col.r += rf;
    fragColor = vec4(col,1.0);
}