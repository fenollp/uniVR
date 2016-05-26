// Shader downloaded from https://www.shadertoy.com/view/XdjXD1
// written by shadertoy user Doublefresh
//
// Name: Quadratic bezier curves
// Description: Drawing some 2d quadratic bezier curves, the SLOW way. Rotating the control points gives some cool fx. Click to move one of the points.
const float Pi = 3.1415926535;

float Point(vec2 uv, vec2 P)
{
    return smoothstep(0.035, 0.005, distance(uv, P));   
}

float cbrt(float x)
{
    return sign(x) * pow(abs(x), 1.0/3.0);
}

// http://tog.acm.org/resources/GraphicsGems/gems/Roots3And4.c
// Solve cubic ax^3 + bx^2 + cx + d = 0 
// Returns amount of roots
int SolveCubic(vec4 coeffs, out vec3 roots)
{
    int nS = 0;  
    // normal form: x^3 + Ax^2 + Bx + C = 0 
    vec4 N = coeffs / coeffs[0];

    // substitute x = y - A/3 
    // depressed cubic: x^3 + px + q = 0 
    float sqA = N[1]*N[1];
    float p = (N[2] - sqA/3.0) / 3.0;
    float q = ( (N[1] * sqA)/13.5 - (N[1] * N[2])/3.0 + N[3]) * 0.5;

    // Use Cardano's formula 
    float cbP = p * p * p;
    float D = q * q + cbP;

    if (abs(D) < 1e-20)
    {
		if (q == 0.0)  
            nS = 1;
		   
		else // one single and one double solution
		{
		    float u = cbrt(-q);
		    roots[0] = 2.0 * u;
		    roots[1] = -u;
		    nS = 2;
		}
    }
    
    else if (D < 0.0) // Casus irreducibilis: three real solutions
    {
		float phi = acos(-q / sqrt(-cbP)) / 3.0;
		float t = 2.0 * sqrt(-p);	
		roots[0] = t * cos(phi);
		roots[1] = -t * cos(phi + Pi/3.0);
		roots[2] = -t * cos(phi - Pi/3.0);
		nS = 3;
    }
    
    else // one real solution 
    {
		float sqrtD = sqrt(D);
		roots[0] = cbrt(sqrtD - q) - cbrt(sqrtD + q);
		nS = 1;
    }

    roots -= N[1] / 3.0;
    
    return nS;
}

vec2 QuadraticBezier(float t, vec2 p0, vec2 p1, vec2 p2)
{
	return mix((mix(p0, p1, t)),(mix(p1, p2, t)), t);
}

// x is a point
// {a, b, c} are the control points
float DistanceQuadraticBezier(vec2 x, vec2 a, vec2 b, vec2 c)
{
    float aa = dot(a,a);	float bc = dot(b,c);	float cc = dot(c,c);
    float ab = dot(a,b);	float bb = dot(b,b);   	float cx = dot(c,x);
    float ac = dot(a,c);	float bx = dot(b,x);
    float ax = dot(a,x);
           
    // Cubic coefficients
    float cu = 4.0*(aa + cc) + 16.0*(bb - ab - bc) + 8.0*ac;
    // Quadratic coefficients
	float qu = 12.0*(bc - ac - aa) - 24.0*bb + 36.0*ab;
    // Linear coefficients
    float li = 4.0*(ac - ax - cx) + 8.0*(bx + bb) + 12.0*aa - 24.0*ab;
    // Constant terms
    float C = 4.0*(ab + ax - aa - bx);
    vec3 roots;
    vec4 coeffs = vec4(cu, qu, li, C);
    
    int nS = SolveCubic(coeffs, roots);  
    float t;

   	float Dist1 = distance(x, QuadraticBezier(clamp(roots.x, 0.0, 1.0), a, b, c));
    float Dist2 = distance(x, QuadraticBezier(clamp(roots.y, 0.0, 1.0), a, b, c));
    float Dist3 = distance(x, QuadraticBezier(clamp(roots.z, 0.0, 1.0), a, b, c));
    
    return min(Dist3, min(Dist1, Dist2));
}                 

vec2 Mouse()
{
    vec2 a = 2.0 *(iMouse.xy / iResolution.xy) - 1.0;
    a.x *= iResolution.x / iResolution.y;
    return a;
    
}

vec3 Curves(vec2 uv)
{
    float t = iGlobalTime * 7.0;
    
    vec2 p1 = vec2(Mouse());
    vec2 p2 = 0.7*vec2(sin(t), cos(t));    
    vec2 p3 = vec2(sin(t*0.04), 0.6);
    vec2 p4 = -p2;
    vec2 p5 = vec2(-p2.y, p2.x);
    vec2 p6 = vec2(p2.y, -p2.x);
    
    float d1 = smoothstep(0.07, 0.00, DistanceQuadraticBezier(uv, p1, p2, p3));
    float d2 = smoothstep(0.03, 0.00, DistanceQuadraticBezier(uv, p1, p4, p3));
    float d3 = smoothstep(0.05, 0.00, DistanceQuadraticBezier(uv, p1, p5, p3));
    float d4 = smoothstep(0.05, 0.00, DistanceQuadraticBezier(uv, p1, p6, p3));
       
    float sP = Point(uv, p1) + Point(uv, p2) + Point(uv, p3) + 
        Point(uv, p4) + Point(uv, p5) + Point(uv, p6); 
    sP = 0.0;
    vec3 L1 = d1 * vec3(0.4, 0.6, 0.2);
    vec3 L2 = d2 * vec3(0.2, 0.4, 0.3);
    vec3 L3 = d3 * vec3(0.1, 0.3, 0.4);
	vec3 L4 = d4 * vec3(0.1, 0.7, 0.2);
    
    return sP + L1 + L2 + L3 + L4;
}   

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy;
    vec2 q = 2.0*p - 1.0;
    q.x *= iResolution.x / iResolution.y;   
    
    vec3 col = vec3(0.2, 0.2, 0.3);
    col = max(col, Curves(q));
       
    col = sqrt(col);
    col = col * 1.5 * (1.0 - 0.2*dot(q,q));
    
    fragColor = vec4(col, 1.0);
}