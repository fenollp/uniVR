// Shader downloaded from https://www.shadertoy.com/view/MlSGzR
// written by shadertoy user paniq
//
// Name: Bokeh Interpolation
// Description: Interpolating four points as overlapping circles with a radius of 1. The falloff is squared to remove the circular discontinuity. Bottom half shows derivative of linear / bokeh function.
float m;

const vec2 texsize = vec2(64.0);
vec3 fetch(ivec2 uv) {
    return texture2D(iChannel0, (vec2(uv) + 0.5) / texsize).rgb;
}

vec4 bokeh_interpolants(vec2 f) {
    vec2 sp = f*f;
    vec2 sq = 1.0-f;
    sq = sq*sq;
    vec4 sd = vec4(sp.x+sp.y, sq.x+sp.y, sp.x+sq.y, sq.x+sq.y);
    vec4 a = max(vec4(0.0),1.0-sqrt(sd));
    a *= a;
    float w = a.x+a.y+a.z+a.w;
    return a/w;
}

vec3 sample(vec2 uv) {
    vec2 suv = uv + iGlobalTime;
    ivec2 ruv = ivec2(floor(suv));
    
    vec2 tuv = suv-0.5;
    vec2 n = floor(tuv);
    vec2 f = fract(tuv);
    
    ivec2 iuv = ivec2(n);
    vec3 total = vec3(0.0);

    vec4 a = bokeh_interpolants(f);    
    total += fetch(iuv + ivec2(0,0)) * a.x;
    total += fetch(iuv + ivec2(1,0)) * a.y;
    total += fetch(iuv + ivec2(0,1)) * a.z;
    total += fetch(iuv + ivec2(1,1)) * a.w;
    
    //return ((uv.x+uv.y-m*8.0) < 0.0)?fetch(ruv):(total/w);
    return ((uv.x+uv.y-m*8.0) < 0.0) ? texture2D(iChannel0,suv/texsize).rgb : total;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv -= 0.5;
    uv.x *= iResolution.x / iResolution.y;
    uv *= 8.0;
    m =( iMouse.x / iResolution.x)*2.0-1.0;
    
    fragColor = (uv.y > -1.0)?vec4(sample(uv),1.0):vec4(0.1*fwidth(sample(uv))*iResolution.x,1.0);
}