// Shader downloaded from https://www.shadertoy.com/view/XlSGRR
// written by shadertoy user paniq
//
// Name: Natural Neighbor Interpolation
// Description: Interpolating texels using 3x3 natural neighbor interpolation, a technique for interpolating voronoi cells that also works for regular grids.
float m;

float compute_area(vec2 uv) {
    vec2 n = abs(normalize(uv));
    vec4 p = (vec4(n.xy,-n.xy)-length(uv)*0.5) / n.yxyx;
    vec4 h = max(vec4(0.0),sign(1.0-abs(p)));
    // fix p becoming NaN; unfortunately 0*(1/0) doesn't
    // fix the value
    p.x = (h.x < 0.5)?0.0:p.x;
    p.y = (h.y < 0.5)?0.0:p.y;
    p.z = (h.z < 0.5)?0.0:p.z;
    p.w = (h.w < 0.5)?0.0:p.w;
    p = (p+1.0)*0.5;
    return 0.5*(h.y*(p.y*p.x*h.x + (p.y+p.w)*h.w) + (p.x+p.z)*h.x*h.z);
}

const vec2 texsize = vec2(64.0);
vec3 fetch(ivec2 uv) {
    return texture2D(iChannel0, (vec2(uv) + 0.5) / texsize).rgb;
}

vec3 sample(vec2 uv) {
    vec2 suv = uv + iGlobalTime;
    vec2 n = floor(suv);
    vec2 f = fract(suv)*2.0-1.0;
    
    ivec2 iuv = ivec2(n);
    vec3 total = vec3(0.0);
    float w = 0.0;
    for (int i = -1; i <= 1; ++i) {
        for (int j = -1; j <= 1; ++j) {
            float a;    
            a = compute_area(f-vec2(float(i),float(j))*2.0);
            total += fetch(iuv + ivec2(i,j)) * a;
            w += a;
        }
    }
    
    return ((uv.x+uv.y-m*8.0) < 0.0)?fetch(iuv):(total/w);
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv -= 0.5;
    uv.x *= iResolution.x / iResolution.y;
    uv *= 8.0;
    m =( iMouse.x / iResolution.x)*2.0-1.0;
    
	fragColor = vec4(sample(uv),1.0);
}