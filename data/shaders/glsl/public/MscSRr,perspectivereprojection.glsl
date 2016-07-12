// Shader downloaded from https://www.shadertoy.com/view/MscSRr
// written by shadertoy user Bers
//
// Name: PerspectiveReprojection
// Description: Screen space parallel lines intersection (vanishing point) is used in order to compute a world space parallelogram. One of the basic principles of automated 3D scene reconstruction. Only a screen space quad input required (3D position is inferred).
// Author : Sébastien Bérubé
// Created : Dec 2015
// Modified : Jan 2016
//
// This shader uses the vanishing point on the image plane in order to infer the world space direction of parallel lines.
// From 4 points (2D) on the image plane, it will use projective geometry properties in order to generate 4 points (3D) world space.
// 
// This is a very important concept for 3D scene reconstruction from 2D images.
//
// The one line that is important in this shader is : "p1_to_p2 = dirVanishingPoint", in function "resolveAdjacentCorner()".
// What this means is : the 3D line starting from the camera center and going towards the vanishing point of 2 parallel lines 
//                      are all parallel with each other (as all lines directed towards this vanishing point are parallel).
//                      Although parallel lines are nerver supposed to cross each other in reality, they however do on the 
//                      projected image plane, and this allows computation of the vanishing point intersection in 2D first,
//                      and then inferring 3D direction by casting a ray from the camera center through this vanishing point
//                      on the image plane.
//
// License : Creative Commons Non-commercial (NC) license
//
const vec2 SS1_BOTTOM_LEFT  = vec2( 0.180, 0.320);
const vec2 SS1_BOTTOM_RIGHT = vec2( 0.332, 0.360);
const vec2 SS1_TOP_RIGHT    = vec2( 0.332, 0.640);
const vec2 SS1_TOP_LEFT     = vec2( 0.180, 0.766);

const vec2 SS2_BOTTOM_LEFT  = vec2( 0.820, 0.343);
const vec2 SS2_BOTTOM_RIGHT = vec2( 0.970, 0.33);
const vec2 SS2_TOP_RIGHT    = vec2( 0.965, 0.745);
const vec2 SS2_TOP_LEFT     = vec2( 0.815, 0.675);
    
struct Cam { vec3 R; vec3 U; vec3 D; vec3 O;}; //R=Right, U=Up, D=Direction, O=Origin
Cam    CAM_lookAt(vec3 target, float pitchAngleRad, float dist, float theta);
Cam    CAM_mouseLookAt(vec3 at, float dst);

//Function to cast a ray through a given coordinate (uv) on the image plane.
//It returns the direction of a 3D Ray.
//Note : screen center is uv=[0,0]
vec3 ray(vec2 uv, Cam cam)
{
    return normalize(uv.x*cam.R+uv.y*cam.U+cam.D);
}

//Function which does the opposite of the previous function:
//It receives a 3D world space position, then flattens it on the image plane 
//and returns its [uv] coordinates.
//Note : screen center is uv=[0,0]
vec2 camProj(Cam c, vec3 p)
{
    p = p-c.O;
    float cZ = dot(p,c.D);
    float cX = dot(p,c.R);
	float cY = dot(p,c.U);
    return vec2(cX/cZ,cY/cZ);
}

//Simple utility function which returns the distance from point "p" to a given line segment defined by 2 points [a,b]
float distanceToLineSeg(vec2 p, vec2 a, vec2 b)
{
    //e = capped [0,1] orthogonal projection of ap on ab
    //       p
    //      /
    //     /
    //    a--e-------b
    vec2 ap = p-a;
    vec2 ab = b-a;
    vec2 e = a+clamp(dot(ap,ab)/dot(ab,ab),0.0,1.0)*ab;
    return length(p-e);
}

//Utility function returning the intersection point of two 2D lines
//[p1a,p1b] = line1
//[p2a,p2b] = line1
vec2 lineLineIntersection(vec2 p1a, vec2 p1b, vec2 p2a, vec2 p2b)
{
    vec2 d1 = (p1b-p1a); //Direction Line 1
    vec2 d2 = (p2b-p2a); //Direction Line 2
    vec2 d1n = vec2(d1.y, -d1.x); //orthogonal line to d1 (normal), optimal direction to reach d1 from anywhere
    float dist = dot(p1a-p2a,d1n);//projection on the optimal direction = distance
    float rate = dot(d2,d1n); //rate : how much is our d2 line in the optimal direction? (<=1.0)
    float t = 10000000.0 ; //INFINITY! (rare parallel case)
    if(rate != 0.0)
		t = dist/rate; //Starting from p2a, find the distance to reach the other line along d2.
    return p2a+t*d2;  //start point + distance along d2 * d2 direction = intersection.
}

//Utility function to compute the distance along a ray to reach a plane, in 3D.
//The value returned is the distance along ray to the plane intersection.
//o = ray origin
//d = ray direction
//po = plane origin
//pn = plane normal
float rayPlaneIntersec(vec3 o, vec3 d, vec3 po, vec3 pn) 
{
    //Same principle as lineLineIntersection() :
    //"How far is the plane"/"approach rate".
    //No need to normalize pn, as dot product above and under cancel out and do not scale the result.
    return dot(po-o,pn)/dot(d,pn);
}

struct screenSpaceQuad{ vec2 a; vec2 b; vec2 c; vec2 d; };
struct worldSpaceQuad{  vec3 a; vec3 b; vec3 c; vec3 d; };

//perspectiveCam : the camera from which the points in screen space come from
//P1 : known world space position of p1
//p1 : screen space p1 (which is resolved, already)
//p2 : screen space p2 (which must be adjacent to p1 - cannot be the opposite corner)
//parallel_a : first point (screen space) in the other line parallel to (p1,p2)
//parallel_b : second point (screen space) in the other line parallel to (p1,p2)
vec3 resolveAdjacentCorner(in Cam perspectiveCam, vec3 P1, vec2 p1_resolved, vec2 p2_adjacent, vec2 parallel_a, vec2 parallel_b)
{
    //screen space intersection (vanishing point on the projection plane)
    vec2 ssIntersec = lineLineIntersection(p1_resolved,p2_adjacent,parallel_a,parallel_b);
    //Vanishing point direction, from camera, in world space.
    vec3 dirVanishingPoint = ray(ssIntersec, perspectiveCam);
    vec3 p1_to_p2 = dirVanishingPoint; //Since vanishing point is at "infinity", p1_to_p2 == dirVanishingPoint
    vec3 r2 = ray(p2_adjacent, perspectiveCam);//Ray from camera to p2, in world space
    
    //<Line3D intersection : where p1_to_p2 crosses r2>
    //(Note : this could probably be made simpler with a proper 3D line intersection formula)
    //Find (rb,p1_to_p2) intersection:
    vec3 n_cam_p1_p2 = cross(p1_to_p2,r2); //normal to the triangle formed by point p1, point p2 and the camera origin
    vec3 n_plane_p2 = cross(n_cam_p1_p2,r2); //normal to the plane which is crossed by line p1-p2 at point p2
    float t = rayPlaneIntersec(P1,p1_to_p2,perspectiveCam.O,n_plane_p2);
    vec3 p2_ws = P1+t*p1_to_p2;
    //</Line3D intersection>
    return p2_ws;
}
    
//Finds each corner, one by one.
void resolvePerspective(in Cam perspectiveCam, in screenSpaceQuad ssQuad, out worldSpaceQuad wsQuad)
{
    vec3 ra = ray(ssQuad.a, perspectiveCam); //Find the direction of the ray passing by point a in screen space.
	                                      //For the sake of simplicity, screenspace [uv.x,uv.y] = worldspace [x,y]. Z = depth.
    //Let's place point a in an arbitrary position along the ray ra. 
    //It does not matter at which distance exactly, as it is the relationship between
    //the corners that is important. The first corner distance simply defines the scaling of the 3D scene.
    wsQuad.a = perspectiveCam.O + 5.5*ra; //5.5 = arbitrary scaling. Projective geometry does not preserve world space scaling.
    wsQuad.b = resolveAdjacentCorner(perspectiveCam, wsQuad.a, ssQuad.a, ssQuad.b, ssQuad.c, ssQuad.d);
    wsQuad.c = resolveAdjacentCorner(perspectiveCam, wsQuad.b, ssQuad.b, ssQuad.c, ssQuad.a, ssQuad.d);
    wsQuad.d = resolveAdjacentCorner(perspectiveCam, wsQuad.a, ssQuad.a, ssQuad.d, ssQuad.b, ssQuad.c);
}

vec3 apply_atmosphere(float travelDist, in vec3 color, in vec3 p)
{
    //From this nice article on fog:
    //http://iquilezles.org/www/articles/fog/fog.htm
    //or this PowerPoint from Crytek:
	//GDC2007_RealtimeAtmoFxInGamesRev.ppt p17
	vec3 c_atmosphere = mix(vec3(0.87,0.94,1.0),vec3(0.6,0.80,1.0),clamp(3.0*p.y/length(p.xz),0.,1.));
    float c = 1.08;
    float b = 0.06;

    float cumul_density = c * exp(-1.0*b) * (1.0-exp( -travelDist*1.0*b ))/1.0;
    cumul_density = clamp(cumul_density,0.0,1.0);
    vec3 FinalColor = mix(color,c_atmosphere,cumul_density);
    return FinalColor;
}

vec3 alphaBlend(vec3 c1, vec3 c2, float alpha)
{
    return mix(c1,c2,clamp(alpha,0.0,1.0));
}

vec2 pixel2uv(vec2 px, bool bRecenter, bool bUniformSpace)
{
    if(bRecenter)
    {
        px.xy-=iResolution.xy*0.5;
	}
    
    vec2 resolution = bUniformSpace?iResolution.xx:iResolution.xy;
    vec2 uv = px.xy / resolution;
    return uv;
}

vec3 drawPoint(vec2 uv, vec2 point, vec3 cBack, vec3 cPoint, float radius, float fZoom)
{
    radius /= fZoom;
    float distPt = length(uv-point);
    float alphaPt = 1.0-smoothstep(radius-.003/fZoom,radius,distPt);
    return alphaBlend(cBack,cPoint,alphaPt);
}

vec3 drawLine(vec2 uv, vec2 pa, vec2 pb, vec3 cBack, vec3 cLine, float radius, float fZoom)
{
    radius /= fZoom;
    float distLine = distanceToLineSeg(uv,pa,pb);
    float alphaLine = 1.0-smoothstep(radius-.003/fZoom,radius,distLine);
    return alphaBlend(cBack,cLine,alphaLine);
}

//wsQuad.a = origin (lower left corner)
//wsQuad.a,b,c,d = CCW point order.
vec2 findParallelogramUV(vec3 o, vec3 d, worldSpaceQuad wsQuad)
{
    //Note : This is tricky because axis are not orthogonal.
    vec3 uvX_ref = wsQuad.b-wsQuad.a; //horitonal axis
    vec3 uvY_ref = wsQuad.d-wsQuad.a; //vertical axis
    vec3 quadN = cross(uvY_ref,uvX_ref);
    float t = rayPlaneIntersec(o, d, wsQuad.a, quadN);
        
    vec3 p = o+t*d;
    vec3 X0_N = cross(uvY_ref,quadN);
    vec3 Y0_N = cross(uvX_ref,quadN);
    
    //Vertical component : find the point where plane X0 is crossed
    float t_x0 = rayPlaneIntersec(p, uvX_ref, wsQuad.a, X0_N);
    vec3 pY = p+t_x0*uvX_ref-wsQuad.a;
    //Horizontal component : find the point where plane Y0 is crossed
    float t_y0 = rayPlaneIntersec(p, uvY_ref, wsQuad.a, Y0_N);
    vec3 pX = p+t_y0*uvY_ref-wsQuad.a;
    
    //All is left to find is the relative length ot pX, pY compared to each axis reference
    return vec2(dot(pX,uvX_ref)/dot(uvX_ref,uvX_ref),
	            dot(pY,uvY_ref)/dot(uvY_ref,uvY_ref));
}

vec3 drawPerspectiveScene(Cam perspectiveCam, vec2 uv, screenSpaceQuad ssQuad, worldSpaceQuad wsQuad, vec3 cBackground, float fZoom)
{
    vec3 cScene = cBackground;
    cScene = texture2D(iChannel0,uv+0.5).xyz;
    
	float fLineWidth = 0.0025;
    cScene = drawLine(uv, ssQuad.a, ssQuad.b, cScene, vec3(0), fLineWidth, fZoom);
    cScene = drawLine(uv, ssQuad.b, ssQuad.c, cScene, vec3(0), fLineWidth, fZoom);
    cScene = drawLine(uv, ssQuad.c, ssQuad.d, cScene, vec3(0), fLineWidth, fZoom);
    cScene = drawLine(uv, ssQuad.d, ssQuad.a, cScene, vec3(0), fLineWidth, fZoom);
    
    float fPointRad = 0.006;
    cScene = drawPoint(uv, ssQuad.a, cScene, vec3(0,1,0), fPointRad, fZoom);
    cScene = drawPoint(uv, ssQuad.b, cScene, vec3(0,1,0), fPointRad, fZoom);
    cScene = drawPoint(uv, ssQuad.c, cScene, vec3(0,1,0), fPointRad, fZoom);
    cScene = drawPoint(uv, ssQuad.d, cScene, vec3(0,1,0), fPointRad, fZoom);
    
    //Show results
    fPointRad = 0.004;
    vec2 aDebug = camProj(perspectiveCam,wsQuad.a);
    vec2 bDebug = camProj(perspectiveCam,wsQuad.b);
    vec2 cDebug = camProj(perspectiveCam,wsQuad.c);
    vec2 dDebug = camProj(perspectiveCam,wsQuad.d);
    cScene = drawPoint(uv, aDebug, cScene, vec3(0,0,1), fPointRad, fZoom);
    cScene = drawPoint(uv, bDebug, cScene, vec3(0,0,1), fPointRad, fZoom);
    cScene = drawPoint(uv, cDebug, cScene, vec3(0,0,1), fPointRad, fZoom);
    cScene = drawPoint(uv, dDebug, cScene, vec3(0,0,1), fPointRad, fZoom);
    
    return cScene;
}

Cam setupPerspectiveCamera()
{
    Cam cam;
    cam.O = vec3(0,0,0);
    cam.R = vec3(1,0,0);
    cam.U = vec3(0,1,0);
    cam.D = vec3(0,0,-1);
    return cam;
}

screenSpaceQuad setupPerspectiveQuad(vec2 mouse_uv)
{
    screenSpaceQuad ssQuad;
    
    //Arbitrary screen-space parallelograms.
    if(fract(iGlobalTime/4.0)> 0.5)
    {
        ssQuad.a = SS1_BOTTOM_LEFT-0.5;
    	ssQuad.b = SS1_BOTTOM_RIGHT-0.5;
    	ssQuad.c = SS1_TOP_RIGHT-0.5;
    	ssQuad.d = SS1_TOP_LEFT-0.5;
    }
    else
    {
     	ssQuad.a = SS2_BOTTOM_LEFT-0.5;
    	ssQuad.b = SS2_BOTTOM_RIGHT-0.5;
    	ssQuad.c = SS2_TOP_RIGHT-0.5;
    	ssQuad.d = SS2_TOP_LEFT-0.5;   
    }
    
    if(iMouse.z > 0.0 && mouse_uv.x < 0.5 && mouse_uv.y < 0.5) //if mouse btn down
    {
		ssQuad.d = mouse_uv;
    }
    
    return ssQuad;
}

vec2 inversePerspective_uv(Cam perspectiveCam, vec2 uv_01, screenSpaceQuad ssQuad, worldSpaceQuad wsQuad )
{
    vec3 x_ws = wsQuad.b-wsQuad.a;
    vec3 y_ws = wsQuad.d-wsQuad.a;
    vec3 p_ws = wsQuad.a+uv_01.x*x_ws + uv_01.y*y_ws;
    vec2 puv = camProj(perspectiveCam,p_ws);
	return puv;
}

Cam setupSceneCamera()
{
    float targetDistance = 10.5;
    vec3 cam_tgt = vec3(0,0,-3.0);
    Cam cam = CAM_lookAt(cam_tgt, -0.2, targetDistance, -0.75+iGlobalTime*0.1);
    if(iMouse.xz != vec2(0.0,0.0) && ( iMouse.x > iResolution.x/4.0 || iMouse.y > iResolution.y/4.0) ) //Mouse button down : user control
    {
    	cam = CAM_mouseLookAt(cam_tgt, targetDistance);
    }
    return cam;
}

vec3 draw3DScene(Cam perspectiveCam, Cam sceneCam, vec2 uv, worldSpaceQuad wsQuad, screenSpaceQuad ssQuad)
{
    vec3 o = sceneCam.O;
    vec3 d = ray(uv,sceneCam);
    
    vec3 cScene = vec3(0);
    
    float t = rayPlaneIntersec(o,d, vec3(0,-1.0,0), vec3(0,1,0));
    if(t<0.0)
    {
        t = 1000.0;
        cScene = apply_atmosphere(t,vec3(1),o+t*d);
    }
    else
    {
		vec3 pFloor = o+t*d;
    	vec3 cFloor = texture2D(iChannel1,pFloor.xz*0.25).xyz;
    	cScene = apply_atmosphere(t,cFloor,pFloor);
    }
    
    float fZoom = 3.0*iResolution.x/1920.;
    vec2 aDebug = camProj(sceneCam,wsQuad.a);
    vec2 bDebug = camProj(sceneCam,wsQuad.b);
    vec2 cDebug = camProj(sceneCam,wsQuad.c);
    vec2 dDebug = camProj(sceneCam,wsQuad.d);
    vec2 oDebug = camProj(sceneCam,perspectiveCam.O);
    cScene = drawPoint(uv,aDebug,cScene,vec3(1,0,0),0.005, fZoom);
    cScene = drawPoint(uv,bDebug,cScene,vec3(1,0,0),0.005, fZoom);
    cScene = drawPoint(uv,cDebug,cScene,vec3(1,0,0),0.005, fZoom);
    cScene = drawPoint(uv,dDebug,cScene,vec3(1,0,0),0.005, fZoom);
    cScene = drawPoint(uv,oDebug,cScene,vec3(0,0,1),0.005, fZoom);
    cScene = drawLine(uv,aDebug,oDebug,cScene,vec3(0,0.8,1),0.0025, fZoom);
    cScene = drawLine(uv,bDebug,oDebug,cScene,vec3(0,0.8,1),0.0025, fZoom);
    cScene = drawLine(uv,cDebug,oDebug,cScene,vec3(0,0.8,1),0.0025, fZoom);
    cScene = drawLine(uv,dDebug,oDebug,cScene,vec3(0,0.8,1),0.0025, fZoom);
    cScene = drawLine(uv,aDebug,bDebug,cScene,vec3(0),0.0025, fZoom);
    cScene = drawLine(uv,bDebug,cDebug,cScene,vec3(0),0.0025, fZoom);
    cScene = drawLine(uv,cDebug,dDebug,cScene,vec3(0),0.0025, fZoom);
    cScene = drawLine(uv,dDebug,aDebug,cScene,vec3(0),0.0025, fZoom);
    
    //Projection Plane (camera near plane)
    float tImage = rayPlaneIntersec(o,d, perspectiveCam.O+normalize(perspectiveCam.D), perspectiveCam.D);
    if(tImage>0.0) //tImage < 0 when the ray never intersects the floor plane (intersection happens behind camera)
    {
        vec3 pImage = o+tImage*d;
        vec2 uv = camProj(perspectiveCam,pImage);
        
        if(abs(uv.x)<0.5 && abs(uv.y)<0.5*iResolution.y/iResolution.x)
        {
            vec3 cPersp = drawPerspectiveScene(perspectiveCam, uv, ssQuad, wsQuad, vec3(0.55), fZoom*0.1);
            cScene = alphaBlend(cScene,cPersp,0.5);
        }
    }
    
    //
    vec3 nQuad = cross((wsQuad.b-wsQuad.a),(wsQuad.d-wsQuad.a));
    float tQuad = rayPlaneIntersec(o,d, wsQuad.a, nQuad);
    if(tQuad>0.0) //tQuad < 0 when the ray never intersects the floor plane (intersection happens behind camera)
    {
        vec2 uv = findParallelogramUV(o,d,wsQuad);
        if(uv.x>0.0 && uv.x<1.0 &&
           uv.y>0.0 && uv.y<1.0 )
        {
            vec2 tuv = inversePerspective_uv(perspectiveCam, uv, ssQuad, wsQuad);
        	vec3 cTest = drawPerspectiveScene(perspectiveCam, tuv, ssQuad, wsQuad, vec3(0.55), fZoom*0.25);
            cScene = alphaBlend(cScene,cTest,0.5);
        }
    }
    
    return cScene;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float perspectiveImageSize = 0.25;
    float fZoom = 3.0*iResolution.x/1920.;
    
    vec2 perspective_uv = pixel2uv(fragCoord/perspectiveImageSize, true, true);
    vec2 perspective_mouse_uv = pixel2uv(iMouse.xy/perspectiveImageSize, true, true);
	
    worldSpaceQuad wsQuad;
    screenSpaceQuad ssQuad = setupPerspectiveQuad(perspective_mouse_uv);
    Cam perspectiveCam = setupPerspectiveCamera();
    resolvePerspective(perspectiveCam,ssQuad,wsQuad);
    
    //Perspective view
    if(fragCoord.x<iResolution.x*perspectiveImageSize && fragCoord.y<iResolution.y*perspectiveImageSize)
    {
        vec3 cPerspective = drawPerspectiveScene(perspectiveCam, perspective_uv, ssQuad, wsQuad, vec3(0.55), fZoom*perspectiveImageSize);
        fragColor = vec4(cPerspective,1.0);
    }
    //Inverse view
    /*else if(fragCoord.x>iResolution.x*(1.0-perspectiveImageSize) && fragCoord.y<iResolution.y*perspectiveImageSize)
    {
        vec2 fragCoordLocal = vec2( fragCoord.x-iResolution.x*(1.0-perspectiveImageSize),fragCoord.y);
        vec2 inverse_perspective_uv = pixel2uv(fragCoordLocal/perspectiveImageSize, false, false);
        
        vec2 tuv = inversePerspective_uv(perspectiveCam, inverse_perspective_uv, ssQuad, wsQuad);
        vec3 cTest = drawPerspectiveScene(perspectiveCam, tuv, ssQuad, wsQuad, vec3(0.55), fZoom*perspectiveImageSize);
        fragColor = vec4(cTest,1.0);
    }*/
    //3D Scene
    else
    {
        vec2 uvScene = pixel2uv(fragCoord, true, true);
	    Cam sceneCam = setupSceneCamera();
	    vec3 cScene = draw3DScene(perspectiveCam, sceneCam, uvScene, wsQuad, ssQuad);
        fragColor = vec4(cScene,1.0);
    }
}

Cam CAM_lookAt(vec3 at, float fPitch, float dst, float rot) 
{ 
    Cam cam;
    cam.D = vec3(cos(rot)*cos(fPitch),sin(fPitch),sin(rot)*cos(fPitch));
    cam.U = vec3(-sin(fPitch)*cos(rot),cos(fPitch),-sin(fPitch)*sin(rot));
    cam.R = cross(cam.D,cam.U); cam.O = at-cam.D*dst;
    return cam;
}
Cam CAM_mouseLookAt(vec3 at, float dst)
{
    vec2 res = iResolution.xy; vec2 spdXY = vec2(15.1416,4.0);
    float fMvtX = (iMouse.x/res.x)-0.535;
    if(fMvtX>0.3) dst *= (1.0+(fMvtX-0.3)/0.03);
    else if(fMvtX<-0.3) dst *= (1.0-(fMvtX+0.3)/(-0.2));
	fMvtX += iGlobalTime*0.0150;//Auto turn
    return CAM_lookAt(at,spdXY.y*((iMouse.y/res.y)-0.5),dst,spdXY.x*fMvtX);
}