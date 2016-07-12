// Shader downloaded from https://www.shadertoy.com/view/XsSSWW
// written by shadertoy user Zavie
//
// Name: Minimal ray tracer
// Description: Only handles specular bounces (no GI) with perfect smoothness.&lt;br/&gt;Bonus question: why are colors different in ANGLE and native?
#define MAX_BOUNCES 8
float gamma = 2.2;

// ---8<----------------------------------------------------------------------
// Geometry

#define PI 3.14159275358979

struct Ray
{
    vec3 o;		// Origin
    vec3 d;		// Direction
};

struct Hit
{
    float t;	// ray solution
    vec3 n;		// normal
    int m;		// material
};
const Hit noHit = Hit(1e10, vec3(0.), -1);

struct Plane
{
    float d;	// offset
    vec3 n;		// normal
    int m;		// material
};

struct Sphere
{
	float r;	// radius
    vec3 p;		// center position
    int m;		// material
};

struct AABox
{
    vec3 s;		// size
    vec3 p;		// center position
    int m;		// metrial
};

Hit intersectPlane(Plane p, Ray r)
{
    float dotnd = -dot(p.n, r.d);
    if (dotnd < 0.) return noHit;

 	float t = (dot(p.n, r.o) + p.d) / dotnd;
 	return Hit(t, p.n, p.m);
}

bool isInside(vec2 a, vec2 b)
{
    return a.x < b.x && a.y < b.y;
}

void AAboxPlaneIntersection(vec3 o, vec3 d, vec3 s, inout float t, out float ndir)
{
    ndir = 0.;
    if (d.x != 0.)
    {
        float tmin = (-0.5 * s.x - o.x) / d.x;
        if (tmin >= 0. && tmin < t && isInside(abs(o.yz + tmin * d.yz), 0.5 * s.yz))
        {
            t = tmin;
            ndir = -1.;
        }

        float tmax = (0.5 * s.x - o.x) / d.x;
        if (tmax >= 0. && tmax < t && isInside(abs(o.yz + tmax * d.yz), 0.5 * s.yz))
        {
            t = tmax;
            ndir = 1.;
        }
    }
}
    
Hit intersectBox(AABox b, Ray r)
{
    Hit hit = noHit;
    vec3 ro = r.o - b.p;

    float ndir = 0.;
    AAboxPlaneIntersection(ro.xyz, r.d.xyz, b.s.xyz, hit.t, ndir);
    if (ndir != 0.) { hit.n = vec3(ndir, 0., 0.); hit.m = b.m; }

    AAboxPlaneIntersection(ro.yzx, r.d.yzx, b.s.yzx, hit.t, ndir);
    if (ndir != 0.) { hit.n = vec3(0., ndir, 0.); hit.m = b.m; }

    AAboxPlaneIntersection(ro.zxy, r.d.zxy, b.s.zxy, hit.t, ndir);
    if (ndir != 0.) { hit.n = vec3(0., 0., ndir); hit.m = b.m; }

    return hit;
}

Hit intersectSphere(Sphere s, Ray r)
{
	vec3 op = s.p - r.o;
    float b = dot(op, r.d);
    float det = b * b - dot(op, op) + s.r * s.r;
    if (det < 0.) return noHit;
    
    det = sqrt(det);
    float t = b - det;
    if (t < 0.) t = b + det;
    if (t < 0.) return noHit;
    
    return Hit(t, (r.o + t*r.d - s.p) / s.r, s.m);
}

Hit intersectScene(Ray r)
{
    Sphere s1 = Sphere(1., vec3(-2., 1., 0.), 0);
    Sphere s2 = Sphere(0.8, vec3(0.5, 0.8, -1.2), 3);
    Sphere s3 = Sphere(0.8, vec3(2.0, 0.8, -0.8), 4);
    Plane p = Plane(0., vec3(0., 1., 0.), 1);
    AABox b = AABox(vec3(0.8, 0.1, 0.75), vec3(1.2, 0.1, 1.7), 2);

    Hit hit = Hit(1e5, vec3(0.), -1);
    Hit hitp = intersectPlane(p, r); if (hitp.m != -1 && hitp.t < hit.t) { hit = hitp; }
    Hit hits1 = intersectSphere(s1, r); if (hits1.m != -1 && hits1.t < hit.t) { hit = hits1; }
    Hit hits2 = intersectSphere(s2, r); if (hits2.m != -1 && hits2.t < hit.t) { hit = hits2; }
    Hit hits3 = intersectSphere(s3, r); if (hits3.m != -1 && hits3.t < hit.t) { hit = hits3; }
	Hit hitb = intersectBox(b, r); if (hitb.t != 0. && hitb.t < hit.t) { hit = hitb; }
    return hit;
}

// ---8<----------------------------------------------------------------------
// Physics

struct Material
{
    vec3 c;		// diffuse color
    vec3 f0;	// specular color
};

#define NUM_MATERIALS 5
Material materials[NUM_MATERIALS];

Material getMaterial(Hit hit)
{
    // FIXME: what would be the correct way to do this?
    Material m = Material(vec3(0.), vec3(0.));
    for (int i = 0; i < NUM_MATERIALS; ++i)
    {
        if (i == hit.m) m = materials[i];
    }
    return m;
}

vec3 sunCol = vec3(1e3);
vec3 sunDir = normalize(vec3(.8, .55, -1.));
vec3 skyColor(vec3 d)
{
    float transition = pow(smoothstep(0.02, .5, d.y), 0.4);

    vec3 sky = 2e2*mix(vec3(0.52, 0.77, 1), vec3(0.12, 0.43, 1), transition);
    vec3 sun = vec3(1e7) * pow(abs(dot(d, sunDir)), 5000.);
    return sky + sun;
}

float pow5(float x) { return x * x * x * x * x; }

// Schlick approximation
vec3 fresnel(vec3 h, vec3 v, vec3 f0)
{
  return pow5(1. - clamp(dot(h, v), 0., 1.)) * (1. - f0) + f0;
}

vec3 radiance(Ray r)
{
    float epsilon = 4e-4;

    vec3 accum = vec3(0.);
    vec3 filter = vec3(1.);

    for (int i = 0; i <= MAX_BOUNCES; ++i)
    {
        Hit hit = intersectScene(r);

        if (hit.m >= 0)
        {
            Material m = getMaterial(hit);
            vec3 f = fresnel(hit.n, -r.d, m.f0);

            // Diffuse
            if (intersectScene(Ray(r.o + hit.t * r.d + epsilon * sunDir, sunDir)).m == -1)
            {
                accum += (1. - f) * filter * m.c * clamp(dot(hit.n, sunDir), 0., 1.) * sunCol;
            }
            
            // Specular: next bounce
            filter *= f;
            vec3 d = reflect(r.d, hit.n);
            r = Ray(r.o + hit.t * r.d + epsilon * d, d);
        }
        else
        {
            accum += filter * skyColor(r.d);
            break;
        }
    }
    return accum;
}

// ---8<----------------------------------------------------------------------
// Tone mapping

// See: http://filmicgames.com/archives/75
vec3 Uncharted2ToneMapping(vec3 color)
{
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = 11.2;
	float exposure = 0.012;
	color *= exposure;
	color = ((color * (A * color + C * B) + D * E) / (color * (A * color + B) + D * F)) - E / F;
	float white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;
	color /= white;
	color = pow(color, vec3(1. / gamma));
	return color;
}

// ---8<----------------------------------------------------------------------
// Scene

void init()
{
    materials[0] = Material(vec3(1.0, 0.0, 0.2), vec3(0.02));
    materials[1] = Material(vec3(0.5, 0.4, 0.3), vec3(0.02));
    // Copper
    materials[2] = Material(vec3(0.1), vec3(0.95, 0.64, 0.54));

    // Chrome
    materials[3] = Material(vec3(0.0), vec3(0.55, 0.56, 0.55));

    // Gold
    materials[4] = Material(vec3(0.0), vec3(1., 0.77, 0.34));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
    
    init();
    
    float o1 = 0.25;
    float o2 = 0.75;
    vec2 msaa[4];
    msaa[0] = vec2( o1,  o2);
    msaa[1] = vec2( o2, -o1);
    msaa[2] = vec2(-o1, -o2);
    msaa[3] = vec2(-o2,  o1);

    vec3 color = vec3(0.);
    for (int i = 0; i < 4; ++i)
    {
        vec3 p0 = vec3(0., 1.1, 4.);
        vec3 p = vec3((2. * (iMouse.xy==vec2(0.)?.5*iResolution.xy:iMouse.xy) / iResolution.xy - 1.) * vec2(1., 1.), 0.) + p0;
        vec3 offset = vec3(msaa[i] / iResolution.y, 0.);
        vec3 d = normalize(vec3(iResolution.x/iResolution.y * uv.x, uv.y, -1.5) + offset);
        Ray r = Ray(p, d);
        color += radiance(r) / 4.;
    }

	fragColor = vec4(Uncharted2ToneMapping(color),1.0);
}
