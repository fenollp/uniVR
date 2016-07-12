// Shader downloaded from https://www.shadertoy.com/view/ltlGzj
// written by shadertoy user Fred1024
//
// Name: cubeOcube
// Description: First try with ray casting and with GLSL,
//    Advice is more than welcome :)
//    
//    
// ~ cubeOcube ~
// Frederic Heintz
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define FOV_DEGRE 62.0
#define LIGHT_RANGE 5.0

ivec3 ptr;
vec3 fraction;
vec3 lightPos;
vec3 mask;

vec3 colorFromPtr( in ivec3 ptr )
{
    float r = (sin( (float(ptr.x) + 0.1) * 2.0) * sin( (float(ptr.y) + 0.5) * 1.1) * sin( (float(ptr.z) + 0.8) * 1.0));
    float b = (sin( (float(ptr.x) + 0.6) * 1.2) * sin( (float(ptr.y) + 0.2) * 1.0) * sin( (float(ptr.z) + 0.5) * 1.2));
    float g = (1.0 - r - b);
    return clamp(vec3(r, g, b), vec3(1.0, 0.5, 0.0), vec3(1.0, 1.0, 1.0));
}

bool mapCube( ivec3 coord )
{
    if( coord.y < 0)	return true;
//    if( coord.y > 1)	return true;
    return false;
}

bool computeRayHit( in vec3 ray, in float dist )
{
    vec3 normalsSign = -sign(ray);
    vec3 dots = vec3(ray.x * normalsSign.x, ray.y * normalsSign.y, ray.z * normalsSign.z);

    ivec3 ptrSteps = ivec3(1, 1, 1); //-normalsSign);
    if(ray.x < 0.0)	ptrSteps.x = -1;
    if(ray.y < 0.0)	ptrSteps.y = -1;
    if(ray.z < 0.0)	ptrSteps.z = -1;
    
    vec3 crossValues = max(vec3(0.0, 0.0, 0.0), normalsSign);	// 0.0 or 1.0

    for(int i = 0; i < 64; i++)
    {
        vec3 vDist = ((1.0 - crossValues - fraction) * normalsSign) / dots;

        float shortestDist = min(min( vDist.x, vDist.y), vDist.z);
        dist -= shortestDist;
        if(dist <= 0.0)
        {
            // far dist or light dist reached
		    break;
        }

        // to current cube exit coord
        fraction = fraction + (ray * shortestDist);
        
        // which side
        if(all(lessThanEqual( vDist.xx, vDist.yz)))  	mask = vec3(1.0, 0.0, 0.0);	  // cut X ?
        else if(vDist.y <= vDist.z)         			mask = vec3(0.0, 1.0, 0.0);   // cut Y ?
        else            								mask = vec3(0.0, 0.0, 1.0);	  // then must be cuting Z
        
        // next cube ( the cube we should be entering )
		ivec3 nextPtr = ptr + ptrSteps * ivec3(mask);
        if( mapCube( nextPtr ) )
        {
            return true;
        }
        
        // bumping on a cube edge ?
        vec3 temp = (1.0 - mask) * abs( fraction - 0.5 );
        float distToClosestSide = max( max( temp.x, temp.y ), temp.z);
        if(distToClosestSide > 0.4)
        {
            return true;
        }

        // next cube is now current
        ptr = nextPtr;
        fraction = mix(fraction, crossValues, mask);	// got to reset the crossing coord component (float imprecision)
	}
    return false;
}

vec3 shadeHit( in vec3 ray, in vec3 hitNormal, in vec3 surfaceColor, in float ao )
{
    vec3 lightDir = (lightPos - (vec3(ptr) + fraction));
    float lightDist = length(lightDir);
    lightDir = normalize(lightDir);
    float lightDot = clamp(dot(lightDir, hitNormal), 0.0, 1.0);

    float spec = 0.0;
	float lightI = 0.0;
    if(lightDot >= 0.0 && lightDist < LIGHT_RANGE)
    {
	    if( computeRayHit(lightDir, lightDist) == false)
        {
	        lightI = lightDot * pow(1.0 - (lightDist / LIGHT_RANGE), 2.0) * 1.6;
		    spec = clamp(dot(ray, normalize(lightDir - hitNormal)), 0.0, 1.0);
		    spec = pow(spec, 40.0) * 0.8;
        }
    }

    return( (surfaceColor * 0.05 * ao) + (surfaceColor * lightI) + spec );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    lightPos = vec3(0.8 - sin(iGlobalTime * 0.15) * 1.8, 0.9 - sin(iGlobalTime * 0.25) * 0.7, cos(iGlobalTime * 0.17) * 0.7);

    // Camera setup
    float height = (iMouse.y / iResolution.y) * 6.0;
    vec3 camPos = vec3(0.5, 0.1 + height, 0.5);
    camPos = mix(camPos, lightPos, 0.2);
	vec3 camTgt = vec3(lightPos.x, 0.5 + (height * 0.5), lightPos.z);

    // A view matrix
    vec3 dir = normalize(camTgt - camPos);					// z
    vec3 side = normalize(cross(dir, vec3(0.0, 1.0, 0.0)));	// side = z X up (with dir and up not || )
    vec3 up = normalize(cross(side, dir));					// up = sideXdir
    mat3 viewMatrix = mat3(side.x, up.x, dir.x, side.y, up.y, dir.y, side.z, up.z, dir.z);
    
    // Ray setup
    float tangF = tan(radians(FOV_DEGRE));
    float ratio = iResolution.y / iResolution.x;
    float rX = (((gl_FragCoord.x / iResolution.x) * 2.0) - 1.0) * tangF;
    float rY = (((gl_FragCoord.y / iResolution.y) * 2.0) - 1.0) * tangF * ratio;
    vec3 ray = normalize(vec3(rX, rY, 1.0));
    
    // apply camera transform to ray
    ray = ray * viewMatrix;

	// search hit
    ptr = ivec3(floor(camPos));
    fraction = fract(camPos);

    // pick color
    vec3 color = vec3(1.0, 0.5, 0.0) * 0.07;
    if( computeRayHit( ray, 16.0 ) == true)
    {
		vec2 testCoord;
        vec3 normalsSign = -sign(ray);
	    vec3 normal = normalsSign * mask;
        testCoord.x = (fraction.y * mask.x) + (fraction.x * mask.y) + (fraction.x * mask.z);
        testCoord.y = (fraction.z * mask.x) + (fraction.z * mask.y) + (fraction.y * mask.z);

        float ao = 1.0;
        vec3 surfaceColor = vec3(211.0 / 255.0, 74.0 / 255.0, 47.0 / 255.0);
        if(any(lessThanEqual( vec4(testCoord, 0.9, 0.9), vec4(0.1, 0.1, testCoord))))
        {
            // cube edge
        	surfaceColor = colorFromPtr( ptr );
            float g0 = 5.0 - abs(testCoord.x - 0.5) * 8.0;
            float g1 = 5.0 - abs(testCoord.y - 0.5) * 8.0;
            ao = min(min(g0, g1), g0 * g1 * 0.25);
        }

        color = shadeHit( ray, normal, surfaceColor, ao );
    }

    // show light
    vec3 hitPos = vec3(ptr) + fraction;
	vec3 lightDir = (lightPos - camPos);
    float lightDist = length(lightDir);
    if(lightDist < length(hitPos - camPos))
    {
        lightDir = normalize(lightDir);
        float lightQ = max( 0.0, dot(ray, lightDir));
        color.xyz += clamp(vec3(pow(lightQ, 1000.0)), 0.0, 1.0);
    }

    fragColor = vec4(color, 1.0);
}

