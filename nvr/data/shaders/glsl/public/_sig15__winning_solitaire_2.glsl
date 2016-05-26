// Shader downloaded from https://www.shadertoy.com/view/MlXXDM
// written by shadertoy user eigenaar
//
// Name: [SIG15] Winning Solitaire 2
// Description: A classic and forever satisfying video game moment. Controls : hold A while running to better see the cards. If you can, increase the number of cards (see &quot;#define OBJECT&quot;) and add the missing patterns (see &quot;#define COMPILE_PATTERNS&quot;).
//======================================================================
// Hold A to better see a sample of the cards.
// On my windows 8 laptop, compilation fails using Chrome
// but works fine with Firefox. Reducing the number of cards
// (by commenting the "#define OBJECT"s below) might help.

// Some symbol patterns on the cards crash at compilation on some browsers,
// so I took them out. You can try adding them back by uncommenting the
// line "#define COMPILE_PATTERNS".

// I left the number of cards at 1 by default so it loads faster, but
// increase it to at least 6 to get nice results. Crank it up
// to 20 if you can :).

// A piecewise parabolic prism bounding volume is used to find a
// good approximation of intersections, and the neighboring cards in the stack
// are then searched for a precise intersection. All designs were
// manually constructed with implicit functions. Cards numbers and suits
// are selected automatically.

// By Olivier Mercier
//======================================================================



// parameters, can be modified
#define CAMERA_SPEED 0.22
#define NB_BOUNCES 10
#define BUMP_HEIGHT_FACTOR 0.5
#define CARD_SPEED 1.0
#define SEED 12834.77346652
#define CARD_DENSITY 8.0
#define NB_MARCH_LAYERS 3 // affects the number of cards searched for intersections.
#define CARD_BORDER_SIZE 0.025
#define CARD_BORDER_TINT1 0.3
#define CARD_BORDER_TINT2 0.2
#define SHOOT_TOWARDS_CAMERA_RANGE 0.95 // range (in radian) for the randomness of the card direction angle
#define SHOOT_TOWARDS_CAMERA_OFFSET 4.0 // to shoot ahead of the camera

//#define COMPILE_PATTERNS

// e.g. if you want 5 card stacks, leave OBJECT1 to OBJECT5 uncommented, and comment OBJECT6 to OBJECT20.
#define OBJECT1
//#define OBJECT2
//#define OBJECT3
//#define OBJECT4
//#define OBJECT5
//#define OBJECT6
//#define OBJECT7
//#define OBJECT8
//#define OBJECT9
//#define OBJECT10
//#define OBJECT11
//#define OBJECT12
//#define OBJECT13
//#define OBJECT14
//#define OBJECT15
//#define OBJECT16
//#define OBJECT17
//#define OBJECT18
//#define OBJECT19
//#define OBJECT20


// constants. DO NOT MODIFY.
#define MATERIAL_UVW 1
#define MATERIAL_NORMAL 2
#define MATERIAL_CARD_SIDE_XM 3
#define MATERIAL_CARD_SIDE_XP 4
#define MATERIAL_CARD_SIDE_YM 5
#define MATERIAL_CARD_SIDE_YP 6
#define MATERIAL_CARD_FACE 7
#define MATERIAL_CARD_BACK 8
#define MATERIAL_FLOOR 9
#define INFINITY 99999.0
#define EPSILON 0.0001
#define PI 3.14159265359
#define CARD_HEIGHT 1.4
#define CARD_WIDTH 1.0
#define CARD_SPEED_ADJUSTED CARD_SPEED/(34.0/5.0)

float multiMin3(float a1, float a2, float a3) {return min(a1,min(a2,a3));}
float multiMin4(float a1, float a2, float a3,float a4) {return min(a1,min(a2,min(a3,a4)));}
float multiMin5(float a1, float a2, float a3,float a4,float a5) {return min(a1,min(a2,min(a3,min(a4,a5))));}
float multiMin6(float a1, float a2, float a3,float a4,float a5,float a6) {return min(a1,min(a2,min(a3,min(a4,min(a5,a6)))));}
float multiMax3(float a1, float a2, float a3) {return max(a1,max(a2,a3));}
float multiMax4(float a1, float a2, float a3,float a4) {return max(a1,max(a2,max(a3,a4)));}
float multiMax5(float a1, float a2, float a3,float a4,float a5) {return max(a1,max(a2,max(a3,max(a4,a5))));}
vec3 minVec3(vec3 a, vec3 b){ return vec3(min(a.x,b.x), min(a.y,b.y), min(a.z,b.z)); }
vec3 multiMin3Vec3(vec3 a1,vec3 a2,vec3 a3){ return minVec3(a1, minVec3(a2,a3)); }
vec3 multiMin4Vec3(vec3 a1,vec3 a2,vec3 a3,vec3 a4){ return minVec3(a1, minVec3(a2,minVec3(a3,a4))); }
vec3 multiMin5Vec3(vec3 a1,vec3 a2,vec3 a3,vec3 a4,vec3 a5){ return minVec3(a1, minVec3(a2,minVec3(a3,minVec3(a4,a5)))); }
vec3 multiMin6Vec3(vec3 a1,vec3 a2,vec3 a3,vec3 a4,vec3 a5,vec3 a6){ return minVec3(a1, minVec3(a2,minVec3(a3,minVec3(a4,minVec3(a5,a6))))); }
vec3 multiMin7Vec3(vec3 a1,vec3 a2,vec3 a3,vec3 a4,vec3 a5,vec3 a6,vec3 a7){ return minVec3(a1, minVec3(a2,minVec3(a3,minVec3(a4,minVec3(a5,minVec3(a6,a7)))))); }
vec3 multiMin9Vec3(vec3 a1,vec3 a2,vec3 a3,vec3 a4,vec3 a5,vec3 a6,vec3 a7,vec3 a8,vec3 a9){ return minVec3(a1, minVec3(a2,minVec3(a3,minVec3(a4,minVec3(a5,minVec3(a6,minVec3(a7,minVec3(a8,a9)))))))); }

struct Intersection {
    float dist;
    vec3 normal;
    vec3 uvw;
    int material;
    int info1;
    int info2;
};
    
float sqr(float x) {return x*x;}

vec3 camPosFun(float time) {
    return 18.0*vec3(2.0*cos(time*CAMERA_SPEED), 0.25, sin(time*CAMERA_SPEED));
}

Intersection rectangle(vec3 ori, vec3 dir, vec3 center, vec3 normal, vec2 size) {
    
    Intersection res;
    vec3 up = vec3(1.0,0.0,0.0);
    vec3 right = cross(normal, up);
    
    float dist = dot(normal, center-ori) / dot(normal, dir);
        vec3 pos = ori + dist*dir;
        vec3 uvw = vec3(vec2(dot(pos-center, right), dot(pos-center,up)), 0.0);
        if(abs(uvw.x) <= size.x && abs(uvw.y) <= size.y) {
            res.dist = dist;
            res.normal = dot(normal, dir) >= 0.0 ? normal : -normal;
            res.uvw = uvw;
            res.material = MATERIAL_FLOOR;
        } else {
            res.dist = -1.0;
        }
    
    return res;
}

// piecewise parabolic funcction representing bounces.
float bounce(float x, float bounceHeight, float bounceStepSize)
{    
    float maxHeight = bounceHeight;
    float MHOverBounceStepSiseSqrDiv = maxHeight/(bounceStepSize*bounceStepSize/4.0);
    float sqrtCoeff = (1.0+sqrt(BUMP_HEIGHT_FACTOR))*sqrt(maxHeight/MHOverBounceStepSiseSqrDiv);
    float sqrtFact = sqrt(BUMP_HEIGHT_FACTOR);
        
    float res = 0.0;
    float center = 0.0;
    float height = maxHeight;
    float fact = 1.0;
    float temp;
    for(int i=0; i<=NB_BOUNCES; i++) {
        temp = -MHOverBounceStepSiseSqrDiv*sqr(x-center) + height;
        if(temp >= 0.0) {res = temp; return res;}
        height *= BUMP_HEIGHT_FACTOR;
        fact *= sqrtFact;
        center = sqrtCoeff*(1.0-fact)/(1.0-sqrtFact); 
    }
    
    return res;
}

float bounceFloor(float x, float bounceHeight, float bounceStepSize) {
    return bounce( floor(EPSILON+x*CARD_DENSITY)/CARD_DENSITY,bounceHeight, bounceStepSize );
}


// returns a different value for each time cycle
float cycleRandom(float time, float frequency, float phase, float seed) {
    return sin(54.1235+SEED*seed + SEED*floor(time*frequency*CARD_SPEED_ADJUSTED - phase));
}


// falling card stack starting at center and extruding in the given direction
Intersection fallingCard(float time, vec3 ori, vec3 dir, float frequency, float phase) {

    vec3 center= vec3(
                     0.0 + 8.0*cycleRandom(time, frequency, phase, 31.512*frequency),
                     0.0,
                     0.0 + 8.0*cycleRandom(time, frequency, phase, 51.512*frequency)
                 );
    float bounceHeight = 8.0 + 4.0*cycleRandom(time, frequency, phase, 3.997*frequency);
    float bounceStepSize = 8.0 + 4.0*cycleRandom(time, frequency, phase, 15.371*frequency);
    float camAngle = CAMERA_SPEED*(SHOOT_TOWARDS_CAMERA_OFFSET+floor(time*frequency*CARD_SPEED_ADJUSTED - phase)/(frequency*CARD_SPEED_ADJUSTED));
    float theta = camAngle + SHOOT_TOWARDS_CAMERA_RANGE*cycleRandom(time, frequency, phase, 12.662*frequency);
    vec3 z = vec3(cos(theta), 0.0, sin(theta));
    vec3 y = vec3(0.0,1.0,0.0);
    
    float speed = CARD_SPEED*frequency*bounceStepSize;
    float bssAdjusted = 34.0*bounceStepSize/5.0;
    
    float zBegin = max(mod(speed*(time-phase/speed*bssAdjusted),bssAdjusted)-12.0*bounceStepSize/5.0,0.0);
    float zEnd = min(mod(speed*(time-phase/speed*bssAdjusted),bssAdjusted),14.0*bounceStepSize/5.0);
   
    int cardId = int(max(min(7.0 + 6.5*cycleRandom(time, frequency, phase, 39.612*frequency),13.0),1.0));
    int cardSuit = int(max(min(3.0 + 2.0*cycleRandom(time, frequency, phase, 634.775*frequency),4.0),1.0));
    
    Intersection res;
    res.info1 = cardId;
    res.info2 = cardSuit;
    
    if(zEnd < zBegin) {res.dist = -1.0; return res;}
    
    
    // transform to local axis-aligned coordinates
    vec3 x = cross(y,z);
    vec3 locOri = vec3( dot(ori-center,x), dot(ori-center,y), dot(ori-center,z) );
    vec3 locDir = vec3( dot(dir,x), dot(dir,y), dot(dir,z) );
    
    
    //=============================================
    // rough intersection with bounding volume
    float tx = INFINITY;
    float ty = INFINITY;
    float tz = INFINITY;
    vec3 interX, interY, interZ;
    
    
    if(abs(locDir.x) > EPSILON/10.0) {
        tx = (sign(locOri.x)*CARD_WIDTH - locOri.x)/locDir.x;
        interX = locOri + tx*locDir;
        if (tx < 0.0) {tx = INFINITY;}
        else if(!( abs(interX.y - bounce(interX.z,bounceHeight,bounceStepSize))<=CARD_HEIGHT && zBegin<=interX.z && interX.z<=zEnd)) {tx = INFINITY;}
    }
    
    
    if(abs(locDir.z) > EPSILON/10.0) {
        tz = min( (zEnd - locOri.z)/locDir.z, (zBegin - locOri.z)/locDir.z );
        interZ = locOri + tz*locDir;
        if (tz < 0.0) {tz = INFINITY;}
        if(!( abs(interZ.x)<=CARD_WIDTH && abs(interZ.y-bounce(interZ.z,bounceHeight,bounceStepSize))<=CARD_HEIGHT )) {tz = INFINITY;}
    }
    
    
    if(abs(locDir.y) > EPSILON/1000.0) {
        float a = -bounceHeight/(bounceStepSize*bounceStepSize/4.0);
        float c = 0.0;
        float h = bounceHeight;
        ty = INFINITY;
        float tyBump;
        
        float bssSqrDiv4 = (bounceStepSize*bounceStepSize/4.0);
        
        float bounceSize = sqrt(h/bounceHeight*bssSqrDiv4);
        
        float tempA2 = 4.0*a*sqr(locDir.z);
        float tempB3 = tempA2/2.0;
        for(int i=0; i<=NB_BOUNCES; i++) {
            if(abs(locDir.z)<=EPSILON) {
                tyBump = min( (h + CARD_HEIGHT - locOri.y + a*(c-locOri.z)*(c-locOri.z))/locDir.y ,
                              (h - CARD_HEIGHT - locOri.y + a*(c-locOri.z)*(c-locOri.z))/locDir.y );
                
            } else {
                float tempA1 = sqr(locDir.y) + 4.0*a*locDir.y*locDir.z*(c-locOri.z);
                float delta1 = tempA1 + tempA2*(locOri.y-(h+CARD_HEIGHT));
                float delta2 = tempA1 + tempA2*(locOri.y-(h-CARD_HEIGHT));
                
                float temp1 = INFINITY;
                float temp2 = INFINITY;
                float tempB1 = locDir.y + 2.0*a*locDir.z*(c-locOri.z);
                if(delta1 >= 0.0) {            
                    float tempB2 = sqrt(delta1);
                    float t1 = (tempB1 + tempB2)/tempB3;
                    if(t1 < 0.0) {t1 = INFINITY;}
                    else {
                        vec3 interBump = locOri + t1*locDir;
                        if( !(abs(interBump.x)<=CARD_WIDTH && abs(interBump.z - c) <= bounceSize && interBump.z >= zBegin && interBump.z <= zEnd) ) {t1 = INFINITY;}
                    }
                    float t2 = (tempB1 - tempB2)/tempB3;
                    if(t2 < 0.0) {t2 = INFINITY;}
                    else {
                        vec3 interBump = locOri + t2*locDir;
                        if( !(abs(interBump.x)<=CARD_WIDTH && abs(interBump.z - c) <= bounceSize && interBump.z >= zBegin && interBump.z <= zEnd) ) {t2 = INFINITY;}
                    }
                                        
                    temp1 = min( t1, t2 );
                }
                if(delta2 >= 0.0) {
                    float tempB2 = sqrt(delta2);
                    float t1 = (tempB1 + tempB2)/tempB3;
                    if(t1 < 0.0) {t1 = INFINITY;}
                    else {
                        vec3 interBump = locOri + t1*locDir;
                        if( !(abs(interBump.x)<=CARD_WIDTH && abs(interBump.z - c) <= bounceSize && interBump.z >= zBegin && interBump.z <= zEnd) ) {t1 = INFINITY;}
                    }
                    float t2 = (tempB1 - tempB2)/tempB3;
                    if(t2 < 0.0) {t2 = INFINITY;}
                    else {
                        vec3 interBump = locOri + t2*locDir;
                        if( !(abs(interBump.x)<=CARD_WIDTH && abs(interBump.z - c) <= bounceSize && interBump.z >= zBegin && interBump.z <= zEnd) ) {t2 = INFINITY;}
                    }
                                        
                    temp2 = min( t1, t2 );
                }
                
                tyBump = min( temp1, temp2 );
                
            }
            
            vec3 interBump = locOri + tyBump*locDir;
            if( abs(interBump.x)<=CARD_WIDTH && abs(interBump.z - c) <= bounceSize ) {
                ty = min(ty, tyBump);
            }
            
            h *= BUMP_HEIGHT_FACTOR;
            c += bounceSize;
            bounceSize = sqrt(h/bounceHeight*bssSqrDiv4);
            c += bounceSize;
            
        }
        
        interY = locOri + ty*locDir;
        if(!( abs(interY.x)<=CARD_WIDTH && zBegin<=interY.z && interY.z<=zEnd)) {ty = INFINITY;}
    }
                
    float minT = multiMin3(tx,ty,tz);
    if(minT > INFINITY/2.0) {res.dist = -1.0; return res;}
    vec3 interBounding = locOri + minT*locDir;
    
   
    
    //=============================================
    // if intersects with bounding volume, refine intersections by looking at the neighboring card slices.
        
    float tCard = INFINITY;
    int material = -1;
    
    
    // refine intersection in x
    if( tx < INFINITY/2.0 ) {
        if( abs(interX.y-bounceFloor(interX.z-0.5*(-1.0+sign(locDir.z))/CARD_DENSITY,bounceHeight,bounceStepSize))<=CARD_HEIGHT ) {
            tCard = min(tCard, tx);
            material = MATERIAL_CARD_SIDE_XM;
        }
    }
    
    
    // refine intersection in z
    if( tz < INFINITY/2.0 ) {
        if( abs(interZ.y-bounceFloor(interZ.z,bounceHeight,bounceStepSize))<=CARD_HEIGHT ) {
            tCard = min(tCard, tz);
            if(locDir.z<=0.0) {material = MATERIAL_CARD_FACE;}
            else              {material = MATERIAL_CARD_BACK;}
        }
    }
    

    
    
    // refine intersection in y by looking at neighboring cards.
    int zFloored = int(floor(EPSILON+interBounding.z*CARD_DENSITY));
    for(int i=-NB_MARCH_LAYERS; i<=NB_MARCH_LAYERS; i++) {
        
        int iSlice = zFloored + int(sign(-locDir.z))*i;
        
        float prevZ = (float(iSlice-int(sign(locDir.z)))/CARD_DENSITY);
        float thisZ = (float(iSlice  )/CARD_DENSITY);
        
        if(thisZ < zBegin || thisZ > zEnd) {continue;}
        float prevY, thisY;
        
        prevY = bounce(prevZ,bounceHeight,bounceStepSize) + CARD_HEIGHT;
        thisY = bounce(thisZ,bounceHeight,bounceStepSize) + CARD_HEIGHT;
         
        float maxPrevThisY = max(prevY,thisY);
        float minPrevThisY = min(prevY,thisY);
        float maxPrevThisZ = max(prevZ,thisZ);
        float minPrevThisZ = min(prevZ,thisZ);
        
        // top of card
        if(abs(locDir.y) > EPSILON) {
            ty = ( minPrevThisY - locOri.y )/locDir.y;
            interY = locOri + ty*locDir;
            if( ty >= 0.0 && minPrevThisZ<=interY.z && interY.z<=maxPrevThisZ && abs(interY.x)<=CARD_WIDTH ) {
                if(ty < tCard) {
                    tCard = ty;
                    material = MATERIAL_CARD_SIDE_YM;
                }
            }
        }
        
        // vertical wall
        if(abs(locDir.z) > EPSILON) {
            tz = ( thisZ - locOri.z )/locDir.z;
            interZ = locOri + tz*locDir;
            if( tz >= 0.0 && minPrevThisY<=interZ.y && interZ.y<=maxPrevThisY && abs(interZ.x)<=CARD_WIDTH ) {
                if(tz < tCard) {
                    tCard = tz;
                    if(locDir.z<=0.0) {material = MATERIAL_CARD_FACE;}
                    else              {material = MATERIAL_CARD_BACK;}
                }
            }
        }
        
        prevY = bounce(prevZ,bounceHeight,bounceStepSize) - CARD_HEIGHT;
        thisY = bounce(thisZ,bounceHeight,bounceStepSize) - CARD_HEIGHT;
        maxPrevThisY = max(prevY,thisY);
        minPrevThisY = min(prevY,thisY);
        
        // top of card
        if(abs(locDir.y) > EPSILON) {
            ty = ( maxPrevThisY - locOri.y )/locDir.y;
            interY = locOri + ty*locDir;
            if( ty >= 0.0 && minPrevThisZ<=interY.z && interY.z<=maxPrevThisZ && abs(interY.x)<=CARD_WIDTH ) {
                if(ty < tCard) {
                    tCard = ty;
                    material = MATERIAL_CARD_SIDE_YM;
                }
                
            }
        }
        
        // vertical wall
        if(abs(locDir.z) > EPSILON) {
            tz = ( thisZ - locOri.z )/locDir.z;
            interZ = locOri + tz*locDir;
            if( tz >= 0.0 && minPrevThisY<=interZ.y && interZ.y<=maxPrevThisY && abs(interZ.x)<=CARD_WIDTH ) {
                if(tz < tCard) {
                    tCard = tz;
                    if(locDir.z<0.0) {material = MATERIAL_CARD_FACE;}
                    else              {material = MATERIAL_CARD_BACK;}
                }
            }
        }
    }
    
    if(tCard > INFINITY/2.0) {res.dist = -1.0;}
    else{
        vec3 interCard = locOri + tCard*locDir;
        res.dist = tCard;
        res.material = material;
        
        if(material == MATERIAL_CARD_SIDE_XM) {
            if(locDir.x >= 0.0) {
                res.material = MATERIAL_CARD_SIDE_XP;
                res.normal = x;
                res.uvw = vec3(interCard.x, interCard.y, interCard.z);
            } else {
                res.material = MATERIAL_CARD_SIDE_XM;
                res.normal = -x;
                res.uvw = vec3(interCard.x, interCard.y, interCard.z);
            }
        } else if(material == MATERIAL_CARD_SIDE_YM) {
            if(locDir.y >= 0.0) {
                res.material = MATERIAL_CARD_SIDE_YM;
                res.normal = y;
                res.uvw = vec3(interCard.x, interCard.y, interCard.z);
            } else {
                res.material = MATERIAL_CARD_SIDE_YP;
                res.normal = -y;
                res.uvw = vec3(interCard.x, interCard.y, interCard.z);
            }
        } else if(material==MATERIAL_CARD_FACE) {
            res.normal = z;
            res.uvw = vec3(interCard.x, interCard.y-bounceFloor(interCard.z,bounceHeight,bounceStepSize), interCard.z);
        } else if(material == MATERIAL_CARD_BACK) {
            res.normal = -z;
            res.uvw = vec3(interCard.x, interCard.y-bounceFloor(interCard.z,bounceHeight,bounceStepSize), interCard.z);
        }
    }    
    
    return res;
}

// 1 to 13 is number+JQK
vec3 cardSymbol(vec2 uv, int id, vec2 center, float size, int suitColor) {
    vec3 color = vec3(1.0);
    
    float x = (uv.x - center.x)/size;
    float y = (uv.y - center.y)/size;
        
    float phi = -1.0;
    if(id==1) {
        phi = multiMin4(1.4-2.8*x-y,1.4+2.8*x-y,2.8+2.0*y,-max(multiMin3(0.075-0.67*x-0.178571*y,0.075+0.67*x-0.178571*y,0.0892857+0.357143*y),multiMin4(-0.401786-0.535714*y,-1.15*x-0.410714*y,1.15*x-0.410714*y,2.57857+1.35714*y)));
    } else if(id==2) {
        float t1 = 0.937994*(1.4+y);
        float t2 = 0.75*(1.0+x);
        float t3 = sqr(-0.75+(t2));
        float t4 = sqr(-1.87638+(t1));
          phi = multiMax3(multiMin3(1.0-1.77778*(t3)-1.77778*(t4),-1.0+16.0*(t3)+16.0*(t4),-min(1.87638-(t1),-0.951057*(-0.75+(t2))-0.309017*(-1.87638+(t1)))),multiMin4(1.0-1.33333*(-0.75+(t2)),1.0+1.33333*(-0.75+(t2)),1.0-4.0*(-0.25+(t1)),1.0+4.0*(-0.25+(t1))),multiMin4(-0.5+(t1),-0.951057*(-1.19721+(t2))-0.309017*(-0.5+(t1)),1.0-0.697681*(-1.19721+(t2))*(-1.19721+(t2))-0.697681*(-0.5+(t1))*(-0.5+(t1)),-1.0+2.05716*(-1.19721+(t2))*(-1.19721+(t2))+2.05716*(-0.5+(t1))*(-0.5+(t1))));
    } else if(id==3) {
        float t1 = sqr(x);
          phi = max(multiMin3(0.489796-(t1)+(-1.74927-1.49938*y)*y,1.77778+5.44444*(t1)+y*(9.52381+8.16327*y),-min(0.-1.4*x,1.+1.71429*y)),multiMin3(0.489796-(t1)+(1.74927-1.49938*y)*y,1.77778+5.44444*(t1)+y*(-9.52381+8.16327*y),-min(0.-1.4*x,1.-1.71429*y)));
    } else if(id==4) {
           phi = min(multiMax3(multiMin4(3.16667-4.16667*x,-1.16667+4.16667*x,-0.333333-1.66667*y,2.33333+1.66667*y),multiMin4(2.77778-2.77778*x,-0.777778+2.77778*x,-0.833333-4.16667*y,2.83333+4.16667*y),multiMin5(2.47-3.25*x,0.990349+0.990349*x,2.18512+2.25965*x-1.61404*y,1.59035-1.13596*y,1.87+2.75*y)),-multiMin3(0.49-1.75*x,0.66+1.75*x-1.25*y,0.25+1.25*y));
    } else if(id==5) {
        float t1 = sqr(-0.7+0.714286*(1.4+y));
        float t2 = 2.85714*(-0.35+0.7*(1.0+x));
        float t3 = 2.0*(-1.5+0.714286*(1.4+y));
        float t4 = 1.42857*(-0.7+0.7*(1.0+x));
        float t5 = 5.0*(-0.2+0.7*(1.0+x));
        float t6 = 5.0*(-1.8+0.714286*(1.4+y));
        float t7 = 5.0*(-1.2+0.714286*(1.4+y));
        phi = multiMax4(multiMin3(1.0-2.04082*sqr(-0.7+0.7*(1.0+x))-2.04082*(t1),-1.0+11.1111*sqr(-0.7+0.7*(1.0+x))+11.1111*(t1),-min(-1.0*(-0.7+0.7*(1.0+x)),-0.7+0.714286*(1.4+y))),multiMin4(1.0-(t4),1.0+(t4),1.0-(t6),1.0+(t6)),multiMin4(1.0-(t2),1.0+(t2),1.0-(t7),1.0+(t7)),multiMin4(1.0-(t5),1.0+(t5),1.0-(t3),1.0+(t3)));
    } else if(id==6) {
        float t1 = sqr(x);
        phi = max(min(-0.280411-(t1)+(-3.44566-2.31812*y)*y,5.97113+5.44444*(t1)+y*(18.7597+12.6209*y)),multiMin4(0.240625+0.34658*x-0.156326*y,0.165609-0.118292*y,0.0713646+0.0303719*x+0.0960231*y,-0.0346321-0.376951*x+0.178595*y));
    } else if(id==7) {
        phi = max(multiMin4(1.-x,1.+x,5.6-4.0*y,-3.6+4.0*y),multiMin4(1.20252-0.364399*x-0.931243*y,-0.103283+0.931243*x-0.364399*y,0.603283-0.931243*x+0.364399*y,1.4+y));
    } else if(id==8) {
        float t1 = sqr(x);
        phi = max(min(0.489796-(t1)+(-1.74927-1.49938*y)*y,1.77778+5.44444*(t1)+y*(9.52381+8.16327*y)),min(0.489796-(t1)+(1.74927-1.49938*y)*y,1.77778+5.44444*(t1)+y*(-9.52381+8.16327*y)));
    } else if(id==9) {
        float t1 = sqr(x);
        phi = max(min(-0.280411-(t1)+(3.44566-2.31812*y)*y,5.97113+5.44444*(t1)+y*(-18.7597+12.6209*y)),multiMin4(-0.0346321+0.376951*x-0.178595*y,0.0713646-0.0303719*x-0.0960231*y,0.165609+0.118292*y,0.240625-0.34658*x+0.156326*y));
    } else if(id==10) {
        phi = max(min(0.816327+(1.22449-2.04082*x)*x-0.510204*sqr(y),x*(-6.66667+11.1111*x)+2.77778*y*y),multiMin4(-3.-5.0*x,5.+5.0*x,1.-0.714286*y,1.+0.714286*y));
    } else if(id==11) {
        phi = multiMax3(multiMin3(-0.55-1.39286*y,0.825255+(-0.326531-1.30612*x)*x+(-0.781706-0.989822*y)*y,-0.0486111+x*(1.77778+7.11111*x)+y*(4.25595+5.38903*y)),multiMin4(3.-4.0*x,-1.+4.0*x,1.56-1.11429*y,0.44+1.11429*y),multiMin4(1.3913-1.3913*x,0.608696+1.3913*x,4.875-3.48214*y,-2.875+3.48214*y));
    } else if(id==12) {
        phi = max(min(0.998283+(-0.0862742-1.08456*x)*x+(0.00145184-0.511241*y)*y,-0.995231+x*(0.23965+3.01266*x)+y*(-0.00403288+1.42011*y)),multiMin4(-0.0868019-1.1716*x-1.12614*y,-0.193198+0.460248*x-0.44239*y,0.829594-0.460248*x+0.44239*y,0.723198+1.1716*x+1.12614*y));
    } else if(id==13) {
        phi = multiMax3(multiMin4(-2.24012-4.24012*x,4.24012+4.24012*x,1.-0.714286*y,1.+0.714286*y),multiMin4(1.06003+1.06003*x-0.928571*y,0.820061-0.585758*y,0.+0.585758*y,-0.23997-1.06003*x+0.928571*y),multiMin4(-0.23997-1.06003*x-0.928571*y,0.-0.585758*y,0.820061+0.585758*y,1.06003+1.06003*x+0.928571*y));
    }
    
    if(phi>=0.0) {
        color.r = suitColor==1?1.0:0.0;
        color.g = 0.0;
        color.b = 0.0;
    }
    
    return color;
}


// 1=diamond, 2=heart, 3=spade, 4=club
vec3 cardSuit(vec2 uv, int id, vec2 center, float size) {
    vec3 color = vec3(1.0);
    
    float x = (uv.x - center.x)/size;
    float y = (uv.y - center.y)/size;
    
    float phi = -1.0;
    if(id==1) {
        phi = multiMin4(1.4-1.4*x-y,1.4+1.4*x-y,1.4-1.4*x+y,1.4+1.4*x+y);
    } else if(id==2) {
           phi = multiMax3(0.202435+(-2.41421-2.91421*x)*x+(1.21619-1.24268*y)*y,0.202435+(2.41421-2.91421*x)*x+(1.21619-1.24268*y)*y,multiMin3(-0.114277-0.788252*y,1.11428-1.20711*x+0.788252*y,1.11428+1.20711*x+0.788252*y));
    } else if(id==3) {
        float t1 = (0.064261+0.298355*y)*y;
        float t2 = (-0.742857-1.72449*y)*y;
        phi = multiMax4(0.42+(2.41421-2.91421*x)*x+(t2),0.42+(-2.41421-2.91421*x)*x+(t2),multiMin3(1.3-1.20711*x-0.928571*y,1.3+1.20711*x-0.928571*y,-0.3+0.928571*y),multiMin6(1.8-1.20711*x,1.8+1.20711*x,0.3-0.928571*y,1.3+0.928571*y,0.124567+(-1.50366+0.504189*x)*x+(t1),0.124567+(1.50366+0.504189*x)*x+(t1)));
    } else if(id==4) {
        phi = multiMax4(-1.22851-3.48205*x*x+(5.31619-3.17049*y)*y,0.249948+(-3.23205-3.48205*x)*x+(-0.0255681-3.17049*y)*y,0.249948+(3.23205-3.48205*x)*x+(-0.0255681-3.17049*y)*y,multiMin6(1.8-x,1.8+x,0.264102-0.954213*y,1.3359+0.954213*y,0.127498+(-1.24567+0.346021*x)*x+(0.0897412+0.31506*y)*y,0.127498+(1.24567+0.346021*x)*x+(0.0897412+0.31506*y)*y));
    }
    
    if(phi>=0.0) {
        color.r = id<3?1.0:0.0;
        color.g = 0.0;
        color.b = 0.0;
    }
    
    return color;
}

// faces for jack, queen and king.
vec3 cardHead(vec2 uv, int id, vec2 center, float size) {
    vec3 color = vec3(1.0);
    
    float x = (uv.x - center.x)/size;
    float y = (uv.y - center.y)/size;
    
    if(id==11) {
        // face
        if( 1.0-2.04082*x*x-2.77778*y*y >= 0.0) {
            color = vec3(1.0, 215.0/255.0, 140.0/255.0);
        }
        // eyes
        if( max(1.0-816.327*(-0.2+x)*(-0.2+x)-816.327*(-0.1+y)*(-0.1+y),1.0-816.327*(0.2+x)*(0.2+x)-816.327*(-0.1+y)*(-0.1+y)) >= 0.0 ) {
            color = vec3(0.0);
        }
        // hair
        if( multiMax5(min(1.0-44.4444*sqr(0.2+x)-44.4444*sqr(0.15+-0.37+y),-1.0+25.0*sqr(0.2+x)+25.0*sqr(0.25-0.37+y)),min(1.0-44.4444*sqr(-0.2+x)-44.4444*sqr(0.15-0.25+y),-1.0+25.0*sqr(-0.2+x)+25.0*sqr(0.25-0.25+y)),min(1.0-25.0*sqr(0.2+0.29552*(-0.2+x)-0.955336*(0.35+y))-25.0*sqr(-0.955336*(-0.2+x)-0.29552*(0.35+y)),-1.0+20.6612*sqr(0.25+0.29552*(-0.2+x)-0.955336*(0.35+y))+20.6612*sqr(-0.955336*(-0.2+x)-0.29552*(0.35+y))),min(1.0-25.0*sqr(0.2-0.29552*(0.2+x)-0.955336*(0.35+y))-25.0*sqr(-0.955336*(0.2+x)+0.29552*(0.35+y)),-1.0+20.6612*sqr(0.25-0.29552*(0.2+x)-0.955336*(0.35+y))+20.6612*sqr(-0.955336*(0.2+x)+0.29552*(0.35+y))),multiMin4(0.2-x,0.2+x,-0.5-y,0.8+y-abs(-0.1+mod(-0.1+x,0.2)))) >= 0.0 ) {
            color = vec3(163.0/255.0, 107.0/255.0, 2.0/255.0);
        }
        // crown
        if( multiMin4(0.5-x,0.5+x,-0.4+y,0.7-y+abs(-0.1+mod(-0.1+x,0.2))) >= 0.0 ) {
            color = vec3(1.0,234.0/255.0,0.0);
        }
        
    } else if(id==12) {
           // face
        if( 1.0-2.04082*x*x-2.77778*y*y >= 0.0) {
            color = vec3(1.0, 215.0/255.0, 140.0/255.0);
        }
        // eyes
        if( max(1.0-816.327*(-0.2+x)*(-0.2+x)-816.327*(-0.1+y)*(-0.1+y),1.0-816.327*(0.2+x)*(0.2+x)-816.327*(-0.1+y)*(-0.1+y)) >= 0.0 ) {
            color = vec3(0.0);
        }
        // hair
        if( multiMax4(min(-1.0+1.5625*sqr(0.62161*(-0.6+x)-0.783327*(-0.35+y))+1.5625*sqr(0.9+0.783327*(-0.6+x)+0.62161*(-0.35+y)),1.0-1.77778*sqr(0.62161*(-0.6+x)-0.783327*(-0.35+y))-1.77778*sqr(0.75+0.783327*(-0.6+x)+0.62161*(-0.35+y)-0.05*(1.0+cos(10.0*PI*(0.62161*(-0.6+x)-0.783327*(-0.35+y)))))),min(-1.0+1.5625*sqr(0.9-0.783327*(0.6+x)+0.62161*(-0.35+y))+1.5625*sqr(0.62161*(0.6+x)+0.783327*(-0.35+y)),1.0-1.77778*sqr(0.62161*(0.6+x)+0.783327*(-0.35+y))-1.77778*sqr(0.75-0.783327*(0.6+x)+0.62161*(-0.35+y)-0.05*(1.0+cos(10.0*PI*(0.62161*(0.6+x)+0.783327*(-0.35+y)))))),min(1.0-16.0*sqr(0.955336*(-0.25+x)-0.29552*(-0.3+y))-16.0*sqr(0.25+0.29552*(-0.25+x)+0.955336*(-0.3+y)),-1.0+sqr(0.955336*(-0.25+x)-0.29552*(-0.3+y))+ sqr(1.05+0.29552*(-0.25+x)+0.955336*(-0.3+y))),min(1.0-16.0*sqr(0.955336*(0.25+x)+0.29552*(-0.3+y))-16.0*sqr(0.25-0.29552*(0.25+x)+0.955336*(-0.3+y)),-1.0+sqr(0.955336*(0.25+x)+0.29552*(-0.3+y))+sqr(1.05-0.29552*(0.25+x)+0.955336*(-0.3+y)))) >= 0.0 ) {
            color = vec3(163.0/255.0, 107.0/255.0, 2.0/255.0);
        }
        // lips
        if( multiMax3(min(1.0-8.16327*x*x-8.16327*sqr(-0.07-y),-1.0+2.77778*x*x+2.77778*sqr(0.23-y)),min(1.0-59.1716*sqr(0.995004*(-0.12+x)+0.0998334*(0.24+y))-59.1716*sqr(0.13-0.0998334*(-0.12+x)+0.995004*(0.24+y)),-1.0+25.0*sqr(0.995004*(-0.12+x)+0.0998334*(0.24+y))+25.0*sqr(0.24-0.0998334*(-0.12+x)+0.995004*(0.24+y))),min(1.0-59.1716*sqr(0.995004*(0.12+x)-0.0998334*(0.24+y))-59.1716*sqr(0.13+0.0998334*(0.12+x)+0.995004*(0.24+y)),-1.0+25.0*sqr(0.995004*(0.12+x)-0.0998334*(0.24+y))+25.0*sqr(0.24+0.0998334*(0.12+x)+0.995004*(0.24+y)))) >= 0.0 ) {
            color = vec3(1.0, 61.0/255.0, 61.0/255.0);
        }
        // crown
        if( multiMin4(0.5-x, 0.5+x, -0.45+y, 0.75-y+abs(-0.1+mod(-0.1+x,0.2))) >= 0.0 ) {
            color = vec3(1.0,234.0/255.0,0.0);
        }
    } else if(id==13) {
        // face
        if( 1.0-2.04082*x*x-2.77778*y*y >= 0.0) {
            color = vec3(1.0, 215.0/255.0, 140.0/255.0);
        }
        // eyes
        if( max(1.0-816.327*(-0.2+x)*(-0.2+x)-816.327*(-0.1+y)*(-0.1+y),1.0-816.327*(0.2+x)*(0.2+x)-816.327*(-0.1+y)*(-0.1+y)) >= 0.0 ) {
            color = vec3(0.0);
        }
        // hair
        if( multiMax5(min(1.0-44.4444*sqr(0.877583*(-0.15+x)+0.479426*(-0.3+y))-44.4444*sqr(0.15-0.479426*(-0.15+x)+0.877583*(-0.3+y)),-1.0+sqr(0.877583*(-0.15+x)+0.479426*(-0.3+y))+sqr(1.1-0.479426*(-0.15+x)+0.877583*(-0.3+y))),min(1.0-44.4444*sqr(0.877583*(0.15+x)-0.479426*(-0.3+y))-44.4444*sqr(0.15+0.479426*(0.15+x)+0.877583*(-0.3+y)),-1.0+sqr(0.877583*(0.15+x)-0.479426*(-0.3+y))+sqr(1.1+0.479426*(0.15+x)+0.877583*(-0.3+y))),min(-1.0+ x*x+sqr(0.53-y),1.0-2.04082*x*x-2.04082*sqr(0.03-y-0.05*(1.0+cos(10.0*PI*x)))),min(1.0-25.0*sqr(0.2+0.29552*(-0.24+x)-0.955336*(0.35+y))-25.0*sqr(-0.955336*(-0.24+x)-0.29552*(0.35+y)),-1.0+11.1111*sqr(0.4+0.29552*(-0.24+x)-0.955336*(0.35+y))+11.1111*sqr(-0.955336*(-0.24+x)-0.29552*(0.35+y))),min(1.0-25.0*sqr(0.2-0.29552*(0.24+x)-0.955336*(0.35+y))-25.0*sqr(-0.955336*(0.24+x)+0.29552*(0.35+y)),-1.0+11.1111*sqr(0.4-0.29552*(0.24+x)-0.955336*(0.35+y))+11.1111*sqr(-0.955336*(0.24+x)+0.29552*(0.35+y)))) >= 0.0 ) {
            color = vec3(166.0/255.0, 166.0/255.0, 166.0/255.0);
        }
        // crown
        if( multiMin4(0.5 -x,0.5 +x,-0.4+y,0.7 -y+abs(-0.1+mod(-0.1+x,0.2))) >= 0.0 ) {
            color = vec3(1.0,234.0/255.0,0.0);
        }
    }
    
    return color;
}


#ifdef COMPILE_PATTERNS

// check if point is inside box, return position inside box mappd to [1.0, 1.4], return vec2(infinity) if outside.
vec2 isInsideBox(vec2 uv, vec2 center, float size) {
    vec2 newUV = (uv - center)/size;
    if(abs(newUV.x) <= CARD_WIDTH && abs(newUV.y) <= CARD_HEIGHT) {return newUV;}
    else {return vec2(INFINITY);}
}


// patterns in center of number cards
vec3 cardPattern(vec2 uv, int number, int suit, int suitColor) {
    vec3 color = vec3(1.0);
    vec2 newUV = vec2(INFINITY);
    
    //return color;
    
    /*
    if(number==1) {
        color = min(color, cardSuit(uv, suit, vec2(0.0,0.0), 0.5));
    } else if(number==2) {
        color = min(color, cardSuit(uv, suit, vec2(0.0,-0.5), 0.25));
        color = min(color, cardSuit(uv, suit, vec2(0.0,0.5), 0.25));
    } else if(number==3) {
        color = min(color, cardSuit(uv, suit, vec2(0.0,-0.7), 0.2));
        color = min(color, cardSuit(uv, suit, vec2(0.0,0.0), 0.2));
        color = min(color, cardSuit(uv, suit, vec2(0.0,0.7), 0.2));
    } else if(number==4) {
        color = min(color, cardSuit(uv, suit, vec2(-0.25,-0.5), 0.2));
        color = min(color, cardSuit(uv, suit, vec2(-0.25, 0.5), 0.2));
        color = min(color, cardSuit(uv, suit, vec2( 0.25,-0.5), 0.2));
        color = min(color, cardSuit(uv, suit, vec2( 0.25, 0.5), 0.2));
    } else if(number==5) {
        color = min(color, cardSuit(uv, suit, vec2(-0.3,-0.55), 0.2));
        color = min(color, cardSuit(uv, suit, vec2(-0.3, 0.55), 0.2));
        color = min(color, cardSuit(uv, suit, vec2( 0.0,0.0), 0.2));
        color = min(color, cardSuit(uv, suit, vec2( 0.3, -0.55), 0.2));
        color = min(color, cardSuit(uv, suit, vec2( 0.3, 0.55), 0.2));
    } else if(number==6) {
        color = min(color, cardSuit(uv, suit, vec2(-0.3,-0.65), 0.18));
        color = min(color, cardSuit(uv, suit, vec2(-0.3, 0.0), 0.18));
        color = min(color, cardSuit(uv, suit, vec2(-0.3, 0.65), 0.18));
        color = min(color, cardSuit(uv, suit, vec2(0.3, -0.65), 0.18));
        color = min(color, cardSuit(uv, suit, vec2(0.3, 0.0), 0.18));
        color = min(color, cardSuit(uv, suit, vec2(0.3, 0.65), 0.18));
    } else if(number==7) {
        color = min(color, cardSuit(uv, suit, vec2(-0.3,-0.7), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(-0.3, 0.0), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(-0.3, 0.7), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(0.3, -0.7), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(0.3, 0.0), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(0.3, 0.7), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(0.0, 0.35), 0.15));
    } else if(number==8) {
        color = min(color, cardSuit(uv, suit, vec2(-0.3,-0.7), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(-0.3, 0.0), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(-0.3, 0.7), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(0.3, -0.7), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(0.3, 0.0), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(0.3, 0.7), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(0.0, 0.35), 0.15));
        color = min(color, cardSuit(uv, suit, vec2(0.0, -0.35), 0.15));
    } else if(number==9) {
        color = min(color, cardSuit(uv, suit, vec2(-0.3,-0.7), 0.12));
        color = min(color, cardSuit(uv, suit, vec2(-0.3,-0.23), 0.12));
        color = min(color, cardSuit(uv, suit, vec2(-0.3, 0.23), 0.12));
        color = min(color, cardSuit(uv, suit, vec2(-0.3, 0.7), 0.12));
        color = min(color, cardSuit(uv, suit, vec2( 0.3,-0.7), 0.12));
        color = min(color, cardSuit(uv, suit, vec2( 0.3,-0.23), 0.12));
        color = min(color, cardSuit(uv, suit, vec2( 0.3, 0.23), 0.12));
        color = min(color, cardSuit(uv, suit, vec2( 0.3, 0.7), 0.12));
        color = min(color, cardSuit(uv, suit, vec2( 0.0, 0.0), 0.12));
    } else if(number==10) {
        color = min(color, cardSuit(uv, suit, vec2(-0.3,-0.7), 0.12));
        color = min(color, cardSuit(uv, suit, vec2(-0.3,-0.23), 0.12));
        color = min(color, cardSuit(uv, suit, vec2(-0.3, 0.23), 0.12));
        color = min(color, cardSuit(uv, suit, vec2(-0.3, 0.7), 0.12));
        color = min(color, cardSuit(uv, suit, vec2( 0.3,-0.7), 0.12));
        color = min(color, cardSuit(uv, suit, vec2( 0.3,-0.23), 0.12));
        color = min(color, cardSuit(uv, suit, vec2( 0.3, 0.23), 0.12));
        color = min(color, cardSuit(uv, suit, vec2( 0.3, 0.7), 0.12));
        color = min(color, cardSuit(uv, suit, vec2( 0.0, -0.45), 0.12));
        color = min(color, cardSuit(uv, suit, vec2( 0.0, 0.45), 0.12));
    }
    */
    
    if(number==1) {
        newUV = min(newUV,isInsideBox(uv, vec2(0.0,0.0), 0.5));
    } else if(number==2) {
        newUV = min(newUV,isInsideBox(uv, vec2(0.0,-0.5), 0.25));
        newUV = min(newUV,isInsideBox(uv, vec2(0.0,0.5), 0.25));
    } else if(number==3) {
        newUV = min(newUV,isInsideBox(uv, vec2(0.0,-0.7), 0.2));
        newUV = min(newUV,isInsideBox(uv, vec2(0.0,0.0), 0.2));
        newUV = min(newUV,isInsideBox(uv, vec2(0.0,0.7), 0.2));
    } else if(number==4) {
        newUV = min(newUV,isInsideBox(uv, vec2(-0.25,-0.5), 0.2));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.25, 0.5), 0.2));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.25,-0.5), 0.2));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.25, 0.5), 0.2));
    } else if(number==5) {
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3,-0.55), 0.2));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3, 0.55), 0.2));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.0,0.0), 0.2));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.3, -0.55), 0.2));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.3, 0.55), 0.2));
    } else if(number==6) {
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3,-0.65), 0.18));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3, 0.0), 0.18));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3, 0.65), 0.18));
        newUV = min(newUV,isInsideBox(uv, vec2(0.3, -0.65), 0.18));
        newUV = min(newUV,isInsideBox(uv, vec2(0.3, 0.0), 0.18));
        newUV = min(newUV,isInsideBox(uv, vec2(0.3, 0.65), 0.18));
    } else if(number==7) {
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3,-0.7), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3, 0.0), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3, 0.7), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(0.3, -0.7), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(0.3, 0.0), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(0.3, 0.7), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(0.0, 0.35), 0.15));
    } else if(number==8) {
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3,-0.7), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3, 0.0), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3, 0.7), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(0.3, -0.7), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(0.3, 0.0), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(0.3, 0.7), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(0.0, 0.35), 0.15));
        newUV = min(newUV,isInsideBox(uv, vec2(0.0, -0.35), 0.15));
    } else if(number==9) {
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3,-0.7), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3,-0.23), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3, 0.23), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3, 0.7), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.3,-0.7), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.3,-0.23), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.3, 0.23), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.3, 0.7), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.0, 0.0), 0.12));
    } else if(number==10) {
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3,-0.7), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3,-0.23), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3, 0.23), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2(-0.3, 0.7), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.3,-0.7), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.3,-0.23), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.3, 0.23), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.3, 0.7), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.0, -0.45), 0.12));
        newUV = min(newUV,isInsideBox(uv, vec2( 0.0, 0.45), 0.12));
    }

	
    if(newUV.x < INFINITY/2.0) {return min(vec3(1.0), cardSuit(newUV, suit, vec2(0.0,0.0), 1.0)); }
    else {return vec3(1.0);}
    
    return color;
}
#endif


// card front face
vec4 cardFace(vec2 uv, int number, int suit, int borderTint) {
    vec3 color = vec3(1);
    float x = uv.x;
    float y = uv.y;

    color = vec3(1.0);
    color = minVec3(color, cardSymbol(uv,number,vec2(-0.75,1.05),0.12, suit<3?1:0));
    color = minVec3(color, cardSuit(uv,suit,vec2(-0.75,0.6),0.12));
    color = minVec3(color, cardSymbol(-uv,number,vec2(-0.75,1.05),0.12, suit<3?1:0));
    color = minVec3(color, cardSuit(-uv,suit,vec2(-0.75,0.6),0.12));

    
    // draw the face or the suit pattern
    if( number==11 || number==12 || number==13 ) {
        color = min(color, cardHead(uv,number,vec2(0.0,0.0),0.9));
    } else {
#ifdef COMPILE_PATTERNS
        color = min(color, cardPattern(uv, number, suit, suit<3?1:0));
#endif
    }
    
    
    // border
    if(x<-CARD_WIDTH+CARD_BORDER_SIZE  || x>CARD_WIDTH-CARD_BORDER_SIZE ||
       y<-CARD_HEIGHT+CARD_BORDER_SIZE || y>CARD_HEIGHT-CARD_BORDER_SIZE )
    {
        if(borderTint==1) {
            color = vec3(CARD_BORDER_TINT1);
        } else {
            color = vec3(CARD_BORDER_TINT2);
        }
        
    }
    
    return vec4(color, 1.0);
}


// card back face, based on the original Solitaire desing.
vec4 cardBack(vec2 uv, int borderTint) {
    
    float x = uv.x;
    float y = uv.y;
    
    // sky
    vec4 color = vec4(0.0, 1.0, 1.0, 1.0);
    // water
    if(0.5 + 0.025*sin(PI*8.0*x) - y >= 0.0) {
        color = vec4(0.0, 43.0/255.0, 170.0/255.0, 1.0);
    }
    // sand
    if( -0.3 + 0.045*sin(PI*5.0*x - 0.6214) - y >= 0.0) {
        color = vec4(1.0, 1.0, 111.0/255.0, 1.0);
    }
    // sun
    if( 1.0 - 25.0*(-0.6 + x)*(-0.6 + x) - 25.0*(-1.0 + y)*(-1.0 + y) >= 0.0 ) {
        color = vec4(1.0, 1.0, 0.0, 1.0);
    }
    // tree
    if( multiMin4(0.6-y, 1.05+y, 0.397485+(0.724928-0.25*x)*x + (-0.277479-0.25*y)*y, -0.217087+(-0.723458+0.173611*x)*x + (0.142472+0.173611*y)*y) >= 0.0 ) {
        color = vec4(110.0/255.0, 61.0/255.0, 56.0/255.0, 1.0);
    }
    // leaves
    if( multiMax4(min(0.23242+(0.208239-8.16327*x)*x+(5.00205-8.16327*y)*y,-0.20324+x*(3.45391+6.25*x)+y*(-2.82657+6.25*y)),min(-4.32311+(-7.66587-8.16327*x)*x+(10.7262-8.16327*y)*y,1.82316+x*(6.44035+6.25*x)+y*(-5.39452+6.25*y)),min(0.0499321+(2.03551-6.25*x)*x+(4.42814-6.25*y)*y,-0.919179+x*(-0.616931+4.0*x)+y*(-0.955262+4.0*y)),min(0.0212551+(-3.72533-4.93827*x)*x+(2.33562-4.93827*y)*y,-0.910767+x*(1.07096+3.30579*x)+y*(-0.18162+3.30579*y))) >= 0.0 ) {
        color = vec4(42.0/255.0, 222.0/255.0, 61.0/255.0, 1.0);
    }
    // border
    if(x<-CARD_WIDTH+CARD_BORDER_SIZE  || x>CARD_WIDTH-CARD_BORDER_SIZE ||
       y<-CARD_HEIGHT+CARD_BORDER_SIZE || y>CARD_HEIGHT-CARD_BORDER_SIZE )
    {
        if(borderTint==1) {
            color = vec4(vec3(CARD_BORDER_TINT1), 1.0);
        } else {
            color = vec4(vec3(CARD_BORDER_TINT2), 1.0);
        }
    }
    
    return color;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if( texture2D( iChannel0, vec2(65.5/256.0,0.25)).x > 0.0 ) {
        
        //=============================================
        // if space is pressed : 2D mode
        
        vec2 uvScreen = vec2(fragCoord.xy/iResolution.xy);
        uvScreen = 1.4*(2.0*uvScreen - vec2(1.0))*iResolution.xy/iResolution.y;
    
        fragColor = vec4(vec3(0.0,127.0/255.0,9.0/255.0),1.0);
    
        for(int i=0; i<14; i++) {
            vec2 center = vec2( -2.1 + mod(float(i),7.0)*4.2/6.0, (i<7?0.65:-0.65) );
            vec2 uv = (uvScreen-center)*3.0;
        
               if(abs(uv.x)<=CARD_WIDTH && abs(uv.y)<=CARD_HEIGHT) {
                fragColor = vec4(vec3(1.0), 1.0);
            }
        }
    
        for(int i=0; i<13; i++) {
            vec2 center = vec2( -2.1 + mod(float(i),7.0)*4.2/6.0, (i<7?0.65:-0.65) );
            vec2 uv = (uvScreen-center)*3.0;
            if(abs(uv.x)<=CARD_WIDTH && abs(uv.y)<=CARD_HEIGHT) {
                vec3 color = cardFace(uv, i+1, int(mod(float(i),4.0))+1, 1).xyz;
                fragColor = min(vec4(vec3(color),1.0),fragColor);
            }
        }
        vec2 center = vec2( 2.1, -0.65 );
        vec2 uv = (uvScreen-center)*3.0;
        if(abs(uv.x)<=CARD_WIDTH && abs(uv.y)<=CARD_HEIGHT) {
            vec3 color = cardBack(uv, 1).xyz;
            fragColor = min(vec4(vec3(color),1.0),fragColor);
        }
        
        
        
    } else {
		
        //=============================================
        // if space is not pressed : 3D mode
    
    
    	float time = iGlobalTime;
    	vec3 uvw = vec3(fragCoord.xy/iResolution.xy, 0.0);
    	vec2 scrPixelPos = (2.0*uvw.xy - vec2(1.0))*iResolution.xy/iResolution.x;

    	vec3 camPos = camPosFun(time);
    	vec3 camLookAt = vec3(0.0, 0.0, 0.0);
    	vec3 camLookForward = normalize(camLookAt - camPos);

    	vec3 worldUp = vec3(0.0, 1.0, 0.0);
    	vec3 camLookRight = normalize(cross(camLookForward, worldUp));
    	vec3 camLookUp = normalize(cross(camLookRight, camLookForward));

    	// screen is at distance 1 from eye.
    	float worldScreenHalfWidth = 0.5;
    	vec3 worldPixelPos =
        	camPos
        	+ camLookForward
        	+ scrPixelPos.x*worldScreenHalfWidth*camLookRight
        	+ scrPixelPos.y*worldScreenHalfWidth*camLookUp;
    	vec3 worldPixelLookDir = normalize(worldPixelPos-camPos);

    	Intersection closestInter;
    	closestInter.dist = -1.0;

    	// objects. Ugly hardcoded pre-processor stuff, but it's the only way I could parameterize the number of cards and still have the shader compile.

#ifdef OBJECT20
    	const int nbObjects = 21;
#else
#ifdef OBJECT19
    	const int nbObjects = 20;
#else
#ifdef OBJECT18
    	const int nbObjects = 19;
#else
#ifdef OBJECT17
    	const int nbObjects = 18;
#else
#ifdef OBJECT16
    	const int nbObjects = 17;
#else
#ifdef OBJECT15
    	const int nbObjects = 16;
#else
#ifdef OBJECT14
    	const int nbObjects = 15;
#else
#ifdef OBJECT13
    	const int nbObjects = 14;
#else        
#ifdef OBJECT12
    	const int nbObjects = 13;
#else
#ifdef OBJECT11
    	const int nbObjects = 12;
#else
#ifdef OBJECT10
        const int nbObjects = 11;
#else
#ifdef OBJECT9
        const int nbObjects = 10;
#else
#ifdef OBJECT8
        const int nbObjects = 9;
#else
#ifdef OBJECT7
        const int nbObjects = 8;
#else
#ifdef OBJECT6
        const int nbObjects = 7;
#else
#ifdef OBJECT5
        const int nbObjects = 6;
#else
#ifdef OBJECT4
        const int nbObjects = 5;
#else
#ifdef OBJECT3
        const int nbObjects = 4;
#else
#ifdef OBJECT2
        const int nbObjects = 3;
#else
#ifdef OBJECT1
        const int nbObjects = 2;
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif        
#endif
#endif
#endif
#endif
#endif
#endif
#endif
#endif        
#endif
#endif
    	Intersection objects[nbObjects];
	    
	    objects[ 0] = rectangle(camPos, worldPixelLookDir, vec3(0.0,-CARD_HEIGHT,0.0), vec3(0.0,1.0,0.0), vec2(50.0,50.0));
#ifdef OBJECT1
        objects[ 1] = fallingCard(time, camPos, worldPixelLookDir, 0.678, 0.0);
#endif
#ifdef OBJECT2
	    objects[ 2] = fallingCard(time, camPos, worldPixelLookDir, 1.053, 0.25);
#endif
#ifdef OBJECT3
	    objects[ 3] = fallingCard(time, camPos, worldPixelLookDir, 0.817, 0.5);
#endif
#ifdef OBJECT4
	    objects[ 4] = fallingCard(time, camPos, worldPixelLookDir, 0.985, 0.75);
#endif
#ifdef OBJECT5
	    objects[ 5] = fallingCard(time, camPos, worldPixelLookDir, 1.164, 0.33);
#endif
#ifdef OBJECT6
	    objects[ 6] = fallingCard(time, camPos, worldPixelLookDir, 0.773, 0.66);
#endif
#ifdef OBJECT7
	    objects[ 7] = fallingCard(time, camPos, worldPixelLookDir, 0.876, 0.15);
#endif
#ifdef OBJECT8
	    objects[ 8] = fallingCard(time, camPos, worldPixelLookDir, 1.350, 0.30);
#endif
#ifdef OBJECT9
	    objects[ 9] = fallingCard(time, camPos, worldPixelLookDir, 0.718, 0.45);
#endif
#ifdef OBJECT10
	    objects[10] = fallingCard(time, camPos, worldPixelLookDir, 0.989, 0.60);
#endif
#ifdef OBJECT11
	    objects[11] = fallingCard(time, camPos, worldPixelLookDir, 1.261, 0.75);
#endif
#ifdef OBJECT112
	    objects[12] = fallingCard(time, camPos, worldPixelLookDir, 0.877, 0.90);
#endif
#ifdef OBJECT113
	    objects[13] = fallingCard(time, camPos, worldPixelLookDir, 1.111, 0.125);
#endif
#ifdef OBJECT114
	    objects[14] = fallingCard(time, camPos, worldPixelLookDir, 0.871, 0.325);
#endif
#ifdef OBJECT115
	    objects[15] = fallingCard(time, camPos, worldPixelLookDir, 1.095, 0.625);
#endif
#ifdef OBJECT116
	    objects[16] = fallingCard(time, camPos, worldPixelLookDir, 0.941, 0.875);
#endif
#ifdef OBJECT117
	    objects[17] = fallingCard(time, camPos, worldPixelLookDir, 1.123, 0.513);
#endif
#ifdef OBJECT118
	    objects[18] = fallingCard(time, camPos, worldPixelLookDir, 0.799, 0.791);
#endif
#ifdef OBJECT119
	    objects[19] = fallingCard(time, camPos, worldPixelLookDir, 0.800, 0.437);
#endif
#ifdef OBJECT120
	    objects[20] = fallingCard(time, camPos, worldPixelLookDir, 1.110, 0.966);
#endif        
	        
	    for(int i=0; i<nbObjects; i++) {
	        if(objects[i].dist > 0.0 && (closestInter.dist < 0.0 || objects[i].dist < closestInter.dist)) {
	          closestInter = objects[i];
	        }
	    }
	    
        // if a collision occured, get color depending on material.
	    if(closestInter.dist > 0.0) {
	        if(closestInter.material == MATERIAL_UVW){
	            fragColor = vec4( closestInter.uvw, 1.0 );
	        } else if(closestInter.material == MATERIAL_FLOOR){
	            fragColor = vec4( 0.7*vec3(0.0,127.0/255.0,9.0/255.0), 1.0 );
	        } else if(closestInter.material == MATERIAL_NORMAL) {
	            fragColor = vec4( closestInter.normal, 1.0 );
	        } else if(closestInter.material == MATERIAL_CARD_BACK) {
	            if( mod( EPSILON + closestInter.uvw.z ,2.0/CARD_DENSITY) <= 1.0/CARD_DENSITY ) {
	                fragColor = cardBack( vec2(-closestInter.uvw.x, closestInter.uvw.y) , 1 );
	            } else {
	                fragColor = cardBack( vec2(-closestInter.uvw.x, closestInter.uvw.y) , 2 );
	            }
	            
	        } else if(closestInter.material == MATERIAL_CARD_FACE) {
	            if( mod( -EPSILON + closestInter.uvw.z ,2.0/CARD_DENSITY) <= 1.0/CARD_DENSITY ) {
	                fragColor = cardFace(closestInter.uvw.xy, closestInter.info1, closestInter.info2, 1);
	            } else {
	                fragColor = cardFace(closestInter.uvw.xy, closestInter.info1, closestInter.info2, 2);
	            }
	        } else if (closestInter.material == MATERIAL_CARD_SIDE_XM ||
	                   closestInter.material == MATERIAL_CARD_SIDE_XP ||
	                   closestInter.material == MATERIAL_CARD_SIDE_YM || 
	                   closestInter.material == MATERIAL_CARD_SIDE_YP)
	        {
	            if( mod( closestInter.uvw.z ,2.0/CARD_DENSITY) <= 1.0/CARD_DENSITY ) {
	                fragColor = vec4(vec3(CARD_BORDER_TINT1), 1.0);
	            } else {
	                fragColor = vec4(vec3(CARD_BORDER_TINT2), 1.0);
	            }
	        }
            
	    } else {
	        fragColor = vec4( vec3(0.0,127.0/255.0,9.0/255.0), 1.0);
	    }
    
    }
    

}