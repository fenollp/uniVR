// Shader downloaded from https://www.shadertoy.com/view/4s33RN
// written by shadertoy user weyland
//
// Name: Luceat lux vestra visualiser
// Description: Quick hack based on https://www.shadertoy.com/view/Xdf3zB by sjb3d and added some cheap res dependent glitch/MPEG distortion from https://www.shadertoy.com/view/Md2GDw# by Kusma
//    
//    You can disable the fake mpeg articfacts and adjust the amount of spheres
// based on: https://www.shadertoy.com/view/Xdf3zB
// Implementation of equi-angular sampling for raymarching through homogenous media
// 2013 @sjb3d

#define PI				3.1415926535
#define SIGMA			0.3
#define STEP_COUNT		16
#define DIST_MAX		10.0
#define LIGHT_POWER		32.0
#define SURFACE_ALBEDO	0.7
#define EPS				0.01
#define BALL_AMOUNT		20
#define GLITCH			true
#define time			iGlobalTime

float audioEnvelope;

// shamelessly stolen from iq!
float hash(float n)
{
    return fract(sin(n)*43758.5453123);
}

void sampleCamera(vec2 fragCoord, vec2 u, out vec3 rayOrigin, out vec3 rayDir)
{
	vec2 filmUv = (fragCoord.xy + u)/iResolution.xy;
	
	float tx = (2.0*filmUv.x - 1.0)*(iResolution.x/iResolution.y);
	float ty = (1.0 - 2.0*filmUv.y);
	float tz = 0.0;
	
	rayOrigin = vec3(0.0, 0.0, 5.0);
	rayDir = normalize(vec3(tx, ty, tz) - rayOrigin);
}

void intersectSphere(
	vec3 rayOrigin,
	vec3 rayDir,
	vec3 sphereCentre,
	float sphereRadius,
	inout float rayT,
	inout vec3 geomNormal)
{
	// ray: x = o + dt, sphere: (x - c).(x - c) == r^2
	// let p = o - c, solve: (dt + p).(dt + p) == r^2
	//
	// => (d.d)t^2 + 2(p.d)t + (p.p - r^2) == 0
	vec3 p = rayOrigin - sphereCentre;
	vec3 d = rayDir;
	float a = dot(d, d);
	float b = 2.0*dot(p, d);
	float c = dot(p, p) - sphereRadius*sphereRadius;
	float q = b*b - 4.0*a*c;
	if (q > 0.0) {
		float denom = 0.5/a;
		float z1 = -b*denom;
		float z2 = abs(sqrt(q)*denom);
		float t1 = z1 - z2;
		float t2 = z1 + z2;
		bool intersected = false;
		if (0.0 < t1 && t1 < rayT) {
			intersected = true;
			rayT = t1;
		} else if (0.0 < t2 && t2 < rayT) {
			intersected = true;
			rayT = t2;
		}
		if (intersected) {
			geomNormal = normalize(p + d*rayT);
		}
	}
}

void intersectScene(
	vec3 rayOrigin,
	vec3 rayDir,
	inout float rayT,
	inout vec3 geomNormal)
{
    float z = 1.0;
    float xfactor = .75;
    float yfactor = 1.0;
    
    for (int stepIndex = 0; stepIndex < BALL_AMOUNT; ++stepIndex)
    {	
        float xtime = time + float(stepIndex)*142.;
        float posx = sin(xtime/(2.0+sin(hash(float(stepIndex*1342)))));
        float posy = cos(xtime/(2.0+sin(hash(float(stepIndex*3234)))));
        float posz = tan(xtime/(2.0+tan(hash(float(stepIndex*2323)))))/3.;
		intersectSphere(rayOrigin, rayDir, vec3( posx/xfactor, posy, z+posz), 0.2*(2.0+sin((float(stepIndex*1342))))/2., rayT, geomNormal);
    }
}

void sampleUniform(
	float u,
	float maxDistance,
	out float dist,
	out float pdf)
{
	dist = u*maxDistance;
	pdf = 1.0/maxDistance;
}

void sampleScattering(
	float u,
	float maxDistance,
	out float dist,
	out float pdf)
{
	// remap u to account for finite max distance
	float minU = exp(-SIGMA*maxDistance);
	float a = u*(1.0 - minU) + minU;

	// sample with pdf proportional to exp(-sig*d)
	dist = -log(a)/SIGMA;
	pdf = SIGMA*a/(1.0 - minU);
}

void sampleEquiAngular(
	float u,
	float maxDistance,
	vec3 rayOrigin,
	vec3 rayDir,
	vec3 lightPos,
	out float dist,
	out float pdf)
{
	// get coord of closest point to light along (infinite) ray
	float delta = dot(lightPos - rayOrigin, rayDir);
	
	// get distance this point is from light
	float D = length(rayOrigin + delta*rayDir - lightPos);

	// get angle of endpoints
	float thetaA = atan(0.0 - delta, D);
	float thetaB = atan(maxDistance - delta, D);
	
	// take sample
	float t = D*tan(mix(thetaA, thetaB, u));
	dist = delta + t;
	pdf = D/((thetaB - thetaA)*(D*D + t*t));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //amplitude envelope
    audioEnvelope = (texture2D(iChannel2, vec2(iChannelTime[1],0.0))).x;
   	int c =0;
  	for(float k = 0.0; k<0.02; k+=0.001)
    {
    	c++;
    	float val = abs((texture2D(iChannel0, vec2(iChannelTime[1]+k,0.0))).x);
    	audioEnvelope+=  val*val;
    }
    
    audioEnvelope = audioEnvelope/float(c);
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 block = floor(fragCoord.xy / vec2(16));
	vec2 uv_noise = block / vec2(64);
	uv_noise += floor(vec2(iGlobalTime) * vec2(1234.0, 3543.0)) / vec2(64);
	
	float block_thresh = pow(fract(iGlobalTime * 1236.0453), 2.0) * 0.2;
	float line_thresh = pow(fract(iGlobalTime * 2236.0453), 3.0) * 0.7;
	
	vec2 uv_r = uv, uv_g = uv, uv_b = uv;

   	// glitch some blocks and lines
	if  (GLITCH && (texture2D(iChannel1, uv_noise).r < block_thresh ||
		texture2D(iChannel1, vec2(uv_noise.y, 0.0)).g < line_thresh)) {

		vec2 dist = (fract(uv_noise) - 0.5) * audioEnvelope;
		fragCoord.x -= dist.x * 250.1 * audioEnvelope;
		fragCoord.y -= dist.y * 250.2 * audioEnvelope;
	}

    fragCoord.x += audioEnvelope * 50.;
	vec3 lightPos = vec3(0.8*sin(iGlobalTime*3.2/4.0), 0.8*sin(iGlobalTime*1.2/4.0), 0.0);
	vec3 lightIntensity = vec3(LIGHT_POWER*audioEnvelope);
	vec3 surfIntensity = vec3(SURFACE_ALBEDO/PI);
	vec3 particleIntensity = vec3(1.0/(4.0*PI));
	
	vec3 rayOrigin, rayDir;
	sampleCamera((fragCoord+uv_r,fragCoord+uv_b), vec2(0.5, 0.5), rayOrigin, rayDir);
	
//	float splitCoord = (iMouse.x == 0.0) ? iResolution.x/2.0 : iMouse.x; // old compare indicator
	float splitCoord = 0.0;
	
	vec3 col = vec3(0.0);
	float t = DIST_MAX;
	{
		vec3 n;
		intersectScene(rayOrigin, rayDir, t, n);
		
		if (t < DIST_MAX) {
			// connect surface to light
			vec3 surfPos = rayOrigin + t*rayDir;
			vec3 lightVec = lightPos - surfPos;
			vec3 lightDir = normalize(lightVec);
			vec3 cameraDir = -rayDir;
			float nDotL = dot(n, lightDir);
			float nDotC = dot(n, cameraDir);
			
			// only handle BRDF if entry and exit are same hemisphere
			if (nDotL*nDotC > 0.0) {
				float d = length(lightVec);
                float t2 = d;
                vec3 n2;
                vec3 rayDir = normalize(lightVec);
				intersectScene(surfPos + EPS*rayDir, rayDir, t2, n2);
                
                // accumulate surface response if not occluded
                if (t2 == d) {
					float trans = exp(-SIGMA*(d + t));
					float geomTerm = abs(nDotL)/dot(lightVec, lightVec);
					col = surfIntensity*lightIntensity*geomTerm*trans;
                }
			}
		}
	}
	
	float offset = hash(fragCoord.y*iResolution.x + fragCoord.x + iGlobalTime);
	for (int stepIndex = 0; stepIndex < STEP_COUNT; ++stepIndex) {
		float u = (float(stepIndex)+offset)/float(STEP_COUNT);
		
		// sample along ray from camera to surface
		float x;
		float pdf;
		if (fragCoord.x < splitCoord) {
			//sampleScattering(u, t, x, pdf);
		} else {
			sampleEquiAngular(u, t, rayOrigin, rayDir, lightPos, x, pdf);
		}
		
		// adjust for number of ray samples
		pdf *= float(STEP_COUNT);
		
		// connect to light and check shadow ray
		vec3 particlePos = rayOrigin + x*rayDir;
		vec3 lightVec = lightPos - particlePos;
		float d = length(lightVec);
		float t2 = d;
		vec3 n2;
		intersectScene(particlePos, normalize(lightVec), t2, n2);
		
		// accumulate particle response if not occluded
		if (t2 == d) {
			float trans = exp(-SIGMA*(d + x));
			float geomTerm = 1.0/dot(lightVec, lightVec);
			col += SIGMA*particleIntensity*lightIntensity*geomTerm*trans/pdf;
		}
	}
/*
	// show slider position in original shader
	if (abs(fragCoord.x - splitCoord) < 1.0) {
		col.x = 1.0;
	}
*/	
	col = pow(col, vec3(1.0/2.2));
	
	fragColor = vec4(col, 1.0);
    
	// interleave lines in some blocks
	if (GLITCH && (texture2D(iChannel1, uv_noise).g * 1.5 < block_thresh ||
		texture2D(iChannel1, vec2(uv_noise.y, 0.0)).g * 2.5 < line_thresh)) {
		float line = fract(fragCoord.y / 3.0);
		vec3 mask = vec3(2.0, 0.0, 0.0);
		if (line > 0.333)
			mask = vec3(0.0, 2.0, 0.0);
		if (line > 0.666)
			mask = vec3(0.0, 0.0, 2.0);
		
		fragColor.xyz *= mask;
	}
}
