// Shader downloaded from https://www.shadertoy.com/view/ldt3Dr
// written by shadertoy user sagarpatel
//
// Name: SDF Reflection/LightBounce Test
// Description: A quick heck test to see how a naive implementation of light bouncing would look like.
//    Output is glitchy: won't attempt to fix here)
// CC0 1.0
// @sagzorz
// HACKED REFLECTION / LIGHT BOUNCE TEST
 
// enabling AA will kill light bounce
const bool isPseudoAA = false;
// min is 1
const int lightBounceCount = 2;

// Building on basics and creating helper functions
// POUET toolbox
// http://www.pouet.net/topic.php?which=7931&page=1&x=3&y=14

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
//  positive means outside of sphere
//  negative means ray is inside
//  0 means its exactly on the surface


// ~~~~~~~ silly function to access array memeber 
// because webgl needs const index for array acess
// TODO :  FIX THIS, disgusting branching etc
// THIS IS DEPRECATED,  NO LONGER NEED AN ARRAY SINCE DIRECT COL MIX NOW
vec3 accessColors(float id)
{    
    vec3 bkgColor = vec3(0.5,0.6,0.7);//vec3(0.75);    
    vec3 objectColor_1 = vec3(1.0, 0.0, 0.0);
    vec3 objectColor_2 = vec3( 0.25 , 0.95 , 0.25 );
    vec3 objectColor_3 = vec3(0.12, 0.12, 0.9);
    vec3 objectColor_4 = vec3(0.65);
    vec3 objectColor_5 = vec3(1.0,1.0,1.0);
    
    vec3 colorsArray[6];
    colorsArray[0] = bkgColor;
    colorsArray[1] = objectColor_1;
    colorsArray[2] = objectColor_2;
    colorsArray[3] = objectColor_3;
    colorsArray[4] = objectColor_4;
    colorsArray[5] = objectColor_5;
    
    
    if(id == -1.0)    
        return bkgColor;
    else if(id == 1.0)
        return colorsArray[1];
    else if(id == 2.0)
        return colorsArray[2];
    else if(id == 3.0)
        return colorsArray[3];
    else if(id == 4.0)
        return colorsArray[4];
    else if(id == 5.0)
        return colorsArray[5];
    else 
        return vec3(1.0,0.0,1.0);
}


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
//  t.x = torus circumference
//  t.y = torus thickness
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

// ~~~~~~~ signed distance function for plane
//  input ps --> specs of plane
//        ps.x --> size x
//        ps.y --> size z
// plane extends indefinately in x and z, 
// so just return height from floor (y)
float sdPlane(vec3 p)
{
    return p.y;
}

// ~~~~~~~ smooth minimum function (polynomial version) from iq's page
// http://iquilezles.org/www/articles/smin/smin.htm
// input d1 --> distance value of object a
// input d1 --> distance value of object b
// input k --> blend factor
// output --> smoothed/blended output
float smin( float d1, float d2, float k)
{    
    float h = clamp( 0.5+0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h);
}

// ~~~~~~~ distance deformation, blends 2 shapes based on their distances
// input o1 --> object 1 (dist and material color)
// input 02 --> object 2 (dist and material color)
// input bf --> blend factor
// output --> blended dist, blended material color
// TODO: FIX/IMPROVE COLOR BLENDING LOGIC
vec4 opBlend( vec4 o1, vec4 o2, float bf)
{    
    float distBlend = smin( o1.x, o2.x, bf);
    
    // blend color based on prozimity to surface
    float dr1 = 1.0 - clamp(o1.x,0.0,1.0);
    float dr2 = 1.0 - clamp(o2.x,0.0,1.0);
    vec3 dc1 = dr1 * o1.yzw;
    vec3 dc2 = dr2 * o2.yzw;
    
    return vec4(distBlend, dc1+dc2);
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

// ~~~~~~~ do shape subtract, cuts d2 out of d1
// by using  the negative of d2, were effectively comparing wrt to internal d
// input d1 --> object/distance 1
// input d2 --> object/distance 2
// output --> cut out distance
float opSub(float d1,float d2)
{
    return max(d1,-d2);   
}

// ~~~~~~~ map out the world
// input p --> is ray position
// basically find the object/point closest to the ray by
// checking all the objects with respect to p
// move objects/shapes by messing with p
// outputs closest distance and blended colors for that surface as a vec4
vec4 map(vec3 p)
{
    // results container
    vec4 res;    
    
    // define objects
        // sphere 1
        // sphere: radius, orbit radius, orbit speed, orbit offset, position
    float sR = 1.359997;
    float sOR = 2.666662;
    float sOS = 0.85;
    vec3 sOO = vec3(2.66662,0.0,0.0);
    vec3 sOP = (sOO + vec3(sOR*cos(sOS*iGlobalTime),sOR*sin(sOS*iGlobalTime),0.0));
    vec3 sP = p - sOP;
    vec4 sphere_1 = vec4( sdSphere(sP,sR), accessColors(1.0) );
    
    vec3 sP2 = p - 1.0515*sOP.xzy;
    vec4 sphere_2 = vec4( sdSphere(sP2,1.1750*sR), accessColors(5.0) );
    
        //  torus 1    
    vec2 torusSpecs = vec2(1.76, 0.413333);
    float twistSpeed = 0.35;
    float twistPower = 3.0*sin(twistSpeed * iGlobalTime);
        // to twist the torus (or any object), we actually distort p/space (domain) itself,
        // this then gives us a distorted view of the object
    vec3 torusPos = vec3(0.0);
    vec3 distortedP = opTwist(p - torusPos, twistPower, 0.0) ;
        //  domain distortion correction:
        //  needed to find this by hand, inversely proportional to domain deformation
    float ddc = 0.25;
    vec4 torus_1 = vec4(ddc*sdTorus(distortedP,torusSpecs),accessColors(2.0));
    
    vec3 boxPos = p - vec3(4.0, -0.800,1.0);
    vec4 box_1 = vec4(sdBox(boxPos,vec3(0.50,1.0,1.5)),accessColors(3.0));
    
    vec3 planePos = p - vec3(0.0, -3.0, 0.0);
    vec4 plane_1 = vec4(sdPlane(planePos), accessColors(4.0));
    
    // blend objects    
    res = opBlend( sphere_1, torus_1, 0.7 );     
    
    res = opBlend( res, box_1, 0.6 );
    res = opBlend( res, plane_1, 0.5);
    
    //res = opBlend( res, sphere_2, 0.87);
    res.x = opSub(res.x,sphere_2.x);
    
    return res;
}

// ~~~~~~~ cast/march ray through the word and see what it hits
// input ro --> ray origin point/position
// input rd --> ray direction
// in/out --> itterationRatio (used for AA),in/out cuz no more room in vec
// output is vec3 where
//  .x = distance travelled by ray
//  .y = hit object's ID
//  .z = itteration ratio
vec4 castRay( vec3 ro, vec3 rd, inout float itterRatio)
{
    // variables used to control the marching process
    const float maxMarchCount = 100.0;
    float maxRayDistance = 50.0;
    // making this more precise can also help with AA detection
    // value lower than 0.000001 causes noise
    float minPrecisionCheck = 0.000001;
    
    float t = 0.001; // travelled distance by ray
    vec3 oc = vec3(1.0,0.0,1.0); // object color
    itterRatio = 0.0;
    
    for(float i = 0.0; i < maxMarchCount; i++)
    {
        // get closest object to current ray position
        vec4 res = map(ro + rd*t);
        
        // stop itterating/marching once either we've past max ray length 
        // or
        // once we're close enough to an object (defined by the precision check variable)
        if(t > maxRayDistance || res.x < minPrecisionCheck)
           break;
        
        // move ray forward by distance to closet object, see
        // http://http.developer.nvidia.com/GPUGems2/elementLinks/08_displacement_05.jpg
        t += res.x; 
        oc = res.yzw;
        itterRatio = i/maxMarchCount;
    }
    
    // if ray goes beyond max distance, force ID back to background one
    if(t > maxRayDistance)
        oc = accessColors(-1.0);
    
    return vec4(t,oc.xyz);
}


// ~~~~~~~ hardShadow, raymarches from shading point to light
//  input sp --> position of surface we are shading
//  input lp --> light position
//  output float --> 0.0 means shadow, 1.0 means no shadow
float castRay_HardShadow(vec3 sp, vec3 lp)
{
    const int hsMaxMarchCount = 100;
    const float hsPrecision = 0.0001;
    
    // direction of ray, from shaded surface point to light pos
    vec3 rd = normalize(lp - sp);
    // max travel distance of hard shadow ray
    float hsMaxT = length(lp - sp);
    // travelled distance by hard shadow ray
    float hsT = 0.02; //2.10 * hsPrecision;
    for(int i = 0; i < hsMaxMarchCount; i++)
    {
        float dist = map(sp + rd*hsT).x;
        // if object hit on way to light, return hard shadow
        if(dist < hsPrecision)
            return 0.0;
        hsT += dist;
    }
    // no object hit on the way to light source
    return 1.0;
}

// ~~~~~~~ softShadow, took pointers from iq's
// http://www.iquilezles.org/www/articles/rmshadows/rmshadows.htm
// and
// https://www.shadertoy.com/view/Xds3zN
//  input sp --> position of surface we are shading
//  input lp --> light position
//  output float --> amount of shadow
float castRay_SoftShadow(vec3 sp, vec3 lp)
{
    const int ssMaxMarchCount = 90;
    const float ssPrecision = 0.001;
    
    // direction of ray, from shaded surface point to light pos
    vec3 rd = normalize(lp - sp);
    // max travel distance of hard shadow ray
    float ssMaxT = length(lp - sp);
    // travelled distance by hard shadow ray
    float ssT = 0.02;
    // softShadow value
    float ssV = 1.0;
    for(int i = 0; i < ssMaxMarchCount; i++)
    {
        float dist = map(sp + rd*ssT).x;
        // if object hit on way to light, return hard shadow
        if(dist < ssPrecision)
            return 0.0;
        
        ssV = min(ssV, 16.0*dist/ssT);
        ssT += dist;
        if(ssT > ssMaxT)
            break;
    }
    return ssV;
}

// ~~~~~~~ ambientOcclusion
// just cast from surface point in direction of normal to see if any hit
// basic concept from:
// http://9bitscience.blogspot.com/2013/07/raymarching-distance-fields_14.html
float castRay_AmbientOcclusion(vec3 sp, vec3 nor)
{
    const int aoMaxMarchCount = 20;
    const float aoPrecision = 0.001;
    // range of ambient occlusion
    float aoMaxT = 1.0;
    float aoT = 0.01;
    float aoV = 1.0;
    for(int i = 0; i < aoMaxMarchCount; i++)
    {
       float dist = map(sp + nor*aoT).x;
       aoV = aoT/aoMaxT;
       if(dist < aoPrecision)
           break;              
       if(aoT > aoMaxT)
           break;
       aoT += dist;
    }
    
    return clamp(aoV, 0.0,1.0);
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

// ~~~~~~~ calculates the normals near point p in world space
// input p --> ray position world coordinates
// input oN --> normal vector at point p
// output --> averaged? out norals diffs of nearby points  
vec3 nearbyNormalsDiff(vec3 p, vec3 oN)
{
    // world pos diff
    float wPD = 0.0;
    wPD = 0.057;
    //wPD = abs(0.05*sin(0.25*iGlobalTime)) + 0.1;
    
    vec3 n1 = calculateNormal(p+vec3(wPD,wPD,wPD));
    //vec3 n2 = calculateNormal(p+vec3(wPD,wPD,-wPD));
    //vec3 n3 = calculateNormal(p+vec3(wPD,-wPD,wPD));
    //vec3 n4 = calculateNormal(p+vec3(wPD,-wPD,-wPD));
    
    // doing full on 8 points version seems to crash it

    vec3 diffVec = vec3(0.0);
    diffVec += oN - n1;
    //diffVec += oN - n2;
    //diffVec += oN - n3;
    //diffVec += oN - n4;
        
    return diffVec;    
}

// ~~~~~~~ do gamma correction
// from iq's pageon outdoor lighting:
// http://www.iquilezles.org/www/articles/outdoorslighting/outdoorslighting.htm
// input c --> original color
// output --> gamma corrected output
vec3 applyGammaCorrection(vec3 c)
{
    return pow( c, vec3(1.0/2.2) );
}

// ~~~~~~~ do fog
// from iq's pageon fog:
// http://www.iquilezles.org/www/articles/fog/fog.htm
// input c --> original color
// input d --> pixel world distance
// input fc1 --> fog color 1
// input fc2 --> fog color 2
// input fs -- fog specs>
//       fs.x --> fog density
//       fs.y --> fog color lerp exponent (iq's default is 8.0)
// input cRD --> camera ray direction
// input lRD --> light ray direction
// output --> color with fog applied
vec3 applyFog(vec3 c,float d,vec3 fc1,vec3 fc2,vec2 fs,vec3 cRD,vec3 lRD)
{
    float fogAmount = 1.0 - exp(-d*fs.x);
    float lightAmount = max( dot( cRD, lRD ), 0.0 );
    vec3 fogColor = mix(fc1,fc2,pow(lightAmount,fs.y));
    return mix(c,fogColor,fogAmount);
}


// ~~~~~~~ render pixel --> find closest surface and apply color accordingly
// input ro --> pixel's ray original position
// input rd --> pixel's ray direction
// in/out aaF --> antialiasing factor
// out sP --> rendered surface position
// out sR --> rendererd surface reflected ray
// output --> pixel color
vec4 render(vec3 ro, vec3 rd, inout float aaF, out vec3 sP, out vec3 sR)
{        
    vec3 ambientLightColor = vec3( 0.001 , 0.001, 0.001 );
    
    float lOR_X = 5.0;
    float lOR_Y = 10.0;
    float lOR_Z = 25.0;
    float lORS = 0.25;
    float lpX = lOR_X*cos(lORS*iGlobalTime);
    float lpY = lOR_Y*sin(lORS*iGlobalTime);
    float lpZ = lOR_Z*cos(lORS*iGlobalTime);
    vec3 lightPos = vec3(lpX,abs(lpY),lpZ);
    float iR = 0.0;
    vec4 res = castRay(ro, rd, iR);
    float t = res.x;
    vec3 objectColor = vec3(1.0,0.0,1.0);
    objectColor = res.yzw;
    
    // hard set pixel value if its a background one
    if(objectColor == accessColors(-1.0))
        return vec4(objectColor.xyz,iR);
    else
    {
        //objectColor = normalize(objectColor);
        // calculate pixel normal
        vec3 pos = ro + t*rd;
        vec3 normal = calculateNormal(pos);
        
        
        float dist = length(pos);
        vec3 lightDir = normalize(lightPos-pos);
        
        // treating light as a point light (calculating normal based on pos)
        float surf = clamp(dot(normal,lightDir), 0.0, 1.0);
        vec3 pixelColor = objectColor * surf;
        
        pixelColor *= castRay_SoftShadow(pos,lightPos);
        pixelColor *= castRay_AmbientOcclusion(pos,normal);
        pixelColor += ambientLightColor;
        
        vec3 fc_1 = vec3(0.5,0.6,0.7);
        vec3 fc_2 = vec3(1.0,0.9,0.7);
        vec2 fS = vec2(0.020,2.0);                    
        pixelColor = applyFog(pixelColor,dist,fc_1,fc_2,fS,rd,lightDir);        
        pixelColor = applyGammaCorrection(pixelColor);
        
        float aaFactor = 0.0;
        if(isPseudoAA == true)
        {
            // AA RELATED STUFF
            // visualize itteration count of pixels
            //pixelColor = vec3(res.z);
            vec3 nnDiff = nearbyNormalsDiff(pos,normal);
            // pseudo edge/tangent detect? wrt ray, approx grazing ray 
            float sEdge = clamp(1.0 + dot(rd,normal),0.0,1.0);
            //sEdge *= 1.0 - (t/200.0);

            // TODO : better weighing for the 2 factors to narrow down on AA p
            // gets affected by castRay precision variable
            
            //aaFactor = 0.75*pow(sEdge,10.0)+ 0.5*iR;
            aaFactor += 0.75*pow(sEdge,10.0);
            // visualizes march count, looks cool!
            aaFactor += 0.5*iR;
            aaFactor += 0.5 *length(nnDiff);

            // visualize AA needing pizel
            pixelColor = vec3(aaFactor);
            //pixelColor = nnDiff;
            aaF = aaFactor;
        }

        // pixelColor in xyz, w is itteration count, used for AA
        vec4 pixelData = vec4(pixelColor.xyz,aaFactor);
        sP = pos;
        sR = reflect(normalize(rd),normal);
        
        return pixelData; 
    }    
}


// ~~~~~~~ generate camera ray direction, different for each frag/pixel
// input fCoord --> pixel coordinate
// input cMatric --> camera matrix
// output --> ray direction
vec3 calculateRayDir(vec2 fCoord, mat3 cMatrix)
{        
    vec2 p = ( -iResolution.xy + 2.0 * fCoord.xy ) / iResolution.y;
        
    // determines ray direction based on camera matrix
    // "lens length" seems to be related to field of view / ray divergence
    float lensLen0gth = 2.0;
    vec3 rD = cMatrix * normalize( vec3(p.xy,2.0) );
    return rD;
}


// ~~~~~~~ render anti aliased, based on pixel's itteration/march count
//          only effective for shape edges, doesn't fix surface col patterns
// input fCoord --> pixel coordinate
// input cPos --> camera position
// input cMat --> camera matrix
// output vec3 --> pixel antialaised color
vec3 render_AA(vec2 fCoord,vec3 cPos,mat3 cMat)
{
    vec3 rd = calculateRayDir(fCoord,cMat);
    float aaF = 0.0;
    vec3 dumSP;
    vec3 dumSR;
    vec4 pData = render(cPos,rd,aaF,dumSP,dumSR);    
    vec3 col = pData.xyz;
    float aaThreashold = 0.845;
    // controls blur amount/sample distance
    float aaPD = 0.500;
    // if requires AA, get color from nearby pixels and average out
    //col = vec3(0.0);
    if(aaF > aaThreashold)
    {
        float dummy = 0.0;
        vec3 rd_U = calculateRayDir(fCoord + vec2(0,aaPD),cMat);
        vec3 pc_U = render(cPos,rd_U,dummy,dumSP,dumSR).xyz;
        
        vec3 rd_D = calculateRayDir(fCoord + vec2(0,-aaPD),cMat);
        vec3 pc_D = render(cPos,rd_D,dummy,dumSP,dumSR).xyz;
        
        vec3 rd_R = calculateRayDir(fCoord + vec2(aaPD,0),cMat);
        vec3 pc_R = render(cPos,rd_R,dummy,dumSP,dumSR).xyz;
        
        vec3 rd_L = calculateRayDir(fCoord + vec2(-aaPD,0),cMat);
        vec3 pc_L = render(cPos,rd_L,dummy,dumSP,dumSR).xyz;
                
        /*
        vec3 rd_UR = calculateRayDir(fCoord + vec2(aaPD,aaPD),cMat);
        vec3 pc_UR = render(cPos,rd_UR,dummy).xyz;
        
        vec3 rd_UL = calculateRayDir(fCoord + vec2(-aaPD,aaPD),cMat);
        vec3 pc_UL = render(cPos,rd_UL,dummy).xyz;
        
        vec3 rd_DR = calculateRayDir(fCoord + vec2(aaPD,-aaPD),cMat);
        vec3 pc_DR = render(cPos,rd_DR,dummy).xyz;
        
        vec3 rd_DL = calculateRayDir(fCoord + vec2(-aaPD,-aaPD),cMat);
        vec3 pc_DL = render(cPos,rd_DL,dummy).xyz;
        col = pc_U+pc_D+pc_R+pc_L+pc_UR+pc_UL+pc_DR+pc_DL;        
        col *= 1.0/8.0;     
        */
        
        col = 0.25*(pc_U+pc_D+pc_R+pc_L);
        // used to visualize pixels that are getting AA
        //col = vec3(1.0,0.0,1.0) + 0.001*(pc_U+pc_D+pc_R+pc_L);        
    }        
    return col;
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
    // camera stuff, the same for all pixel in a frame
    float camOrbitSpeed = 0.10;
    float camOrbitRadius = 6.3333;
    float oOff = 0.00750;
    float camPosX = camOrbitRadius * cos( camOrbitSpeed * iGlobalTime + oOff);
    float camPosZ = camOrbitRadius * sin( camOrbitSpeed * iGlobalTime + oOff);
    vec3 camPos = vec3(camPosX, 2.015, camPosZ);
    vec3 lookAtTarget = vec3(0.0);
    mat3 camMatrix = setCamera(camPos, lookAtTarget, 0.0);
    
    // ordinary, no AA render
    vec3 rd = calculateRayDir(fragCoord,camMatrix);        
    vec3 col;
    
    if(isPseudoAA == false)
    {       
        float dum = 0.0;
        vec3 renderedSurfPos;
        vec3 rendererdSurfRefl;
        for(int i = 0; i < lightBounceCount; i++)
        {   
            if(i == 0)
            {
                vec3 dumSR;                 
                col = render(camPos,rd,dum,renderedSurfPos,rendererdSurfRefl).xyz;
            }
            else
            {
             	float bounceAttenRatio = 0.01 + 0.5*(1.0 - float(i)/float(lightBounceCount));
                vec3 bCol = render(renderedSurfPos,rendererdSurfRefl,dum,renderedSurfPos,rendererdSurfRefl).xyz;
                //col += 0.133333*vec3(length(bCol));
                col += bounceAttenRatio* bCol;
            }
                
        }
    }
   	else
    	col = render_AA(fragCoord,camPos,camMatrix);
    
    fragColor = vec4(col,1.0);
    //fragColor = vec4(fragCoord.xy/iResolution.y,0,0);
}


