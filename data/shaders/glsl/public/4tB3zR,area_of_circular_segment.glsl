// Shader downloaded from https://www.shadertoy.com/view/4tB3zR
// written by shadertoy user paniq
//
// Name: Area of Circular Segment
// Description: computing the area of a circular segment on the unit circle; drag the mouse to see the cut plane; color at that position designates area.
float radius = 1.0;

vec3 hue2rgb(float hue) {
    return clamp( 
        abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 
        0.0, 1.0);
}

float compute_area(vec2 uv, float r) {
    float d = min(r,length(uv));
    float h = r - d;
    float phi = 2.0*acos(d/r);
    return r*r*(phi - sin(phi)) / 2.0;
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
    
    float q = max(0.0,-sign(length(uv)-radius));
    float b = max(0.0,-sign(abs(dot(vec3(normalize(m),-length(m)), vec3(uv,1.0)))-0.01));
    float a = compute_area(uv, radius);
    
	fragColor = vec4(hue2rgb(a / 3.141592)*(0.5+q*0.5)+b,1.0);
}