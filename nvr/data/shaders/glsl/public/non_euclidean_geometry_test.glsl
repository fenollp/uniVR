// Shader downloaded from https://www.shadertoy.com/view/4llSWf
// written by shadertoy user Flyguy
//
// Name: Non-Euclidean Geometry Test
// Description: Testing non-euclidean geometry in a distance field ray marcher.
//    Mostly fixed artifacts by scaling the map and ray origin upon entering the &quot;warp zone&quot; instead of speeding up rays.
#define MIN_DIST 0.0005
#define MAX_DIST 64.0
#define MAX_STEPS 128
#define STEP_MULT 0.4
#define NORMAL_OFFS 0.02

//#define DISABLE_WARP
//#define HIDE_BOX

float pi = atan(1.0)*4.0;
float tau = atan(1.0)*8.0;

//Returns a rotation matrix for the given angles around the X,Y,Z axes.
mat3 Rotate(vec3 angles)
{
    vec3 c = cos(angles);
    vec3 s = sin(angles);
    
    mat3 rotX = mat3( 1.0, 0.0, 0.0, 0.0,c.x,s.x, 0.0,-s.x, c.x);
    mat3 rotY = mat3( c.y, 0.0,-s.y, 0.0,1.0,0.0, s.y, 0.0, c.y);
    mat3 rotZ = mat3( c.z, s.z, 0.0,-s.z,c.z,0.0, 0.0, 0.0, 1.0);

    return rotX*rotY*rotZ;
}

//==== Distance field operators/functions by iq. ====
float opU( float d1, float d2 )
{
    return min(d1,d2);
}

float opS( float d1, float d2 )
{
    return max(-d1,d2);
}

float opI( float d1, float d2 )
{
    return max(d1,d2);
}

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdPlane( vec3 p, vec3 n )
{
  return dot(p, normalize(n));
}

float sdBox(vec3 p, vec3 s)
{
    p = abs(p) - s / 2.0;
    return max(max(p.x,p.y),p.z);
}
//===================================================

vec3 scale = vec3(1,1,1);

//Defines the volume in which rays will speed up/slow down.
float Warp(vec3 p)
{
    return sdBox(p + vec3(0,0,0.5), vec3(3.0,1.5,0.75));
}

float Scene(vec3 p)
{
    float d = 1000.0;
    
    p *= scale;
    
    d = opU(d, -sdPlane(p, vec3(0,0,1)));
    
    #ifndef HIDE_BOX
    d = opU(d, sdBox(p,vec3(3,2,2)));
    d = opS(sdBox(p + vec3(0,0,0.5), vec3(4,1.5,0.75)), d);
    #endif
    
    d = opU(d, sdSphere(p + vec3(2,0,0.5),0.25));
    d = opU(d, sdBox(p + vec3(-2,0,0.5), vec3(0.5,0.5,0.5)));
    
    d = opU(d, -sdSphere(p,32.0));
    
	return d;
}

float MarchWarp(vec3 origin,vec3 dir)
{
    float dist = 0.0;
    
    for(int i = 0;i < MAX_STEPS;i++)
    {
        float sceneDist = Warp(origin + dir * dist);
        
        dist += sceneDist * STEP_MULT;
        
        if(abs(sceneDist) < MIN_DIST || sceneDist > MAX_DIST)
        {
            break;
        }
    } 
    return dist;
}

vec3 MarchRay(vec3 origin,vec3 dir)
{
    bool inWarp = false;
    
    float dist = 0.0;
    
    //Distance to the "warp zone".
    float warpDist = MarchWarp(origin,dir);
    
    for(int i = 0;i < MAX_STEPS;i++)
    {
        float sceneDist = Scene(origin + dir * dist);
        
        //Reset the march distance, set the ray origin to the surface of the "warp zone", scale the map and ray origin.
        #ifndef DISABLE_WARP
        if(warpDist < dist && !inWarp)
    	{
            scale.x = 4.0;
            
            dist = 0.0;
            origin = origin + dir * warpDist;
            origin /= scale;
            
            inWarp = true;
    	}
        #endif
        
        dist += sceneDist * STEP_MULT;
        
        if(abs(sceneDist) < MIN_DIST || sceneDist > MAX_DIST)
        {
            if(sceneDist < 0.0)
            {
                dist += MIN_DIST;
            }
            
            break;
        }
    }
    
    return origin + dir * dist;
}

vec3 Normal(vec3 p)
{
    vec3 off = vec3(NORMAL_OFFS,0,0);
    return normalize
    ( 
        vec3
        (
            Scene(p+off.xyz) - Scene(p-off.xyz),
            Scene(p+off.zxy) - Scene(p-off.zxy),
            Scene(p+off.yzx) - Scene(p-off.yzx)
        )
    );
}

vec3 Shade(vec3 position, vec3 normal, vec3 direction, vec3 camera)
{
    position *= scale;
    vec3 color = vec3(1.0);
    
    color = color * 0.75 + 0.25;
    
    color *= normal * .25 + .75;
    
    float checker = sin(position.x * pi * 4.0) * sin(position.y * pi * 4.0) * sin(position.z * pi * 4.0);
    
    color *= step(0.0,checker) * 0.25 + 0.75;
    
    float ambient = 0.1;
    float diffuse = 0.5 * -dot(normal,direction);
    float specular = 1.0 * max(0.0, -dot(direction, reflect(direction,normal)));
    
    color *= vec3(ambient + diffuse + pow(specular,5.0));

    color *= smoothstep(12.0,6.0,length(position));
    
    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.y;
    
    vec3 angles = vec3(0);
    
    
    if(iMouse.xy == vec2(0))
    {
    	angles = vec3(iGlobalTime * 0.2, 1.3, 0.0);
    }
    else
    {
    	angles = vec3((iMouse.xy/iResolution.xy)*pi,0);
    }
    
    angles.xy *= vec2(2.0,1.0);
    angles.y = clamp(angles.y,-tau/4.0, 1.5);
    
    mat3 rotate = Rotate(angles.yzx);
    
    vec3 orig = vec3(0,0,-3) * rotate;
    vec3 dir = normalize(vec3(uv - res/2.0,0.5)) * rotate;
    
    vec3 hit = MarchRay(orig,dir);
    vec3 norm = Normal(hit);
    
    vec3 color = Shade(hit,norm,dir,orig);
    
	fragColor = vec4(color,1.0);
}