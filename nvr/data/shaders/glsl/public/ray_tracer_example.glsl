// Shader downloaded from https://www.shadertoy.com/view/Xtf3RS
// written by shadertoy user akaitora
//
// Name: Ray Tracer Example
// Description: Here is my first ray tracer.  The specular lighting is wrong.  A work in progress...
//--------------------------------------------------------------------------------------------
// Simple Ray Tracer
// By: Brandon Fogerty
// bfogerty at gmail dot com
//--------------------------------------------------------------------------------------------


//--------------------------------------------------------------------------------------------
// Begin Region: Defines
//--------------------------------------------------------------------------------------------
#define PrimitiveType_None          0.0
#define PrimitiveType_Sphere        1.0
#define PrimitiveType_Plane         2.0

#define MAX_SPHERES                 4
#define MAX_PLANES                  6

#define TimeValue                   iGlobalTime
#define ResolutionValue             iResolution
#define MouseValue					iMouse
#define Epsilon                     0.00001
//--------------------------------------------------------------------------------------------
// End Region
//--------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------
// Begin Region: Data Structures
//--------------------------------------------------------------------------------------------
struct Ray
{
    vec3 origin;
    vec3 direction;
};

struct SphereParms
{
    vec3 position;
    float radius;
    vec3 diffuseColor;
    int lightVisualizer;
   
    float receiveShadow;
    float shadowCasterIntensity;
    float reflectionIntensity;
   
};
 
struct PlaneParams
{
    vec3 pointOnPlane;
    vec3 normal;
    vec3 diffuseColor;
    
    float receiveShadow;
    float shadowCasterIntensity;
    float reflectionIntensity;
};

struct HitInfo
{
    vec3 position;
    vec3 normal;
    vec3 rayDir;
    float t;
    float dist;
    vec3 diffuseColor;
    
    float receiveShadow;
    float shadowCasterIntensity;
    float reflectionIntensity;
 
    int lightVisualizer;
   
    float primitiveType;
    float hit;
};
 
//--------------------------------------------------------------------------------------------
// End Region
//--------------------------------------------------------------------------------------------
 
//--------------------------------------------------------------------------------------------
// Begin Region: Global Variables
//--------------------------------------------------------------------------------------------
SphereParms spheres[MAX_SPHERES];
HitInfo sphereHitInfos[MAX_SPHERES];
PlaneParams planes[MAX_PLANES];
HitInfo planeHitInfos[MAX_PLANES];
vec3 lightPos;
//--------------------------------------------------------------------------------------------
// End Region
//--------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------
vec3 checkerBoardTexture( vec3 hitPos )
{
     vec2 p = floor( hitPos.xz * 1.0 );
     float s = mod( p.x + p.y, 2.0 );
     vec3 c = vec3( 0.4 ) * s;
     c = mix( c, vec3( 0.9 ), hitPos.z / 30.0 );
   
     return c;
}

//--------------------------------------------------------------------------------------------
void sphere( Ray ray, SphereParms sphereParams, inout HitInfo hitInfo )
{
    hitInfo.primitiveType = PrimitiveType_None;
    hitInfo.t = -1.0;
    hitInfo.hit = 0.0;
 
    vec3 newO = ray.origin - sphereParams.position;
    float b = 2.0 * dot( newO, ray.direction );
    float c = dot( newO, newO ) - (sphereParams.radius*sphereParams.radius);
 
    float h = b*b - (4.0*c);
    if( h < 0.0 ) return;
    float t = (-b - sqrt( h ) ) / 2.0;
 
    if ( t < Epsilon ) return;
    
    hitInfo.position = ray.origin + ray.direction * t;
    hitInfo.normal = normalize( ( hitInfo.position - sphereParams.position ) / sphereParams.radius );
    hitInfo.t = t;
    hitInfo.dist = length( hitInfo.position - ray.origin );
    hitInfo.rayDir = ray.direction;
    hitInfo.diffuseColor = sphereParams.diffuseColor;
    hitInfo.receiveShadow = sphereParams.receiveShadow;
    hitInfo.shadowCasterIntensity = sphereParams.shadowCasterIntensity;
    hitInfo.reflectionIntensity = sphereParams.reflectionIntensity;
    hitInfo.lightVisualizer = sphereParams.lightVisualizer;
    hitInfo.primitiveType = PrimitiveType_Sphere;
    hitInfo.hit = 1.0;
}

//--------------------------------------------------------------------------------------------
void plane( Ray ray, PlaneParams planeParams, inout HitInfo hitInfo )
{
    hitInfo.primitiveType = PrimitiveType_None;
    hitInfo.t = -1.0;
    hitInfo.hit = 0.0;
 
    float d = dot( planeParams.pointOnPlane, planeParams.normal );
    float t = ( d - dot( ray.origin, planeParams.normal ) ) / dot( ray.direction, planeParams.normal );
 
    if( t < 0.00 )
    {
        return;
    }
 
    hitInfo.position = ray.origin + ray.direction * t;
    hitInfo.normal = normalize( planeParams.normal );
    hitInfo.t = t;
    hitInfo.dist = length( hitInfo.position - ray.origin );
    hitInfo.rayDir = ray.direction;
    hitInfo.diffuseColor = planeParams.diffuseColor;
    hitInfo.receiveShadow = planeParams.receiveShadow;
    hitInfo.shadowCasterIntensity = planeParams.shadowCasterIntensity;
    hitInfo.reflectionIntensity = planeParams.reflectionIntensity;
    hitInfo.lightVisualizer = 0;
    hitInfo.primitiveType = PrimitiveType_Plane;
    hitInfo.hit = 1.0;
}

//--------------------------------------------------------------------------------------------
HitInfo intersect( Ray ray )
{
    HitInfo hitInfo;
    hitInfo.primitiveType = PrimitiveType_None;
    
    for( int i = 0; i < MAX_SPHERES; ++i )
    {
        
        sphere( ray, spheres[i], sphereHitInfos[i] );
       
        if( sphereHitInfos[i].primitiveType > PrimitiveType_None )
        {
            if(  sphereHitInfos[i].dist <  hitInfo.dist || hitInfo.primitiveType <= PrimitiveType_None )
            {
                hitInfo = sphereHitInfos[i];
            }
        }
    }
   
    for( int i = 0; i < MAX_PLANES; ++i )
    {
        
        plane( ray, planes[i], planeHitInfos[i] );
       
        if( planeHitInfos[i].primitiveType > PrimitiveType_None )
        {
            if(  planeHitInfos[i].dist <  hitInfo.dist || hitInfo.primitiveType <= PrimitiveType_None )
            {
                hitInfo.diffuseColor = planeHitInfos[i].diffuseColor;
                if( i == 0 || i == 4 )
                {
                    planeHitInfos[i].diffuseColor = checkerBoardTexture( planeHitInfos[i].position ) * planeHitInfos[i].diffuseColor;
                }

                hitInfo = planeHitInfos[i];
            }
        }
    }
    
    return hitInfo;
}

//--------------------------------------------------------------------------------------------
void onSetupScene()
{
    lightPos = vec3( 0.0, 8.0, 2.0 );
   
    // Light Visualizer
    spheres[0].position = lightPos;
    spheres[0].radius = 0.5;
    spheres[0].diffuseColor = vec3( 1.0, 1.0, 0.0 );
    spheres[0].shadowCasterIntensity = 1.0;
    spheres[0].lightVisualizer = 1;
    spheres[0].reflectionIntensity = 0.0;
   
    spheres[1].position = vec3( -5.0, 1.0, -3.0 );
    spheres[1].radius = 1.0;
    spheres[1].diffuseColor = vec3( 1.0, 1.4, 1.0 );
    spheres[1].shadowCasterIntensity = 0.5;
    spheres[1].reflectionIntensity = 0.0;
    
    spheres[2].position = vec3( 0.0, 1.0, 1.0 );
    spheres[2].radius = 1.0;
    spheres[2].diffuseColor = vec3( 1.0, 0.4, 1.0 );
    spheres[2].shadowCasterIntensity = 0.5;
    spheres[2].reflectionIntensity = 0.7;
    
    spheres[3].position = vec3( 5.0, 1.0, -3.0 );
    spheres[3].radius = 1.0;
    spheres[3].diffuseColor = vec3( 0.0, 1.0, 1.4 );
    spheres[3].shadowCasterIntensity = 0.5;
    spheres[3].reflectionIntensity = 0.0;
    
    planes[0].pointOnPlane = vec3( 0.0, 0.0, 0.0 );
    planes[0].normal = vec3( 0.0, 1.0, 0.0 );
    planes[0].diffuseColor = vec3( 0.8 );
    planes[0].shadowCasterIntensity = 1.0;
    planes[0].reflectionIntensity = 0.0;
    
    planes[1].pointOnPlane = vec3( -10.0, 0.0, 0.0 );
    planes[1].normal = vec3( 1.0, 0.0, 0.0 );
    planes[1].diffuseColor = vec3( 1.0, 0.0, 0.0 );
    planes[1].shadowCasterIntensity = 1.0;
    planes[1].reflectionIntensity = 0.0;
    
    planes[2].pointOnPlane = vec3( 10.0, 0.0, 0.0 );
    planes[2].normal = vec3( -1.0, 0.0, 0.0 );
    planes[2].diffuseColor = vec3( 0.0, 0.0, 1.0 );
    planes[2].shadowCasterIntensity = 1.0;
    planes[2].reflectionIntensity = 0.0;
    
    planes[3].pointOnPlane = vec3( 0.0, 0.0, -10.0 );
    planes[3].normal = vec3( 0.0, 0.0, 1.0 );
    planes[3].diffuseColor = vec3( 0.0, 1.0, 0.0 );
    planes[3].shadowCasterIntensity = 1.0;
    planes[3].reflectionIntensity = 0.0;
    
    planes[4].pointOnPlane = vec3( 0.0, 15.0, 0.0 );
    planes[4].normal = vec3( 0.0, -1.0, 0.0 );
    planes[4].diffuseColor = vec3( 0.0, 1.0, 1.0 );
    planes[4].shadowCasterIntensity = 1.0;
    planes[4].reflectionIntensity = 0.0;
    
    planes[5].pointOnPlane = vec3( 0.0, 0.0, 15.0 );
    planes[5].normal = vec3( 0.0, 0.0, -1.0 );
    planes[5].diffuseColor = vec3( 1.0, 1.0, 0.0 );
    planes[5].shadowCasterIntensity = 1.0;
    planes[5].reflectionIntensity = 0.0;
}

//--------------------------------------------------------------------------------------------
void onAnimateScene()
{
    float animationTime = TimeValue * 0.5;
 
    float radius = 5.0;
    //lightPos = vec3( 0.0, 8.0, 2.0 ) + vec3(cos(animationTime)*radius, cos(animationTime)*6.0, sin(animationTime)*radius);
    
	lightPos = vec3( 0.0, 10.0, 9.0 );
	
    spheres[0].position = lightPos;
    
    spheres[2].position.x += sin( animationTime * 1.0 ) * 3.0;
    spheres[2].position.y += abs( sin( animationTime * 4.0 ) * 4.0 );
    spheres[2].position.z += sin( cos( animationTime)  *    3.0 ) * 2.0;
}

//--------------------------------------------------------------------------------------------
vec3 calculateReflection( vec3 currentPixelColor, vec3 viewDir, HitInfo hitInfo )
{    
     Ray reflectionRay;
     reflectionRay.direction = normalize( reflect( hitInfo.rayDir, hitInfo.normal ) );
     reflectionRay.origin = hitInfo.position + hitInfo.normal * Epsilon;
    
     HitInfo rHitInfo = intersect( reflectionRay );
     currentPixelColor += ( rHitInfo.diffuseColor * hitInfo.reflectionIntensity );
    
    
     return currentPixelColor;
}
//--------------------------------------------------------------------------------------------
vec3 calculateShadow( vec3 currentPixelColor, vec3 lightDir, HitInfo hitInfo )
{
    Ray shadowRay;
    shadowRay.direction = normalize( lightDir );
    shadowRay.origin = hitInfo.position + (shadowRay.direction * Epsilon);
    HitInfo shadowHitInfo = intersect( shadowRay );
    currentPixelColor *= clamp( shadowHitInfo.shadowCasterIntensity, 0.00, 1.0 );
    
    return currentPixelColor;
}

//--------------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 mouse=(MouseValue.xy / ResolutionValue.xy - 0.5) * 3.0;
  
    vec2 uv = fragCoord.xy / ResolutionValue.x;
    vec2 uvp = (uv * 2.0 - 1.0) + mouse;
 
    Ray ray;
    ray.origin = vec3( 0.0, 5.0, 10.0 );
    ray.direction = normalize( vec3( uvp, -1.0 ) );
 
    onSetupScene();
    onAnimateScene();
 
    HitInfo hitInfo = intersect( ray );
 
    vec3 c = vec3( 0.9 );
    if( hitInfo.primitiveType <= PrimitiveType_None )
    {
        fragColor = vec4( c, 1.0 );
        return;
    }

    vec3 lightDir = normalize( lightPos - hitInfo.position );
    // Calculate Lighting
    float dif = clamp( dot( hitInfo.normal, lightDir ), 0.00, 1.00 );
    vec3 reflectionVector = normalize( reflect( lightDir, hitInfo.normal ) );
    vec3 cameraToSurface = ray.direction;
    float spec = pow( clamp( dot( reflectionVector, cameraToSurface ), 0.00, 1.0 ), 10.0 );
    c = calculateReflection( hitInfo.diffuseColor, ray.direction, hitInfo ) * dif + vec3( 0.5 ) * spec;
   
    c = calculateShadow( c, lightDir, hitInfo );
   
    fragColor = vec4( c, 1.0 );
}
