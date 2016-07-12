// Shader downloaded from https://www.shadertoy.com/view/MtsXzl
// written by shadertoy user demofox
//
// Name: Infinite Hermite Rectangles
// Description: Based on https://www.shadertoy.com/view/ltsXzl, but extended to multiple squares.  Each checkerboard square is a cubic hermite rectangle.  Could add lower frequency sine waves to look better maybe.
#define SHOW_GRID 1
#define FUN_REFLECT 0

const float c_scale = 0.5;
const float c_rate = 2.0;

#define FLT_MAX 3.402823466e+38

//=======================================================================================
float CubicHermite (float A, float B, float C, float D, float t)
{
	float t2 = t*t;
    float t3 = t*t*t;
    float a = -A/2.0 + (3.0*B)/2.0 - (3.0*C)/2.0 + D/2.0;
    float b = A - (5.0*B)/2.0 + 2.0*C - D / 2.0;
    float c = -A/2.0 + C/2.0;
   	float d = B;
    
    return a*t3 + b*t2 + c*t + d;
}

//=======================================================================================
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

//=======================================================================================
float GetHeightAtTile(vec2 T)
{
    float rate = hash(hash(T.x) * hash(T.y))*0.5+0.5;
    
    return (sin(iGlobalTime*rate*c_rate) * 0.5 + 0.5) * c_scale;
}

//=======================================================================================
float HeightAtPos(vec2 P)
{
    vec2 tile = floor(P);
    
    P = fract(P);
    
    float CP0X = CubicHermite(
        GetHeightAtTile(tile + vec2(-1.0,-1.0)),
        GetHeightAtTile(tile + vec2(-1.0, 0.0)),
        GetHeightAtTile(tile + vec2(-1.0, 1.0)),
        GetHeightAtTile(tile + vec2(-1.0, 2.0)),
        P.y
    );
    
    float CP1X = CubicHermite(
        GetHeightAtTile(tile + vec2( 0.0,-1.0)),
        GetHeightAtTile(tile + vec2( 0.0, 0.0)),
        GetHeightAtTile(tile + vec2( 0.0, 1.0)),
        GetHeightAtTile(tile + vec2( 0.0, 2.0)),
        P.y
    );    
    
    float CP2X = CubicHermite(
        GetHeightAtTile(tile + vec2( 1.0,-1.0)),
        GetHeightAtTile(tile + vec2( 1.0, 0.0)),
        GetHeightAtTile(tile + vec2( 1.0, 1.0)),
        GetHeightAtTile(tile + vec2( 1.0, 2.0)),
        P.y
    );        
    
    float CP3X = CubicHermite(
        GetHeightAtTile(tile + vec2( 2.0,-1.0)),
        GetHeightAtTile(tile + vec2( 2.0, 0.0)),
        GetHeightAtTile(tile + vec2( 2.0, 1.0)),
        GetHeightAtTile(tile + vec2( 2.0, 2.0)),
        P.y
    );
    
    return CubicHermite(CP0X, CP1X, CP2X, CP3X, P.x);
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
    #if SHOW_GRID
    pos = mod(floor(pos),2.0);
    return vec3(mod(pos.x + pos.z, 2.0) < 1.0 ? 1.0 : 0.4);
    #else
    return vec3(0.1, 0.8, 0.9);
    #endif
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
        color += pow(abs(dp), 15.0) * vec3(0.5);		
    
    // reflection (environment mappping)
    #if FUN_REFLECT
    reflection = reflect(rayDir, normalize(normal*vec3(1.0,0.9,1.0)));
    color += textureCube(iChannel0, reflection).rgb * vec3(0.25,0.0,0.0);    
    reflection = reflect(rayDir, normalize(normal*vec3(1.0,1.0,1.0)));
    color += textureCube(iChannel0, reflection).rgb * vec3(0.0,0.25,0.0);   
    reflection = reflect(rayDir, normalize(normal*vec3(1.0,1.1,1.0)));
    color += textureCube(iChannel0, reflection).rgb * vec3(0.0,0.0,0.25);                          
    #else
    reflection = reflect(rayDir, normal);
    color += textureCube(iChannel0, reflection).rgb * 0.25;    
    #endif
    
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
    
    vec2 timeMinMax = vec2(0.0, 20.0);
    
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

	return pixelColor;
}

//=======================================================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	   
    // scrolling camera
    vec3 cameraOffset = vec3(iGlobalTime, 0.5, iGlobalTime);
    
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