// Shader downloaded from https://www.shadertoy.com/view/4tfXz2
// written by shadertoy user demofox
//
// Name: Cubic Bezier Rectangle
// Description: Using ray marching to render a bezier rectangle.  Raytrace bounding box, raymarch interior.  The control points of the rectangle are 1d, which makes it easier to render, but limits the control points to only moving on the Y axis.
/*
For more information, check this out:
http://blog.demofox.org/2015/07/28/rectangular-bezier-patches/
*/

#define SHOW_BOUNDINGBOX   0
#define SHOW_CONTROLPOINTS 0

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
float QuadraticBezier (float A, float B, float C, float t)
{
    float s = 1.0 - t;
    float s2 = s * s;
    float t2 = t * t;
    
    return A*s2 + B*2.0*s*t + C*t2;
}

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
    float CP0X = CubicBezier(CP00, CP01, CP02, CP03, P.x);
    float CP1X = CubicBezier(CP10, CP11, CP12, CP13, P.x);
    float CP2X = CubicBezier(CP20, CP21, CP22, CP23, P.x);
    float CP3X = CubicBezier(CP30, CP31, CP32, CP33, P.x);
    
    return CubicBezier(CP0X, CP1X, CP2X, CP3X, P.y);
}

//=======================================================================================
vec3 Gradient (vec2 p)
{
    float CP0_ = CubicBezier(CP00, CP01, CP02, CP03, p.x);
    float CP1_ = CubicBezier(CP10, CP11, CP12, CP13, p.x);
    float CP2_ = CubicBezier(CP20, CP21, CP22, CP23, p.x);
    float CP3_ = CubicBezier(CP30, CP31, CP32, CP33, p.x);  
    float FY1 = CP1_ - CP0_;
    float FY2 = CP2_ - CP1_;
    float FY3 = CP3_ - CP2_;
    float valueY = 3.0 * QuadraticBezier(FY1, FY2, FY3,  p.y);    
    
    float CP_0 = CubicBezier(CP00, CP10, CP20, CP30, p.y);
    float CP_1 = CubicBezier(CP01, CP11, CP21, CP31, p.y);
    float CP_2 = CubicBezier(CP02, CP12, CP22, CP32, p.y);
    float CP_3 = CubicBezier(CP03, CP13, CP23, CP33, p.y);  
    float FX1 = CP_1 - CP_0;
    float FX2 = CP_2 - CP_1;
    float FX3 = CP_3 - CP_2;
    float valueX = 3.0 * QuadraticBezier(FX1, FX2, FX3,  p.x);      
    
    return vec3(valueX,-1.0,valueY)*-1.0;
}

//=======================================================================================
vec3 NormalAtPos( vec2 p )
{
    #if 1
    return normalize(Gradient(p));
    #else    
	float eps = 0.01;
    vec3 n = vec3( HeightAtPos(vec2(p.x-eps,p.y)) - HeightAtPos(vec2(p.x+eps,p.y)),
                         2.0*eps,
                         HeightAtPos(vec2(p.x,p.y-eps)) - HeightAtPos(vec2(p.x,p.y+eps)));
    return normalize( n );
	#endif
}

//=======================================================================================
bool RayIntersectAABox (vec3 boxMin, vec3 boxMax, in vec3 rayPos, in vec3 rayDir, out vec2 time)
{
	vec3 roo = rayPos - (boxMin+boxMax)*0.5;
    vec3 rad = (boxMax - boxMin)*0.5;

    vec3 m = 1.0/rayDir;
    vec3 n = m*roo;
    vec3 k = abs(m)*rad;
	
    vec3 t1 = -n - k;
    vec3 t2 = -n + k;

    time = vec2( max( max( t1.x, t1.y ), t1.z ),
                 min( min( t2.x, t2.y ), t2.z ) );
	
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
    if (!RayIntersectAABox(vec3(0.0,CPMin,0.0), vec3(1.0,CPMax,1.0), rayPos, rayDir, timeMinMax))
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
vec3 HandleControlPoints (in vec3 rayPos, in vec3 rayDir, in vec3 pixelColor, inout float hitTime)
{
    #if SHOW_CONTROLPOINTS
    float cpHitTime = RayIntersectSphere(vec4(0.0, CP00, 0.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(1.0,0.0,0.0);
    }
    cpHitTime = RayIntersectSphere(vec4(1.0/3.0, CP01, 0.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(1.0,0.0,0.0);
    }    
    cpHitTime = RayIntersectSphere(vec4(2.0/3.0, CP02, 0.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(1.0,0.0,0.0);
    }    
    cpHitTime = RayIntersectSphere(vec4(1.0, CP03, 0.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(1.0,0.0,0.0);
    }        
    
    
    cpHitTime = RayIntersectSphere(vec4(0.0, CP10, 1.0/3.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(0.0,1.0,0.0);
    }
    cpHitTime = RayIntersectSphere(vec4(1.0/3.0, CP11, 1.0/3.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(0.0,1.0,0.0);
    }    
    cpHitTime = RayIntersectSphere(vec4(2.0/3.0, CP12, 1.0/3.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(0.0,1.0,0.0);
    }       
    cpHitTime = RayIntersectSphere(vec4(1.0, CP13, 1.0/3.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(0.0,1.0,0.0);
    }      
    
    
    cpHitTime = RayIntersectSphere(vec4(0.0, CP20, 2.0 / 3.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(0.0,0.0,1.0);
    }
    cpHitTime = RayIntersectSphere(vec4(1.0/3.0, CP21, 2.0 / 3.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(0.0,0.0,1.0);
    }    
    cpHitTime = RayIntersectSphere(vec4(2.0/3.0, CP22, 2.0 / 3.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(0.0,0.0,1.0);
    }     
    cpHitTime = RayIntersectSphere(vec4(1.0, CP23, 2.0 / 3.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(0.0,0.0,1.0);
    }     
    
    
    cpHitTime = RayIntersectSphere(vec4(0.0, CP30, 1.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(1.0,1.0,0.0);
    }
    cpHitTime = RayIntersectSphere(vec4(1.0/3.0, CP31, 1.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(1.0,1.0,0.0);
    }    
    cpHitTime = RayIntersectSphere(vec4(2.0/3.0, CP32, 1.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(1.0,1.0,0.0);
    }     
    cpHitTime = RayIntersectSphere(vec4(1.0, CP33, 1.0, 0.01), rayPos, rayDir);
    if (cpHitTime > 0.0 && cpHitTime < hitTime)
    {
        hitTime = cpHitTime;
        pixelColor = vec3(1.0,1.0,0.0);
    }       
    #endif
    
    return pixelColor;
}

//=======================================================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{		
    // keep it from degenerating when all control points are the same - like at the start!
    CPMin -= 0.005;
    CPMax += 0.005;
    
    //----- camera
    vec2 mouse = iMouse.xy / iResolution.xy;

    vec3 cameraAt 	= vec3(0.5,0.5,0.5);

    float angleX = iMouse.z > 0.0 ? 6.28 * mouse.x : 3.14 + iGlobalTime * 0.25;
    float angleY = iMouse.z > 0.0 ? (mouse.y * 6.28) - 0.4 : 0.5;
    vec3 cameraPos	= (vec3(sin(angleX)*cos(angleY), sin(angleY), cos(angleX)*cos(angleY))) * 3.0;
    cameraPos += vec3(0.5,0.5,0.5);

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
    pixelColor = HandleControlPoints(cameraPos, rayDir, pixelColor, hitTime);
    
    fragColor = vec4(clamp(pixelColor,0.0,1.0), 1.0);
}