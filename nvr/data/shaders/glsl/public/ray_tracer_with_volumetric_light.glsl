// Shader downloaded from https://www.shadertoy.com/view/4dsGRn
// written by shadertoy user anji
//
// Name: Ray tracer with volumetric light
// Description: Your basic sphere/plane ray tracer with some volumetric shadowing thrown into the mix. Code can still be made a little more elegant I think. Nearly melted my Macbook making this.
// Ray tracing with improvised volumetric shadows
// Attempting to make it windows friendly by reducing loopiness.
// Thanks to iq for fixing the sphere intersection code, sqrt(-n) is bad :)
// Matthijs De Smedt
// @anji_nl

float time = iGlobalTime;
vec3 resolution = iResolution;

const float ZMAX = 99999.0;
const float EPSILON = 0.001;
const int MAX_BOUNCES = 3; // For looping version
const int VOLUMETRIC_SAMPLES = 10;

struct Intersection
{
	vec3 p;
	float dist;
	
	vec3 n;
	vec3 diffuse;
	vec3 specular;
};
	
struct Ray
{
	vec3 o;
	vec3 dir;
};
	
struct Light
{
	vec3 p;
	vec3 color;
	float radius;
};
	
struct Plane
{
	vec3 n;
	float d;
};
	
struct Sphere
{
	vec3 c;
	float r;
};
	
float saturate(float f)
{
	return clamp(f,0.0,1.0);
}

vec3 saturate(vec3 v)
{
	return clamp(v,vec3(0,0,0),vec3(1,1,1));
}

float rand(vec2 co)
{
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453 + time);
}

Intersection RaySphere(Ray ray, Sphere sphere)
{
	Intersection i;
	i.dist = ZMAX;
	vec3 c = sphere.c;
	float r = sphere.r;
	vec3 e = c-ray.o;
	float a = dot(e, ray.dir);
	float b = r*r - dot(e,e) + a*a;
	if( b>0.0 )
	{
		float f = sqrt(b);
		float t = a - f;
		if(t > EPSILON)
		{
			i.p = ray.o + ray.dir*t;
			i.n = normalize(i.p-c);
			i.dist = t;
		}
	}
	return i;
}

Intersection RayPlane(Ray ray, Plane p)
{
	Intersection i;
	float num = p.d-dot(p.n, ray.o);
	float denom = dot(p.n, ray.dir);
	float t = num/denom;
	if(t > EPSILON)
	{
		i.p = ray.o + ray.dir * t;
		i.n = p.n;
		i.dist = t;
	}
	else
	{
		i.dist = ZMAX;
	}
	return i;
}

Intersection MinIntersection(Intersection a, Intersection b)
{
	if(a.dist < b.dist)
	{
		return a;
	}
	else
	{
		return b;
	}
}

vec3 PlaneMaterial(Intersection i)
{
	float d = 0.0;
	d = mod(floor(i.p.x)+floor(i.p.z),2.0);
	return vec3(d,d,d)*0.8;
}

Intersection SceneIntersection(Ray r)
{
	Intersection iOut;
	
	Plane plane;
	plane.n = normalize(vec3(0,1,0));
	plane.d = -2.0;
	Intersection iPlane = RayPlane(r, plane);
	iPlane.diffuse = PlaneMaterial(iPlane);
	iPlane.specular = vec3(1,1,1)-iPlane.diffuse;
	iOut = iPlane;
	
	for(int s = 0; s <= 3; s++)
	{
		float fs = float(s);
		float t = time*0.3+fs*2.0;
		vec3 pos;
		pos.x = sin(t*2.0)*2.0+sin(t*2.0)*3.0;
		pos.y = abs(sin(t))*2.0;
		pos.z = 6.0+cos(t)*2.0+cos(t*1.5)*2.0;
		Sphere sphere;
		sphere.c = pos;
		sphere.r = 2.0;
		Intersection iSphere = RaySphere(r, sphere);
		iSphere.diffuse = vec3(0.0,0.0,0.2);
		iSphere.specular = vec3(0.2,0.2,0.6);
		iOut = MinIntersection(iOut, iSphere);
	}
	
	return iOut;
}

vec3 CalcIrradiance(Light light, vec3 p)
{
	float distA = 1.0-saturate(length(light.p-p)/light.radius);
	return distA * light.color;
}

vec3 CalcLighting(Light light, Intersection i, vec3 origin)
{
	vec3 n = i.n;
	vec3 p = i.p;
	vec3 l = normalize(light.p-p);
	vec3 v = normalize(origin-p);
	vec3 h = normalize(l+v);
	float NdotL = saturate(dot(n,l));
	float NdotH = saturate(dot(n,h));
	vec3 diffuse = NdotL*i.diffuse;
	vec3 spec = pow(NdotH,8.0) * i.specular;
	float distA = 1.0-saturate(length(light.p-p)/light.radius);
	vec3 color;
	color = (diffuse+spec) * distA * light.color;
	
	float shadow = 1.0;
	Ray shadowRay;
	shadowRay.o = i.p;
	float lightDist = length(light.p-i.p);
	shadowRay.dir = (light.p-i.p)/lightDist;
	Intersection shadowI = SceneIntersection(shadowRay);
	if(shadowI.dist < lightDist)
	{
		shadow = 0.0;
	}
	color *= shadow;
	
	return color;
}

vec3 GetLighting(Intersection i, vec3 origin)
{
	vec3 color = vec3(0,0,0);
	Light light;
	
	light.p = vec3(sin(time*0.3)*2.0,5,cos(time*0.3)*2.0+4.0);
	light.color = vec3(1,1,1);
	light.radius = 20.0;
	color += CalcLighting(light, i, origin);
	
	/*
	light.p = vec3(cos(time*0.2)*2.0,5,sin(time*0.2)*2.0+8.0);
	light.color = vec3(1,1,1);
	light.radius = 20.0;
	color += CalcLighting(light, i, origin);
*/
	
	return color;
}

vec3 GetVolumetricLighting(Ray ray, float maxDist, vec2 fragCoord)
{
	vec3 color = vec3(0,0,0);
	Light light;
	light.p = vec3(sin(time*0.3)*2.0,5,cos(time*0.3)*2.0+4.0);
	light.color = vec3(1,1,1);
	light.radius = 20.0;
	
	float inscattering = maxDist/200.0;
	float volRayStep = maxDist/float(VOLUMETRIC_SAMPLES-1);
	float randomStep = rand(fragCoord.xy)*volRayStep;
	Ray volRay;
	volRay.o = ray.o + ray.dir*randomStep;
	for(int v = 0; v < VOLUMETRIC_SAMPLES; v++)
	{
		vec3 lightVec = light.p-volRay.o;
		float lightDist = length(lightVec);
		volRay.dir = lightVec/lightDist;
		Intersection i = SceneIntersection(volRay);
		if(i.dist > lightDist)
		{
			color += CalcIrradiance(light, volRay.o)*inscattering;
		}
		volRay.o += ray.dir * volRayStep;
	}
	
	return color;
}

vec3 GetColor(Ray ray, vec2 fragCoord)
{
	vec3 color = vec3(0,0,0);
	vec3 volumetric = vec3(0,0,0);
	vec3 prevSpecular = vec3(1.0,1.0,1.0);
	/*
	// Loop version
	for(int r = 0; r <= MAX_BOUNCES; r++)
	{
		Intersection i;
		// Find intersection
		i = SceneIntersection(ray);
		if(r == 0)
		{
			volumetric = GetVolumetricLighting(ray, min(i.dist, 20.0));
		}
		if(i.dist >= ZMAX-EPSILON)
		{
			break;
		}
		// Blend color
		vec3 diffuse = GetLighting(i, ray.o);
		color += diffuse * prevSpecular;
		prevSpecular *= i.specular;
		// Calculate next ray
		vec3 incident = normalize(i.p-ray.o);
		ray.dir = reflect(incident,i.n);
		ray.o = i.p+ray.dir*EPSILON;
	}
	*/
	// Branch version
	Intersection i = SceneIntersection(ray);
	// Volumetrics
	volumetric = GetVolumetricLighting(ray, min(i.dist, 20.0), fragCoord);
	vec3 specular;
	vec3 incident;
	if(i.dist < ZMAX-EPSILON)
	{
		color += GetLighting(i, ray.o);
		specular = i.specular;
		incident = normalize(i.p-ray.o);
		ray.dir = reflect(incident,i.n);
		ray.o = i.p+ray.dir*EPSILON;
		// First bounce
		i = SceneIntersection(ray);
		if(i.dist < ZMAX-EPSILON)
		{
			color += GetLighting(i, ray.o) * specular;
			specular *= i.specular;
			incident = normalize(i.p-ray.o);
			ray.dir = reflect(incident,i.n);
			ray.o = i.p+ray.dir*EPSILON;
			// Second bounce
			i = SceneIntersection(ray);
			if(i.dist < ZMAX-EPSILON)
			{
				color += GetLighting(i, ray.o) * specular;
			}
		}
	}
	color -= volumetric*0.5; // Ho ho ho.
	color += volumetric;
	return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 pos = -1.0 + 2.0 * ( fragCoord.xy / resolution.xy );
	vec2 posAR;
	posAR.x = pos.x * (resolution.x/resolution.y);
	posAR.y = pos.y;
	vec3 rayDir = normalize(vec3(posAR.x, posAR.y, 1.0));
	Ray ray;
	ray.o = vec3(sin(time*0.2),0,0);
	ray.dir = rayDir;
	
	vec3 color = GetColor(ray, fragCoord);
	fragColor = vec4(color.x, color.y, color.z, 1.0 );
}