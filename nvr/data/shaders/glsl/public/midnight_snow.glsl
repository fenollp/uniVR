// Shader downloaded from https://www.shadertoy.com/view/XlBGzm
// written by shadertoy user RavenWorks
//
// Name: Midnight Snow
// Description: [b]I hate winter, except when it does this.[/b] Music is based on George Winston's arrangement of Carol Of The Bells.
//    Got curious about raytracing a bounding box to skip raymarches; works pretty well, at the cost of crashing WebGL if too many objects&hellip;


const float PI =3.141592;
const float PI2=6.2831853;




float smooth( float a, float b, float k ){
    float h = clamp(0.5+0.5*(b-a)/k,0.0,1.0);
    return mix(b,a,h) - k*h*(1.0-h);
}

void hardAdd(inout int curMaterial, inout float curD, int newMaterial, float newD){
    if (newD < curD) {
        curD = newD;
        curMaterial = newMaterial;
    }
}
void hardSubtract(inout float curD, float newD) {
    curD = max( -newD, curD );
}
void smoothAdd(inout float curD, float newD, float blendPower){//blend colors too?
    curD = smooth( newD, curD, blendPower );
}
void smoothSubtract(inout float curD, float newD, float blendPower){
    curD = -smooth( newD , -curD , blendPower );
}


float obj_ball(vec3 p, vec3 center, float radius){
    return length(p-center)-radius;
}
float obj_cylinder(vec3 p, vec3 center, vec2 size, float roundness){
    vec3 tp = p-center;
    vec2 d = abs(vec2(length(tp.yz),tp.x)) - size;
    return min(max(d.x,d.y)+roundness,0.0) + length(max(d,0.0))-roundness;
}
float obj_planeY(vec3 p, float planeY){
    return p.y-planeY;
}
float obj_roundline( vec3 p, vec3 a, vec3 b, float r ){
    vec3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}
float obj_box(vec3 p, vec3 center, vec3 size, float roundness){
    vec3 d = abs(p-center) - (size-roundness);
    return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)) - roundness;
}

float middleMod(float val,float modDist){
    return mod(val+modDist*0.5,modDist)-modDist*0.5;
}



float det2d(vec2 vecA, vec2 vecB){
    return vecA.x*vecB.y - vecA.y*vecB.x;
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

vec2 rotVec(vec2 v, vec2 r){
    return vec2(
    	v.x*r.x - v.y*r.y,
        v.x*r.y + v.y*r.x
    );
}


void moveToBranchSpace(inout vec3 rayPt, inout vec3 rayDir, vec3 rotOrigin, float pitch, float yaw) {
    
    rayPt -= rotOrigin;
    
    vec2 yawVec = vec2(cos(yaw),sin(yaw));
    rayPt.xz = rotVec(rayPt.xz,yawVec);
    rayDir.xz = rotVec(rayDir.xz,yawVec);
    
    vec2 pitchVec = vec2(cos(pitch),sin(pitch));
    rayPt.xy = rotVec(rayPt.xy,pitchVec);
    rayDir.xy = rotVec(rayDir.xy,pitchVec);
    
}

vec3 moveFromBranchSpace(vec3 rayPt, vec3 rotOrigin, float pitch, float yaw){
    
    vec3 resultPt = rayPt;
    
    vec2 yawVec = vec2(cos(-yaw),sin(-yaw));
    resultPt.xz = rotVec(resultPt.xz,yawVec);
    
    vec2 pitchVec = vec2(cos(-pitch),sin(-pitch));
    resultPt.xy = rotVec(resultPt.xy,pitchVec);
    
    resultPt += rotOrigin;
    
    return resultPt;
    
}


const vec3 e=vec3(0.00007,0,0);
const float maxd=256.0; //Max depth
float nearestD = maxd;
vec3 color = vec3(0.0,0.0,1.0);

const float branchStart=0.1;
float branchEnd=0.0;

float branchDistance(vec3 p, inout int material){
    
    
    float distance = 9999.9;
    material = 0;
    
    const float snowR = 0.2;
    vec3 cylMiddle = vec3((branchStart+branchEnd)*0.5,0.0,0.0);
    vec2 cylSize = vec2(0.0,(branchEnd-branchStart)*0.5-snowR);
    
    const float leavesR = 0.2;
    
    const float branchLeavesBelow = -0.2;
    const vec3 subBranchOff = vec3(0.0,branchLeavesBelow,0.0);
    
    hardAdd(material,distance,1, obj_cylinder(p, cylMiddle, cylSize, snowR) );
    
    const float subBranchGap = 0.5;//total space before wrap
    const float subBranchStride = subBranchGap-snowR*2.0;//branch size allowing for rounded ends
    
    const vec3 subBranchStart = vec3(snowR,0.0,0.0);
    const vec3 subBranchLength = vec3(subBranchStride,-0.8,0.8);
    
    if ( (p.x < branchEnd) && (p.x > branchStart) ) {
        
        float branchX = (floor((branchEnd-p.x)/subBranchGap)*subBranchGap);//step
    	vec3 modP = vec3(mod(branchEnd-p.x,subBranchGap),p.y,abs(p.z));
        
        float unit = (branchX/(branchEnd-branchStart));
        float subBranchAmt = sin(unit*PI);
        
        vec3 subBranchSnowEnd = subBranchStart+subBranchLength*subBranchAmt;
        vec3 subBranchLeafEnd = subBranchStart+subBranchLength*(subBranchAmt + 0.2);
        
        smoothAdd(distance, obj_roundline(modP,subBranchSnowEnd,subBranchStart,snowR), 0.2);
        hardAdd(material,distance,2, obj_roundline(modP,subBranchLeafEnd+subBranchOff,subBranchStart+subBranchOff,leavesR) );
        
    }
    
    hardAdd(material,distance,2, obj_cylinder(p, cylMiddle+vec3(0.0,branchLeavesBelow,0.0), cylSize, leavesR) );
    
    return distance;
    
    
}

void raytraceBranch(vec3 rayPt, vec3 rayDir, vec3 treeOrigin, float theBranchEnd, float pitch, float yaw){
    
    
    branchEnd = theBranchEnd;//is it a terrible idea to use globals to avoid passing arguments over and over? (or a great idea?)
    
    
    moveToBranchSpace(rayPt, rayDir, treeOrigin, pitch, yaw);
    
    float testDist = -1.0;
    if (!testAABB(rayPt, rayDir,
                  vec3((branchStart+branchEnd)*0.5,-0.05,0.0),//hardcoded y offset
                  vec3((branchEnd-branchStart)*0.5,0.8,2.0),//hardcoded size
                  testDist)) return;
    
    
    
    vec3 p = rayPt + rayDir*testDist;

    float f=testDist;
    float d=0.01;
    float curMaxD = testDist + branchEnd*2.0;//slightly overkill but close enough
    int mat, dummyMat;
    for(int i=0;i<16;i++){
        if (f >= curMaxD) {
			f = maxd;
			break;
		}
		if (abs(d) < .01) break;
        f+=d;
        p=rayPt + rayDir*f;
        d = branchDistance(p,mat);
    }
    
    
    
    
    
    if (f < nearestD) {

        nearestD = f;

        // this normal calculation actually ignores the branch's tilt,
        // but whatever, it's close enough for lighting this vague
        vec3 n = normalize(vec3(d-branchDistance(p-e.xyy,dummyMat),
                                d-branchDistance(p-e.yxy,dummyMat),
                                d-branchDistance(p-e.yyx,dummyMat)));
        

        if (mat == 1) {
            
            float diffuse=max(dot(n,vec3(0.0,1.0,0.0)),0.0);
            diffuse = pow(diffuse,0.5);
            color = mix(vec3(0.90,0.55,0.00),vec3(0.95,0.85,0.70),diffuse);
            
        } else {
            
            float diffuse=max(dot(n,vec3(0.0,1.0,0.0)),0.0);
            color = vec3(0.1,0.2,0.2) * diffuse;

        }

    }
    
    #ifdef DRAW_CLIP_RAYTRACES
    color = mix(color,vec3(1.0,0.0,0.0),0.1);
    #endif
    
}


void raytraceBranchShelf(vec3 rayPt, vec3 rayDir, vec3 shelfOrigin, float shelfRad, float shelfPitch, float shelfYawOff){
    
    float shelfHeight = sin(shelfPitch)*shelfRad;
    float shelfWidth = cos(shelfPitch)*shelfRad;
    
    float dummyDist;
    if (!testAABB(rayPt, rayDir,
                  shelfOrigin-vec3(0.0,shelfHeight,0.0),
                  vec3(shelfWidth,abs(shelfHeight)+2.0,shelfWidth),//hardcoded box height padding
                  dummyDist)) return;
    
    
    const int branchesAround = 8;
    for(int i=0; i<8; i++){
    	raytraceBranch(rayPt,rayDir,shelfOrigin,shelfRad,shelfPitch,shelfYawOff + PI*float(i)/float(branchesAround)*2.0);
    }
    
    #ifdef DRAW_CLIP_RAYTRACES
    color = mix(color,vec3(0.0,0.0,1.0),0.1);
    #endif
}


float timeToWindWaveAmt(float time){
    
    float wave = sin( time + sin(time*0.8) + sin(time*0.2)*sin(time*2.1) );
    return wave*0.5 + 0.5;
    
}


void raytraceTree(vec3 rayPt, vec3 rayDir, vec3 treeOrigin, float yOff, float heightOff, float widthOff){
    
    treeOrigin.y += 6.0+yOff;
    
	vec2 aboveRayPt = rayPt.xz;
    vec2 aboveRayDir = normalize(rayDir.xz);
    vec2 aboveTreeOrigin = treeOrigin.xz;
    vec2 aboveTreeGap = aboveTreeOrigin-aboveRayPt;
    
    // test between cylinder ends
    
    float distToTree = length(aboveTreeGap);
    float stepLength = length(rayDir.xz);
    float stepsToTree = distToTree/stepLength;
    float yAtTree = rayPt.y + rayDir.y*stepsToTree;
    float coneBtmY = treeOrigin.y-12.0;
    float coneTopY = treeOrigin.y+20.0;//hook these up to the same property as actually determines the branches? :|
    if (yAtTree < coneBtmY) return;
    if (yAtTree > coneTopY) return;
    float coneFracY = (yAtTree - coneBtmY) / (coneTopY - coneBtmY);
    
    
    // test within cylinder radius
    const float coneTopRad = 2.0;
    const float coneBtmRad = 14.0;
    float treeHitzoneRadius = coneTopRad + (coneBtmRad-coneTopRad)*(1.0-coneFracY);
    float distToPointOnRayClosestToCenterOfTree = dot(aboveTreeGap,aboveRayDir)/length(aboveRayDir);
    if (distToPointOnRayClosestToCenterOfTree <= 0.0) return;//should consider radius of cylinder too, but won't matter for this scene
    vec2 pointOnRayClosestToCenterOfTree = aboveRayPt+aboveRayDir*distToPointOnRayClosestToCenterOfTree;
    float closestDistToTreeCenter = length(pointOnRayClosestToCenterOfTree-aboveTreeOrigin);
    if (closestDistToTreeCenter > treeHitzoneRadius) return;
    
    
    const float numShelves=11.0;
    for(float i=0.0; i<numShelves; i++){
        float branchFrac = i/numShelves;
        
        float windWaveOff = treeOrigin.x*-0.007;
        float windWaveAmt = timeToWindWaveAmt(iGlobalTime*1.5 + windWaveOff);
        windWaveAmt = 1.0 - pow( 1.0-windWaveAmt , 2.0 );
        const float windWaveMin = 0.2;
        windWaveAmt = windWaveAmt*(1.0-windWaveMin) + windWaveMin;
        
        float subWave = sin(iGlobalTime*3.0 + treeOrigin.x*-0.01 + branchFrac*1.2);
        subWave = subWave*0.5+0.5;
        subWave = 1.0-pow(1.0-subWave,2.0);
        
        float windWave = subWave*windWaveAmt*-0.04;
        
    	raytraceBranchShelf(rayPt, rayDir,
                            treeOrigin+vec3(0.0,1.0+(pow(1.0-branchFrac,0.6))*(13.0+heightOff),0.0),//height
                            branchStart+0.5+(9.0+widthOff)*branchFrac,//length
                            0.05+0.6*branchFrac + windWave,//pitch
                            3.0*branchFrac//yaw offset
                           );
    }
    
    
    float trunkRadius = -(yAtTree-(treeOrigin.y+8.0))*0.1;
    if (yAtTree < treeOrigin.y+10.0) {
        if (closestDistToTreeCenter < trunkRadius) {
            // this is utterly fudged, but it's close enough for such a tiny detail
            float trunkFracFudged = (1.0-pow((closestDistToTreeCenter/trunkRadius),3.0))*trunkRadius;
            float trunkDist = distToPointOnRayClosestToCenterOfTree - trunkFracFudged;
            if (trunkDist < nearestD) {
                nearestD = trunkDist;
            	color = vec3(0.15,0.10,0.00)*(trunkFracFudged+0.2);
            } else {
                #ifdef DRAW_CLIP_RAYTRACES
                color -= vec3(0.0,0.5,0.0);
                #endif
            }
        }
    }
    
    
    
    
    
    
    #ifdef DRAW_CLIP_RAYTRACES
    color = mix(color,vec3(0.0,1.0,0.0),0.1);
    #endif
}

void raytraceTreeline(vec3 rayPt, vec3 rayDir, float treelineZ, float treeGapX, float offX, float groundY){
    
    float rayGapStepsZ = (treelineZ-rayPt.z)/rayDir.z;
    float rayX = rayPt.x + rayDir.x*rayGapStepsZ;
    float treeX = floor((rayX-offX)/treeGapX)*treeGapX + treeGapX*0.5 + offX;
    
    if (abs(treeX) > 240.0) return;
    
    raytraceTree(rayPt,rayDir,vec3(treeX,groundY,treelineZ),
    	sin(treeX+treelineZ)*1.5,//yOff
        sin(treeX*0.7+treelineZ)*4.0,//heightOff
        sin(treeX*0.85+treelineZ)*1.0//widthOff
    );
    
    #ifdef DRAW_CLIP_RAYTRACES
    //color.r += sin(treeX*0.1)*0.01+0.5;
    #endif
    
}

void raytraceHillTreeline(vec3 rayPt, vec3 rayDir, float treelineX, float treeGapZ, float offZ, float offY, float slopeY){
    
    if (rayDir.x < 0.0) treelineX *= -1.0;
    
    float groundY = 0.0;
    
    float rayGapStepsX = (treelineX-rayPt.x)/rayDir.x;
    float rayZ = rayPt.z + rayDir.z*rayGapStepsX;
    float treeZ = floor((rayZ-offZ)/treeGapZ)*treeGapZ + treeGapZ*0.5 + offZ;
    
    if (treeZ > 40.0) return;
    if (treeZ < -70.0) return;
    
    const float hillNearZ = 0.0;
    if (treeZ > hillNearZ) groundY = (treeZ-hillNearZ)*slopeY;
    
    groundY += offY;
    
    raytraceTree(rayPt,rayDir,vec3(treelineX,groundY,treeZ),
    	sin(treeZ+treelineX)*1.5,//yOff
        sin(treeZ*0.7+treelineX)*4.0,//heightOff
        sin(treeZ*0.85+treelineX)*1.0//widthOff
    );
    
    //#ifdef DRAW_CLIP_RAYTRACES
    //color.g += sin(treeZ*0.2)*0.1+0.5;
    //#endif
    
}



const float roadZ = 54.0;
const float roadGroundY = -14.0;
const float roadW = 240.0;

float groundDistance(vec3 p, inout int material){
    
    float distance = 9999.9;
    material = 0;
    
    
    
    hardAdd(material,distance,1,
    	obj_box(p, vec3(0.0,-50.0,-23.0),
		vec3(70.0,50.0,55.0),
		40.0) );
    
    smoothAdd(distance,
		obj_box(p, vec3(0.0,-12.0,-75.0),
        vec3(58.0,32.0,36.0),
        30.0), 30.0 );
    
    smoothAdd(distance,
        obj_box(p, vec3(0.0,roadGroundY-20.0,64.0),
        vec3(roadW,20.0,100.0),
        20.0), 15.0 );
    
    distance += sin( p.x*0.4 + sin(p.x*0.2) + sin(p.z*0.5)*0.75 )*0.2;
    distance += sin( p.z*0.4 + sin(p.z*0.2) + sin(p.x*0.5)*0.75 )*0.2;
    
    smoothSubtract(distance,
		obj_box(p, vec3(0.0,roadGroundY+4.9,roadZ),
        vec3(roadW,6.0,12.0),
        4.0), 1.0 );
    
    hardAdd(material,distance,3,
    	obj_box(p, vec3(0.0,roadGroundY-3.1,roadZ),
        vec3(roadW,2.1,12.0),
        0.0) );
    
    
    
    
    
    return distance;
    
}

float flakeDistance(vec3 p){
    
    const float snowflakeMaxDist = 20.0;
    if ( (abs(p.x) > snowflakeMaxDist) || (abs(p.y) > snowflakeMaxDist) || (abs(p.z) > snowflakeMaxDist) ) return 9999.9;
    
    float snowPush = 1.25*iGlobalTime;
    
    p.x += snowPush*-10.0;
    p.y += snowPush*1.5;
    p.z += snowPush*-0.25;
    
    const float modDist = 4.0;
    
    float stepX = floor(p.x/modDist);
    float stepY = floor(p.y/modDist);
    float stepZ = floor(p.z/modDist);
    
    vec3 flakeP = vec3(
        mod(p.x,modDist),
        mod(p.y,modDist),
        mod(p.z,modDist)
    );
    
    vec3 flakePos = vec3(modDist*0.5);
    
    flakePos.x += sin(snowPush+stepY*1.0)*(2.0/5.0)*modDist;
    flakePos.y += sin(snowPush+stepZ*1.3)*(2.0/5.0)*modDist;
    flakePos.z += sin(snowPush+stepX*1.7)*(2.0/5.0)*modDist;
	
    
    return obj_ball(flakeP, flakePos, 0.08);
    
}


void tiretrack(vec3 p, inout float clearAmt, float period, float origOffX, float offY, float amt, float width) {
    
    float offX = origOffX;
    
    float testY = p.z - roadZ;
    if (testY < 0.0) {
        testY *= -1.0;
        offX += 8.0;
    }
    if (testY > 5.0) {
        testY -= 5.0;
        offX += 8.0;
    }
    
    float waveY = sin(p.x*period+offX)*amt+offY;
    float offDist = abs(testY-waveY)/width;
    if (offDist<1.0) clearAmt += 1.0-pow(offDist,2.0);
    
}






void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 fragRayOri, in vec3 fragRayDir ) {
    
    
    
    vec3 scrCoord = fragRayOri;
    vec3 curCameraRayUnit = fragRayDir;
    
    
    
    scrCoord.y += 1.7;// standing person
    
    
    // bleh.. but, I accidentally set the scene up backwards! 9_9
    curCameraRayUnit *= vec3(-1.0,1.0,-1.0);
    scrCoord *= vec3(-1.0,1.0,-1.0);
    //
    
    
    
    vec3 p = scrCoord;

    float f=0.0;
    float d=0.01;
    int mat, dummyMat;
    for(int i=0;i<64;i++){
        if ((abs(d) < .001) || (f > maxd)) break;
        f+=d;
        p=scrCoord + curCameraRayUnit*f;
        d = groundDistance(p,mat);
    }
    
    if (f < nearestD) {

        nearestD = f;
        
        vec3 n = normalize(vec3(d-groundDistance(p-e.xyy,dummyMat),
                                d-groundDistance(p-e.yxy,dummyMat),
                                d-groundDistance(p-e.yyx,dummyMat)));


        if (mat == 1) {
            
            float diffuse=max(dot(n,vec3(0.0,1.0,0.0))*0.5+0.5,0.0);
            const float minVal = -1.0;
            diffuse = max(0.0, minVal + diffuse*(1.0-minVal) );
            diffuse = pow(diffuse,2.0);
            color = mix(vec3(0.25,0.0,0.10),vec3(0.95,0.85,0.60),diffuse);
            
        }
        if (mat == 3) {
            if ( abs(p.z-roadZ) < 0.8 ) {
                color = vec3(0.47,0.42,0.20);
            } else {
            	color = vec3(0.20,0.15,0.15);
            }
            float clearAmt = 0.5;
            
            const float trackW = 0.8;
            tiretrack(p,clearAmt,
                      0.13,//period
                      6.0,//offX
                      1.5,//offY
                      0.5,//amp
                      trackW
                     );
            tiretrack(p,clearAmt,
                      0.06,//period
                      0.0,//offX
                      2.5,//offY
                      0.5,//amp
                      trackW
                     );
            tiretrack(p,clearAmt,
                      0.22,//period
                      19.0,//offX
                      3.5,//offY
                      0.5,//amp
                      trackW
                     );
            clearAmt /= 3.0;
            clearAmt = 1.0-pow(1.0-clearAmt,1.5);
            color = mix(color,vec3(0.95,0.85,0.60),0.5-0.4*clearAmt);
        }

    }
    
    
    
    
    
    
    
    
    raytraceHillTreeline(scrCoord,curCameraRayUnit, 75.0, 19.0,  4.0,  -6.0, -0.4);
    raytraceHillTreeline(scrCoord,curCameraRayUnit,100.0, 12.0,  0.0, -10.0, -0.25);
    
    raytraceTreeline(scrCoord,curCameraRayUnit,roadZ+25.0, 17.0, 12.0,roadGroundY-1.0);
    raytraceTreeline(scrCoord,curCameraRayUnit,roadZ+40.0, 14.0,  2.0,roadGroundY-1.0);
    raytraceTreeline(scrCoord,curCameraRayUnit,roadZ+55.0, 11.0,  3.0,roadGroundY-1.0);
    
    
    
    float litAmt = max(0.0,dot(vec3(0.0,1.0,0.0),curCameraRayUnit))*0.5+0.5;
    litAmt = 1.0-pow(1.0-litAmt,1.5);
    vec3 skyCol = mix(vec3(0.45,0.10,0.25),vec3(0.90,0.80,0.50),litAmt);
    
    float distFrac = nearestD/maxd;
    color = mix(color,skyCol,distFrac);
    
    
    
    
    
    
    
    
    f=0.0;
    d=0.01;
    const vec3 flakeE=vec3(0.007,0,0);
    for(int i=0;i<128;i++){
        if ((abs(d) < .001) || (f > maxd)) break;
        f+=d*0.125;
        p=scrCoord + curCameraRayUnit*f;
        d = flakeDistance(p);
    }
    
    if (f < nearestD && abs(d)<0.001) {

        nearestD = f;
        
        vec3 n = normalize(vec3(d-flakeDistance(p-flakeE.xyy),
                                d-flakeDistance(p-flakeE.yxy),
                                d-flakeDistance(p-flakeE.yyx)));


        float edgeFade = pow(max(0.0,dot(n,-curCameraRayUnit)),3.0)*0.7;
        float distFade = max(0.0,1.0-(nearestD/20.0));
        color = mix(color,vec3(1.0,0.9,0.6),edgeFade*distFade);

    }
    
    
    
    
    
    
    
    fragColor = vec4(color,1.0);
    
    
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	
    
    float camLookX, camLookY;
    
    vec2 mouseFrac = iMouse.xy/iResolution.xy;
    mouseFrac -= 0.5;
    mouseFrac *= 2.0;
    
    if (iMouse.z != 0.0) {
        
        camLookX = -mouseFrac.x * PI;
        camLookX += PI;
        
    	camLookY = mouseFrac.y;
        camLookY *= PI*0.35;
        
    } else {
        camLookX = PI*0.75;
        camLookY = PI*-0.05;
    }
    
    
    
    
    float vertFov = 50.0;
    float horizFov = 2.0*atan(tan((vertFov/180.0*PI)/2.0)*(iResolution.x/iResolution.y))*180.0/PI;
    vec4 fovAngsMono = vec4(horizFov/2.0, horizFov/2.0, vertFov/2.0, vertFov/2.0);
    
    
    
    vec2 fragFrac = fragCoord.xy/iResolution.xy;

    vec2 eyeRes = iResolution.xy;
    vec4 fovAngs = fovAngsMono;


    //vec3 cameraRight,cameraUp,cameraFwd;
    //quatToAxes(headOrientation,cameraRight,cameraUp,cameraFwd);
    vec3 cameraRight = vec3(cos(camLookX),0.0,sin(camLookX));
    vec3 cameraFwd = vec3(cos(camLookX+PI*0.5)*cos(camLookY),sin(camLookY),sin(camLookX+PI*0.5)*cos(camLookY));
    vec3 cameraUp = -cross(cameraRight,cameraFwd);
    cameraFwd *= -1.0;
    
    
    
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
    
    
    
    // scene is accidentally backwards, ugh
    curCameraRayUnit *= vec3(-1.0,1.0,-1.0);
    scrCoord *= vec3(-1.0,1.0,-1.0);
    //
    
    mainVR(fragColor,fragCoord,scrCoord,curCameraRayUnit);
    
    
    
}