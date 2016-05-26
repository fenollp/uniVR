// Shader downloaded from https://www.shadertoy.com/view/lscGzn
// written by shadertoy user 445615105
//
// Name: Dog
// Description: use Distance Field to draw a dog. thx @candycat
float sdfCircle(vec2 center, float radius, vec2 coord) {
    vec2 offset = coord - center;

    return sqrt((offset.x * offset.x) + (offset.y * offset.y)) - radius;
}

float sdfEllipse(vec2 center, float a, float b, vec2 coord) {
    float a2 = a * a;
    float b2 = b * b;
    return (b2 * (coord.x - center.x) * (coord.x - center.x) + a2 * (coord.y - center.y) * (coord.y - center.y) - a2 * b2)/(a2 * b2);
}

float sdfLine(vec2 p0, vec2 p1, float width, vec2 coord) {
    vec2 dir0 = p1 - p0;
    vec2 dir1 = coord - p0;
    float h = clamp(dot(dir0, dir1)/dot(dir0, dir0), 0.0, 1.0);
    return (length(dir1 - dir0 * h) - width * 0.5);
}

vec4 render(float d, vec3 color, float stroke) {
    float anti = fwidth(d) * 1.0;
    vec4 colorLayer = vec4(color, 1.0 - smoothstep(-anti, anti, d));
    if (stroke < 0.000001) {
        return colorLayer;
    }

    vec4 strokeLayer = vec4(vec3(0.05, 0.05, 0.05), 1.0 - smoothstep(-anti, anti, d - stroke));
    return vec4(mix(strokeLayer.rgb, colorLayer.rgb, colorLayer.a), strokeLayer.a);
}

float sdfUnion( const float a, const float b ) {
    return min(a, b);
}

float sdfDifference( const float a, const float b) {
    return max(a, -b);
}

float sdfIntersection( const float a, const float b ) {
    return max(a, b);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iGlobalTime;
    float size = min(iResolution.x, iResolution.y);
    float pixSize = 1.0 / size;
	vec2 uv = fragCoord.xy / iResolution.xy;
    float stroke = pixSize * 0.5;
    vec2 center = vec2(0.5, 0.5 * iResolution.y/iResolution.x);
	float bottom = 0.08;
    float handleWidth = 0.02;
    float handleRadius = 0.1;
    float index = mod(ceil(time/1.0),5.0);
	float d = sdfCircle(vec2(0.8-handleRadius+0.3*handleWidth, 0.5), handleRadius, uv);
	if (index == 0.0)
	{
        float c = sdfCircle(vec2(0.8-handleRadius+0.3*handleWidth, 0.5), handleRadius-handleWidth, uv);
        d = sdfDifference(d,c);
        c = uv.y - 0.5;
        d = sdfIntersection(d,c);
        c = sdfCircle(vec2(0.3-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
		d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.3-handleRadius+0.3*handleWidth, 0.7), handleRadius-handleWidth, uv);
        d = sdfDifference(d, c);
        c = sdfLine(vec2(0.3, 0.6), vec2(0.3, 0.9), handleWidth, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.55-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.55-handleRadius+0.3*handleWidth, 0.7), handleRadius-handleWidth, uv);
        d = sdfDifference(d,c);
        c = sdfCircle(vec2(0.8-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.8-handleRadius+0.3*handleWidth, 0.7), handleRadius-handleWidth, uv);
        d = sdfDifference(d,c);
        c = sdfLine(vec2(0.796, 0.5), vec2(0.796, 0.7), handleWidth, uv);
        d = sdfUnion(d,c);
	}
	else if (index == 1.0)
	{
        float c = sdfCircle(vec2(0.8-handleRadius+0.3*handleWidth, 0.5), handleRadius-handleWidth, uv);
        d = sdfDifference(d,c);
        c = uv.y - 0.5;
        d = sdfIntersection(d,c);
        c = sdfCircle(vec2(0.3-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
		d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.3-handleRadius+0.3*handleWidth, 0.7), handleRadius-handleWidth, uv);
        d = sdfDifference(d, c);
        c = sdfLine(vec2(0.3, 0.6), vec2(0.3, 0.9), handleWidth, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.55-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.55-handleRadius+0.3*handleWidth, 0.7), handleRadius-handleWidth, uv);
        d = sdfDifference(d,c);
        c = sdfCircle(vec2(0.8-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.85-handleRadius+0.3*handleWidth, 0.75), handleRadius/2.2, uv);
        d = sdfDifference(d,c);
        c = sdfLine(vec2(0.796, 0.5), vec2(0.796, 0.7), handleWidth, uv);
        d = sdfUnion(d,c);
        c = sdfLine(vec2(0.2, 0.8), vec2(0.7, 0.8), handleWidth, uv);
        d = sdfUnion(d,c);
	}
	else if (index == 2.0)
	{
        float c = sdfCircle(vec2(0.8-handleRadius+0.3*handleWidth, 0.5), handleRadius-handleWidth, uv);
        d = sdfDifference(d,c);
        c = uv.y - 0.5;
        d = sdfIntersection(d,c);
        float e = sdfCircle(vec2(0.66-handleRadius+0.3*handleWidth, 0.8), handleRadius, uv);
        float f = sdfCircle(vec2(0.66-handleRadius+0.3*handleWidth, 0.8), handleRadius-handleWidth, uv);
        e = sdfDifference(e, f);
        f = 0.8 - uv.y;
        e = sdfIntersection(e,f);
        d = sdfUnion(d,e);
        c = sdfCircle(vec2(0.3-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
		d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.3-handleRadius+0.3*handleWidth, 0.7), handleRadius-handleWidth, uv);
        d = sdfDifference(d, c);
        c = sdfLine(vec2(0.3, 0.6), vec2(0.3, 0.9), handleWidth, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.55-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.55-handleRadius+0.3*handleWidth, 0.7), handleRadius-handleWidth, uv);
        d = sdfDifference(d,c);
        c = sdfCircle(vec2(0.8-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.85-handleRadius+0.3*handleWidth, 0.75), handleRadius/2.2, uv);
        d = sdfDifference(d,c);
        c = sdfLine(vec2(0.796, 0.5), vec2(0.796, 0.7), handleWidth, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.58-handleRadius+0.3*handleWidth, 0.72), handleRadius/4.0, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.66-handleRadius+0.3*handleWidth, 0.85), handleRadius/4.0, uv);
        d = sdfUnion(d,c);
        c = sdfLine(vec2(0.2, 0.8), vec2(0.7, 0.8), handleWidth, uv);
        d = sdfUnion(d,c);
	}
	else if (index == 3.0)
	{
        float c = sdfCircle(vec2(0.8-handleRadius+0.3*handleWidth, 0.5), handleRadius-handleWidth, uv);
        d = sdfDifference(d,c);
        c = uv.y - 0.5;
        d = sdfIntersection(d,c);
        float e = sdfCircle(vec2(0.66-handleRadius+0.3*handleWidth, 0.8), handleRadius, uv);
        float f = sdfCircle(vec2(0.66-handleRadius+0.3*handleWidth, 0.8), handleRadius-handleWidth, uv);
        e = sdfDifference(e, f);
        f = 0.8 - uv.y;
        e = sdfIntersection(e,f);
        d = sdfUnion(d,e);
        c = sdfCircle(vec2(0.3-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
		d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.3-handleRadius+0.3*handleWidth, 0.7), handleRadius-handleWidth, uv);
        d = sdfDifference(d, c);
        c = sdfLine(vec2(0.3, 0.6), vec2(0.3, 0.9), handleWidth, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.55-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.55-handleRadius+0.3*handleWidth, 0.7), handleRadius-handleWidth, uv);
        d = sdfDifference(d,c);
        c = sdfCircle(vec2(0.8-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.85-handleRadius+0.3*handleWidth, 0.75), handleRadius/2.2, uv);
        d = sdfDifference(d,c);
        c = sdfLine(vec2(0.796, 0.5), vec2(0.796, 0.7), handleWidth, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.58-handleRadius+0.3*handleWidth, 0.72), handleRadius/4.0, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.66-handleRadius+0.3*handleWidth, 0.85), handleRadius/4.0, uv);
        d = sdfUnion(d,c);
        c = sdfLine(vec2(0.2, 0.8), vec2(0.7, 0.8), handleWidth, uv);
        d = sdfUnion(d,c);
        float g = sdfCircle(vec2(0.4-handleRadius+0.3*handleWidth, 0.85), handleRadius, uv);
        float h = sdfCircle(vec2(0.4-handleRadius+0.3*handleWidth, 0.85), handleRadius-handleWidth, uv);
        g = sdfDifference(g, h);
        h = uv.x - 0.3;
        g = sdfIntersection(g,h);
        d = sdfUnion(d,g);
        float i = sdfCircle(vec2(0.64-handleRadius+0.3*handleWidth, 0.56), handleRadius, uv);
        float j = sdfCircle(vec2(0.64-handleRadius+0.3*handleWidth, 0.56), handleRadius-handleWidth, uv);
        i = sdfDifference(i, j);
        j = uv.y - 0.57;
        i = sdfIntersection(i,j);
        j = 0.55 - uv.x;
        i = sdfIntersection(i,j);
        d = sdfUnion(d,i);
	}
	else if (index == 4.0)
	{
        float c = sdfCircle(vec2(0.8-handleRadius+0.3*handleWidth, 0.5), handleRadius-handleWidth, uv);
        d = sdfDifference(d,c);
        c = uv.y - 0.5;
        d = sdfIntersection(d,c);
        float e = sdfCircle(vec2(0.66-handleRadius+0.3*handleWidth, 0.8), handleRadius, uv);
        float f = sdfCircle(vec2(0.66-handleRadius+0.3*handleWidth, 0.8), handleRadius-handleWidth, uv);
        e = sdfDifference(e, f);
        f = 0.8 - uv.y;
        e = sdfIntersection(e,f);
        d = sdfUnion(d,e);
        c = sdfCircle(vec2(0.3-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
		d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.3-handleRadius+0.3*handleWidth, 0.7), handleRadius-handleWidth, uv);
        d = sdfDifference(d, c);
        c = sdfLine(vec2(0.3, 0.6), vec2(0.3, 0.9), handleWidth, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.55-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.55-handleRadius+0.3*handleWidth, 0.7), handleRadius-handleWidth, uv);
        d = sdfDifference(d,c);
        c = sdfCircle(vec2(0.8-handleRadius+0.3*handleWidth, 0.7), handleRadius, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.85-handleRadius+0.3*handleWidth, 0.75), handleRadius/2.2, uv);
        d = sdfDifference(d,c);
        c = sdfLine(vec2(0.796, 0.5), vec2(0.796, 0.7), handleWidth, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.58-handleRadius+0.3*handleWidth, 0.72), handleRadius/4.0, uv);
        d = sdfUnion(d,c);
        c = sdfCircle(vec2(0.66-handleRadius+0.3*handleWidth, 0.85), handleRadius/4.0, uv);
        d = sdfUnion(d,c);
        c = sdfLine(vec2(0.2, 0.8), vec2(0.7, 0.8), handleWidth, uv);
        d = sdfUnion(d,c);
        float g = sdfCircle(vec2(0.4-handleRadius+0.3*handleWidth, 0.85), handleRadius, uv);
        float h = sdfCircle(vec2(0.4-handleRadius+0.3*handleWidth, 0.85), handleRadius-handleWidth, uv);
        g = sdfDifference(g, h);
        h = uv.x - 0.3;
        g = sdfIntersection(g,h);
        d = sdfUnion(d,g);
        float i = sdfCircle(vec2(0.64-handleRadius+0.3*handleWidth, 0.56), handleRadius, uv);
        float j = sdfCircle(vec2(0.64-handleRadius+0.3*handleWidth, 0.56), handleRadius-handleWidth, uv);
        i = sdfDifference(i, j);
        j = uv.y - 0.57;
        i = sdfIntersection(i,j);
        j = 0.55 - uv.x;
        i = sdfIntersection(i,j);
        d = sdfUnion(d,i);
        c = sdfLine(vec2(0.7, 0.4), vec2(0.6, 0.1), handleWidth, uv);
        d = sdfUnion(d,c);
        c = sdfLine(vec2(0.3, 0.6), vec2(0.1, 0.1), handleWidth, uv);
        d = sdfUnion(d,c);
	}   
    vec4 layer0 = render(d, vec3(0.404, 0.298, 0.278), stroke);
	fragColor = layer0;
	fragColor.rgb = pow(fragColor.rgb, vec3(1.6));
}