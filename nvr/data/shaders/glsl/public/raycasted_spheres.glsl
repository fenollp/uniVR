// Shader downloaded from https://www.shadertoy.com/view/XlSGR3
// written by shadertoy user Aj_
//
// Name: Raycasted spheres
// Description: My first attempt at creating a raycasted scene using intersection equations and all. Not optimized. 
//    Also could anyone tell me why lines 80 and 89 doesn't work (when uncommented)?
const int NUM_PRIMS = 4;	//number of spheres in the scene
const int NUM_LIGHTS = 4; //number of lights in the scene
const float FAR = 100.;	//far clipping plane distance

#define MRX(X) mat3(1., 0., 0. ,0., cos(X), -sin(X) ,0., sin(X), cos(X))	//x axis rotation matrix
#define MRY(X) mat3(cos(X), 0., sin(X),0., 1., 0.,-sin(X), 0., cos(X))	//y axis rotation matrix	
#define MRZ(X) mat3(cos(X), -sin(X), 0.	,sin(X), cos(X), 0.	,0., 0., 1.)	//z axis rotation matrix
#define MRF(X,Y,Z) MRZ(Z)*MRY(Y)*MRX(X)	//x,y,z combined rotation macro

struct Primitive {	//structure for representing primitves
    vec3 forward;	//forward of the primitive. Only applicable to planes
    float id;	//id for indentifying the object
    vec3 pos;	//positionof the object in the world space
    vec3 normal;	//surface normal at the point of intersection
    float size;	//size of the object. only applicable to some primitive like spheres
    bool isIntersected ;	//used to store ray intersection status
    vec3 intersecPoint;	//point of intersection by the ray
    float specular;  //specular reflection value for the primitive
};  
    

struct Light {	//structuer for storing light info
    vec3 pos;	//position of the light
    vec3 col;	//color of the light
};


//sphere-ray intersection solver
/*	sph -> reference to the primitive object. (sphere in this case)
 *	rayOr -> origin position of the ray
 *	rayDir -> direction of the ray
 *	smooth -? extra smoothing boundary for calculating intersection.
 */
	
void getSphereIntersec(inout Primitive sph, vec3 rayOr, vec3 rayDir, float smooth) {
    vec3 rx = rayOr-sph.pos;
    float vrx = dot(rayDir, rx);
    float drx = distance(rayOr,sph.pos);
    float v = vrx*vrx 
         - (drx*drx - (sph.size+smooth)*(sph.size+smooth)); //sphere line intersection equation    
    float ld = -vrx; //sphere line intersection equation
	float sqrtv = sqrt(abs(v)); 
    float dist1 = ld + sqrtv; //dist to intersection point1
    float dist2 = ld - sqrtv; //dist to intersection point2
    sph.intersecPoint =rayOr+ min(dist1, dist2) * rayDir; //calculating the closest intersection point   	
    sph.isIntersected = v<0.?false:true;	//set whether the sphere was interseced 
    sph.normal =normalize(sph.intersecPoint - sph.pos); //set the surface normal at the intersection point
      
}
//plane-ray intersection solver
/*	plane -> reference to the plane object. 
 *	rayOr -> origin position of the ray
 *	rayDir -> direction of the ray	
 */
void getPlaneIntersec(inout Primitive plane, vec3 rayOr, vec3 rayDir) {
    float rdn = dot( rayDir, plane.normal); //plane line intersection
    float frdn = rdn==0.?1.:rdn; 
    float dfc = dot(plane.normal, (plane.pos - rayOr))/frdn; //dist of plane from ray origin
     plane.intersecPoint = rayOr + dfc*rayDir; //intersection point of plane and ray
   
    plane.isIntersected = rdn==0.?false:true; //whether or not the plane was intersected, without considering its size
    vec3 dVec = vec3(plane.intersecPoint - plane.pos); //distance from the center of the plane to the point of intersection
    plane.isIntersected = (plane.isIntersected&&(abs(dVec.x)	//if the point of intersection is outside the plane 
                          +abs(dVec.y)+abs(dVec.z)<=plane.size))?true:false;	//set as not intersected, otherwise intersected
    
    
}


float minLen; //distance from the ray origin to the closest intersection point
Primitive nope; //dummy 'null' equivalent object
Primitive prim ; //temporary primitive object representing the intersected object
    
//Checks which primitive in prims is first intersected by the ray and returns it
//rayOr -> Origin of the ray
//rayDir -> direction of the ray
//prims -> primitive array
 //smooth -> smoothness value to send to the intersection solver function
Primitive processRayIntersect(vec3 rayOr, vec3 rayDir,inout Primitive prims[NUM_PRIMS], float smooth) {
     
    minLen = FAR+1.; //initialize minLen to the farthest possible distance   
    prim = nope;   //no object has been intersected yet
    
       float tl; 
    for(int i=1;i<NUM_PRIMS;i++) { //for every primitive in prims
       
    	prims[i].id = float(i);
        getSphereIntersec(prims[i], rayOr, rayDir, smooth); //process sphere-ray intersection
        tl = distance(rayOr, prims[i].intersecPoint);	//get distance from the ray origin to the intersection point
        minLen = prims[i].isIntersected&&tl<=minLen?tl:minLen; //if the current primitive was intersected, and t1 is less than minLen, 
																//set minLen as t1
        
        if(tl==minLen) {	//if minLen is same as t1
            prim = prims[i];	//this is the first primitive the ray has encountered
        }
    }
    
    getPlaneIntersec(prims[0], rayOr ,rayDir); // process plane-ray intersection
    tl = distance(rayOr, prims[0].intersecPoint); // distance from ray origin to point of intersection on plane
    minLen = prims[0].isIntersected&&tl<=minLen?tl:minLen; //if the plane has been intersected and if t1 is less than minLen
															// then set t1 as minLen
        
    if(tl==minLen) {    //if t1 is minLen
        prim = prims[0]; //the object that is interected first is the plane

    }
    return prim; //return the primitive that was that is first intersected by the ray
    
   
    }


	
	//Creates a scene containing 3 spheres, a plane and some lights and then calls ray-primitive intersection
	// solvers, calculates reflection value for the intersection point and then sets the pixel color
	//rayOr -> ray origin
	//rayDir -> ray direction
	//vec3 sphPos -> pre defined position for center sphere
	
vec3 makeScene(vec3 rayOr,vec3 rayDir, vec3 sphPos) {
   
  
    Primitive sph1, plane1, sph2, sph3, sph4, sph5; //Spheres
    sph3.size = .18;  //setting sphere size
    sph3.pos =sphPos + vec3(0., 0., sph3.size);	//sphere position
    
    sph1.size = .08;
    sph1.pos = vec3(sph3.pos.x-(sph1.size+sph3.size)*1.02,sph3.pos.y, sph1.size-.001);
    sph2.size =.18;
    sph2.pos = vec3(sph3.pos.x+(sph3.size+sph2.size)*1.02,sph3.pos.y, sph3.size-.001);
    sph1.specular = sph2.specular = sph3.specular = .5;    //specular reflection values for spheres
    
    plane1.pos = vec3(vec2(sph3.pos.xy), sph1.pos.z - sph1.size+.005); //plane position
    plane1.normal = normalize(vec3(0., 0., .1)); //plane surface normal
    plane1.size = 1.;  //plane's side length
    
    Primitive prims[NUM_PRIMS];
    
    prims[0] = plane1; //adding primitives into an array
    prims[1] = sph1;
    prims[2] = sph2;
    prims[3] = sph3;    
    //prims[4] = sph4;
    //prims[5] = sph5;
       
    
  
    Primitive rayPrim = processRayIntersect(rayOr, rayDir, prims, 0.); //perform camera ray intersection check on all primitives
																	   //rayPrim is the primitive that was first intersected by the
																	   //camera ray
    Light lights[NUM_LIGHTS]; //lights array
    lights[0].pos = vec3(sph2.pos.x, sph2.pos.y+.9, .9);//pos of light1;
    lights[0].col = vec3(.1, .4, .2)*2.; //set light color
    lights[1].pos =  vec3(-.8, .3, .4);
    lights[1].col = vec3(.4, .1, .1)*3.;
    lights[2].pos = vec3(1.8, .2, .5);
    lights[2].col = vec3(.2, .1, .4)*4.;
    lights[3].pos = vec3(.5, .2, 7.2);
    lights[3].col = vec3(.3, .3, .8);
    Primitive lightPrim;
    vec3 finalCol = vec3(0.,0.,0.); //initialize final pixel color to zero vector
    vec3 lRefl;	//
    float str;
    for(int i=0;i<NUM_LIGHTS;i++) {
        lightPrim = processRayIntersect(lights[i].pos
                        , normalize(rayPrim.intersecPoint - lights[i].pos), prims, .001); //check if a light ray from this light
														//reaches the point intersected by the camera ray and set lightPrim
														//as the primitive first intersected by the light ray
        if(lightPrim.id == plane1.id) { //if the light ray towards the primitive intersection point intersects the plane
										
        finalCol+= lightPrim.id==rayPrim.id?max(dot(rayPrim.normal //if the ray from the light and the ray from the camera intersect																	
               , normalize( -(rayPrim.intersecPoint) + lights[i].pos))	//the aame primitive, calculate diffuse shading color value for the
               *lights[i].col*.4, 0.):vec3(0., 0., 0.);					//current light and add it to the pixel color
            
        }
        else { //if the light ray didn't intersect the plane
        lRefl = reflect(rayPrim.intersecPoint - lights[i].pos //calculate the reflection vector at the intersected surface
                            , rayPrim.normal);				  //point for the light ray
        str = max((-1.*dot(normalize(lRefl), rayDir)-rayPrim.specular), 0.0) *5.; //calculate specular reflection value
																				  //for the light ray
												
        finalCol += mix(finalCol,                  //if the light ray and the camera ray hit the same point,		
                       lightPrim.id==rayPrim.id?   //add the light value vector to the final pixel color
                        str*lights[i].col		   //else add a zero vector
            :vec3(0., 0., 0.)
                        , .9 );
       }
    }

    
    return finalCol;	//return the final pixel color
    
    
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    nope.normal = vec3(0., 0., 0.); //set the normal for the nope object
    nope.id = -1.;
	float t = iGlobalTime;
	vec2 uv = (fragCoord.xy )/max(iResolution.x, iResolution.y); //normalized uv co-ordinates
    vec3 center = vec3(vec2(iResolution.xy/2./max(iResolution.x, iResolution.y)), -3.0); //get the center of the uv co-ordinate
    uv -=center.xy; //offset the uv co-ordinates so that the new center will be at (0, 0)
    mat3 rotM = MRZ(t); //create a x axis rotation matrix whose angle varies by time
    vec3 camPos = vec3(0, -4., 3.0);//vec3(0.5, .25, 15.25); //position the camera
    camPos = rotM*(camPos); //apply rotation to camera
    vec3 sph1Pos = vec3 (0., 0., 0.); //place sphere 1 at (0, 0, 0)
    vec3 forward = normalize(sph1Pos - camPos); //set the camera to look at sphere 1
    vec3 upVec = normalize(cross(cross(forward, vec3(0., 0., 1.)), forward)); //set a vector perpendicular to
												// the both z-axis and the camera forwars as the camera up vector
   
    vec3 scrnPos = camPos+forward*2.; //position the screen plane
    vec3 planeLeft = normalize(cross(forward, upVec)); //calculate the left direction vector of the screen plane
	vec3 planeUV =upVec * uv.y + planeLeft*uv.x; //find out a point on the plane for the current pixel
    vec3 rayDirUV = normalize(scrnPos + planeUV - camPos); //calculate the ray direction as the direction from
														   //the camera position to the point on the screen
    vec3 val = makeScene(camPos,rayDirUV, sph1Pos); //get the color value for the current pixel
    fragColor = vec4(vec3(val), 1.); //set the pixel color
    
}

