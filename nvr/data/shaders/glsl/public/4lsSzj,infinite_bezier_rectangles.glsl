// Shader downloaded from https://www.shadertoy.com/view/4lsSzj
// written by shadertoy user demofox
//
// Name: Infinite Bezier Rectangles
// Description: The same shader as https://www.shadertoy.com/view/4tfXz2, but tiled.  Ray vs plane to figure out where to start raymarching.  This would look way cooler using wang tiling (https://www.shadertoy.com/view/XsSXzR)
/*
For more information, check this out:
http://blog.demofox.org/2015/07/28/rectangular-bezier-patches/
*/

#define SHOW_BOUNDINGBOX   0

float CP00 = sin(iGlobalTime*0.30) * 0.5 + 0.5;
float CP01 = sin(iGlobalTime*0.10) * 0.5 + 0.5;
float CP02 = sin(iGlobalTime*0.70) * 0.5 + 0.5;
float CP03 = sin(iGlobalTime*0.52) * 0.5 + 0.5;

float CP10 = sin(iGlobalTime*0.20) * 0.5 + 0.5;
float CP11 = sin(iGlobalTime*0.40) * 0.5 + 0.5;
float CP12 = sin(iGlobalTime*0.80) * 0.5 + 0.5;
float CP13 = sin(iGlobalTime*0.61) * 0.5 + 0.5;

float CP20 = sin(iGlobalTime*0.50) * 0.5 + 0.5;
float CP21 = sin(iGlobalTime*0.90) * 0.5 + 0.5;
float CP22 = sin(iGlobalTime*0.60) * 0.5 + 0.5;
float CP23 = sin(iGlobalTime*0.32) * 0.5 + 0.5;

float CP30 = sin(iGlobalTime*0.27) * 0.5 + 0.5;
float CP31 = sin(iGlobalTime*0.64) * 0.5 + 0.5;
float CP32 = sin(iGlobalTime*0.18) * 0.5 + 0.5;
float CP33 = sin(iGlobalTime*0.95) * 0.5 + 0.5;

float CPMin =
    min(CP00,min(CP01,min(CP02,min(CP03,
    min(CP10,min(CP11,min(CP12,min(CP13,
    min(CP20,min(CP21,min(CP22,min(CP23,
    min(CP30,min(CP31,min(CP32,CP33)))))))))))))));    

float CPMax =
    max(CP00,max(CP01,max(CP02,max(CP03,
    max(CP10,max(CP11,max(CP12,max(CP13,
    max(CP20,max(CP21,max(CP22,max(CP23,
    max(CP30,max(CP31,max(CP32,CP33))))))))))))))); 

#define FLT_MAX 3.402823466e+38

//=======================================================================================
float CubicBezier (float A, float B, float C, float D, float t)
{
    float s = 1.0 - t;
    float s2 = s * s;
    float s3 = s * s * s;
    float t2 = t * t;
    float t3 = t * t * t;
    
    return A*s3 + B*3.0*s2*t + C*3.0*s*t2 + D*t3;
}


//=======================================================================================
float HeightAtPos(vec2 P)
{
    vec2 tile = mod(floor(P),2.0);
    
    P = fract(P);
    
    if (tile.x == 1.0)
        P.x = 1.0 - P.x;
    
    if (tile.y == 1.0)
        P.y = 1.0 - P.y;
    
    float CP0X = CubicBezier(CP00, CP01, CP02, CP03, P.x);
    float CP1X = CubicBezier(CP10, CP11, CP12, CP13, P.x);
    float CP2X = CubicBezier(CP20, CP21, CP22, CP23, P.x);
    float CP3X = CubicBezier(CP30, CP31, CP32, CP33, P.x);
    
    return CubicBezier(CP0X, CP1X, CP2X, CP3X, P.y);
}

//=======================================================================================
vec3 NormalAtPos( vec2 p )
{
	float eps = 0.01;
    vec3 n = vec3( HeightAtPos(vec2(p.x-eps,p.y)) - HeightAtPos(vec2(p.x+eps,p.y)),
                         2.0*eps,
                         HeightAtPos(vec2(p.x,p.y-eps)) - HeightAtPos(vec2(p.x,p.y+eps)));
    return normalize( n );
}

//=======================================================================================
bool RayIntersectAABoxYAxis (vec3 boxMin, vec3 boxMax, in vec3 rayPos, in vec3 rayDir, out vec2 time)
{
	float roo = rayPos.y - (boxMin.y+boxMax.y)*0.5;
    float rad = (boxMax.y - boxMin.y)*0.5;

    float m = 1.0/rayDir.y;
    float n = m*roo;
    float k = abs(m)*rad;
	
    float t1 = -n - k;
    float t2 = -n + k;

    time = vec2(t1, t2);
	
    return time.y>time.x && time.y>0.0;
}

//=======================================================================================
float RayIntersectSphere (vec4 sphere, in vec3 rayPos, in vec3 rayDir)
{
	//get the vector from the center of this circle to where the ray begins.
	vec3 m = rayPos - sphere.xyz;

    //get the dot product of the above vector and the ray's vector
	float b = dot(m, rayDir);

	float c = dot(m, m) - sphere.w * sphere.w;

	//exit if r's origin outside s (c > 0) and r pointing away from s (b > 0)
	if(c > 0.0 && b > 0.0)
		return -1.0;

	//calculate discriminant
	float discr = b * b - c;

	//a negative discriminant corresponds to ray missing sphere
	if(discr < 0.0)
		return -1.0;

	//ray now found to intersect sphere, compute smallest t value of intersection
	float collisionTime = -b - sqrt(discr);

	//if t is negative, ray started inside sphere so clamp t to zero and remember that we hit from the inside
	if(collisionTime < 0.0)
		collisionTime = -b + sqrt(discr);
    
    return collisionTime;
}

//=======================================================================================
vec3 DiffuseColor (in vec3 pos)
{
	// checkerboard pattern
    return vec3(mod(floor(pos.x * 10.0) + floor(pos.z * 10.0), 2.0) < 1.0 ? 1.0 : 0.4);
}

//=======================================================================================
vec3 ShadePoint (in vec3 pos, in vec3 rayDir, float time, bool fromUnderneath)
{
	vec3 diffuseColor = DiffuseColor(pos);
	vec3 reverseLightDir = normalize(vec3(1.0,1.0,-1.0));
	vec3 lightColor = vec3(0.95,0.95,0.95);	
	vec3 ambientColor = vec3(0.05,0.05,0.05);

	vec3 normal = NormalAtPos(pos.xz);
    normal *= fromUnderneath ? -1.0 : 1.0;

    // diffuse
	vec3 color = diffuseColor * ambientColor;
	float dp = dot(normal, reverseLightDir);
	if(dp > 0.0)
		color += (diffuseColor * dp * lightColor);
    
    // specular
    vec3 reflection = reflect(reverseLightDir, normal);
    dp = dot(rayDir, reflection);
    if (dp > 0.0)
        color += pow(dp, 15.0) * vec3(0.5);		
    
    // reflection (environment mappping)
    reflection = reflect(rayDir, normal);
    color += textureCube(iChannel0, reflection).rgb * 0.25;    
    
    return color;
}

//=======================================================================================
vec3 HandleRay (in vec3 rayPos, in vec3 rayDir, in vec3 pixelColor, out float hitTime)
{
	float time = 0.0;
	float lastHeight = 0.0;
	float lastY = 0.0;
	float height;
	bool hitFound = false;
    hitTime = FLT_MAX;
    bool fromUnderneath = false;
    
    vec2 timeMinMax = vec2(0.0);
    if (!RayIntersectAABoxYAxis(vec3(0.0,CPMin,0.0), vec3(1.0,CPMax,1.0), rayPos, rayDir, timeMinMax))
        return pixelColor;
    
    time = timeMinMax.x;
    
    const int c_numIters = 100;
    float deltaT = (timeMinMax.y - timeMinMax.x) / float(c_numIters);
    
    vec3 pos = rayPos + rayDir * time;
    float firstSign = sign(pos.y - HeightAtPos(pos.xz));
    
	for (int index = 0; index < c_numIters; ++index)
	{		
		pos = rayPos + rayDir * time;
        
        height = HeightAtPos(pos.xz);
        
        if (sign(pos.y - height) * firstSign < 0.0)
        {
            fromUnderneath = firstSign < 0.0; 
        	hitFound = true;
			break;
        }
		
		time += deltaT;		
		lastHeight = height;
		lastY = pos.y;
    }
    
	
	if (hitFound) {
		time = time - deltaT + deltaT*(lastHeight-lastY)/(pos.y-lastY-height+lastHeight);
		pos = rayPos + rayDir * time;
		pixelColor = ShadePoint(pos, rayDir, time, fromUnderneath);
        hitTime = time;
	}
    else
    {
        #if SHOW_BOUNDINGBOX
        	pixelColor += vec3(0.2);
        #endif
    }
    
	return pixelColor;
}

//=======================================================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
    // keep it from degenerating when all control points are the same - like at the start!
    CPMin -= 0.005;
    CPMax += 0.005;
    
    // scrolling camera
    vec3 cameraOffset = vec3(iGlobalTime, iGlobalTime / 10.0, iGlobalTime);
    
    //----- camera
    vec2 mouse = iMouse.xy / iResolution.xy;

    vec3 cameraAt 	= vec3(0.5,0.5,0.5) + cameraOffset;

    float angleX = iMouse.z > 0.0 ? 6.28 * mouse.x : 3.14 + iGlobalTime * 0.25;
    float angleY = iMouse.z > 0.0 ? (mouse.y * 6.28) - 0.4 : 0.5;
    vec3 cameraPos	= (vec3(sin(angleX)*cos(angleY), sin(angleY), cos(angleX)*cos(angleY))) * 5.0;
    cameraPos += vec3(0.5,0.5,0.5) + cameraOffset;

    vec3 cameraFwd  = normalize(cameraAt - cameraPos);
    vec3 cameraLeft  = normalize(cross(normalize(cameraAt - cameraPos), vec3(0.0,sign(cos(angleY)),0.0)));
    vec3 cameraUp   = normalize(cross(cameraLeft, cameraFwd));

    float cameraViewWidth	= 6.0;
    float cameraViewHeight	= cameraViewWidth * iResolution.y / iResolution.x;
    float cameraDistance	= 6.0;  // intuitively backwards!
	
		
	// Objects
	vec2 rawPercent = (fragCoord.xy / iResolution.xy);
	vec2 percent = rawPercent - vec2(0.5,0.5);
	
	vec3 rayTarget = (cameraFwd * vec3(cameraDistance,cameraDistance,cameraDistance))
				   - (cameraLeft * percent.x * cameraViewWidth)
		           + (cameraUp * percent.y * cameraViewHeight);
	vec3 rayDir = normalize(rayTarget);
	
	
    float hitTime = FLT_MAX;
	vec3 pixelColor = textureCube(iChannel0, rayDir).rgb;
    pixelColor = HandleRay(cameraPos, rayDir, pixelColor, hitTime);
    
    fragColor = vec4(clamp(pixelColor,0.0,1.0), 1.0);
}