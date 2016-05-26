// Shader downloaded from https://www.shadertoy.com/view/MdBSz3
// written by shadertoy user RavenWorks
//
// Name: VR test scene
// Description: Here's my first WebVR raymarching test scene, now ported to ShaderToy's VR mode!
//    Standalone version here: [url]http://raven.works/projects/raymarchFull/[/url]


const float PI =3.14159265;
const float PI2=6.28318531;

float obj_ball(vec3 p, vec3 center, float radius){
    return length(p-center)-radius;
}
float obj_box(vec3 p, vec3 center, vec3 size, float roundness){
    vec3 d = abs(p-center)-size;
    return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)) - roundness;
}
float obj_cylinder(vec3 p, vec3 center, vec2 size, float roundness){
    vec3 tp = p-center;
    vec2 d = abs(vec2(length(tp.xz),tp.y)) - size;
    return min(max(d.x,d.y)+roundness,0.0) + length(max(d,0.0))-roundness;
}
float obj_planeX(vec3 p, float planeX){
    return p.x-planeX;
}
float obj_planeY(vec3 p, float planeY){
    return p.y-planeY;
}
float obj_planeZ(vec3 p, float planeZ){
    return p.z-planeZ;
}

float obj_cylForeverZ(vec2 p, float middleY, float radius){
    return abs(length(vec2(p.x,p.y-middleY))) - radius;
}

float smooth( float a, float b, float k ){
    float h = clamp(0.5+0.5*(b-a)/k,0.0,1.0);
    return mix(b,a,h) - k*h*(1.0-h);
}

void hardAdd(inout float curD, inout int curMaterial, float newD, int newMaterial){
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

const float cylMidZ = -1.5;

vec3 rotMod(vec3 p, vec2 middle, float modFrac){
    vec2 cylRel = vec2(p.x-middle.x,p.z-middle.y);
    float cylAng = atan(cylRel.y,cylRel.x);
    float cylDist = length(cylRel);
    float modSlice = PI2/modFrac;
    float newAng = (mod((cylAng+modSlice*0.5),(modSlice)))-(modSlice*0.5);
    return vec3(cos(newAng)*cylDist,p.y,sin(newAng)*cylDist);

}

float middleMod(float val,float modDist){
    return mod(val+modDist*0.5,modDist)-modDist*0.5;
}

float room(vec3 p, out int material){






    float distance = 9999.9;
    material = 0;

    const float pillarGapX = 2.5;
    const float pillarGapZ = 0.5;

    const float floorTileGap = 0.5;
    const float floorTileGrout = 0.07;

    const float ceilY = 9.0;

    const float mirrorY = 0.5;

    vec3 pillarP = vec3(mod(p.x,pillarGapX*2.0),-abs(p.y-mirrorY)+mirrorY,mod(p.z,pillarGapZ*2.0));

    // ceiling flat
    hardAdd(distance,material,
            -obj_planeY(p ,ceilY),
            3);

    // ceiling groove
    hardSubtract(distance,
                 obj_cylForeverZ(vec2(middleMod(p.x,5.0),p.y),ceilY,2.3));

    // base
    hardAdd(distance,material,
            obj_box(pillarP,vec3(pillarGapX,-1.4,pillarGapZ),vec3(0.4,0.15,0.4),0.0),
            1);

    // base blend
    smoothAdd(distance,
              obj_cylinder(pillarP,vec3(pillarGapX,-1.15,pillarGapZ),vec2(0.3,0.1),0.0),
              0.11);

    // floor
    hardAdd(distance,material,
            obj_box(vec3(mod(p.x,floorTileGap*2.0),p.y,mod(p.z,floorTileGap*2.0)),vec3(floorTileGap,-1.5-floorTileGap,floorTileGap),vec3(floorTileGap-floorTileGrout),floorTileGrout),
            2);

    //column
    hardAdd(distance,material,
            obj_cylinder(pillarP,vec3(pillarGapX,mirrorY,pillarGapZ),vec2(0.25,2.0),0.0),
            1);







    return distance;

}







void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 fragRayOri, in vec3 fragRayDir ) {
    
    
    vec3 cameraPos = fragRayOri;
    vec3 curCameraRayUnit = fragRayDir;
    
    
    
    //scene movement
    float fwdDist = iGlobalTime*0.2;
    cameraPos.z -= fwdDist;
    
    
    
    // Raymarching.
    const vec3 e=vec3(0.00007,0,0);
    const float maxd=40.0; //Max depth
    vec3 p;

    float f=0.0;
    float d=0.01;
    int surfaceMaterial = 0;
    for(int i=0;i<96;i++){
        if ((abs(d) < .001) || (f > maxd)) break;
        f+=d;
        p=cameraPos+curCameraRayUnit*f;
        d = room(p,surfaceMaterial);
    }


    vec3 color;
    int dummyMaterial;

    if (f < maxd){

        vec3 surfaceColor;
        float specA, specP;
        float difP = 1.0;
        vec3 normalCheat = vec3(0.0,0.0,0.0);//generally not advisable in stereo, but it's used very shallowly here

        if (surfaceMaterial == 1){

            vec3 marbleP = p;

            marbleP.x += sin(p.y*20.0)*0.12;
            marbleP.z += sin(p.y*22.0)*0.1;
            marbleP.y += sin(p.x*25.0)*0.13;
            marbleP.y += sin(p.z*23.0)*0.14;

            marbleP.y += sin(p.x*1.3)*0.5;
            marbleP.y += sin(p.z*1.5)*0.6;

            marbleP.x += sin(p.y*150.0)*0.011;
            marbleP.z += sin(p.y*162.0)*0.013;
            marbleP.y += sin(p.x*145.0)*0.012;
            marbleP.y += sin(p.z*153.0)*0.015;

            marbleP.x *= 20.0;
            marbleP.z *= 20.0;
            marbleP.y *= 10.0;

            float marbleAmtA = abs(sin(marbleP.x)+sin(marbleP.y)+sin(marbleP.z))/3.0;
            marbleAmtA = pow(1.0-marbleAmtA,5.0);

            marbleP = p;

            marbleP.x += sin(p.y*21.0)*0.12;
            marbleP.z += sin(p.y*23.0)*0.1;
            marbleP.y += sin(p.x*22.0)*0.13;
            marbleP.y += sin(p.z*24.0)*0.14;

            marbleP.y += sin(p.x*1.2)*0.5;
            marbleP.y += sin(p.z*1.4)*0.6;

            marbleP.x += sin(p.y*150.0)*0.011;
            marbleP.z += sin(p.y*162.0)*0.013;
            marbleP.y += sin(p.x*145.0)*0.012;
            marbleP.y += sin(p.z*153.0)*0.015;

            marbleP.x *= 22.0;
            marbleP.z *= 23.0;
            marbleP.y *= 11.0;

            float marbleAmtB = abs(sin(marbleP.x)+sin(marbleP.y)+sin(marbleP.z))/3.0;
            marbleAmtB = pow(1.0-marbleAmtB,9.0);
            marbleAmtB = 1.0-(1.0-marbleAmtB*0.3);

            float marbleAmt = marbleAmtA + marbleAmtB;
            marbleAmt = clamp(marbleAmt,0.0,1.0);

            surfaceColor = mix(vec3(0.0,0.8,0.5),vec3(0.70),marbleAmt);
            specA = mix(1.0,0.8,marbleAmt);
            specP = mix(16.0,28.0,marbleAmt);

        }
        if (surfaceMaterial == 2) {

            vec3 marbleP = p;
            vec3 intensityP = p;

            float tileSize = 1.0;
            if ( ceil(mod(p.x,tileSize*2.0)/tileSize) == ceil(mod(p.z,tileSize*2.0)/tileSize) ) {
                surfaceColor = vec3(0.45,0.0,0.0);
                marbleP.x *= -1.0;
                intensityP.x *= -1.0;
                marbleP.z += 1.0;
                intensityP.z += 1.0;
            } else {
                surfaceColor = vec3(0.75,0.75,0.6);
            }
            specA = 1.0;
            specP = 16.0;




            marbleP.x += marbleP.z*0.5;
            marbleP.z += marbleP.x*0.4;

            marbleP.x += sin(marbleP.x*  3.8)*0.125;
            marbleP.z += sin(marbleP.z*  3.6)*0.135;

            marbleP.x += sin(marbleP.z* 20.0)*0.025;
            marbleP.z += sin(marbleP.x* 25.0)*0.025;

            marbleP.x += sin(marbleP.z* 40.0)*0.025;
            marbleP.z += sin(marbleP.x* 45.0)*0.025;

            marbleP.x += sin(marbleP.z*150.0)*0.01;
            marbleP.z += sin(marbleP.x*160.0)*0.011;

            marbleP *= 36.0;




            intensityP.z -= 10000.0;

            intensityP.x += intensityP.z*0.3;
            intensityP.z += intensityP.x*0.1;

            intensityP.x += sin(intensityP.x*1.2)*0.36;
            intensityP.z += sin(intensityP.z*1.3)*0.21;

            intensityP.x += sin(intensityP.z*2.2)*0.8;
            intensityP.z += sin(intensityP.x*2.3)*0.9;

            intensityP *= 6.0;


            float intensityAmt = (sin(intensityP.x)*sin(intensityP.z))*0.5+0.5;
            intensityAmt = 1.0-pow(1.0-intensityAmt,0.5);

            float marbleAmt = (sin(marbleP.x)*sin(marbleP.z))*0.5+0.5;


            float marbleGrainAmt = marbleAmt;
            marbleGrainAmt = 1.0-((1.0-pow(marbleGrainAmt,1.5))*(1.0-intensityAmt)*1.125);
            marbleGrainAmt = 1.0-pow(1.0-marbleGrainAmt,5.0);

            surfaceColor *= marbleGrainAmt;
            specA *= marbleGrainAmt;



            float marbleGashAmt = marbleAmt;
            marbleGashAmt *= 0.5 + 18.0*intensityAmt;
            marbleGashAmt += pow(intensityAmt,2.5)*18.0;
            marbleGashAmt = clamp(marbleGashAmt,0.0,1.0);

            float marbleGoldAmt = pow(marbleGashAmt,1.0);
            float marbleShadeAmt = pow(marbleGashAmt,16.0);

            surfaceColor *= marbleShadeAmt;
            specA *= marbleShadeAmt;

            vec3 myNormalCheat = vec3(
                sin( p.x*200.0 + sin(p.z*100.0)*0.5 + sin(p.z*17.0)*(5.0+sin(p.x*20.0)*4.0) )*0.000015,
                0.0,
                0.0
            );

            surfaceColor = mix(vec3(1.0,0.9,0.0),surfaceColor,marbleGoldAmt);
            specP = mix(256.0,specP,marbleGoldAmt);
            specA = mix(1.0,specA,marbleGoldAmt);
            difP = mix(6.0,difP,marbleGoldAmt);
            normalCheat = mix(myNormalCheat,normalCheat,marbleGoldAmt);

        }
        if (surfaceMaterial == 3){

            float splinters =
                pow(abs( ( sin(p.x*100.0)*0.5 + sin(p.y*100.0)*0.5 ) ), 0.1)
                *
                (sin(p.z*2.0+sin(p.x*10.0)*4.0+sin(p.x*27.0)*3.0)*0.5+0.5);

            float waves = sin(
                p.z*10.0 +
                sin(p.z*3.0 + sin(p.x*11.0)*0.5 )*1.0 +
                sin((p.z + sin(p.z*0.5)*5.5)*0.15 + sin(p.x*0.8)*2.0) * 14.0 +
                pow(abs(sin((p.x*1.0 + sin(p.x*3.0)*0.5)*25.0)),0.5) * 0.5
            );

            float grain = splinters * 0.3 + waves * 0.7;
            grain = pow(grain*0.5+0.5,0.25);

            surfaceColor = mix(vec3(0.2,0.1,0.1),vec3(0.4,0.2,0.05),grain);
            specP = mix(30.0,20.0,grain);
            specA = grain;

        }

        vec3 n = vec3(d-room(p-e.xyy,dummyMaterial),
                      d-room(p-e.yxy,dummyMaterial),
                      d-room(p-e.yyx,dummyMaterial));
        n += normalCheat;
        vec3 N = normalize(n);

        vec3 pointLightPos = vec3(0.0,2.0,-4.5-fwdDist);
        vec3 L = normalize(pointLightPos-p);

        float diffuse=max(dot(N,L),0.0);
        vec3 H = normalize(L-curCameraRayUnit);
        float specular = max(dot(H,N),0.0);
        color = pow(diffuse,difP)*surfaceColor + pow(specular,specP)*specA;

        float lightDist = (length(pointLightPos-p)) * 0.04;
        lightDist = max(0.0,min(1.0,lightDist));
        color *= pow(1.0-lightDist, 2.0);

    } else {

        color = vec3(0.0,0.0,0.0);

    }



    fragColor = vec4(color,1.0);
    
}



void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	
    
    float vertFov = 50.0;
    float horizFov = 2.0*atan(tan((vertFov/180.0*PI)/2.0)*(iResolution.x/iResolution.y))*180.0/PI;
    vec4 fovAngsMono = vec4(horizFov/2.0, horizFov/2.0, vertFov/2.0, vertFov/2.0);
    


    



    vec2 fragFrac = fragCoord.xy/iResolution.xy;

    vec2 eyeRes = iResolution.xy;
    vec4 fovAngs = fovAngsMono;


/*
    vec3 cameraRight,cameraUp,cameraFwd;
    quatToAxes(headOrientation,cameraRight,cameraUp,cameraFwd);
	cameraFwd *= -1.0;
*/
    float camLookY = sin(PI*0.5+iGlobalTime*-0.2)*0.5 - 0.25;
    vec3 cameraRight = vec3(1.0,0.0,0.0);
    vec3 cameraFwd = -vec3(0.0,sin(camLookY),cos(camLookY));
    vec3 cameraUp = cross(cameraRight,cameraFwd);

    




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