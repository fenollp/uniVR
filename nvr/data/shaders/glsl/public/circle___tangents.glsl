// Shader downloaded from https://www.shadertoy.com/view/MsBXWh
// written by shadertoy user Doublefresh
//
// Name: Circle - tangents
// Description: More circles! This time: how to find tangent lines to circles. You can move the blue circle around.
#define LINETHICKNESS 	0.010
#define LINECOLOUR 		vec3(0.3, 0.7, 0.1)
#define RADIUS1			0.12
#define RADIUS2			0.15

float Plane(vec2 pix, vec3 plane)
{
    // Absolute distance to the plane(line in R^2)
    float D = abs(dot(plane, vec3(pix, 1.0))); 
    return 1.2 * smoothstep(LINETHICKNESS, 0.0, D);
}

float Circle(vec2 pix, vec3 C)
{
    float r = length(C.xy - pix);
    float d = abs(r - C.z);  
    return smoothstep(0.015, 0.0, d) + 0.5*smoothstep(0.06, 0.00, r - C.z);
}

// Outer tangent lines for two circles 
float CircleOuterTangents(vec2 pix, vec3 C1, vec3 C2)
{
    vec3 dx = (C1 - C2) / distance(C1.xy, C2.xy);   
    float ro = sqrt(1.0 - dx.z*dx.z);
    
    float X = dx.z*dx.x;
    float Y = dx.z*dx.y;
    float Z = dx.y*ro;
    float W = dx.x*ro;
    
    float a = X - Z;
    float b = Y + W;
    float c = C1.z - (a*C1.x + b*C1.y);
 
    float d = X + Z;
    float e = Y - W;
    float f = C1.z - (d*C1.x + e*C1.y);
    
    return Plane(pix, vec3(a,b,c)) + Plane(pix, vec3(d,e,f));
}

// Compute tangent lines for two circles 
float CirclesTangents(vec2 pix, vec3 C1, vec3 C2)
{          
    float outer = CircleOuterTangents(pix, C1, C2);
    // The inner tangent lines are given by negating one of the circles' radii
    C1.z *= -1.0;
    float inner = CircleOuterTangents(pix, C1, C2);
    
    float signal = smoothstep(-0.15, 0.15, sin(iGlobalTime));    
    return mix(inner, outer, signal);
}

vec3 Background(vec2 p)
{
 	return length(p) * vec3(0.16, 0.15, 0.17) * (0.3 + abs(p.y)); 
}

vec2 Mouse()
{
    vec2 r = (2.0 * iMouse.xy / iResolution.xy) - 1.0;
    r.x *= iResolution.x / iResolution.y;
    return r;
}

vec3 Scene(vec2 pix)
{
 	vec3 col = Background(pix);
  	float t = iGlobalTime;
    
    vec3 circle1 = vec3(Mouse(), RADIUS1);
    vec3 circle2 = vec3(0.4*sin(t), 0.4*cos(t), RADIUS2);  	
    vec3 circle3 = vec3(0.7*cos(t), 0.7*sin(0.3*t), 0.15);
    
    col += vec3(0.1, 0.2, 0.7) * Circle(pix, circle1);
    col += vec3(0.7, 0.0, 0.3) * Circle(pix, circle2);
    col += vec3(0.6, 0.6, 0.63) * Circle(pix, circle3);
    col += LINECOLOUR * CirclesTangents(pix, circle1, circle2);
    col += (LINECOLOUR + vec3(0.5, -0.1, 0.5)) * CirclesTangents(pix, circle2, circle3);
    col += (LINECOLOUR + vec3(0.2, -0.0, 0.7)) * CirclesTangents(pix, circle1, circle3);
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = 2.0 * (fragCoord.xy / iResolution.xy) - 1.0;
    p.x *= iResolution.x / iResolution.y;
    
    vec3 s = Scene(p);
	fragColor = vec4(s * (1.0 - 0.5 * length(p)), 1.0);
}