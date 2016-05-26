// Shader downloaded from https://www.shadertoy.com/view/ltj3Ww
// written by shadertoy user citruslee
//
// Name: LRSK - Lame Raymarch Scene Kit
// Description: I got fed up with the awkward math where positive direction from camera was a negative number, also juggling with operators and ugly one liners with millions of unite operators. So this framework is the result.
/************************************************************************************************

	By citrus, Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

    I got fed up with the awkward math where positive direction 
    from camera was a negative number, also juggling with operators 
    and ugly one liners with millions of unite operators. So this 
    framework is the result.

	Addendum: This is just an experiment to achieve some kind of easier scene construction
			  and I DO NOT TAKE RESPONSIBILITY for this shader. Use it freely tho, but it is
			  slow as hell and a very lame framework yet. Will update it over time. 

			  Any help or insight is well appreciated!

			  
     21/04/2015:
     - published

     22/04/2015:
     - Camera on mouse move from on musk's shader 
	   https://www.shadertoy.com/view/lds3RX - Spheres/Plane
	 
	 - Basic scenegraph structures

	 23/04/2015:
     - Based on iq's insight, I moved the shading from the 
	   raymarch into the main function, now it should perform better


************************************************************************************************/

//The for loop loop count (heh)
#define EVALCNT 40.0
//The constant when we hit the surface
#define AEPSILON 0.01
//shiny!
#define CORNFLOWERBLUE vec4(0.392157, 0.584314, 0.929412, 1.0);

//object type constants
//TODO: Write constants also for the shading types
#define OBJ_SPHERE 1
#define OBJ_BOX 2
#define OBJ_CONE 3

//TODO!!!!!!!!!!!!!!: Object params should be added to this!!!
//TODO2: Rotations!
//TODO3: Scaling!
//TODO4: Operators! (Bend, displace)
//MAYBE-TODO: Texture ID-s
struct Object
{
    vec3 pos;		//the object position in 3D
	int type;		//the object type (e.g.: box, cone, blah, blah)
    int material;	//the material used to render this object
};

//this is just an unverified theory and a preparation for implementation
struct Leaf
{

    int command; 	//union, substract, intersect, none...
    Object object;	//the primitive to draw to
};
    
struct Trunk
{
    int isRootLeaf; //0 if not and 1 if yes
    int childCount;	//if 0, then it is a single object in the scenegraph
    Leaf parent[10];	//the parent leaf in the hierarchy...on the first depth level should give the root
    Leaf sibling[10];	//"pointer" to the next leaf on the same depth
    Leaf child[10];		//child leaves are the sub-branches
};
    
struct Scenegraph
{
 	int objectCount;
    int lightCount;
    
    Trunk root;
};

//Yeah, I ripped these functions from iq...sorry but thanks :)
float sdSphere(vec3 p, float s)
{
    return length(p) - s;
}

float sdBox(vec3 p, vec3 b)
{
  vec3 d = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)),0.0) + length(max(d, 0.0));
}

float sdCone(in vec3 p, in vec3 c)
{
    vec2 q = vec2(length(p.xz), p.y );
#if 0
	return max(max(dot(q, c.xy), p.y), -p.y - c.z );
#else
    float d1 = -p.y - c.z;
    float d2 = max(dot(q, c.xy), p.y);
    return length(max(vec2(d1, d2), 0.0)) + min(max(d1, d2), 0.);
#endif    
}

float opS( float d1, float d2 )
{
    return max(-d2,d1);
}

vec2 opU( vec2 d1, vec2 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}

//This function is called on every object, getting the object type and rendering it to it's position.
//TODO: Fix the hardcoded stuff like object parameters
float traceObject(vec3 pos, Object obj)
{
    if(obj.type == OBJ_SPHERE)
	{
        return sdSphere(pos - obj.pos, 1.0);
    }
    else if(obj.type == OBJ_BOX)
	{
        return sdBox(pos - obj.pos, vec3(1.0));
    }
    else if(obj.type == OBJ_CONE)
	{
        return sdCone(pos - obj.pos, vec3(1.8, 1.6, 1.0)) * 0.5;	//without the multiplication
        															//the object looks pretty bugged
    }
    else
    {
     	return 0.0;   
    }
}

#define OBJCNT 3

//Here is the whole scene setup via the Object struct
//Every object is then rendered by a for loop, but you must specify the max OBJCNT above
vec2 scene(vec3 pos)
{
    Object object[OBJCNT];
    object[0].pos = vec3(0.0, 0.0, 1.0);
    object[0].type = OBJ_SPHERE;
    object[0].material = 2;
    
    object[1].pos = vec3(-1.0, 1.0, 2.0);
    object[1].type = OBJ_BOX;
    object[1].material = 2;
    
    object[2].pos = vec3(2.0, 1.0, 2.0);
    object[2].type = OBJ_CONE;
    object[2].material = 2;
    
    vec2 result = vec2(0.0);
    for(int i = 0; i < OBJCNT; i++)
    {
        if(i == 0)
        {
            result = vec2(traceObject(pos, object[i]), object[i].material);   
        }
    	else
    	{
			result = opU(vec2(traceObject(pos, object[i]), object[i].material), result);
    	}
    }
 	return result;   
}

vec3 sceneNormal(vec3 pos)
{
	float distancePoint = scene(pos).x;
    float aepsilon = 0.01;
    float x = scene(pos + vec3(AEPSILON, 0.0, 0.0)).x;
    float y = scene(pos + vec3(0.0, AEPSILON, 0.0)).x;
    float z = scene(pos + vec3(0.0, 0.0, AEPSILON)).x;
	return normalize(vec3(x - distancePoint, y - distancePoint, z -distancePoint));
}

// brdf
vec3 brdf(vec3 normal, vec3 lightDist, vec3 viewDir, float roughness, vec3 diffuseReflectance, vec3 specularReflectance, vec3 lightIntensity) 
{
	vec3 halfvec = normalize(lightDist + viewDir );
	
	float dotNH = max(dot(normal, halfvec), 0.0);
	float dotNV = max(dot(normal, viewDir), 0.0);
	float dotNL = max(dot(normal, lightDist), 0.0);
	float dotH   = max(dot(halfvec, viewDir), 0.0);
	
	float g = 2.0 * dotNH / dotH;
	float G = min(min(dotNV, dotNL) * g, 1.0);

	float squareNH   = dotNH * dotNH;
	float squaredNHM = squareNH * (roughness * roughness);
	float D = exp((squareNH - 1.0) / squaredNHM) / (squareNH * squaredNHM);
	
	vec3 fresnelSpecular = specularReflectance + (1.0  - specularReflectance) * pow(1.0 - dotH  , 5.0);
	vec3 fresnelDiffuse = specularReflectance + (1.0  - specularReflectance) * pow(1.0 - dotNL, 5.0);
	
	vec3 brdfSpecular = fresnelSpecular * D * G / ( dotNV * dotNL * 4.0 );
	vec3 brdfDiffuse = diffuseReflectance * (1.0 - fresnelDiffuse);
	return (brdfSpecular + brdfDiffuse) * lightIntensity * dotNL;	
}

//a lame, I think phong lightning, will be modified
vec4 phong(vec3 pos)
{
	vec3 normals = sceneNormal(pos);
        
    vec3 dirToLight = vec3(-1.0, 1.0, 0.0);
	vec4 lightIntensity = vec4(1.0, 1.0, 1.0, 1.0);
    vec3 normCamSpace = normalize(normals);
    
    float cosAngIncidence = dot(normCamSpace, dirToLight);
    cosAngIncidence = clamp(cosAngIncidence, 0.0, 1.0);
    
    return lightIntensity * cosAngIncidence;
}

//Remarks: vec.x component will be used for normals
//		   vec.y component is the material in use with the object
//
//			I think, maybe vec.z could be used for texture selection
vec4 shade(vec2 shadinginfo, vec3 pos, vec3 eye)
{
	if(shadinginfo.y == 0.0)
    {
     	return phong(pos);	//flat shade   
    }
    else if(shadinginfo.y == 1.0)
    {
     	return phong(pos);	//non-flat shade   
    }
    else if(shadinginfo.y == 2.0)
    {
     	return phong(pos);	//non-non-flat shade   
    }
    else
    {
     	return CORNFLOWERBLUE;   //whatever
    }
}

vec2 raymarch(inout vec3 pos, inout vec3 dir)
{
    vec2 result;	//the scene is contained in this variable
    
    for(float i = 0.0; i < EVALCNT; i++)
    {
        result = scene(pos);
        pos += dir * result.x;
        if(result.x < AEPSILON)
        {
            return result;
        }
    }
 	return vec2(99999.0, 99999.0);   //here should be some sky color computations, but now, I cannot do such
    						 //thing with my n00b ass...nonetheless, cornflower blue rulz
}

vec3 rotate_z(vec3 v, float angle)
{
	float ca = cos(angle); float sa = sin(angle);
	return v*mat3(
		+ca, -sa, +.0,
		+sa, +ca, +.0,
		+.0, +.0,+1.0);
}

vec3 rotate_y(vec3 v, float angle)
{
	float ca = cos(angle); float sa = sin(angle);
	return v*mat3(
		+ca, +.0, -sa,
		+.0,+1.0, +.0,
		+sa, +.0, +ca);
}

vec3 rotate_x(vec3 v, float angle)
{
	float ca = cos(angle); float sa = sin(angle);
	return v*mat3(
		+1.0, +.0, +.0,
		+.0, +ca, -sa,
		+.0, +sa, +ca);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy - 0.5;
	uv.x *= iResolution.x / iResolution.y; //fix aspect ratio
	vec3 mouse = vec3(iMouse.xy / iResolution.xy - 0.5, iMouse.z - .5);
	
	float t = iGlobalTime * .5 * 0.0 + 30.0;
	mouse += vec3(sin(t) * .05, sin(t) * .01, .0);
	
	float offs0 = 5.0;
	float offs1 = 1.0;
	
	//setup the camera
	vec3 p = vec3(0, 0.0, -1.0);
	p = rotate_x(p, mouse.y * 9.0 + offs0);
	p = rotate_y(p, mouse.x * 9.0 + offs1);
	p *= (abs(p.y * 2.0 + 1.0) + 1.0);
	vec3 d = vec3(uv, 1.0);
	d.z -= length(d) * .6; //lens distort
	d = normalize(d);
	d = rotate_x(d, mouse.y * 9.0 + offs0);
	d = rotate_y(d, mouse.x*9.0 + offs1);
   	vec2 result = raymarch(p, d);
    
    if(result.y == 99999.0)
    {
        fragColor = CORNFLOWERBLUE;
    }
    else
    {
		fragColor = shade(result, p, d);
    }
}