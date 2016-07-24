// Shader downloaded from https://www.shadertoy.com/view/4tjGR3
// written by shadertoy user RavenWorks
//
// Name: VR blobject
// Description: Saving performance in high-res VR by only raymarching on the pixels that can actually see the raymarched object.
//    Poly-bg version here: [url]http://raven.works/projects/raymarchObject/[/url]
//    I could watch this blob all day :P
//#define SHOW_RAYMARCHED_BOUNDS


const float PI =3.141592;
const float PI2=6.2831853;


const vec3 objCenter = vec3(0.0,1.35,-0.75);



float smoothBlend( float a, float b, float k ){
    float h = clamp(0.5+0.5*(b-a)/k,0.0,1.0);
    return mix(b,a,h) - k*h*(1.0-h);
}

void hardAdd(inout float curD, float newD){
    if (newD < curD) {
        curD = newD;
    }
}
void smoothAdd(inout float curD, float newD, float blendPower){//blend colors too?
    curD = smoothBlend( newD, curD, blendPower );
}


float obj_ball(vec3 p, vec3 center, float radius){
    return length(p-center)-radius;
}




bool testAABB(vec3 rayPt, vec3 rayDir, vec3 boxMid, vec3 boxSizeHalf, out float dist){
    
    // thank you http://gamedev.stackexchange.com/a/18459
    
    vec3 lbGap = (boxMid-boxSizeHalf-rayPt)/rayDir;
    vec3 rtGap = (boxMid+boxSizeHalf-rayPt)/rayDir;
    
    float tmin = max(max(min(lbGap.x,rtGap.x),min(lbGap.y,rtGap.y)),min(lbGap.z,rtGap.z));
    float tmax = min(min(max(lbGap.x,rtGap.x),max(lbGap.y,rtGap.y)),max(lbGap.z,rtGap.z));
    if (tmax < 0.0) return false;
    if (tmin > tmax) return false;
	
	dist = tmin;
	
    return true;
    
}


const vec3 e=vec3(0.001,0,0);
const float maxd=256.0; //Max depth
float nearestD = maxd;
vec3 color = vec3(0.0,0.0,1.0);
vec3 normal = vec3(0.0);
const vec3 lightPt = vec3(0.0,1.9,0.0);

void renderAABB(vec3 rayPt, vec3 rayDir, vec3 boxMid, vec3 boxSizeHalf, vec3 boxColor, out float dist){
    float curDist;
    if (testAABB(rayPt, rayDir, boxMid, boxSizeHalf, curDist)) {
        if (curDist < dist) {
            
            vec3 intersectPt = rayPt + rayDir*curDist;
            vec3 norm = (intersectPt - boxMid) / boxSizeHalf;
            
            // I'm sure this is very silly but whatever
            if (abs(norm.x) > abs(norm.y)) {
                norm.y = 0.0;
                if (abs(norm.x) > abs(norm.z)) {
                    norm.z = 0.0;
                    norm.x = (norm.x>0.0)?1.0:-1.0;
                } else {
                    norm.x = 0.0;
                    norm.z = (norm.z>0.0)?1.0:-1.0;
                }
            } else {
                norm.x = 0.0;
                if (abs(norm.y) > abs(norm.z)) {
                    norm.z = 0.0;
                    norm.y = (norm.y>0.0)?1.0:-1.0;
                } else {
                    norm.y = 0.0;
                    norm.z = (norm.z>0.0)?1.0:-1.0;
                }
            }
            
            normal = norm;
            color = boxColor;
            dist = curDist;
            
        }
    }
}





vec3 blobBallPos(float i){
    
    float v = iGlobalTime*2.0 + i*100.0;
    return vec3(
        sin( v + sin(v*0.8) + sin(v*0.2)*sin(v*2.1) )*0.1,
    	sin( v + sin(v*0.6) + sin(v*0.4)*sin(v*2.2) )*0.1,
    	sin( v + sin(v*0.4) + sin(v*0.6)*sin(v*2.3) )*0.1
    );
    
}

float blobDistance(vec3 p){
    
    float distance = 9999.9;
    const float blobRad = 0.09;
    
    hardAdd(distance, obj_ball(p, objCenter+blobBallPos(0.0), blobRad) );
    for(float i=1.0; i<8.0; i+=1.0){
    	smoothAdd(distance, obj_ball(p, objCenter+blobBallPos(i), blobRad) , 0.08);
    }
    
    
    
    
    
    
    return distance;
    
}

void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 fragRayOri, in vec3 fragRayDir ) {
    
    
    
    vec3 scrCoord = fragRayOri;
    vec3 curCameraRayUnit = fragRayDir;
    
    
    color = vec3(0.0);
    normal = vec3(0.0);
    
    
    scrCoord.y += 1.5;
    
    
    
    vec3 wallColor = vec3(0.75,0.75,1.0);
    vec3 standColor = vec3(0.625,0.625,1.0);
    vec3 standAccentColor = vec3(0.5625,0.5625,1.0);
    vec3 floorTileColor = vec3(0.6875,0.6875,1.0);
    
    renderAABB(scrCoord,curCameraRayUnit,vec3(0.0,1.0,2.1),vec3(2.0,1.0,0.1),wallColor,nearestD);
    renderAABB(scrCoord,curCameraRayUnit,vec3(0.0,1.0,-2.1),vec3(2.0,1.0,0.1),wallColor,nearestD);
    renderAABB(scrCoord,curCameraRayUnit,vec3(0.0,-0.1,0.0),vec3(2.0,0.1,2.0),wallColor,nearestD);
    renderAABB(scrCoord,curCameraRayUnit,vec3(0.0,2.1,0.0),vec3(2.0,0.1,2.0),wallColor,nearestD);
    renderAABB(scrCoord,curCameraRayUnit,vec3(2.1,1.0,0.0),vec3(0.1,1.0,2.0),wallColor,nearestD);
    renderAABB(scrCoord,curCameraRayUnit,vec3(-2.1,1.0,0.0),vec3(0.1,1.0,2.0),wallColor,nearestD);
    
    renderAABB(scrCoord,curCameraRayUnit,vec3(0.0,0.9,-0.75),vec3(0.25,0.025,0.25),standAccentColor,nearestD);
    renderAABB(scrCoord,curCameraRayUnit,vec3(0.0,0.5,-0.75),vec3(0.2,0.5,0.2),standColor,nearestD);
    
    const float roomW = 4.0;
    const float roomL = 4.0;
    for(float tileX=0.0; tileX<roomW; tileX+=1.0){
        for(float tileY=0.0; tileY<roomL; tileY+=1.0){
            renderAABB(scrCoord,curCameraRayUnit,
                       vec3(tileX-(roomW-1.0)/2.0,0.0,tileY-(roomL-1.0)/2.0),
                       vec3(0.485,0.025,0.485),floorTileColor,nearestD);
        }
    }
    
    
    float diffuseCheat = 0.0;
    float specP = 1.0;
    float specA = 0.0;
    
    
    float dummyD = 9999.9;
    if (testAABB(scrCoord,curCameraRayUnit,objCenter,vec3(0.21),dummyD)) {
        
        #ifdef SHOW_RAYMARCHED_BOUNDS
        color += vec3(0.1,0.0,0.0);
        #endif
        
        vec3 p = scrCoord;
        
        float f=0.0;
        float d=0.01;
        for(int i=0;i<64;i++){
            if ((abs(d) < .001) || (f > maxd)) break;
            f+=d;
            p=scrCoord + curCameraRayUnit*f;
            d = blobDistance(p);
        }

        if (f < nearestD) {

            nearestD = f;

            normal = normalize(vec3(d-blobDistance(p-e.xyy),
                                    d-blobDistance(p-e.yxy),
                                    d-blobDistance(p-e.yyx)));
            
            color = vec3(1.0,0.0,1.0);
            diffuseCheat = 0.2;
            specP = 8.0;
            specA = 1.0;
            
        }
        
    }
    
    
    
    vec3 intersectPt = scrCoord + curCameraRayUnit * nearestD;
    
    vec3 lightGap = lightPt-intersectPt;
    vec3 lightGapNorm = normalize(lightGap);
    float litAmt = dot(normal,lightGapNorm);
    litAmt = litAmt*(1.0-diffuseCheat)+diffuseCheat;

    float lightDist = length(lightGap);
    lightDist /= 16.0;
    lightDist = max(lightDist,0.0);
    lightDist = min(lightDist,1.0);
    lightDist = pow(1.0-lightDist,2.0);
    
    float specular = max(0.0,dot(normalize(lightGapNorm-curCameraRayUnit),normal));
    
    color = color*litAmt*lightDist + pow(specular,specP)*specA;
    
    
    
    
    fragColor = vec4(color,1.0);
    
    
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	
    
    float camLookX, camLookY;
    
    vec2 mouseFrac = iMouse.xy/iResolution.xy;
    mouseFrac -= 0.5;
    mouseFrac *= 2.0;
    
    if (iMouse.z != 0.0) {
        
        camLookX = PI + mouseFrac.x * PI;
        
    	camLookY = -mouseFrac.y;
        camLookY *= PI*0.35;
        
    } else {
        camLookX = PI;
        camLookY = -0.25;
    }
    
    
    
    
    // all this stuff with working from FOVs is for the sake of WebVR compatibility,
    // which is redundant for shadertoy, but handy for my personal site
    
    float vertFov = 50.0;
    float horizFov = 2.0*atan(tan((vertFov/180.0*PI)/2.0)*(iResolution.x/iResolution.y))*180.0/PI;
    vec4 fovAngsMono = vec4(horizFov/2.0, horizFov/2.0, vertFov/2.0, vertFov/2.0);
    
    
    
    vec2 fragFrac = fragCoord.xy/iResolution.xy;

    vec2 eyeRes = iResolution.xy;
    vec4 fovAngs = fovAngsMono;
    
    vec3 cameraRight = vec3(cos(camLookX),0.0,sin(camLookX));
    vec3 cameraFwd = vec3(cos(camLookX+PI*0.5)*cos(camLookY),sin(camLookY),sin(camLookX+PI*0.5)*cos(camLookY));
    vec3 cameraUp = -cross(cameraRight,cameraFwd);
    
    
    
    // position

    vec3 cameraPos = vec3(0.0);
    
    
    
    float fovL = -fovAngs.x/180.0*PI;
    float fovR =  fovAngs.y/180.0*PI;
    float fovU = -fovAngs.z/180.0*PI;
    float fovD =  fovAngs.w/180.0*PI;

    float fovMiddleX = (fovR + fovL) * 0.5;
    float fovMiddleY = (fovU + fovD) * 0.5;
    float fovHalfX = (fovR - fovL) * 0.5;
    float fovHalfY = (fovD - fovU) * 0.5;



    float scrWorldHalfX = sin(fovHalfX)/sin(PI*0.5 - fovHalfX);
    float scrWorldHalfY = sin(fovHalfY)/sin(PI*0.5 - fovHalfY);


    // determine screen plane size from FOV values, then interpolate to find current pixel's world coord

    vec2 vPos = fragFrac;//0 to 1
    vPos.x -= (-fovL/(fovHalfX*2.0));
    vPos.y -= (-fovU/(fovHalfY*2.0));

    vec3 screenPlaneCenter = cameraPos+cameraFwd;
    vec3 scrCoord = screenPlaneCenter + vPos.x*cameraRight*scrWorldHalfX*2.0 + vPos.y*cameraUp*scrWorldHalfY*2.0;
    vec3 curCameraRayUnit = normalize(scrCoord-cameraPos);
    
    
    
    mainVR(fragColor,fragCoord,cameraPos,curCameraRayUnit);
    
    
}