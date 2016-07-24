// Shader downloaded from https://www.shadertoy.com/view/ltSSRd
// written by shadertoy user ValXp
//
// Name: Sub
// Description: Just my subwoofer.
#define MAX_ITERATIONS 80.0
#define MAX_RAY_DISTANCE 30.0
#define M_PI 3.1415926535897932384626433832795

#define LOW_FREQUENCY 20.0
#define LOW_LIMIT 0.5

//#define JUST_BEATS

vec3 lightPosition;
mat4 rotation;
mat4 coneRotation;
vec3 diffuseColor = vec3(0.9, 0.02, 0.05);
vec3 specularColor = vec3(0.1, 0.3, 0.6);
vec3 ambientColor = vec3(0.01, 0.01, 0.01);
float shininess = 20.0;
float screenGamma = 2.2;

mat4 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           -5.0,
                0.0,                                0.0,                                0.0,                                1.0);
}


// polynomial smooth min (k = 0.1);
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}


vec2 matMin(vec2 left, vec2 right)
{
    return left.x > right.x ? right : left;
}


// Distance field equation for a sphere.
float sphereDist(vec3 position, float radius)
{
    return length(position) - radius;
}

float coneDist( vec3 position, vec2 cone )
{
    // c must be normalized
    float q = length(position.xy);
    return dot(cone,vec2(q,position.z));
}

float sdCappedCone( in vec3 position, in vec3 cone )
{
    vec2 q = vec2( length(position.xz), position.y );
    vec2 v = vec2( cone.z*cone.y/cone.x, -cone.z );
    vec2 w = v - q;
    vec2 vv = vec2( dot(v,v), v.x*v.x );
    vec2 qv = vec2( dot(v,w), v.x*w.x );
    vec2 d = max(qv,0.0)*qv/vv;
    return sqrt( dot(w,w) - max(d.x,d.y) )* sign(max(q.y*v.x-q.x*v.y,w.y));
}

float sdTorus( vec3 position, vec2 torus )
{
  vec2 q = vec2(length(position.xz)-torus.x,position.y);
  return length(q)-torus.y;
}

float udRoundBox( vec3 position, vec3 box, float radius )
{
  return length(max(abs(position)-box,0.0))-radius;
}

float sdCappedCylinder( vec3 position, vec2 cylinder )
{
  vec2 d = abs(vec2(length(position.xz),position.y)) - cylinder;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

// Distance field.
// Takes a 3D position and gives the distance value in the field.
vec2 map(vec3 position)
{
    position.z -= 10.0;
    position = (rotation * vec4(position, 0.0)).xyz;

    vec3 boxPosition = position;
    boxPosition.z -= 1.3;
    float box = udRoundBox(boxPosition, vec3(4.0, 5.0, 3.0), 0.5);
    
    vec3 holesPosition = (coneRotation * vec4(position, 0.0)).xyz;
    holesPosition.z -= 3.5;
    holesPosition.x += 2.5;
    float hole1 = sdCappedCylinder(holesPosition, vec2(1.0, 4.0));
    
    float holes;
    vec3 torusPosition = holesPosition;
    torusPosition.y += 2.15;
    float hole1Entrance = sdTorus(torusPosition, vec2(1.0, 0.1));
    float hole1Tube = sdCappedCylinder(holesPosition, vec2(0.95, 2.2));
    float hole1TubeHole = sdCappedCylinder(holesPosition, vec2(0.85, 3));
    
    holes = smin(hole1Entrance, max(hole1Tube, -hole1TubeHole), 0.2);
    
    holesPosition.x -= 5.0;
    float hole2 = sdCappedCylinder(holesPosition, vec2(1.0, 4.0));
    box = max(max(box, -hole1), -hole2);
    
    torusPosition = holesPosition;
    torusPosition.y += 2.15;
    float hole2Entrance = sdTorus(torusPosition, vec2(1.0, 0.1));
    float hole2Tube = sdCappedCylinder(holesPosition, vec2(0.95, 2.2));
    float hole2TubeHole = sdCappedCylinder(holesPosition, vec2(0.85, 3));
    
    holes = min(holes, smin(hole2Entrance, max(hole2Tube, -hole2TubeHole), 0.2));
    
    
    boxPosition.z += 0.2;
    boxPosition.y -= 1.0;
    boxPosition = (coneRotation * vec4(boxPosition, 0.0)).xyz;
    float coneNeg = sdCappedCone(boxPosition, vec3(0.5, 0.5, 4.0));
    box = max(box, -coneNeg);
    
    position.y -= 1.0;
    float value = texture2D( iChannel0, vec2( 0.001, 0.25 ) ).x / 2.0;
#ifdef JUST_BEATS
    position.z += value;
#else
    float rawWave = sin(LOW_FREQUENCY * 2.0 * M_PI * iChannelTime[0]);
	float wave = rawWave * LOW_LIMIT * 0.5 + 0.5;
	position.z += clamp(wave * value, 0.0, 1.0);
#endif
    
    float centerSphere = sphereDist(position, 1.3);
    position.z -= 1.0;
    position = (coneRotation * vec4(position, 0.0)).xyz;
    
    float cone = sdCappedCone(position, vec3(0.5, 0.5, 3.0));
    position.y += 0.1;
    float coneNegative = sdCappedCone(position, vec3(0.5, 0.5, 3.0));
    cone = max(cone, -coneNegative);
    
    position.y += 2.8;
	float torus = sdTorus(position, vec2(3.0, 0.3));
	cone = min(cone, torus);
    
    
    return matMin(vec2(min(smin(centerSphere, cone, 0.2), holes), 1.0), vec2(box, 2.0));
}

float mapf(vec3 position)
{
    return map(position).x;
}

// Ray marching.
// Given a start point and a direction. Sample the distance field until collision with an object.
// Return this 3D collision point.
vec4 rayMarch(vec3 start, vec3 direction)
{
    float rayPrecision = 0.008;
    float rayLength = 0.0;
    vec3 intersection = vec3(0.0);
    float material = 0.0;
    for (float i = 0.0; i < MAX_ITERATIONS; i++)
    {
        vec3 intersection = start + (direction * rayLength);
        vec2 ret = map(intersection);
        // ret.x -> Distance. ret.y -> material
        if (abs(ret.x) < rayPrecision)
            return vec4(intersection, ret.y);
        if (ret.x > MAX_RAY_DISTANCE)
            return vec4(0.0);
        rayLength += ret.x * .85;
        material = ret.y;
    }
    return vec4(intersection, material);
}


// Calculate normal of a point.
// Samples the distance field to find the direction at which the distance increases in 3D space.
vec3 calcNormal(vec3 point)
{
    vec3 delta = vec3(0.001, 0.001, 0.001);
    float x0 = mapf(point);
    float xn = mapf(vec3(point.x + delta.x, point.yz)) - x0;//mapf(vec3(point.x - delta.x, point.yz));
    float yn = mapf(vec3(point.x, point.y + delta.y, point.z)) - x0;//mapf(vec3(point.x, point.y - delta.y, point.z));   
    float zn = mapf(vec3(point.xy, point.z + delta.z)) - x0;//mapf(vec3(point.xy, point.z - delta.z));
    return normalize(vec3(xn, yn, zn));
}

// Simple shading function
vec4 shade(vec4 intersection)
{
    vec3 point = intersection.xyz;
    vec3 normal = calcNormal(point);
    vec3 lightDir = normalize(lightPosition - point);
    
    float lambertian = max(dot(lightDir, normal), 0.0);
    float specular = 0.0;
    
    if (lambertian > 0.0)
    {
        vec3 viewDir = normalize(-point);
        
        vec3 halfDir = normalize(lightDir + viewDir);
        float specAngle = max(dot(halfDir, normal), 0.0);
        specular = pow(specAngle, shininess);
    }
    
    vec3 diffuse = vec3(0.0);
    if (intersection.a == 2.0) // box
    {
        diffuse = diffuseColor;
        diffuse = texture2D(iChannel1, vec2(intersection.x / 4.0, intersection.y / 4.0)).xyz * 0.6;
    } else if (intersection.a == 1.0) // Woofer
    {
        diffuse = vec3(0.02, 0.02, 0.02);
        specular /= 10.0;
    }
    
    vec3 colorLinear = ambientColor;
    colorLinear += specular * specularColor;
    colorLinear += lambertian * diffuse;
      
    return vec4(colorLinear, 1.0);
}
                     
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    lightPosition = vec3(5.0 * sin(iGlobalTime/2.0), 1.0 * sin(iGlobalTime*4.0), 5.0 * cos(iGlobalTime/2.0));
    rotation = rotationMatrix(vec3(0.0, 1.0, 0.0), cos(5.0 + (iMouse.x / iResolution.x) * 6.3));
    coneRotation = rotationMatrix(vec3(1.0, 0.0, 0.0), M_PI / 2.0);
    
    float screenZ = 3.0;
    vec2 screenUV = fragCoord.xy / iResolution.xy;
    screenUV.x *= iResolution.x/iResolution.y;
    
    vec3 eye = vec3(1.0, 0.5, 2.6);
	vec3 pixelLoc = vec3(screenUV, screenZ);
    
    vec3 ray = normalize(pixelLoc - eye);
    vec4 intersection = rayMarch(pixelLoc, ray);
    
    fragColor = vec4(ambientColor, 1.0);
    if (intersection.xyz != vec3(0.0)) {
    	//float depth = (intersection.z-3.0)/5.0;
    	//fragColor = vec4(depth, depth, 0.0, 1.0);
        //fragColor = vec4(calcNormal(intersection.xyz), 1.0);
        
        fragColor = shade(intersection);
    }
    fragColor = vec4(pow(fragColor.xyz, vec3(1.0 / screenGamma)), 1.0);
}
