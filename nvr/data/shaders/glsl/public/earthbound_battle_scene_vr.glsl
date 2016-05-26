// Shader downloaded from https://www.shadertoy.com/view/MljGRd
// written by shadertoy user RavenWorks
//
// Name: Earthbound Battle Scene VR
// Description: [url=https://www.shadertoy.com/view/MtsXRX]Check out the expanded version by clicking HERE![/url]
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
    vec2 d = abs(vec2(length(tp.yz),tp.x)) - (size-roundness);
    return min(max(d.x,d.y)+roundness,0.0) + length(max(d,0.0))-roundness;
}
float obj_cylForever(vec2 p, vec2 middle, float radius){
    return abs(length(p-middle)) - radius;
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


const float bgDist = 10.0;
const float statusDist = -0.75;
const float statusHeight = 0.85;
const float enemyDist = -2.0;
const float enemyHeight = 1.0;
const float enemyOffX = 0.6;

float sceneDistance(vec3 p, inout int material){
    
    float distance = 9999.9;
    material = 0;
    
    
    
    hardAdd(material,distance,1,
    	-obj_cylForever(p.xz, vec2(0.0),bgDist)
    );
    
    
    const float outlineRad = 0.02;
    float healthModX = 0.35;
    vec2 healthSize = vec2(0.25,0.35)/2.0;
    if (abs(p.x)<healthModX*2.0) {
        
        vec3 healthP = p;
        healthP.y -= statusHeight;
        
        healthP.x = mod(healthP.x,healthModX);
        healthP.x -= healthModX/2.0;
        
        vec3 healthFrameP = healthP;
        healthFrameP.y = abs(healthFrameP.y);
        healthFrameP.x = abs(healthFrameP.x);
        
        
        const float boxThickness = 0.03;
        hardAdd(material,distance,3,
			obj_box(healthFrameP,vec3(0.0,0.0,statusDist-boxThickness+0.01),vec3(healthSize.xy,boxThickness),0.0)
		);
        
        const float healthInset = 0.01;
        smoothSubtract(distance,
            obj_box(healthP,vec3(0.05,-0.1,statusDist),vec3(0.075,0.125,healthInset),0.0),
        	0.01
        );

        
        hardAdd(material,distance,2,
            obj_quartertorus(healthFrameP,vec3(healthSize.xy,statusDist),vec2(outlineRad,outlineRad-0.001))
        );
        
        
        
        vec3 wheelP = healthP;
        wheelP.x -= 0.05;
        wheelP.x = abs(wheelP.x);


        wheelP.y += 0.075;
        wheelP.y = abs(wheelP.y);

        hardAdd(material,distance,2,
        	obj_cylinder(wheelP,vec3(0.0,0.05,statusDist-healthInset),vec2(0.05,0.025),0.0075)
        );
        hardAdd(material,distance,2,
        	obj_cylinder(wheelP,vec3(0.05,0.05,statusDist-healthInset),vec2(0.05,0.025),0.0075)
        );

    }
    
    vec3 statusP = p;
    statusP.y -= statusHeight+1.0;
    statusP.y = abs(statusP.y);
    
    statusP.x += 0.25;
    statusP.x = abs(statusP.x);
    
    hardAdd(material,distance,2,
    	obj_quartertorus(statusP,vec3(0.4,0.1,statusDist),vec2(0.02,0.01))
    );
    hardAdd(material,distance,4,
    	obj_box(statusP,vec3(0.0,0.0,statusDist-0.005),vec3(0.41,0.12,0.01),0.0)
    );
    
    
    
    
    float ufoHeight = enemyHeight+sin(iGlobalTime*2.5)*0.02;
    
    vec3 ufoRotP = p;
    
    vec3 ufoBodyP = ufoRotP;
    ufoBodyP.y -= ufoHeight+0.3;
    ufoBodyP.y = abs(ufoBodyP.y);
    
    hardAdd(material,distance,5,
		obj_ball(ufoBodyP,vec3(-enemyOffX,-1.0,enemyDist),1.1)
	);
    smoothAdd(distance,
		obj_ball(ufoBodyP,vec3(-enemyOffX,0.03,enemyDist),0.2),
    0.1);
    
    vec3 ufoEyeP = ufoRotP;
    ufoEyeP.x -= -enemyOffX+0.05;
    ufoEyeP.x = abs(ufoEyeP.x);
    
    hardAdd(material,distance,6,
		obj_ball(ufoEyeP,vec3(0.045,ufoHeight+0.41,enemyDist+0.25),0.025)
	);
    
    
    
    
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




const vec3 e=vec3(0.00007,0,0);
const float maxd=256.0; //Max depth
float nearestD = maxd;
vec3 color;

void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 fragRayOri, in vec3 fragRayDir ) {
    
    
    
    vec3 scrCoord = fragRayOri;
    vec3 curCameraRayUnit = fragRayDir;
    
    
    color = vec3(0.0);
    
    
    scrCoord.y += 1.5;
    
    
    
    
    
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
        
        // BG
        if (mat == 1) {
            color = bgTexture(vec2(atan(p.x,p.z)/PI2*32.0,p.y/bgDist*4.0));
            color *= 1.0-pow(min((abs(p.y)/30.0),1.0),2.0);//1.0- should be inside, but it looks cooler this way~
            
        //frame outline
        } else if (mat == 2) {
            color = vec3(1.0);
            
        //health pattern
        } else if (mat == 3) {
            const float checkerSize = 0.05;
            if ( (mod(p.x,checkerSize)<checkerSize*0.5) == (mod(p.y,checkerSize)<checkerSize*0.5) ) {
                color = vec3(144.0/255.0,128.0/255.0,168.0/255.0);
            } else {
                color = vec3(144.0/255.0,144.0/255.0,232.0/255.0);
            }
            
        //status pattern
        } else if (mat == 4) {
            color = vec3(0.0);
            
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
        
        
        
    }


    
    
    
    fragColor = vec4(color,1.0);
    
    
}


const float transitionTime = 2.5;
const float fadeSpd = 1.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	
    
    float introTime = iGlobalTime - 1.25;
    
    
    if (introTime < transitionTime) {
        
        
        float extent = min(iResolution.x,iResolution.y);
        vec2 uv = fragCoord.xy / extent;
        uv *= 2.0;
        uv -= 1.0;
        uv -= ((iResolution.xy/extent)-1.0);
        
        uv.x *= 0.8;
        
        
        vec3 color = vec3(0.35+sin(uv.x*16.0+uv.y*6.0)*0.15);
        

        float dist = length(uv);
        dist = pow(dist,0.42);
        float ang = atan(uv.y,uv.x);
        float angFrac = ang/(PI*2.0)+0.5;

        const float stripeWidth = 0.15;

        dist += angFrac*stripeWidth*2.0;

        float stripeProgress = floor(dist/stripeWidth)-angFrac*2.0;
        
        float swirlOff = introTime*10.0;
        if (mod(dist,stripeWidth*2.0) < stripeWidth) swirlOff -= 1.5;
        
        float stripeLit = (stripeProgress-swirlOff)*16.0;
        float greenVal = max(0.0,min(1.0,(0.8-stripeLit)));
        
        
        float fadeOutAmt = pow(min(1.0,(transitionTime-introTime)*fadeSpd),2.0);
        
        
        color *= vec3(1.0-greenVal,1.0,1.0-greenVal);
        color *= fadeOutAmt;
        
        fragColor = vec4(color,1.0);
        
        
        
    } else {



        vec3 cameraPos = vec3(0.0,0.06,0.75);

        vec2 mouseFrac = iMouse.xy/iResolution.xy;
        mouseFrac -= 0.5;
        mouseFrac *= 2.0;

        if (iMouse.z != 0.0) {

            cameraPos.x -= mouseFrac.x*0.75;
            cameraPos.y -= mouseFrac.y*0.75;

        } else {
            
            float waveTime = iGlobalTime - transitionTime - 2.0;
            cameraPos.x += sin(waveTime*0.5)*0.4;
            cameraPos.y += sin(waveTime*1.0)*-0.05;
            
        }
        
        
        vec3 cameraFwd = normalize(vec3(0.0,-0.4,-2.0)-cameraPos);
        vec3 cameraUp = vec3(0.0,1.0,0.0);
        vec3 cameraRight = normalize(-cross(cameraUp,cameraFwd));
        
        
        
        
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
        
        
        
        float fadeInAmt = min(1.0,(introTime-transitionTime)*fadeSpd);
        fragColor.xyz *= pow(fadeInAmt,2.0);
        

    }
    
    
}