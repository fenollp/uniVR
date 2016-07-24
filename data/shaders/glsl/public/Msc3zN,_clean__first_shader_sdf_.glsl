// Shader downloaded from https://www.shadertoy.com/view/Msc3zN
// written by shadertoy user sagarpatel
//
// Name: (CLEAN) first shader/sdf 
// Description: This is a clean/from scratch re-implementation of my first shdaer/sdf, which was based on @cabbibo's awesome SDF tutorial and iq's Raymarching Primitives.
//    Tons of comments explaining how I derived stuff.
// CC0 1.0
// @sagzorz

// NOTE: if you are new to SDFs, do @cabbibo's tutorial first!!!
// 
// @cabbibo's original SDF tutorial --> https://www.shadertoy.com/view/Xl2XWt
// my original hacked up shader --> https://www.shadertoy.com/view/4d33z4

// this is a clean/from scratch re-implementation of my first shdaer/sdf,
// which was based on @cabbibo's awesome SDF tutorial
// also used functions from iq's super handy page about distance functions
// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
// resstructured to be closer to iq's Raymarching Primitives example
// https://www.shadertoy.com/view/Xds3zN

// NOW PROPERLY MARCHING THE RAY!
// (was using silly hack in original version to compensate for twist artifacts)
// Performs much better than old version

// the sd functions below are the same as from iq's page (link above)
// though when I wrote this version I derived from scratch as much as I could on my own 
// by thinking/sketching on paper etc. 
// The comments explain my interpretation of the funcs

// for all signed distance functions sd*() below,
// input p --> is ray position, where the object is at the origin (0,0,0)
// output float is distance from ray position to surface of sphere
// 	positive means outside of sphere
// 	negative means ray is inside
// 	0 means its exactly on the surface


// ~~~~~~~ signed fistance fuction for sphere
// input r --> is sphere radius
// pretty simple, just compare point to radius of sphere
float sdSphere(vec3 p, float r)
{
    return length(p) - r;
}

// ~~~~~~~ signed distance function for box
// input s -- > is box size vector (all postive values)
//
// the key to simply calcualting distance to surface to box is to first 
// force the ray position into the first octant (all positive values)
// this massively simplifies the math and is ok since distance to surf
// on a box is the same in the - or + direction on a given axis
// simple to figure by once you sketch out 2D equivalent problem on papaer
// 2D ex: distance to box of size (2,1) 
// for p of (-3,-2) == (-3, 2) == (3, -2) == (3, 2)
//
// now that all the coordinates are "normalized"/positive, its much easier,
// the next part is to figure out the diff between the box surface the and p
// a bit like the sphere function were you do p - "shape size", but
// you clamp the result to >0, done below by using max() with 0
// i'm having trouble putting this into words corretcly, but it was really easy
// to understand once I sketched out a rect and points on paper, 
// that was enough for me to be able to derive the 3D version 
//
// the last part is to account for is p is insde the box, 
// in which case we need to return a negative value
// for that value, its a simple check of which side is the closest
float sdBox(vec3 p, vec3 s)
{
    vec3 diffVec = abs(p) - s;
    float surfDiff_Outter = length(max(diffVec,0.0));
    float surfDiff_Inner = min( max(diffVec.z,max(diffVec.x,diffVec.y)),0.0);
    return surfDiff_Outter + surfDiff_Inner;              
}
/*
// Minimial IQ version
float sdBox( vec3 p, vec3 s )
{
  vec3 d = abs(p) - s;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}
*/

// ~~~~~~~ signed distance function for torus
// input t --> torus specs where:
// 	t.x = torus circumference
//	t.y = torus thickness
//  
// think of the torus as circles wrappeed around 1 large cicle (perpendicular)
// first flatten the y axis of p (by using p.xz) and get the distance to 
// the torus circumference/core/radius which is flat on the y axis
// then simply subtract the torus thickenss from that 
float sdTorus(vec3 p, vec2 t)
{
    float distPtoTorusCircumference = length(vec2( length(p.xz)-t.x , p.y));
    return distPtoTorusCircumference - t.y;
}
/*
// IQ version
float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

*/

// ~~~~~~~ smooth minimum function (polynomial version) from iq's page
// http://iquilezles.org/www/articles/smin/smin.htm
// input d1 --> distance value of object a
// input d1 --> distance value of object b
// output --> smoothed/blended output
float smin( float d1, float d2)
{
    float k = 0.6521;
    float h = clamp( 0.5+0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h);
}

// ~~~~~~~ distance deformation, blends 2 shapes based on their distances
// input d1 --> distance of object 1
// input d2 --> distance of object 2
// output --> blended object
float opBlend( float d1, float d2)
{    
    return smin( d1, d2 );
}

// ~~~~~~~ domain deformation, twists the shape
// input p --> original ray position
// input t --> twist scale factor
// output --> twisted ray position
// 
// need more max itterations on ray march for stronger/bigger domain deformation
vec3 opTwist( vec3 p, float t, float yaw )
{
    float  c = cos(t * p.y + yaw);
    float  s = sin(t * p.y + yaw);
    mat2   m = mat2(c,-s,s,c);
    return vec3(m*p.xz,p.y);
}

// ~~~~~~~ do Union / combine 2 sd objects
// input vec2 --> .x is the distance, .y is the object ID
// returns the closest object (basically does a min() but we use if() 
vec2 opU(vec2 o1, vec2 o2)
{
    if(o1.x < o2.x)
        return o1;
    else 
        return o2;
}

// ~~~~~~~ map out the world
// input p --> is ray position
// basically find the object/point closest to the ray by
// checking all the objects with respect to p
// move objects/shapes by messing with p
vec2 map(vec3 p)
{
    // results container
    vec2 res;    
    
    // define objects
    	// sphere 1
    	// sphere: radius, orbit radius, orbit speed, orbit offset, position
    float sR = 1.359997;
    float sOR = 2.666662;
    float sOS = 0.85;
    vec3 sOO = vec3(2.66662,0.0,0.0);
    vec3 sP = p - (sOO + vec3(sOR*cos(sOS*iGlobalTime),sOR*sin(sOS*iGlobalTime),0.0));
    vec2 sphere_1 = vec2( sdSphere(sP,sR), 1.0 );
		
    	//	torus 1    
    vec2 torusSpecs = vec2(1.6, 0.613333);
    float twistSpeed = 0.35;
    float twistPower = 5.0*sin(twistSpeed * iGlobalTime);
    	// to twist the torus (or any object), we actually distort p/space (domain) itself,
    	// this then gives us a distorted view of the object
    vec3 torusPos = vec3(0.0);
    vec3 distortedP = opTwist(p - torusPos, twistPower, 0.0) ;
        // 	domain distortion correction:
        // 	needed to find this by hand, inversely proportional to domain deformation
    float ddc = 0.25;
    vec2 torus_1 = vec2(ddc * sdTorus(distortedP, torusSpecs), 2.0);
    
    // combine and blend objects
    res = opU( sphere_1, torus_1 );
    res.x = opBlend( sphere_1.x, torus_1.x );    
    //res.x = torus_1.x;
    
    return res;
}

// ~~~~~~~ cast/march ray through the word and see what it hits
// input ro --> ray origin point/position
// input rd --> ray direction
// output is vec2 where
// 	.x = distance travelled by ray
// .y = hit object's ID
//
vec2 castRay( vec3 ro, vec3 rd)
{
	// variables used to control the marching process
    const int maxMarchCount = 300;
    float maxRayDistance = 20.0;
    float minPrecisionCheck = 0.001;
    
    float t = 0.0; // travelled distance by ray
    float id = -1.0; // object ID, default of -1 means background
    
    for(int i = 0; i < maxMarchCount; i++)
    {
        // get closest object to current ray position
        vec2 res = map(ro + rd*t);
        
        // stop itterating/marching once either we've past max ray length 
        // or
        // once we're close enough to an object (defined by the precision check variable)
       	if(t > maxRayDistance || res.x < minPrecisionCheck)
           break;
        
        // move ray forward by distance to closet object, see
        // http://http.developer.nvidia.com/GPUGems2/elementLinks/08_displacement_05.jpg
        t += res.x; 
        id = res.y;
    }
    
    // if ray goes beyond max distance, force ID back to background one
    if(t > maxRayDistance)
        id = -1.0;
    
    return vec2(t, id);
}

// ~~~~~~ calculate normal of closest objects surface given a ray position
// input p --> ray position (calculated previously from ray cast position, no iteration now
// output --> surface normal vector
//
// gets the surface normal by sampling neaby points and getting direction of diffs

vec3 calculateNormal(vec3 p)
{
    float normalEpsilon = 0.0001;
    vec3 eps = vec3(normalEpsilon,0,0);
    vec3 normal = vec3( map(p + eps.xyy).x - map(p - eps.xyy).x,
                       	map(p + eps.yxy).x - map(p - eps.yxy).x,
                       	map(p + eps.yyx).x - map(p - eps.yyx).x
                       );
    return normalize(normal);
}

// ~~~~~~~ render pixel --> find closest surface and apply color accordingly
// input ro --> pixel's ray original position
// input rd --> pixel's ray direction
// output --> pixel color
vec3 render(vec3 ro, vec3 rd)
{
    vec3 bkgColor = vec3(0.75);
    vec3 light = normalize( vec3(1.0, 4.0, 3.0) );
    vec3 objectColor_1 = vec3(1.0, 0.0, 0.0);
    vec3 objectColor_2 = vec3( 0.25 , 0.95 , 0.25 );
    vec3 objectColor_3 = vec3(0.12, 0.12, 0.9);
    vec3 ambientLightColor = vec3( 0.3 , 0.1, 0.2 );
    
    vec2 res = castRay(ro, rd);
    float t = res.x;
    float id = res.y;
    
    // hard set pixel value if its a background one
    if(id == -1.0)
    	return bkgColor;
    else
    {
        // calculate pixel normal
        vec3 pos = ro + t*rd;
        vec3 normal = calculateNormal(pos);
        vec3 objectColor = vec3(1);
        
        if(id == 1.0)
            objectColor = objectColor_1;
        else if(id == 2.0)
            objectColor = objectColor_2;
        else if(id == 3.0)
            objectColor = objectColor_3;
        
        float surf = clamp(dot(normal, light), 0.0, 1.0);
        vec3 pixelColor = objectColor * surf + ambientLightColor;
		return pixelColor;            
    }
}

// ~~~~~~~ creates camera matrix used to transform ray point/direction
// input camPos --> camera position
// input targetPos --> look at target position
// input roll --> how much camera roll
// output --> camera matrix used to transform
mat3 setCamera( in vec3 camPos, in vec3 targetPos, float roll )
{
	vec3 cw = normalize(targetPos - camPos);
	vec3 cp = vec3(sin(roll), cos(roll),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    // get pixel (range from -1.0 to 1.0)
    vec2 p = ( -iResolution.xy + 2.0 * fragCoord.xy ) / iResolution.y;
    
    // camera stuff
    float camOrbitSpeed = 0.5;
    float camOrbitRadius = 7.3333;
    float camPosX = camOrbitRadius * cos( camOrbitSpeed * iGlobalTime);
    float camPosZ = camOrbitRadius * sin( camOrbitSpeed * iGlobalTime);
    vec3 camPos = vec3(camPosX, 0.5, camPosZ);
    vec3 lookAtTarget = vec3(0.0);
    mat3 camMatrix = setCamera(camPos, lookAtTarget, 0.0);
    
    // determines ray direction based on camera matrix
    // "lens length" seems to be related to field of view / ray divergence
    float lensLength = 2.0;
    vec3 rd = camMatrix * normalize( vec3(p.xy,2.0) );
    vec3 col = render(camPos,rd);
    
	fragColor = vec4(col,1.0);
}


