// Shader downloaded from https://www.shadertoy.com/view/ldB3DK
// written by shadertoy user Ramocles
//
// Name: Portal Gun
// Description: THE CAKE IS A LIE. <br/>Fully functional ray marched portal system. Mouse controls the camera direction (both "subjective camera" and "3rd person camera"). Sorry, no Companion Cube this time. <br/>
//////////////////////////////////////////
//
// Created by Ramon Viladomat
//
// Description: 
//
// Fully functional portal system with two portals connected. Mouse controls 
// the camera direction (both "subjective camera" and "3rd person camera"). 
//
// How it works:  
//
// The basic idea behind this shader is to first compute the portals 
// used for the given ray before the raymarching phase( storing
// ray lambdas, positions and offsets for each portal cross ). 
// 
// Next we raymarch checking the portal data at each step to know which 
// ray origin and direction we should use for the distance function based 
// on the line lambda.
//
// The camera movement uses a sequence of bezier splines going from portal to portal.
//
// Hope you like it. 
//
//////////////////////////////////////////

//////////////////////////////////////////
// Option MACROS

//Comment this to have an static camera and see the whole scene from a 3rd person view 
#define SUBJETIVE_CAMERA

//Comment this to remove the ilumination of the spark representing the subjective camera
#define SPARK_ILUMINATION

//////////////////////////////////////////
//Common MACROS

#define PI          3.1415
#define EPSILON     0.002
#define TIME_SCALE  1.0
#define TIME_OFFSET -0.5

//////////////////////////////////////////
//Fade-In Transition Times
#define FADE_IN_START 0.5
#define FADE_IN_END   1.5

//////////////////////////////////////////
//Ray marching MACROS

#define NUM_RAYMARCH_STEP 150
#define STEP_REDUCTION    0.8
#define NUM_REFLECTIONS   3

//////////////////////////////////////////
//Portal MACROS

#define NUM_PORTAL_RECURSIONS    4
#define PORTAL_EPSILON           0.02
#define PORTAL_RADIUS            1.5
#define PORTAL_SHAPE_INV_SCALE_X 1.7
#define PORTAL_OPEN_SPEED        5.0
#define PORTAL_CLOSE_SPEED       20.0

//////////////////////////////////////////
// Global Definitions

//Portal Ray Properties
vec3 rayDirections[NUM_PORTAL_RECURSIONS]; 
vec3 rayPositions[NUM_PORTAL_RECURSIONS];
vec4 rayColors[NUM_PORTAL_RECURSIONS];
float distances[NUM_PORTAL_RECURSIONS];

//Current Portals VARS
vec3 portal1Norm = vec3(0.0,0.0,-1.0); 
vec3 portal1Pos = vec3(-8.0,-3.5,-PORTAL_EPSILON);  
float portal1Radius = 1.5; 
	
vec3 portal2Norm = vec3(0.0,0.0,1.0); 
vec3 portal2Pos = vec3(-8.0,-3.5,-10.0+PORTAL_EPSILON);  
float portal2Radius = 1.5; 

//Animation VARS

#define NUM_CAMERA_TRAMS 5
vec3 cameraControl0[NUM_CAMERA_TRAMS]; 
vec3 cameraControl1[NUM_CAMERA_TRAMS];
vec3 cameraControl2[NUM_CAMERA_TRAMS];
vec3 cameraControl3[NUM_CAMERA_TRAMS];
float cameraDuration[NUM_CAMERA_TRAMS];

#define NUM_PORTAL_TRAMS 5
vec3 portal1Normals[NUM_PORTAL_TRAMS];
vec3 portal1Positions[NUM_PORTAL_TRAMS];
float portal1Duration[NUM_PORTAL_TRAMS];

vec3 portal2Normals[NUM_PORTAL_TRAMS];
vec3 portal2Positions[NUM_PORTAL_TRAMS];
float portal2Duration[NUM_PORTAL_TRAMS];

////////////////
// DATA SETUP //
////////////////

void InitData()
{
	//Portal 1 - Blue
	portal1Duration [0] = 4.0; 
	portal1Normals  [0] = vec3(0.0,0.0,-1.0);
	portal1Positions[0] = vec3(-8.0,-3.5,-PORTAL_EPSILON); 
	
	portal1Duration [1] = 2.6; 
	portal1Normals  [1] = vec3(0.0,0.0,1.0);
	portal1Positions[1] = vec3(8.0,8.0,-10.0+PORTAL_EPSILON); 
	
	portal1Duration [2] = 1.0; 
	portal1Normals  [2] = vec3(0.0,0.0,-1.0);
	portal1Positions[2] = vec3(8.0,5.0,10.0-PORTAL_EPSILON); 
	
	portal1Duration [3] = 5.0; 
	portal1Normals  [3] = vec3(0.0,0.0,1.0);
	portal1Positions[3] = vec3(8.0,-3.5,-10.0+PORTAL_EPSILON); 
	
	//Note: portal 4 doesn't have 4rt place
	
	//Portal 2 - Red
	portal2Duration [0] = 1.0; 
	portal2Normals  [0] = vec3(0.0,0.0,1.0);
	portal2Positions[0] = vec3(-8.0,-3.5,-10.0+PORTAL_EPSILON); 

	portal2Duration [1] = 4.6; 
	portal2Normals  [1] = vec3(0.0,0.0,-1.0);
	portal2Positions[1] = vec3(8.0,-3.5,-PORTAL_EPSILON); 
	
	portal2Duration [2] = 0.45; 
	portal2Normals  [2] = vec3(0.0,1.0,0.0);
	portal2Positions[2] = vec3(0.0,-10.0+PORTAL_EPSILON,-5.0);
	
	portal2Duration [3] = 2.0; 
	portal2Normals  [3] = vec3(0.0,0.0,-1.0);
	portal2Positions[3] = vec3(8.0,1.5,10.0-PORTAL_EPSILON); 	
	
	portal2Duration [4] = 5.0; 
	portal2Normals  [4] = vec3(0.0,0.0,1.0);
	portal2Positions[4] = vec3(-8.0,-3.5,-10.0+PORTAL_EPSILON); 
	
  	//Camera 
	cameraDuration[0] = 3.0; 
	cameraControl0[0] = portal2Positions[0];
	cameraControl1[0] = portal2Positions[0] + portal2Normals[0]*2.0;
	cameraControl2[0] = portal1Positions[0] + portal1Normals[0]*2.0;
	cameraControl3[0] = portal1Positions[0];
	
	cameraDuration[1] = 2.0; 
	cameraControl0[1] = portal2Positions[1];
	cameraControl1[1] = portal2Positions[1] + portal2Normals[1]*2.0;
	cameraControl2[1] = vec3(8.0,-3.5,-5.0); 
	cameraControl3[1] = vec3(5.0,-3.5,-5.0);
	
	cameraDuration[2] = 1.0; 
	cameraControl0[2] = cameraControl3[1];
	cameraControl1[2] = cameraControl3[1]-vec3(2.0,0.0,0.0);
	cameraControl2[2] = portal2Positions[2] + portal2Normals[2]*5.0;
	cameraControl3[2] = portal2Positions[2];
	
	cameraDuration[3] = 1.5; 
	cameraControl0[3] = portal1Positions[1];
	cameraControl1[3] = portal1Positions[1] + portal1Normals[1]*5.0;
	cameraControl2[3] = portal2Positions[3] + portal2Normals[3]*2.0;
	cameraControl3[3] = portal2Positions[3];
	
	cameraDuration[4] = 1.5; 
	cameraControl0[4] = portal1Positions[2];
	cameraControl1[4] = portal1Positions[2] + portal1Normals[2]*10.0;
	cameraControl2[4] = portal1Positions[3] + portal1Normals[3]*2.0;
	cameraControl3[4] = portal1Positions[3];
}

///////////////////
// WORLD UPDATES //
///////////////////

vec3 Bezier(in vec3 p0, in vec3 p1, in vec3 p2, in vec3 p3, in float t, out vec3 tangent)
{
	// n : being n+1 the number of control points
	// Bezier(t) = SUM[i=0..n]( Bernstein<n,i>(t)*ControlPoint<i> )

	// Bernstein polys for the given factor
	// Berstein<n,i>(t) = (n!/(i!*(n-i)!))*t^i*(1-t)^(n-i)
	
	float t2 = t*t;
	float t3 = t*t*t;

	float minusT = 1.0 - t;
	float minusT2 = minusT * minusT;
	float minusT3 = minusT2 * minusT;

	// Tangent
	
	// derived Bernstein polys for the given factor
	// Berstein<n,i>(t) = (n!/(i!*(n-i)!))*t^i*(1-t)^(n-i)
	
	tangent = normalize((p1-p0)*minusT2 + (p2-p1)*(2.0*t*minusT) + (p3-p2)*t2);
	
	// Position
	
	float b0 = minusT3;		  //(1-t)^3
	float b1 = 3.0*t*minusT2; //3t(1-t)^2
	float b2 = 3.0*t2*minusT; //3t^2(1-t)
	float b3 = t3;			  //t^3

	return (b0*p0)+(b1*p1)+(b2*p2)+(b3*p3);
}

vec3 GetCameraPos(in float time, out vec3 tangent)
{
	float localTime = time; 	
	for (int i=0;i<NUM_CAMERA_TRAMS;++i)
	{
		if (localTime < cameraDuration[i])
		{
			return Bezier(cameraControl0[i],cameraControl1[i],cameraControl2[i],cameraControl3[i],localTime/cameraDuration[i],tangent);
		}
						
		localTime -= cameraDuration[i];		
	}
	return vec3(0.0);
}

vec3 UpdatePortals(in float time)
{
	float localTime1 = time; 	
	float localTime2 = time; 	
	for (int i=0;i<NUM_PORTAL_TRAMS;++i)
	{
		if (localTime1 < portal1Duration[i])
		{
			portal1Norm = portal1Normals[i];
			portal1Pos  = portal1Positions[i];
			float openCloseFactor = min(PORTAL_OPEN_SPEED*localTime1,PORTAL_CLOSE_SPEED*abs(localTime1 - portal1Duration[i])); 
			portal1Radius = PORTAL_RADIUS*min(openCloseFactor,1.0);
			localTime1  = 99999.0; 
		}
		
		if (localTime2 < portal2Duration[i])
		{
			portal2Norm = portal2Normals[i];
			portal2Pos  = portal2Positions[i];
			float openCloseFactor = min(PORTAL_OPEN_SPEED*localTime2,PORTAL_CLOSE_SPEED*abs(localTime2 - portal2Duration[i])); 
			portal2Radius = PORTAL_RADIUS*min(openCloseFactor,1.0);
			localTime2  = 99999.0; 
		}
						
		localTime1 -= portal1Duration[i];		
		localTime2 -= portal2Duration[i];
	}
	return vec3(0.0);
}

////////////////
// MORPHOLOGY //
////////////////

float AnaliticalDistSpark(in vec3 ro, in vec3 rd, vec3 point, float distThreshold)
{
	float lambda = dot(-(ro - point),rd);
	float dist = length((ro+rd*lambda)-point);
	return mix(9999.0,dist,step(-1.0,lambda)*step(lambda,distThreshold+1.0)); 
}

float DistBox(in vec3 p, in vec3 dimensions)
{
	return length(max(abs(p) - dimensions,0.0)); 
}

float DistWalls( in vec3 p)
{
	return min(min(-p.z+10.0,-p.x+10.0),-p.y+10.0);
}

float Map( in vec3 p )
{
	vec3 q = vec3(abs(p.x),p.y,p.z); 
	
	return  min(
			   DistWalls(vec3(q.x,abs(q.y),abs(q.z))),
			   min(DistBox(q-vec3(0.0,-10.0,10.0),vec3(10.0)),DistBox(q-vec3(15.0,-15.0,0.0),vec3(10.0)))
			   );
}

////////////
// PORTAL //
////////////

float RayPortalIntersection(
	in vec3 rayOrigin,
	in vec3 rayDir, 
	in vec3 portalNorm, 
	in vec3 portalLeft, 
	in vec3 portalUp,
	in vec3 portalPos, 
	in float portalRadius, 
	in float otherRadius,
	out vec3 localRayDir,
	out vec2 localPos, 
	out float signedDist
)
{
	float t = dot(portalNorm,portalPos-rayOrigin) / (dot(rayDir,portalNorm)); 
	vec3 intersectionPos = rayOrigin + t*rayDir; 
	
	float dotRayNorm = dot(rayDir,portalNorm); 
	
	vec3 localp = intersectionPos - portalPos;
	localPos = vec2(dot(localp,portalLeft),dot(localp,portalUp));
	localRayDir = vec3(dot(rayDir,portalLeft),dot(rayDir,portalUp),dotRayNorm); 
					
	//check distance to portal 
	const vec2 scale = vec2(PORTAL_SHAPE_INV_SCALE_X,1.0); 

	vec2 localPosScaled = localPos*scale;
	
	vec2 closestBorderPoint = normalize(localPosScaled)*min(portalRadius,otherRadius); 
	vec2 borderDeltaVec = localPosScaled - closestBorderPoint; 
	
	signedDist = dot(borderDeltaVec,closestBorderPoint)*length(borderDeltaVec/scale); 
	
	//return data
	float insidePortal = step(dotRayNorm,0.0)*step(EPSILON,t)*step(length(localPosScaled),portalRadius);
	return mix(9999.0,t,insidePortal);
}

vec4 GetPortalColor(in float signedDist, in vec3 baseColor)
{
	return vec4(baseColor,clamp(1.0+signedDist*20.0,0.0,1.0)); 
}

float PortalCheck(
	in vec3 rayOrigin,
	in vec3 rayDir, 
	out vec3 outRayOrigin,
	out vec3 outRayDir,
	out vec4 outPortalColor
	)
{
	vec3 realUp1 = mix(vec3(0.0,1.0,0.0),vec3(-1.0,0.0,0.0),step(0.9,dot(vec3(0.0,1.0,0.0),portal1Norm)));
	vec3 realUp2 = mix(vec3(0.0,1.0,0.0),vec3(-1.0,0.0,0.0),step(0.9,dot(vec3(0.0,1.0,0.0),portal2Norm)));
	
	vec3 portal1Left = normalize(cross(realUp1,portal1Norm));
	vec3 portal1Up = normalize(cross(portal1Norm,portal1Left));
	vec3 portal2Left = normalize(cross(realUp2,portal2Norm));
	vec3 portal2Up = normalize(cross(portal2Norm,portal2Left));
	
	vec2 portal1localPos;
	vec3 portal1localRay; 
	float portal1SignedDist; 
	float p1 = RayPortalIntersection(rayOrigin,rayDir,portal1Norm,portal1Left,portal1Up,portal1Pos,portal1Radius,portal2Radius,portal1localRay,portal1localPos,portal1SignedDist); 
	vec4 portal1Color = GetPortalColor(portal1SignedDist,vec3(0.0,0.0,1.0)); 	
	
	vec2 portal2localPos;
	vec3 portal2localRay; 
	float portal2SignedDist; 
	float p2 = RayPortalIntersection(rayOrigin,rayDir,portal2Norm,portal2Left,portal2Up,portal2Pos,portal2Radius,portal1Radius,portal2localRay,portal2localPos,portal2SignedDist); 
	vec4 portal2Color = GetPortalColor(portal2SignedDist,vec3(1.0,0.0,0.0)); 	
	
	vec3 outPosp1p2 = portal2Pos - portal1localPos.x*portal2Left + portal1localPos.y*portal2Up;
	vec3 outDirp1p2 = -portal1localRay.x*portal2Left + portal1localRay.y*portal2Up - portal1localRay.z*portal2Norm; 	

	vec3 outPosp2p1 = portal1Pos - portal2localPos.x*portal1Left + portal2localPos.y*portal1Up;
	vec3 outDirp2p1 = -portal2localRay.x*portal1Left + portal2localRay.y*portal1Up - portal2localRay.z*portal1Norm; 	

	float portalSelector = step(p2,p1); // 0 if portal 1 -> portal 2 | 1 if portal 2 -> portal 1 	
	outRayOrigin = mix(outPosp1p2,outPosp2p1,portalSelector);
	outRayDir = mix(outDirp1p2,outDirp2p1,portalSelector);
	outPortalColor = mix(portal1Color,portal2Color,portalSelector);
	return mix(p1,p2,portalSelector);
}

void ComputePortals(in vec3 rayOrigin, in vec3 rayDir)
{
	rayPositions[0]=rayOrigin;
	rayDirections[0]=rayDir; 
	distances[0]=0.0;
	rayColors[0]=vec4(0.0);
	
	for (int i=1;i<NUM_PORTAL_RECURSIONS;++i)
	{
		distances[i]=distances[i-1] + PortalCheck(rayPositions[i-1],rayDirections[i-1],rayPositions[i],rayDirections[i],rayColors[i]);		
	}
}

float ExtractPortalRay(in float t, out vec3 rayOrigin, out vec3 rayDir)
{
	float ret = 0.0; 
	rayOrigin = vec3(0.0); 
	rayDir = vec3(0.0);
	
	for (int i=0;i<NUM_PORTAL_RECURSIONS;++i)
	{
		float isCopy = step(distances[i],t);
		float minusIsCopy = 1.0 - isCopy; 
		
		ret = (distances[i]*isCopy)+(ret*minusIsCopy);
		rayOrigin = (rayPositions[i]*isCopy)+(rayOrigin*minusIsCopy);
		rayDir = (rayDirections[i]*isCopy)+(rayDir*minusIsCopy);		
	}
	return ret;
}

vec4 ExtractPortalColor(in float t)
{
	vec4 ret = vec4(0.0); 
	
	for (int i=0;i<NUM_PORTAL_RECURSIONS;++i)
	{
		float blendFactor = (1.0 - ret.w)*rayColors[i].w*step(distances[i],t); 
		ret.xyz = ret.xyz + blendFactor*rayColors[i].xyz;
		ret.w += blendFactor; 
	}
	return ret;
}

///////////////
// MATERIALS //
///////////////

vec4 CalcColor( in vec3 pos, in vec3 nor)
{
	//ground/ceiling basic Color
	vec2 groundtiles = 2.0*(0.5 - abs(0.5-mod(pos.xz,vec2(1.0)))); 
	float groundtileBorder = smoothstep(0.0,0.1,min(groundtiles.x,groundtiles.y));
	vec4 groundColor = groundtileBorder*vec4(0.2,0.2,0.2,0.08); 
	
	//walls
	vec3 wallTiles = 2.0*abs(vec3(1.0,2.5,1.0)-mod(pos+vec3(0.96,2.5,0.96),vec3(2.0,5.0,2.0)));
	float walltileBorder = smoothstep(0.0,0.1,min(min(wallTiles.x,wallTiles.y),wallTiles.z));
	vec4 wallColor = walltileBorder*vec4(0.05,0.05,0.05,0.02);
		
	return mix(wallColor,groundColor,abs(dot(nor,vec3(0.0,1.0,0.0))));
}

//////////////////////
// MAIN RAY/SHADING //
//////////////////////

float Intersect()
{
	vec3 ro; 
	vec3 rd; 
	float res = 2.0*EPSILON;
    float t = 0.0;
    for( int i=0; i<NUM_RAYMARCH_STEP; i++ )
    {
		if( abs(res)<EPSILON ) continue;
		float dist = ExtractPortalRay(t,ro,rd);
		res = Map( ro+rd*(t-dist) );
		t += res*STEP_REDUCTION;
    }
	return t;
}

vec3 CalcNormal( in vec3 pos )
{
    vec2 eps = vec2(EPSILON,0.0);
	return normalize( vec3( Map(pos+eps.xyy) - Map(pos-eps.xyy), Map(pos+eps.yxy) - Map(pos-eps.yxy), Map(pos+eps.yyx) - Map(pos-eps.yyx) ) );
}

//IQ ray-marched ambient occlusion algorithm 
float AmbientOcclusion( in vec3 pos, in vec3 nor )
{
	float totao = 0.0;
    float sca = 1.0;
    for( int aoi=0; aoi<8; aoi++ )
    {
        float hr = 0.01 + 1.2*pow(float(aoi)/8.0,1.5);
        vec3 aopos =  nor * hr + pos;
        float dd = Map( aopos );
        totao += -(dd-hr)*sca;
        sca *= 0.85;
    }
    return clamp( 1.0 - 0.6*totao, 0.0, 1.0 );
}

//////////
// MAIN //
//////////

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	////////////////
	//Init Data
	InitData();
	
	////////////////
	//Update World
	float localTime = mod(TIME_OFFSET+iGlobalTime*TIME_SCALE,9.0);
	vec3 tangent;
	vec3 worldCameraPos = GetCameraPos(localTime,tangent);
	UpdatePortals(localTime); 
		
	////////////////
	// Render
    vec2 puv = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    vec2 p = vec2(puv.x * iResolution.x/iResolution.y,puv.y);
	
	// Compute Camera
	vec2 mousePos = iMouse.xy/iResolution.xy;
	
#ifdef SUBJETIVE_CAMERA
	
	//move camera when clicking	
	vec2 mouseAngles = (mix(vec2(0.0),(mousePos*2.0)-1.0,clamp(iMouse.z,0.0,1.0)))*vec2(PI,PI*0.5);
	
	vec3 camPosition = worldCameraPos;
	vec3 camTmpRight = normalize( cross(tangent,vec3(0.0,1.0,0.0) ) );
    vec3 camTmpUp    = normalize( cross(camTmpRight,tangent));
	
	//apply camera extra rotation
	vec3 camFront    = (tangent*cos(mouseAngles.x)+camTmpRight*sin(mouseAngles.x))*cos(mouseAngles.y)+camTmpUp*sin(mouseAngles.y);
	vec3 camRight 	 = normalize( cross(camFront,camTmpUp));

#else
	
	//apply permanent camera movement 
	float inputCamAngle = PI-2.0*PI*mousePos.x;
	vec3 camPosition    = vec3(0.0,2.0,-5.0);
	vec3 camTarget	    = camPosition + vec3(sin(inputCamAngle), (3.0*mousePos.y)-1.0, cos(inputCamAngle));
	vec3 camFront 	    = normalize( camTarget - camPosition );
	vec3 camRight 	    = normalize( cross(camFront,vec3(0.0,1.0,0.0) ) );
   
#endif
	
	vec3 camUp 		 = normalize( cross(camRight,camFront));
    vec3 rayDir 	 = normalize( p.x*camRight + p.y*camUp + 2.0*camFront );
	
	// light compute 
	vec3 lightPos1 = vec3(0.0,5.0,0.0);
	vec3 lightColor1 = vec3(1.0,1.0,1.0);
				
	// Start Ray
    vec3 finalcolor = vec3(0.0);
	float attenuation = 1.0;
	for( int reflectCount=0; reflectCount<NUM_REFLECTIONS; reflectCount++ )
	{
		// Portal logic goes here 
		ComputePortals(camPosition,rayDir);
							
		// Compute color for single ray
    	float t = Intersect();
		
		vec3 prevRayDir = rayDir; 
		vec3 prevCamPosition = camPosition;
		
		// results extraction
		vec4 portalColor = ExtractPortalColor(t);
		float dist = ExtractPortalRay(t,camPosition,rayDir); 
		float localDist = t-dist;
		
		vec3 position 	= camPosition + localDist*rayDir;
		vec3 normal 	= normalize(CalcNormal(position));
		vec3 reflDir 	= reflect(rayDir,normal);
			
		// lights and materials 
		vec4 materialColor 	= CalcColor( position, normal );
		
		float ambient  		= 0.7 + 0.3*normal.y;
		vec3 ambientColor 	= ambient*materialColor.rgb;
		
		//ambient occlusion
		float occlusion = AmbientOcclusion( position, normal );
		
		//light 1
		vec3 lightDir1 	= normalize(lightPos1 - position);
		float diffuse1  = max(dot(normal,lightDir1),0.0);
		vec3 diffuseColor = diffuse1*lightColor1*materialColor.rgb;		
		
		//bluelightComponent shining
		vec2 lightSource = -(abs(position.xz)-10.0);
		float blueIntensity = pow(smoothstep(2.0,10.0,position.y)*(1.0-smoothstep(0.0,8.0,min(lightSource.x,lightSource.y))),50.0);  
		
		//fluroescentCeiling shining
		lightSource = abs(mod(position.xz-vec2(10.0),vec2(4.0))-vec2(2.0));
		float whiteIntensity = smoothstep(9.9,10.0,position.y)*(1.0 - smoothstep(1.0,2.5,lightSource.y))*(1.0 - smoothstep(1.0,2.5,lightSource.x));
			
		vec3 lightShine = max(0.0,blueIntensity)*vec3(0.0,0.1,0.5)+vec3(1.0)*max(whiteIntensity,0.0);
		
#ifndef SUBJETIVE_CAMERA

		//Render Spark on the subjective Camera position
		float fwdSparkDist = AnaliticalDistSpark(prevCamPosition,prevRayDir,worldCameraPos,dist); 
		float ptlSparkDist = AnaliticalDistSpark(camPosition,rayDir,worldCameraPos,localDist);
				
		finalcolor += attenuation*vec3(pow(max(smoothstep(4.0,0.0,min(fwdSparkDist,ptlSparkDist)),0.0),80.0));
		
#ifdef SPARK_ILUMINATION
		//Spark ilumination
		vec3 lightDir2 	= worldCameraPos - position;
		float diffuse2  = smoothstep(5.0,1.0,length(lightDir2))*max(dot(normal,normalize(lightDir2)),0.0);
		diffuseColor += diffuse2*materialColor.rgb;		
#endif
		
#endif
		//mixing lights
		finalcolor += attenuation*(lightShine + mix(mix(ambientColor,occlusion*diffuseColor,0.8),portalColor.xyz,portalColor.w));
		
		// prepare next ray for reflections 
		rayDir = reflDir;
		attenuation *= 2.0*materialColor.w;
		camPosition = position + EPSILON*normal;
	}
	
	// saturate
	finalcolor = min(finalcolor,vec3(1.0));
	
	// desaturation, gamma correction and simple vignette
	finalcolor = pow(mix( finalcolor, vec3(dot(finalcolor,vec3(0.33))), 0.3 ), vec3(0.45));
	float introTransition = smoothstep(FADE_IN_START,FADE_IN_END,iGlobalTime); 
	finalcolor *= introTransition*mix(1.0,0.0,smoothstep(0.7,2.0,length(puv)));
	
    fragColor = vec4( finalcolor,1.0 );
}