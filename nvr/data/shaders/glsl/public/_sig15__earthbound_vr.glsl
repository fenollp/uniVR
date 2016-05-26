// Shader downloaded from https://www.shadertoy.com/view/MtsXRX
// written by shadertoy user RavenWorks
//
// Name: [SIG15] Earthbound VR
// Description: Based partly on work I did before the compo was announced, but now with greatly expanded content!
//    I always wondered what it would be like to be 'in' these scenes...
//    Kind of a mishmash of scenes throughout the game because I couldn't pick just one :P
//sync with sound
const float encounterStart = 9.2;
const float transitionStart = encounterStart+0.25;
const float transitionEnd = transitionStart+3.0;









vec3 diamondShine(float i){
    float shine = abs(mod(i,2.0)-1.0);
    shine *= 7.0;
    return vec2(32.0+shine*24.0,4.0+shine*20.0).xxy/255.0;
}

vec3 bgTexture(vec2 tileCoord)
{
	
    tileCoord.y += iGlobalTime*0.1;
    tileCoord.y += pow(sin(tileCoord.y+iGlobalTime*0.75),2.0);
    
    vec2 withinTile = mod(tileCoord,1.0);
    vec2 tileStep = floor(tileCoord);
    
    bool inDiamond = (abs(withinTile.x-0.5) + abs(withinTile.y-0.5)) < 0.5;
    
    vec3 color;
    if (inDiamond) {
        return diamondShine( tileStep.x*1.1 + tileStep.y*1.6 + iGlobalTime*0.5 );
    } else {
        return vec3(80.0/255.0,96.0/255.0,72.0/255.0);
    }
	
}










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
void smoothAdd(inout float curD, float newD, float blendPower){
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
    vec2 d = abs(vec2(length(tp.yz),tp.x)) - (size-roundness);
    return min(max(d.x,d.y)+roundness,0.0) + length(max(d,0.0))-roundness;
}
float obj_cylForever(vec2 p, vec2 middle, float radius){
    return abs(length(p-middle)) - radius;
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
float obj_torus( vec3 p, vec3 center, vec2 t ){
    vec3 tp = p-center;
	vec2 q = vec2(length(tp.xy)-t.x,tp.z);
	return length(q)-t.y;
}
float obj_quartertorus( vec3 p, vec3 center, vec2 t ){
    vec3 tp = p-center;
    tp.x = max(tp.x,0.0);
    tp.y = max(tp.y,0.0);
    // okay that honestly isn't what I set out to make, but it saves me several other shapes..!
	vec2 q = vec2(length(tp.xy)-t.x,tp.z);
	return length(q)-t.y;
}

float obj_repeatPebble(vec3 p, vec2 period, float radius){
    vec3 mp = p;
    const float offset = 1000.0;
    mp.x = mod(p.x+offset,period.x);
    mp.z = mod(p.z+offset,period.y);
    float stepX = floor((p.x+offset)/period.x);
    float stepZ = floor((p.z+offset)/period.y);
    vec3 c = vec3(period.x*0.5,0.0,period.y*0.5);
    c.x += (sin(stepX) + sin(stepZ))*0.125*period.x;
    c.z += (sin(stepX*2.0) + sin(stepZ))*0.125*period.y;
    float r = radius * (1.0 + (sin(stepX) + sin(stepZ))*0.25);
    return obj_ball(mp,c,r);
}


// I should probably make a way to bundle materials into shapes
// rather than being redundant with hardAdd like this
// oh well
void obj_ufo(vec3 p, vec3 center, float eyeOff, inout int curMaterial, inout float curD){
    
    float distance = 9999.9;
    int material = 0;
    
    vec3 ufoRotP = p;
    
    vec3 ufoBodyP = ufoRotP;
    ufoBodyP.y -= center.y+0.3;
    ufoBodyP.y = abs(ufoBodyP.y);
    
    hardAdd(material,distance,5,
		obj_ball(ufoBodyP,vec3(center.x,-1.0,center.z),1.1)
	);
    smoothAdd(distance,
		obj_ball(ufoBodyP,vec3(center.x,0.03,center.z),0.2),
    0.1);
    
    vec3 ufoEyeP = ufoRotP;
    ufoEyeP.x -= center.x+eyeOff;
    ufoEyeP.x = abs(ufoEyeP.x);
    
    hardAdd(material,distance,6,
		obj_ball(ufoEyeP,vec3(0.045,center.y+0.41,center.z+0.25),0.025)
	);
    
    
    
    
    if (distance < curD) {
        curD = distance;
        curMaterial = material;
    }
    
    
}





const float fadeSpd = 1.0;


float ufoX = 0.0;
float ufoZ = 0.0;


float caveDistance(vec3 p, inout int material){
    
    float distance = 9999.9;
    material = 0;
    
    
    
    
    
    
    
    const float wallLumpDist = 4.0;
    const float lumpsBeforeMod = 4.0;
    
    vec3 wallP = p;
    wallP.x = abs(p.x);
    for(float i=0.0; i<lumpsBeforeMod; i++){
        
        float subOff = (i/lumpsBeforeMod)*wallLumpDist;
        float wallStep = (floor((p.z+subOff)/wallLumpDist)-(i/lumpsBeforeMod))*wallLumpDist + ((p.x<0.0)?60.0:0.0);
        wallP.z = mod(p.z+subOff,wallLumpDist);
        
        float wallDist = 6.0;
        wallDist += sin(wallStep*10.0)*0.1;
        wallDist += sin(wallStep*17.0)*0.1;
        wallDist += sin(wallStep*0.5)*1.0;
        wallDist += sin(wallStep*0.87)*0.25;
        if (p.y > 5.0) wallDist += 6.0;//safe because we're looking up
        
        float curD = obj_cylinder(wallP.yxz,vec3(0.0,wallDist,wallLumpDist*0.5),vec2(0.6,12.0),0.0);
        
        if (i==0.0) {
            hardAdd(material,distance,2,curD);
        } else {
            smoothAdd(distance,curD,0.3);
        }
    }
    
    
    
    hardAdd(material,distance,1,
		p.y-0.0
    );
    
    smoothAdd(distance,
		obj_repeatPebble(p,vec2(0.65,2.01),0.05)
	,0.05);
    smoothAdd(distance,
		obj_repeatPebble(p,vec2(0.47,1.51),0.04)
	,0.04);
    smoothAdd(distance,
		obj_repeatPebble(p,vec2(0.81,1.01),0.03)
	,0.03);
    
    
    
    
    
    vec3 ufoPos = vec3(ufoX,1.1,ufoZ);
    obj_ufo(p,ufoPos,0.0,material,distance);
    
    
    
    return distance;
    
}






const float bgDist = 10.0;
const float enemyDist = -2.0;
const float enemyHeight = 0.9;
const float enemyOffX = 0.6;
const float healthDist = -0.75;
const float healthModX = 0.35;


float sceneDistance(vec3 p, inout int material){
    
    float distance = 9999.9;
    material = 0;
    
    
    
    hardAdd(material,distance,1,
    	-obj_cylForever(p.xz, vec2(0.0),bgDist)
    );
    
    
    const float outlineRad = 0.02;
    vec2 healthSize = vec2(0.25,0.3)/2.0;
    if (abs(p.x)<healthModX*2.0) {
        
        vec3 healthP = p;
        healthP.y -= 0.85;
        
        healthP.x = mod(healthP.x,healthModX);
        healthP.x -= healthModX/2.0;
        
        vec3 healthFrameP = healthP;
        healthFrameP.y = abs(healthFrameP.y);
        healthFrameP.x = abs(healthFrameP.x);
        
        
        const float boxThickness = 0.03;
        hardAdd(material,distance,3,
			obj_box(healthFrameP,vec3(0.0,0.0,healthDist-boxThickness+0.01),vec3(healthSize.xy,boxThickness),0.0)
		);
        
        const float healthInset = 0.01;
        smoothSubtract(distance,
            obj_box(healthP,vec3(0.05,-0.075,healthDist),vec3(0.075,0.125,healthInset),0.0),
        	0.01
        );

        
        hardAdd(material,distance,2,
            obj_quartertorus(healthFrameP,vec3(healthSize.xy,healthDist),vec2(outlineRad,outlineRad-0.001))
        );
        
        
        
        vec3 wheelP = healthP;
        wheelP.x -= 0.05;
        wheelP.x = abs(wheelP.x);


        wheelP.y += 0.05;
        wheelP.y = abs(wheelP.y);

        hardAdd(material,distance,2,
        	obj_cylinder(wheelP,vec3(0.0,0.05,healthDist-healthInset),vec2(0.05,0.025),0.0075)
        );
        hardAdd(material,distance,2,
        	obj_cylinder(wheelP,vec3(0.05,0.05,healthDist-healthInset),vec2(0.05,0.025),0.0075)
        );

    }
    
    vec3 statusP = p;
    statusP.y -= 2.1;
    statusP.y = abs(statusP.y);
    
    statusP.x += 0.6;
    statusP.x = abs(statusP.x);
    
    const float statusW = 1.2;
    const float statusH = 0.3;
    const float statusDist = -3.0;
    const float innerRad = 0.025;
    
    hardAdd(material,distance,2,
    	obj_quartertorus(statusP,vec3(statusW,statusH,statusDist),vec2(innerRad*2.0,innerRad))
    );
    hardAdd(material,distance,4,
    	obj_box(statusP,vec3(0.0,0.0,statusDist-0.005),vec3(statusW+innerRad,statusH+innerRad,0.01),0.0)
    );
    
    
    
    
    float ufoHeight = enemyHeight+sin(iGlobalTime*2.5)*0.02;
    obj_ufo(p,vec3(-enemyOffX,ufoHeight,enemyDist),0.05,material,distance);
    
    
    
    
    const float foppyWidth = 0.1;
    float foppyBob = pow(1.0-(sin(iGlobalTime*4.0)*0.5+0.5),1.1);
    float foppyHeight = enemyHeight+0.3 + foppyBob*0.03;
    hardAdd(material,distance,7,
    	obj_ball(p,vec3(enemyOffX+foppyWidth,foppyHeight,enemyDist),0.2)
	);
    smoothAdd(distance,
    	obj_ball(p,vec3(enemyOffX-foppyWidth,foppyHeight,enemyDist),0.2),
	0.3);
    
    float legOff = 0.25 - foppyBob*0.02;
    float legSize = 0.09 - foppyBob*0.01;
    hardAdd(material,distance,7,
    	obj_ball(p,vec3(enemyOffX-legOff,enemyHeight+0.1,enemyDist+0.2),legSize)
	);
    hardAdd(material,distance,7,
    	obj_ball(p,vec3(enemyOffX+legOff,enemyHeight+0.08,enemyDist-0.1),legSize)
	);
    
    
    vec3 foppyEyeP = p;
    foppyEyeP.x -= enemyOffX-0.05;
    foppyEyeP.x = abs(foppyEyeP.x);
    
    hardAdd(material,distance,8,
    	obj_ball(foppyEyeP,vec3(0.1,foppyHeight+0.07,enemyDist+0.26),0.015)
	);
    
    
    
    return distance;
    
}





//
// https://gist.github.com/num3ric/4408481
//
struct Ray {
    vec3 o; //origin
    vec3 d; //direction (should always be normalized)
};
struct Sphere {
    vec3 pos;   //center of sphere position
    float rad;  //radius
};
float intersectSphere(in Ray ray, in Sphere sphere){
    vec3 oc = ray.o - sphere.pos;
    float b = 2.0 * dot(ray.d, oc);
    float c = dot(oc, oc) - sphere.rad*sphere.rad;
    float disc = b * b - 4.0 * c;

    if (disc < 0.0)
        return -1.0;

    // compute q as described above
    float q;
    if (b < 0.0)
        q = (-b - sqrt(disc))/2.0;
    else
        q = (-b + sqrt(disc))/2.0;

    float t0 = q;
    float t1 = c / q;

    // make sure t0 is smaller than t1
    if (t0 > t1) {
        // if t0 is bigger than t1 swap them around
        float temp = t0;
        t0 = t1;
        t1 = temp;
    }

    // if t1 is less than zero, the object is in the ray's negative direction
    // and consequently the ray misses the sphere
    if (t1 < 0.0)
        return -1.0;

    // if t0 is less than zero, the intersection point is at t1
    if (t0 < 0.0) {
        return t1;
    } else {
        return t0; 
    }
}




// uuuuuuuugh
int getBit(int bitnum){
    if (bitnum == 0) return 1;
    if (bitnum == 1) return 2;
    if (bitnum == 2) return 4;
    if (bitnum == 3) return 8;
    if (bitnum == 4) return 16;
    if (bitnum == 5) return 32;
    if (bitnum == 6) return 64;
    if (bitnum == 7) return 128;
    if (bitnum == 8) return 256;
    if (bitnum == 9) return 512;
    if (bitnum == 10) return 1024;
    if (bitnum == 11) return 2048;
    if (bitnum == 12) return 4096;
    if (bitnum == 13) return 8192;
    if (bitnum == 14) return 16384;
    return 0;
}

bool bitLit(int readfrom, int bitnum){
    int divideBy = getBit(bitnum);
    int divided = readfrom/divideBy;
    int wipedFirstBit = divided/2;
    wipedFirstBit *= 2;
    return (divided != wipedFirstBit);
}


int getStatusMsg1a(int x){
	if (x == 0 || x == 2) return 0x18;
	if (x == 1) return 0x3c;
	if (x == 5 || x == 9) return 0x1;
	if (x == 6 || x == 8) return 0x6;
	if (x == 7 || x == 31) return 0xf8;
	if (x == 11 || x == 14 || x == 23 || x == 41 || x == 49) return 0x78;
	if (x == 12 || x == 13) return 0x84;
	if (x == 16) return 0x7c;
	if (x == 17 || x == 18 || x == 42) return 0x80;
	if (x == 19 || x == 28) return 0xfc;
	if (x == 24 || x == 25 || x == 39 || x == 40 || x == 50 || x == 51) return 0x94;
	if (x == 26 || x == 52) return 0x58;
	if (x == 29 || x == 30) return 0x4;
	if (x == 33 || x == 44) return 0x278;
	if (x == 34 || x == 35 || x == 45 || x == 46) return 0x484;
	if (x == 36 || x == 47) return 0x3fc;
	if (x == 38) return 0x60;
    return 0;
}
int getStatusMsg1b(int x){
    if (x == 0 || x == 5 || x == 6 || x == 34 || x == 35 || x == 37 || x == 38) return 0x4;
	if (x == 1) return 0x7f;
	if (x == 2) return 0x84;
	if (x == 4 || x == 16) return 0xff;
	if (x == 7 || x == 36 || x == 39) return 0xf8;
	if (x == 9 || x == 25 || x == 44) return 0x78;
	if (x == 10 || x == 11 || x == 23 || x == 24 || x == 42 || x == 43) return 0x94;
	if (x == 12) return 0x58;
	if (x == 17 || x == 18) return 0x9;
	if (x == 19) return 0x39;
	if (x == 20) return 0xc6;
	if (x == 22 || x == 41) return 0x60;
	if (x == 26 || x == 45) return 0x80;
	if (x == 28) return 0x27c;
	if (x == 29 || x == 30) return 0x480;
	if (x == 31) return 0x3fc;
	if (x == 33) return 0xfc;
    return 0;
}
int getStatusMsg1c(int x){
    if (x == 0) return 0xfc;
	if (x == 1) return 0x8;
	if (x == 2 || x == 10 || x == 11) return 0x4;
	if (x == 4 || x == 14 || x == 19) return 0x78;
	if (x == 5 || x == 6 || x == 20 || x == 21) return 0x84;
	if (x == 7) return 0x48;
	if (x == 9 || x == 22 || x == 32) return 0xff;
	if (x == 12) return 0xf8;
	if (x == 15 || x == 16) return 0x94;
	if (x == 17) return 0x58;
	if (x == 26 || x == 30) return 0x7f;
	if (x == 27 || x == 28 || x == 29) return 0x80;
	if (x == 33 || x == 34) return 0x9;
	if (x == 35) return 0x1;
	if (x == 37 || x == 41) return 0x7e;
	if (x == 38 || x == 39 || x == 40) return 0x81;
    return 0;
}
int getStatusMsg2(int x){
	if (x == 5 || x == 32) return 0x60;
	if (x == 6 || x == 7 || x == 30 || x == 31) return 0x94;
	if (x == 8 || x == 16 || x == 36 || x == 41 || x == 44 || x == 51 || x == 54) return 0x78;
	if (x == 9 || x == 64) return 0x80;
	if (x == 11 || x == 56) return 0xfc;
	if (x == 12 || x == 13 || x == 25 || x == 47 || x == 48 || x == 58 || x == 60) return 0x4;
	if (x == 14 || x == 49) return 0xf8;
	if (x == 17 || x == 18 || x == 27 || x == 37 || x == 38 || x == 42 || x == 43 || x == 52 || x == 53 || x == 62) return 0x84;
	if (x == 19 || x == 46) return 0xff;
	if (x == 23) return 0xfd;
	if (x == 26 || x == 61) return 0x7f;
	if (x == 29) return 0x88;
	if (x == 39) return 0x48;
	if (x == 57) return 0x8;
    return 0;
}





const vec3 e=vec3(0.00007,0,0);
const float maxd=256.0; //Max depth
float nearestD = maxd;
vec3 color;

void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 fragRayOri, in vec3 fragRayDir ) {
    
    
    
    vec3 scrCoord = fragRayOri;
    vec3 curCameraRayUnit = fragRayDir;
    
    
    color = vec3(0.0);
    
    
    const float headHeight = 1.5;
    scrCoord.y += headHeight;
    
    
    
    
    
    
    
    
    if (iGlobalTime < transitionEnd) {
        
        
        float fwd = (encounterStart-iGlobalTime)*1.0;
        fwd = max(0.0,fwd);
        scrCoord.z += fwd;
        
        
        
        
        
        float straightUfoDist = (encounterStart - iGlobalTime)*4.0;
        straightUfoDist = max(0.0,straightUfoDist);
        const float ufoStepDist = 12.0;
        float ufoStep = floor(straightUfoDist/ufoStepDist);
        float withinStep = mod(straightUfoDist/ufoStepDist,1.0);
        const float ufoDuty = 0.5;
        withinStep /= ufoDuty;
        withinStep = min(1.0,withinStep);
        float stutterUfoDist = (ufoStep+withinStep)*ufoStepDist;

        ufoX = 0.0;
        ufoX += sin(stutterUfoDist*0.5)*1.0;
        ufoX += sin(stutterUfoDist*0.9)*1.0;
        
        ufoZ = -1.5-stutterUfoDist;

        
        
        
        
        
        
        float f=0.0;
        float d=0.01;
        int mat=0;
        int dummyMat;
        vec3 p;
        for(int i=0;i<72;i++){
            if ((abs(d) < .001) || (f > maxd)) break;
            f+=d;
            p=scrCoord + curCameraRayUnit*f;
            d = caveDistance(p,mat);
        }

        if (f < nearestD) {

            nearestD = f;

            vec3 n = normalize(vec3(d-caveDistance(p-e.xyy,dummyMat),
                                    d-caveDistance(p-e.yxy,dummyMat),
                                    d-caveDistance(p-e.yyx,dummyMat)));


            
            float specP = 1.0;
            float specA = 0.0;
            float diffMin = 0.0;
            vec3 lightCol = vec3(1.0);
            vec3 darkCol = vec3(0.0);

            // floor
            if (mat == 1) {
                lightCol = vec3(160.0,144.0,96.0)/255.0;
                darkCol = vec3(144.0,128.0,88.0)/255.0;
                diffMin = -1.5;
            // wall
            } else if (mat == 2) {
                if (mod(p.y+pow(sin((p.z+abs(p.x))*8.0),4.0)*0.08+0.9,0.4)<0.1) {
                    lightCol = vec3(192.0,200.0,152.0)/255.0;
                    darkCol = vec3(120.0,120.0,104.0)/255.0;
                } else {
                	lightCol = vec3(152.0,160.0,128.0)/255.0;
                    darkCol = vec3(80.0)/255.0;
                }
                diffMin = -1.5;
                
            //UFO skin
            } else if (mat == 5) {
                lightCol = vec3(0.7);
                specA = 1.0;
                specP = 6.0;
                
            //UFO eyes
            } else if (mat == 6) {
                lightCol = vec3(0.2);
                specA = 0.65;
                specP = 16.0;
                
            }
            
            
            
            
            vec3 pointLightPos = vec3(0.0,2.0,scrCoord.z-1.5);
            vec3 L = normalize(pointLightPos-p);

            float diffuse=max(dot(n,L),0.0);
            diffuse = diffMin + (1.0-diffMin)*diffuse;
            vec3 H = normalize(L-curCameraRayUnit);
            float specular = max(dot(H,n),0.0);
            color = mix(darkCol,lightCol,diffuse) + pow(specular,specP)*specA;

            float lightDist = (length(pointLightPos-p)) * 0.02;
            lightDist = max(0.0,min(1.0,lightDist));
            color *= 1.0-lightDist;//a little faker without a square falloff but I think I like it like that
            
            
            if (p.y < 0.5) {// if NOT the ufo!
                float occlusion = length(p.xz-vec2(ufoX,ufoZ));
                occlusion = pow(occlusion,0.5);
                occlusion = max(0.0,min(1.0,(occlusion*1.8)));
                occlusion = 0.7+occlusion*0.3;
                color *= occlusion;
            }
            
            
        }
        
        if (iGlobalTime > encounterStart) {
            
            if (mat < 5) {
                
                color = vec3(color.r*0.2126+color.g*0.7152+color.b*0.0722);
                const float blackLevel = 0.2;
                color = blackLevel + color*(1.0-blackLevel);
                
                vec3 headSphereMiddle = vec3(0.0,headHeight,0.0);
                float headSphereRad = headHeight;
                float swirlSphereDist = intersectSphere(Ray(scrCoord,curCameraRayUnit),Sphere(headSphereMiddle,headSphereRad));
                vec3 swirlSpherePt = scrCoord+curCameraRayUnit*swirlSphereDist;
                swirlSpherePt -= headSphereMiddle;
                swirlSpherePt /= headSphereRad;
                
                float swirlDist = -swirlSpherePt.z;
                swirlDist = acos(swirlDist);
            	swirlDist /= (PI/2.0);
                swirlDist = pow(swirlDist,0.22);
                
                float swirlAng = atan(swirlSpherePt.y,swirlSpherePt.x);
                swirlAng = swirlAng/(PI*2.0)+0.5;
                
                const float stripeWidth = 0.04;
                
                swirlDist += swirlAng*stripeWidth*2.0;
                
                float stripeProgress = floor(swirlDist/stripeWidth)-swirlAng*2.0;
                
                float swirlOff = (0.5/stripeWidth)+(iGlobalTime-transitionStart)*10.0;
                if (mod(swirlDist,stripeWidth*2.0) < stripeWidth) swirlOff -= 1.5;
                
                float greenAmt = (stripeProgress-swirlOff)*16.0;
                greenAmt = max(0.0,min(1.0,1.0-greenAmt));
                
                color *= vec3(1.0-greenAmt,1.0,1.0-greenAmt);
            }
            
        }



        float fadeOutAmt = min(1.0,(transitionEnd-iGlobalTime)*fadeSpd);
        color *= pow(fadeOutAmt,2.0);
        
        
        
    } else {
        
        
        vec3 p = scrCoord;

        float f=0.0;
        float d=0.01;
        int mat, dummyMat;
        for(int i=0;i<64;i++){
            if ((abs(d) < .001) || (f > maxd)) break;
            f+=d;
            p=scrCoord + curCameraRayUnit*f;
            d = sceneDistance(p,mat);
        }

        if (f < nearestD) {

            nearestD = f;

            vec3 n = normalize(vec3(d-sceneDistance(p-e.xyy,dummyMat),
                                    d-sceneDistance(p-e.yxy,dummyMat),
                                    d-sceneDistance(p-e.yyx,dummyMat)));



            vec3 lightDir = normalize(vec3(0.0,0.25,1.0));
            float specP = 1.0;
            float specA = 0.0;

            float diffMin = 0.0;
            
            
            
            bool bit = false;
            if (mat == 2 || mat == 3) {
                int statusNum = int(floor(p.x/healthModX))+2;
                vec2 perStatusP = vec2(mod(p.x,healthModX),p.y);
                perStatusP.x -= 0.05;
                perStatusP.y -= 1.025;
                perStatusP *= 160.0;
                perStatusP.y *= -1.0;
                perStatusP -= vec2(2.0,8.0);
                
                int byte1 = 0;
                int byte2 = 0;
                int byte3 = 0;
                
                int charX;
                int charY;
                
                if (perStatusP.y >= 0.0 && perStatusP.y < 9.0) {
                    int char = int(floor(perStatusP.x/6.0));
                    charX = int(floor(mod(perStatusP.x,6.0)));
                    charY = int(floor(perStatusP.y));
                    if (statusNum == 0) {
                        if (char == 0) {
							// R
							byte1 = 0x6de0;
							byte2 = 0x3dfb;
							byte3 = 0x1b;
                        } else if (char == 1) {
                            // a
							byte1 = 0x3800;
							byte2 = 0x6fd8;
							byte3 = 0x1e;
                        } else if (char == 2) {
                            // v
							byte1 = 0x6c00;
							byte2 = 0x39db;
							byte3 = 0x4;
                        } else if (char == 3) {
                            // e
							byte1 = 0x3800;
							byte2 = 0xdfb;
							byte3 = 0xe;
                        } else if (char == 4) {
                            // n
							byte1 = 0x3400;
							byte2 = 0x6f7b;
							byte3 = 0x1b;
                        }
                    } else if (statusNum == 1) {
                        if (char == 0) {
                            // P
							byte1 = 0x6de0;
							byte2 = 0xdfb;
							byte3 = 0x3;
                        } else if (char == 1 || char == 4) {
                            // a
							byte1 = 0x3800;
							byte2 = 0x6fd8;
							byte3 = 0x1e;
                        } else if (char == 2) {
                            // u
							byte1 = 0x6c00;
							byte2 = 0x6f7b;
							byte3 = 0x16;
                        } else if (char == 3) {
                            // l
							byte1 = 0x18c6;
							byte2 = 0x18c6;
							byte3 = 0x6;
                        }
                    } else if (statusNum == 2) {
                        if (char == 0) {
                            // J
							byte1 = 0x18c0;
							byte2 = 0x18c6;
							byte3 = 0xcc6;
                        } else if (char == 1) {
                            // e
							byte1 = 0x3800;
							byte2 = 0xdfb;
							byte3 = 0xe;
                        } else if (char == 2 || char == 3) {
                            // f
							byte1 = 0x3ccc;
							byte2 = 0x18c6;
							byte3 = 0xcc6;
                        }
                    } else if (statusNum == 3) {
                        if (char == 0) {
                            // P
							byte1 = 0x6de0;
							byte2 = 0xdfb;
							byte3 = 0x3;
                        } else if (char == 1 || char == 2) {
                            // o
							byte1 = 0x3800;
							byte2 = 0x6f7b;
							byte3 = 0xe;
                        }
                    }
                }
                perStatusP.y -= 15.0;
                if (perStatusP.y > 0.0) {
                    int pY = int(floor(mod(perStatusP.y,16.0)));
                    int row = int(floor(perStatusP.y/16.0));
                    int leftX = int(floor(mod(perStatusP.x,6.0)));
                    int letter = int(floor(perStatusP.x/6.0));
                    if (row == 0 && letter == 0 && leftX > 2 && pY != 4) leftX -= 3;
                    if (letter >= 0 && row < 2) {
                        if (pY < 9 && leftX < 3 && letter < 2) {
                            if (pY == 0 || pY == 8) bit = true;
                            if (leftX == 0) bit = !bit;
                        }
                        if (row != 0 || letter != 0) {
                            if (letter < 2) {
                                if (leftX == 3) {
                                    if (pY < 8 && pY != 1 && pY != 5) bit = true;
                                } else if (leftX > 3) {
                                    if (pY == 0+(leftX-4) || pY == 6-(leftX-4)) bit = true;
                                }
                            }
                            if (letter == 2 && leftX == 0 && pY > 1 && pY < 5) bit = true;
                        }
                    }
                }
                
                perStatusP.x -= 15.5;
                int wheelNum = int(floor(perStatusP.x/8.0));
                int wheelRow = int(floor(perStatusP.y/16.0));
                int pX = int(floor(mod(perStatusP.x,8.0)));
                int pY = int(floor(mod(perStatusP.y,16.0)));
                
                if (wheelNum >= 0 && wheelRow >= 0 && pY<9) {
                    charX = pX;
                    charY = pY;
                    if (wheelRow == 0) {
                        if (statusNum == 0) {
                            if (wheelNum == 0) {
                                // 3
                                byte1 = 0x6f6e;
                                byte2 = 0x61d8;
                                byte3 = 0x3b7b;
                            } else if (wheelNum == 1) {
                                // 1
								byte1 = 0x31cc;
								byte2 = 0x318c;
								byte3 = 0x798c;
                            } else if (wheelNum == 2) {
                                // 4
								byte1 = 0x7b98;
								byte2 = 0x6f7b;
								byte3 = 0x631f;
                            }
                        } else if (statusNum == 1) {
                            if (wheelNum == 0) {
                                // 1
								byte1 = 0x31cc;
								byte2 = 0x318c;
								byte3 = 0x798c;
                            } else if (wheelNum == 1) {
                                // 5
								byte1 = 0xf7f;
								byte2 = 0x630f;
								byte3 = 0x3b7b;
                            } else if (wheelNum == 2) {
                                // 9
								byte1 = 0x6f6e;
								byte2 = 0x63db;
								byte3 = 0x3b7b;
                            }
                        } else if (statusNum == 2) {
                            if (wheelNum == 0) {
                                // 2
								byte1 = 0x6f6e;
								byte2 = 0x1998;
								byte3 = 0x7f63;
                            } else if (wheelNum == 1) {
                                // 6
								byte1 = 0x6f6e;
								byte2 = 0x6de3;
								byte3 = 0x3b7b;
                            } else if (wheelNum == 2) {
                                // 5
								byte1 = 0xf7f;
								byte2 = 0x630f;
								byte3 = 0x3b7b;
                            }
                        } else if (statusNum == 3) {
                            if (wheelNum == 0) {
                                // 3
								byte1 = 0x6f6e;
								byte2 = 0x61d8;
								byte3 = 0x3b7b;
                            } else if (wheelNum == 1) {
                                // 5
								byte1 = 0xf7f;
								byte2 = 0x630f;
								byte3 = 0x3b7b;
                            } else if (wheelNum == 2) {
                                // 9
								byte1 = 0x6f6e;
								byte2 = 0x63db;
								byte3 = 0x3b7b;
                            }
                        }
                    } else if (wheelRow == 1) {
                        if (statusNum == 0) {
                            if (wheelNum == 1) {
                                // 2
								byte1 = 0x6f6e;
								byte2 = 0x1998;
								byte3 = 0x7f63;
                            } else if (wheelNum == 2) {
                                // 7
								byte1 = 0x637f;
								byte2 = 0x19dc;
								byte3 = 0x18c6;
                            }
                        } else if (statusNum == 1) {
                            if (wheelNum == 1) {
                                // 1
								byte1 = 0x31cc;
								byte2 = 0x318c;
								byte3 = 0x798c;
                            } else if (wheelNum == 2) {
                                // 8
								byte1 = 0x6f6e;
								byte2 = 0x6ddb;
								byte3 = 0x3b7b;
                            }
                        } else if (statusNum == 2) {
                            if (wheelNum == 2) {
                                // 0
								byte1 = 0x6f6e;
								byte2 = 0x6f7b;
								byte3 = 0x3b7b;
                            }
                        } else if (statusNum == 3) {
                            if (wheelNum == 1) {
                                // 2
								byte1 = 0x6f6e;
								byte2 = 0x1998;
								byte3 = 0x7f63;
                            } else if (wheelNum == 2) {
                                // 8
								byte1 = 0x6f6e;
								byte2 = 0x6ddb;
								byte3 = 0x3b7b;
                            }
                        }
                    }
                }
                
                
                
                if (byte1 > 0 || byte2 > 0 || byte3 > 0) {
                    if (charX < 5) {
                        int readfrom;
                        if (charY < 3) {
                            readfrom = byte1;
                        } else if (charY < 6) {
                            readfrom = byte2;
                            charY -= 3;
                        } else {
                            readfrom = byte3;
                            charY -= 6;
                        }
                        
                        if (bitLit(readfrom,charY*5 + charX)) bit = true;
                    }
                }
                
            }
            
            
            if (mat == 4) {
                vec2 statusOrigin = vec2(p.x+1.75,p.y-2.35);
                statusOrigin *= 70.0;
                statusOrigin.y *= -1.0;
                
                int pX = int(floor(statusOrigin.x));
                int pY = int(floor(statusOrigin.y));
                
                int readfrom;
                int rownum = 0;
                if (pY < 16) {
                    if (pX < 56) {
                        readfrom = getStatusMsg1a(pX);
                    } else if (pX < 102) {
                        readfrom = getStatusMsg1b(pX-56);
                    } else {
                        readfrom = getStatusMsg1c(pX-102);
                    }
                } else {
                    readfrom = getStatusMsg2(pX);
                    rownum = 1;
                    pY -= 16;
                }
                
                if (pY >= 0 && pY < 11) {
                	if (bitLit(readfrom,pY)) bit = true;
                }
                
                if ( (pX + 150*rownum) > int((iGlobalTime-(transitionEnd+2.0))*300.0) ) {
                    bit = false;
                }
                
            }
            
            
            
            
            
            // BG
            if (mat == 1) {
                color = bgTexture(vec2(atan(p.x,p.z)/PI2*32.0,p.y/bgDist*4.0));
                color *= 1.0-pow(min((abs(p.y)/30.0),1.0),2.0);//1.0- should be inside, but it looks cooler this way~

            //frame outline
            } else if (mat == 2) {
                color = vec3(1.0);
                if (bit) color = vec3(0.0);

            //health pattern
            } else if (mat == 3) {
                const float checkerSize = 0.05;
                if ( (mod(p.x,checkerSize)<checkerSize*0.5) != (mod(p.y,checkerSize)<checkerSize*0.5) ) {
                    color = vec3(144.0,128.0,168.0)/255.0;
                } else {
                    color = vec3(144.0,144.0,232.0)/255.0;
                }
                if (bit) color = vec3(1.0);
                
            //status pattern
            } else if (mat == 4) {
                color = vec3(0.0);
                if (bit) color = vec3(1.0);

            //UFO skin
            } else if (mat == 5) {
                color = vec3(0.7);
                specA = 1.0;
                specP = 6.0;
                lightDir = normalize(vec3(0.25,0.5,1.0));

            //UFO eyes
            } else if (mat == 6) {
                color = vec3(0.2);
                specA = 0.65;
                specP = 16.0;
                lightDir = normalize(vec3(0.25,0.5,1.0));

            //Foppy skin
            } else if (mat == 7) {

                float normGap = pow(dot(-curCameraRayUnit,n),1.7);
                color = mix(
                    vec3(144.0/255.0,0.0,48.0/255.0)*0.75,
                    vec3(240.0/255.0,0.0,96.0/255.0),
                normGap);

                specA = 0.75;
                specP = 12.0;
                lightDir = normalize(vec3(1.0,1.0,0.0));
                diffMin = 1.0;





            //Foppy eyes
            } else if (mat == 8) {
                color = vec3(0.2);
                specA = 0.3;
                specP = 48.0;
            }

            color *= dot(n,lightDir)*(1.0-diffMin)+diffMin;

            float specular = max(0.0,dot(normalize(lightDir-curCameraRayUnit),n));
            color += pow(specular,specP)*specA;



            const float shadowPlane = enemyHeight;
            float stepsToPlane = (shadowPlane-scrCoord.y)/curCameraRayUnit.y;
            vec3 planePt = scrCoord+curCameraRayUnit*stepsToPlane;
            planePt.x = abs(planePt.x);

            if (planePt.z < 0.0 && planePt.z > -3.0 && planePt.z > p.z) {
                float occlusion = length(planePt.xz-vec2(enemyOffX,enemyDist));
                occlusion = pow(occlusion,0.5);
                occlusion = max(0.0,min(1.0,(occlusion*1.7)));
                occlusion = 0.3+occlusion*0.7;
                color *= occlusion;
            }

			float fadeInAmt = min(1.0,(iGlobalTime-transitionEnd)*fadeSpd);
    		color *= pow(fadeInAmt,2.0);

        }



    }


    
    
    
    fragColor = vec4(color,1.0);
    
    
}




void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	
    vec2 mouseFrac = iMouse.xy/iResolution.xy;
    mouseFrac -= 0.5;
    mouseFrac *= 2.0;
    
    vec3 cameraPos;
    vec3 cameraFwd;
    vec3 cameraUp;
    vec3 cameraRight;
    if (iGlobalTime < transitionEnd) {
        cameraPos = vec3(0.0);
        if (iMouse.z > 0.0) {
            
            float camLookX = PI - mouseFrac.x * PI * 0.5;
            float camLookY = -mouseFrac.y*0.15*PI;
            
            cameraRight = -vec3(cos(camLookX),0.0,sin(camLookX));
            cameraFwd = vec3(cos(camLookX+PI*0.5)*cos(camLookY),sin(camLookY),sin(camLookX+PI*0.5)*cos(camLookY));
            cameraUp = cross(cameraRight,cameraFwd);
            
        } else {
			cameraFwd = vec3(0.0,0.0,-1.0);
            cameraUp = vec3(0.0,1.0,0.0);
            cameraRight = normalize(-cross(cameraUp,cameraFwd));
        }
    } else {
        cameraPos = vec3(0.0,0.06,0.75);
        if (iMouse.z > 0.0) {

            cameraPos.x -= mouseFrac.x*0.7;
            cameraPos.y -= mouseFrac.y*0.75;

        } else {

            float waveTime = iGlobalTime;
            cameraPos.x += sin(waveTime*0.5)*0.4;
            cameraPos.y += sin(waveTime*1.0)*-0.05;

        }
        cameraFwd = normalize(vec3(0.0,-0.4,-2.0)-cameraPos);
        cameraUp = vec3(0.0,1.0,0.0);
        cameraRight = normalize(-cross(cameraUp,cameraFwd));
    }
    
    
    
    
    
    // all this stuff with working from FOVs is for the sake of WebVR compatibility,
    // which is redundant for shadertoy, but handy for my personal site

    float vertFov = 50.0;
    float horizFov = 2.0*atan(tan((vertFov/180.0*PI)/2.0)*(iResolution.x/iResolution.y))*180.0/PI;
    vec4 fovAngsMono = vec4(horizFov/2.0, horizFov/2.0, vertFov/2.0, vertFov/2.0);



    vec2 fragFrac = fragCoord.xy/iResolution.xy;

    vec2 eyeRes = iResolution.xy;
    vec4 fovAngs = fovAngsMono;









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