// Shader downloaded from https://www.shadertoy.com/view/llf3Wl
// written by shadertoy user heyx3
//
// Name: heyx3 Distance-estimated fractal
// Description: Playing around with distance-estimated 3D fractals
//------Distance field--------

//Returns the following values:
//X: distance to the fractal.
//Y: number of iterations needed, from 0 to 1.
//Z: The 'r' value.
//W: The 'dr' value.
vec4 getDistanceToFractal(vec3 pos, float timeScale, float bailoutScale)
{
    const int Iterations = 6;
    float Bailout = 2.0 * bailoutScale;
    float powLerp = 0.5 + (0.5 * sin((iGlobalTime * timeScale) + 4.9));
    float Power = mix(1.0, 8.0, pow(powLerp, 1.0));
    
    vec3 z = pos;
	float dr = 1.0;
	float r = 0.0;
    float nIterations = 0.0;
	for (int i = 0; i < Iterations ; i++) {
		r = length(z);
        nIterations += 1.0;
        
		if (r>Bailout)
        {
            break;
        }
		
		// convert to polar coordinates
		float theta = acos(z.z/r);
		float phi = atan(z.y,z.x);
		dr =  pow( r, Power-1.0)*Power*dr + 1.0;
		
		// scale and rotate the point
		float zr = pow( r,Power);
		theta *= Power;
		phi *= Power;
		phi = (phi);
        
		// convert back to cartesian coordinates
		z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
		z+=pos;
	}
	return vec4(0.5*log(r)*r/dr,
                nIterations / float(Iterations),
                r,
                dr);
}

mat3 rotPos2 = mat3(-0.7071067812, -0.7071067812, 0.0,
                   	0.70710678120, -0.7071067812, 0.0,
                    0.0, 		   0.0, 		  1.0);
//Returns the following values:
//X: distance to the surface.
//Y: number of iterations needed, from 0 to 1.
//Z: The 'r' value.
//W: The 'dr' value.
vec4 getDistanceToSurface(vec3 pos)
{
    return getDistanceToFractal(pos, 1.0, 1.0);
    vec4 first = getDistanceToFractal(pos, 1.0, 1.0),
         second = getDistanceToFractal(pos, 1.04, 1.0);
    if (first.x < -second.x) return first;
    else return second;
}

vec3 getNormal(vec3 pos)
{
    const vec2 epsilon = vec2(0.0, 0.0001);
    
    return normalize(vec3(getDistanceToSurface(pos + epsilon.yxx).x -
                              getDistanceToSurface(pos - epsilon.yxx).x,
                     	  getDistanceToSurface(pos + epsilon.xyx).x -
                              getDistanceToSurface(pos - epsilon.xyx).x,
                     	  getDistanceToSurface(pos + epsilon.xxy).x -
                              getDistanceToSurface(pos - epsilon.xxy).x));
}



//-----Ray-marching---------

struct RayMarchData
{
    float moveDist;
    vec3 hitPos;
    float nIterations;
    
    float nFractalIterations;
    float fractalR, fractalDR;
};

#define MAX_ITERATIONS 100
#define MAX_ITERATIONS_F float(MAX_ITERATIONS)

#define SHADOW_AMBIENT 0.6
    
#define DISTANCE_EPSILON 0.001

//Performs the ray-marching algo. Returns whether something was hit.
bool marchRay(out RayMarchData dat, vec3 rayStart, vec3 rayDir)
{
    dat.hitPos = rayStart;
    dat.nIterations = 0.0;
    vec4 distData;
    
    for (int i = 0; i < MAX_ITERATIONS; ++i)
    {
        dat.nIterations += 1.0;
        distData = getDistanceToSurface(dat.hitPos);
        
        if (distData.x < DISTANCE_EPSILON)
        {
            dat.nFractalIterations = distData.y;
            dat.nIterations /= float(MAX_ITERATIONS);
            dat.fractalR = distData.z;
            dat.fractalDR = distData.w;
            return true;
        }
        
        dat.hitPos += (distData.x * rayDir);
        dat.moveDist += distData.x;
    }
    
    dat.nIterations /= float(MAX_ITERATIONS);
    return false;
}



//-----------Main------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    //Cam data.
    float distFromCenter = 2.5 + (0.0000 * sin(1.8 * iGlobalTime));
    const float camRotSpeed = 0.25;
    vec3 camForward = normalize(vec3(cos((camRotSpeed * iGlobalTime) + (iMouse.x / iResolution.x * -8.0)),
                                     sin((camRotSpeed * iGlobalTime) + (iMouse.x / iResolution.x * -8.0)),
                                     mix(-1.5, 1.5, iMouse.y / iResolution.y))),
         camPos = distFromCenter * -camForward,
         camUp = vec3(0.0, 0.0, 1.0),
         camSide = cross(camForward, camUp);
    camUp = cross(camSide, camForward);
    
    
    //Ray data.
    const float fovScale = 1.0;
    vec2 uvNormalized = -1.0 + (2.0 * uv);
    vec3 rayStart = camPos + (camForward * fovScale) +
        			(camSide * uvNormalized.x) +
        			(camUp * uvNormalized.y * (iResolution.y / iResolution.x));
    vec3 rayDir = normalize(rayStart - camPos);
    
     
    //Ray-march through the scene.
    RayMarchData dat;
    bool hit = marchRay(dat, rayStart, rayDir);
    
    //Color the scene.
    if (hit)
    {
        //fragColor.xyz = fract(dat.hitPos * 2.0);
        float val = 1.0 - smoothstep(0.0, 1.0, smoothstep(0.0, 1.0, pow(dat.nIterations, 0.35)));
        //float val = pow(dat.fractalR, 0.25);
        
        fragColor.xyz = vec3(val);
        fragColor = texture2D(iChannel0, vec2(val, iGlobalTime * 0.01));
        
        fragColor = vec4(dat.hitPos * pow(val, 0.5), 1.0);
    }
    else
    {
        fragColor = vec4(textureCube(iChannel1, rayDir.xzy).xyz, 1.0);
    }
    
    
    //Some debug-logging color outputs.
    //fragColor = vec4(1.0, 1.0, 1.0, 1.0);
    //fragColor = vec4(0.5 + (0.5 * getNormal(dat.hitPos)), 1.0);
}