// Shader downloaded from https://www.shadertoy.com/view/lts3Ds
// written by shadertoy user paniq
//
// Name: Area of Square Segment
// Description: computes the area of a square snippet as cut by a line; Useful to compute how much area a new voronoi cell would steal from a square cell as part of a voronoi / natural neighbor weight computation.
vec3 hue2rgb(float hue) {
    return clamp( 
        abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 
        0.0, 1.0);
}

float compute_area(vec2 uv) {
    float a = 0.0;
    vec2 n = abs(normalize(uv));
    float d = length(uv);
    vec4 p = (vec4(n.xy,-n.xy)-d) / n.yxyx;
    vec4 h = max(vec4(0.0),sign(1.0-abs(p)));
    p = (p+1.0)*0.5;
    return 0.5*(h.y*(p.y*p.x*h.x + (p.y+p.w)*h.w) + (p.x+p.z)*h.x*h.z);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv -= 0.5;
    uv.x *= iResolution.x / iResolution.y;
    uv *= 2.2;
    vec2 m = iMouse.xy / iResolution.xy;
    m -= 0.5;
	m.x *= iResolution.x / iResolution.y;
    m *= 2.2;
    
    float q = max(0.0,-sign(max(abs(uv.x),abs(uv.y))-1.0));
    float b = max(0.0,-sign(abs(dot(vec3(normalize(m),-length(m)), vec3(uv,1.0)))-0.01));
    float a = compute_area(uv);
    
	fragColor = vec4(hue2rgb(a*8.0)*(0.5+q*0.5)+b,1.0);
    // uncomment to see derivatives
	// fragColor = vec4(hue2rgb(fwidth(a)*iResolution.x)*(0.5+q*0.5)+b,1.0);    
}