// Shader downloaded from https://www.shadertoy.com/view/4lSGzh
// written by shadertoy user GayCat
//
// Name: basic point and line
// Description: study
vec4 circle(vec2 pos, vec2 center, float radius, vec3 color, float antialias){   
    // d为圆形内外所有的点   
    float d = length(pos - center) - radius;   
    // 公式smoothstep：将d限制在0到antialias之间，再通过公式计算插值   
    // 返回为0的表示是圆   
    // 返回为[0-1]的表示是平滑区域   
    // 返回为1表示是非圆区域   
    float t = smoothstep (0.0,antialias,d);   
    // 返回为1表示为圆   
    return vec4(color, 1.0 - t);   
} 
// 直线方程为：kx - y + b = 0   
vec4 line(vec2 pos, vec2 point1, vec2 point2, float width, vec3 color, float antialias) {     
    // 计算斜率k   
    float k = (point1.y - point2.y)/(point1.x - point2.x);     
    // 求b   
    float b = point1.y - k * point1.x;     
    // 点到直线的距离：d=|A·a+B·b+C|/√(A²+B²)   
    // d = |kx-y+b|/√(k²+1²)   
    float d = abs(k * pos.x - pos.y + b) / sqrt(k * k + 1.0);     
    // 公式smoothstep：将d限制在0到antialias之间，再通过公式计算插值   
    // 返回为0表示是在线上   
    // 返回为[0-1]表示是平滑区域   
    // 返回为1表示不在线上   
    float t = smoothstep(width/2.0, width/2.0 + antialias, d);     
    return vec4(color, 1.0 - t);     
} 

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv.y += 0.25 * sin(uv.x + 2.0 * iGlobalTime);   
    vec4 bg = vec4(0,1,1,1);
    vec4 cc = circle(uv, vec2(0.5,0.5),0.2,vec3(1,1,0),0.01);
    vec4 lin = line(uv, vec2(0.1,0.5), vec2(0.9, 0.5), 0.02,vec3(0,0,1),0.01);
	fragColor = mix(bg,cc,cc.a);
    fragColor = mix(fragColor,lin,lin.a);
}