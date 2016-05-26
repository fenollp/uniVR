// Shader downloaded from https://www.shadertoy.com/view/4dV3DG
// written by shadertoy user wjbgrafx
//
// Name: Carousel 2: horsPwr++; shiny--;
// Description: A modified version of the slow Carousel #1. This version is based on Inigo Quilez' &quot;Raymarching Primitives&quot; code.
/*
 	Carousel 2 : horsepower++ ; shiny--;
 		by wjbgrafx
 		
 	This code is a slightly modified version of
 	Raymarching Primitives
	https://www.shadertoy.com/view/Xds3zN	
 	Created by inigo quilez - iq/2013
 	License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported 
	
	Additional sources:

	Antialiasing code in the castRay() function
 	From "Edge AA"   Uploaded by Trisomie21 on 2014-Jul-29
	https://www.shadertoy.com/view/MsfXDS
	
	getRayDir() function
	From "Distance Functions Playground, by Ruslan Shestopalyuk, 2014/15
	https://www.shadertoy.com/view/MtXGDr

	createCamRotMatrix() function
	From	"Simple test/port of Mercury's SDF library to WebGL"
 	https://www.shadertoy.com/view/Xs3GRB    Uploaded by tomkh on 2015-Dec-16

	"4-tap" calcNormal() function
	http://raymarching.com/WebGL/WebGL_ShadowsReflections.htm
    Author - Gary "Shane" Warne
	
	Unsigned Triangle function by Inigo Quilez	
	http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

	Smooth Minimum blending function by Otavio Good
	https://www.shadertoy.com/view/XtjXWD

	HG_SDF GLSL Library for building signed distance bounds by MERCURY
	http://mercury.sexy/hg_sdf
	
	--------------------------------
	Editing and modification by wjb. 
	
	The modeling code within the map() function is licensed under a Creative
	Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
*/
//==============================================================================

#define PI 					3.1415926535897932384626433832795

#define CAM_DIST 			75.0
#define MAX_RAY_DIST		150.0
#define LOOK_AT  			vec3( 0.0, 2.0, 0.0 )
#define CAM_FOV_FACTOR		4.0
#define NUM_RAY_STEPS		100

vec3 lightPos = vec3( 0.0 );

//------------------------------------------------------------------------------
// Function declarations
vec3 getRayDir( vec3 camPos, vec3 viewDir, vec2 pixelPos ); 
mat4 createCamRotMatrix();
vec3 applyTexture( vec4 hitPosAndID );
vec3 texture1( vec3 pos );
vec3 texture2( vec3 pos );
vec3 texture3( vec3 pos );
vec3 texture4( vec3 pos );
vec3 texture5( vec3 pos );
vec3 texture6( vec3 pos );
vec3 texture7( vec3 pos );

// Comments here are from the HG_SDF Library.
// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
float pModPolar(inout vec2 p, float repetitions);
float fSphere(vec3 p, float r);
// Plane with normal n (n is normalized) at some distance from the origin
float fPlane(vec3 p, vec3 n, float distanceFromOrigin);
// Torus in the XZ-plane
float fTorus(vec3 p, float smallRadius, float largeRadius);
// Cylinder standing upright on the xz plane
float fCylinder(vec3 p, float r, float height);
// Cone with correct distances to tip and base circle. 
// Y is up, 0 is in the middle of the base.
float fCone(vec3 p, float radius, float height);
// Capsule version 2: between two end points <a> and <b> with radius r 
float fCapsule(vec3 p, vec3 a, vec3 b, float r);
float udTriangle( vec3 p, vec3 a, vec3 b, vec3 c );
float snoise(vec3 v);
float smin(float a, float b);

//------------------------------------------------------------------------------

// MAP
// ---

vec2 map( vec3 p ) 
{
	// Copy p before repetition domain operation.
	vec3 p0 = p;

	// Ground Plane
	float objID = 1.0;
	vec2 ground = vec2( fPlane( p - vec3( 0.0, -1.0, 0.0 ),
	                      normalize( vec3( 0.0, 1.0, 0.0 ) ), 1.0 ), objID );	
	
	// Ground ring for inner structure frame.
	objID = 2.0;
	vec2 inGrndRing = vec2( fTorus( p - vec3( 0.0, -1.85, 0.0 ), 0.15, 10.0 ), 
	                                                                   objID );		
	// Top ring for inner structure frame.
	vec2 inUprRing = vec2( fTorus( p - vec3( 0.0, 9.7, 0.0 ), 0.15, 10.0 ), 
	                                                                   objID );	
	// Ground ring for outer structure frame.
	objID = 3.0;
	vec2 outGrndRing = vec2( fTorus( p - vec3( 0.0, -1.85, 0.0 ), 0.15, 20.0 ), 
	                                                                   objID );	
	// Top ring for outer structure frame.
	vec2 outUprRing = vec2( fTorus( p - vec3( 0.0, 10.0, 0.0 ), 0.15, 20.0 ), 
	                                                                   objID );	
	// Roof
	objID = 4.0;
	vec2 roof = vec2( fCone( p - vec3( 0.0, 10.0, 0.0 ), 20.0, 5.0 ), objID );
	
	// Repetition : 
	//------------------------------------
	float segNum = pModPolar( p.xz, 6.0 );
	//------------------------------------
	
	// Inner ring poles
	objID = 2.0;
	vec2 inrPole = vec2( fCylinder( p - vec3( 10.0, 0.0, 0.0 ), 0.15, 10.0 ), 
	                                                                   objID );
	// Outer ring poles
	objID = 3.0;
	vec2 outrPoleA = vec2( fCylinder( 
	                       p - vec3( 19.3, 0.0, -5.0 ), 0.15, 10.0 ), objID );
	                                                                   
	vec2 outrPoleB = vec2( fCylinder( 
                           p - vec3( 19.3, 0.0,  5.0 ), 0.15, 10.0 ), objID );
	                                                                   
	// Roof dividers
	vec2 rfDivA = vec2( fCapsule( p, vec3( 19.3, 10.0, 5.0 ),
	                                 vec3(  0.0, 15.0, 0.0 ), 0.1 ), objID );
	
	vec2 rfDivB = vec2( fCapsule( p, vec3( 19.3, 10.0, -5.0 ),
	                                 vec3(  0.0, 15.0, 0.0 ), 0.1 ), objID );
	
	//------------------------------------	
	// Calculating horse up/down movement.
	//------------------------------------
	// From the HG_SDF Library:
	// "Many of the operators partition space into cells. An identifier
	// or cell index is returned, if possible. This return value is
	// intended to be optionally used e.g. as a random seed to change
	// parameters of the distance functions inside the cells."
	
	// I used the variable segNum for the return values, but they were not the
	// simple values I'd expected. The ranges or exact values returned for each 
	// segment ( direction ) are listed below. So it wasn't just simply a matter
	// of testing for an individual value, it required testing in a certain
	// order: NW, NE, E, SE, W, SW, S, else N 
	
	// nothing >3 or <-2
	// NW,W >2 and <=3
	// SW,W,NW >1 and <=2
	// nothing >1 and <2
	// NE,E,SE = 1
	// nothing >0 and <1
	// NE,E = 0
	// nothing >-1 and <0
	// NE = -1
	// nothing >-2 and <-1
	// NW = -2
	// nothing <-2

	// Assign varying y-coords for each horse copy.
	float bodyPosY = 0.0;

	if ( segNum <= -2.0 )
	{
		 bodyPosY = 0.6 * sin( iGlobalTime );
	}
	else if ( segNum < -1.0 )
	{
		 bodyPosY = 0.6 * sin( iGlobalTime + 150.0 );
	}
	else if ( segNum < 0.0 )
	{
		 bodyPosY = 0.6 * sin( iGlobalTime + 300.0 );
	}
	else if ( segNum < 1.0 )
	{
		 bodyPosY = 0.6 * sin( iGlobalTime + 450.0 );
	}
	else if ( segNum < 2.0 )
	{
		 bodyPosY = 0.6 * sin( iGlobalTime + 600.0 );
	}
	else if ( segNum < 3.0 )
	{
		 bodyPosY = 0.6 * sin( iGlobalTime + 750.0 );
	}
	else
	{
		 bodyPosY = 0.6 * sin( iGlobalTime + 900.0 );
	}
		
	//--------------------------------------------
	// Horse body
	objID = 5.0;
	float y = 1.25; // Initial ground offset for horse body
	
	float body1= fSphere( p - vec3( 15.0, y + bodyPosY, -0.9 ), 0.9 );
	float body2 = fSphere( p - vec3(15.0, y + bodyPosY,  0.9 ), 0.9 );
	vec2 body = vec2( smin( body1, body2 ), objID );

	//--------------------------------------------
	// Legs
	// Front left leg in two parts
	float x = 14.3,
	      z = -1.2,
	      legFLa = fCapsule( p, vec3( x,  0.25 + bodyPosY, z ),	   
	                            vec3( x, -0.25 + bodyPosY, z - 0.61 ), 0.2 );

	vec2 legFLb = vec2( smin( body1, legFLa ), objID );

	vec2 legFL = vec2( fCapsule( p, vec3( x, -0.26 + bodyPosY, z - 0.61 ),
	                                vec3( x, -1.26 + bodyPosY, z - 0.6 ), 
	                                0.16 ), objID );
	//--------------------------------------------
	// Front right leg in two parts
	x = 15.7;
	z = -1.2;
	float legFRa = fCapsule( p, vec3( x,  0.25 + bodyPosY, z ),	         
	                            vec3( x, -0.25 + bodyPosY, z + 0.13 ), 0.2 );

	vec2 legFRb = vec2( smin( body1, legFRa ), objID );

	vec2 legFR = vec2( fCapsule( p, vec3( x, -0.26 + bodyPosY, z + 0.12 ),
	                                vec3( x, -1.26 + bodyPosY, z + 0.9 ), 
	                                0.16 ), objID );	
	
	//--------------------------------------------
	// Back left leg in two parts
	x = 14.5;
	z = 1.2;
	float legBLa = fCapsule( p, vec3( x,  0.25 + bodyPosY, z ),	  
	                            vec3( x, -0.25 + bodyPosY, z - 0.75 ), 0.2 );

	vec2 legBLb = vec2( smin( body2, legBLa ), objID );

	vec2 legBL = vec2( fCapsule( p, vec3( x, -0.26 + bodyPosY, z - 0.75 ),
	                                vec3( x, -1.26 + bodyPosY, z - 0.6 ), 
	                                0.16 ), objID );
	
	//--------------------------------------------
	// Back right leg in two parts
	x = 15.7;
	z = 1.2;
	float legBRa = fCapsule( p, vec3( x,  0.25 + bodyPosY, z ),	
	                            vec3( x, -0.25 + bodyPosY, z + 0.13 ), 0.2 );

	vec2 legBRb = vec2( smin( body2, legBRa ), objID );

	vec2 legBR = vec2( fCapsule( p, vec3( x, -0.26 + bodyPosY, z + 0.12 ),
	                                vec3( x, -1.26 + bodyPosY, z + 0.75 ), 
	                                0.16 ), objID );
	
	//--------------------------------------------
	// Neck
	float neckA = fCapsule( p, vec3( 15.0, 2.0 + bodyPosY, -1.8 ),
	                          vec3( 15.0,  3.0 + bodyPosY, -2.3 ), 0.35 );
	                          
	vec2 neck = vec2( smin( neckA, body1 ), objID );	
	
	//--------------------------------------------
	// Head
	float headA = fCapsule( p, vec3( 15.0, 3.1 + bodyPosY, -2.5 ),
	                           vec3( 15.0, 2.1 + bodyPosY, -3.25 ), 0.275 );
	 
	vec2 head = vec2( smin( neckA, headA ), objID );	
	
	//---------------------------------------------	
	// Tail
	vec2 tail = vec2( fCapsule( p, vec3( 15.0,  1.6 + bodyPosY, 1.7 ),
	                                vec3( 15.0, -0.5 + bodyPosY, 2.5 ), 
	                                0.125 ), objID );
	
	//---------------------------------------------
	// Ears
	vec2 earL = vec2( fCapsule( p, vec3( 14.6, 3.2 + bodyPosY, -2.2 ),
	                               vec3( 14.6, 3.9 + bodyPosY, -2.2 ),
	                               0.1 ), objID );  
	
	vec2 earR = vec2( fCapsule( p, vec3( 15.4, 3.2 + bodyPosY, -2.2 ),
	                               vec3( 15.4, 3.9 + bodyPosY, -2.2 ),
	                               0.1 ), objID );  
	
	//---------------------------------------------
	// Horse pole
	objID = 2.0;
	vec2 hPole = vec2( fCylinder( 
	                        p - vec3( 15.0, 0.0, 0.0 ), 0.05, 10.0 ), objID );	
	// Flag pole
	vec2 flagPole = vec2( fCylinder(	
	                        p - vec3( 0.0, 15.0, 0.0 ), 0.05, 3.0 ), objID );
	
	// Flag in non-repeated space: p0
	objID = 6.0;
	float wind = sin( iGlobalTime );
	vec2 flag = vec2( udTriangle( p0, vec3(  0.0, 16.5, 0.0 ), 
	                                  vec3(  0.0, 18.0, 0.0 ),
	                          vec3( -4.0, 17.0 + wind, wind * 2.0 ) ), objID );
	// Pole top spheres
	vec2 poleTopA = vec2( fSphere( p - vec3( 19.3, 10.5, -5.0 ), 0.4 ), objID );
	vec2 poleTopB = vec2( fSphere( p - vec3( 19.3, 10.5,  5.0 ), 0.4 ), objID );
	
	// Flag sphere
	objID = 3.0;
	vec2 flagSphere = vec2( fSphere( p - vec3( 0.0, 15.4, 0.0 ), 0.4 ), objID );
	
	// Outer ring spheres
	objID = 2.0;
	vec2 outRingA = vec2( fSphere( p - vec3( 19.3, -1.65, -5.0 ), 0.6 ), objID );
	vec2 outRingB = vec2( fSphere( p - vec3( 19.3, -1.65,  5.0 ), 0.6 ), objID );

	// Center sphere
	objID = 7.0;	
	vec2 cntrSphere = vec2( 
	                      fSphere( p - vec3( 0.0, -9.0, 0.0 ), 10.0 ), objID );
	
	// Center ring spheres
	objID = 4.0;
	vec2 cntrRingSphere = vec2( 
	                      fSphere( p - vec3( 9.0, -1.25, 0.0 ), 0.75 ), objID ); 
	                      
	//-------------------------------------------
	// Distance comparisons for minimum distance.
	
	vec2 closest = ground.s < inGrndRing.s ? ground : inGrndRing;
	closest = closest.s < inUprRing.s ? closest : inUprRing;
	closest = closest.s < outGrndRing.s ? closest : outGrndRing;
	closest = closest.s < outUprRing.s ? closest : outUprRing;
	closest = closest.s < roof.s ? closest : roof;
	closest = closest.s < inrPole.s  ? closest : inrPole;
	closest = closest.s < outrPoleA.s  ? closest : outrPoleA;
	closest = closest.s < outrPoleB.s  ? closest : outrPoleB;
	closest = closest.s < rfDivA.s  ? closest : rfDivA;
	closest = closest.s < rfDivB.s  ? closest : rfDivB;

	closest = closest.s < body.s ? closest : body;
	closest = closest.s < legFLb.s ? closest : legFLb ;
	closest = closest.s < legFL.s ? closest : legFL;
	closest = closest.s < legFRb.s ? closest : legFRb ;
	closest = closest.s < legFR.s ? closest : legFR;
	closest = closest.s < legBLb.s ? closest : legBLb ;
	closest = closest.s < legBL.s ? closest : legBL;
	closest = closest.s < legBRb.s ? closest : legBRb ;
	closest = closest.s < legBR.s ? closest : legBR;
	closest = closest.s < neck.s ? closest : neck;
	closest = closest.s < head.s ? closest : head;
	closest = closest.s < tail.s ? closest : tail;
	closest = closest.s < earL.s ? closest : earL;
	closest = closest.s < earR.s ? closest : earR;
	
	closest = closest.s < hPole.s ? closest : hPole;
	closest = closest.s < flagPole.s ? closest : flagPole;
	closest = closest.s < flag.s ? closest : flag;
	closest = closest.s < poleTopA.s ? closest : poleTopA;
	closest = closest.s < poleTopB.s ? closest : poleTopB;
	closest = closest.s < flagSphere.s ? closest : flagSphere;
	closest = closest.s < outRingA.s ? closest : outRingA;
	closest = closest.s < outRingB.s ? closest : outRingB;
	closest = closest.s < cntrSphere.s ? closest : cntrSphere;
	closest = closest.s < cntrRingSphere.s ? closest : cntrRingSphere;
	
	return closest;
}

// end map()

//------------------------------------------------------------------------------

// CALC NORMAL
// -----------
// http://raymarching.com/WebGL/WebGL_ShadowsReflections.htm
// Author - Gary "Shane" Warne
// If speed is an issue, here's a slightly-less-accurate, 4-tap version.  
// Visually speaking, it's virtually the same    

vec3 calcNormal( in vec3 p )
{

	float eps = 0.005;
	float ref = map( p ).s;
	vec2 e = vec2( eps, 0.0 );
	return normalize( vec3( map( vec3( p.x + eps, p.y, p.z ) ).s - ref,
		                    map( vec3( p.x, p.y + eps, p.z ) ).s - ref,
		                    map( vec3( p.x, p.y, p.z + eps ) ).s - ref ) ); 
}

// end calcNormal()

//------------------------------------------------------------------------------
// This is a modified version of the lighting section of the render function in 
// IQ's Raymarching Primitives code

// GET COLOR
// ---------

vec3 getColor( vec3 rayOrig, vec3 rayDir, float objDist, float objID )
{
    vec3 pos = rayOrig + objDist * rayDir;
    vec3 nor = calcNormal( pos );
    vec3 ref = reflect( rayDir, nor );
    
    vec3 clr = vec3( 1.0 );
	clr = mix( applyTexture( vec4( pos, objID ) ), clr, 0.5 );
	
    // lighting        
	vec3  lig = normalize( lightPos );
	float amb = clamp( 0.5+0.5*nor.y, 0.0, 1.0 );
    float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
    float bac = clamp( dot( nor, normalize(vec3(-lig.x,0.0,-lig.z))), 
                                          0.0, 1.0 )*clamp( 1.0-pos.y,0.0,1.0);
    float dom = smoothstep( -0.1, 0.1, ref.y );
    float fre = pow( clamp(1.0+dot(nor,rayDir),0.0,1.0), 2.0 );
	float spe = pow(clamp( dot( ref, lig ), 0.0, 1.0 ),6.0);

	vec3 lin = vec3(0.0);
    lin += 1.20*dif*vec3(1.00,0.85,0.55);
	lin += 1.20*spe*vec3(1.00,0.85,0.55)*dif;
    lin += 0.20*amb*vec3(0.50,0.70,1.00);
    lin += 0.30*dom*vec3(0.50,0.70,1.00);
    lin += 0.30*bac*vec3(0.25,0.25,0.25);
    lin += 0.40*fre*vec3(1.00,1.00,1.00);
	clr = clr*lin;

	return clamp( clr, 0.0, 1.0 );	
}	

// end getColor()

//------------------------------------------------------------------------------
// From 	Edge AA   Uploaded by Trisomie21 in 2014-Jul-29
//		    https://www.shadertoy.com/view/MsfXDS

vec4 blend( vec4 fg, in vec4 bg ) 
{
	float alpha = 1.0 - fg.a;
	return fg + bg * alpha;
}

//------------------------------------------------------------------------------
// From 	Edge AA   Uploaded by Trisomie21 in 2014-Jul-29
//		    https://www.shadertoy.com/view/MsfXDS

// CAST RAY
// --------

vec3 castRay( in vec3 rayOrig, in vec3 rayDir )
{
	vec4 clr = vec4(0.0);	// Forground (pre-multiplied)
	 
	      // Minimum distance considered an object hit
	float minHitDist = 0.001,   
          // Distance to surface returned by map() from the most recent
          // ray position
          curDist = 0.0,
          // The smallest of any distance returned from map() 	
    	  minCurDist = 1e20,
          // The accumulation of all step distances returned from map()
          sumDist = 0.0, 
          // The smallest value sumDist has held so far
          minSumDist = 0.0,
          // The objectID number of the current closest object
          objID = -1.0, 	
	      // Keep track of the most recent object's ID number
	      storedObjID = -1.0,
		  // Keep track if moving closer to or away from a surface
	      movingCloserFlag = 1.0;	

    // Raymarch loop
    for( int i = 0; i < NUM_RAY_STEPS; i++ )
	{
        // Update the cumulative distance ray has traveled.
        sumDist += curDist;
	    
	    // Find current closest distance and ID of closest object
	    vec2 res = map( rayOrig + rayDir * sumDist );
        curDist = res.x;
	    objID = res.y;

		// If current closest distance is within hit distance, or
		// cumulative distance ray has travelled is beyond back plane
		if( abs( curDist ) < minHitDist || sumDist > MAX_RAY_DIST ) 
		{
			break;
		}
		
		// If the ray is closer than it's been to any object so far...
		if( curDist < minCurDist ) 
		{ 
			// then it's moving closer to an object
			movingCloserFlag = 1.0;
			
			// Set the least distance to any object as the current distance
			minCurDist = curDist;
			
			// Set the current ray length as the minimum of any ray length
			minSumDist = sumDist;
			
			// Store the ID number of this closest object
			storedObjID = objID;
		} 
		// Otherwise the ray is moving away from the nearest object. Enter this
		// section only if the ray was most recently moving towards an object.
		else if( movingCloserFlag > 0.0 ) 
		{ 
			// moving away
			movingCloserFlag = 0.0;
			
			// The outline pixel size is normalized to the screen height, based
			// on the length of the shortest ray length so far.
			// Changing pixSize changes the width of the antialiased 'outline'.			
			float pixSize = ( minSumDist + 1.0 ) / iResolution.y;

			//----------------------------------------------------------------
			// This fragment of code can be used as a replacement for the code
			// just below, to enlarge the width of the antialiasing outline. It
			// will make the object edge appear fuzzier.
			//if ( minCurDist < pixSize * 4.0 ) 
			//{
			//	  float alpha = 1.0 - ( minCurDist / pixSize * 0.25 );
			//----------------------------------------------------------------
			
			// If the minimum ray-to-object length of any ray so far is less 
			// than the pixel size
			if( minCurDist < pixSize ) 
			{
				// The color transparency is based on the ratio of shortest
				// distance so far, to pixel size
				float alpha = 1.0 - ( minCurDist / pixSize );
						
				// Color of the closest object to the current ray position.
				vec3 rgb = getColor( rayOrig, rayDir, minSumDist, storedObjID );
				clr = blend( clr, vec4( rgb * alpha, alpha ) );

				// To view "outlined" pixels in white, uncomment this line:
				//clr = vec4(1.0);
			}
		
		} // end else if (... )
    
    } // end for( i... ) raymarch loop
			
	//---------------------------------------------------------
	// Toggle antialiasing: Turn off by uncommenting this line:
	//clr = vec4(0.0);

	//----------------------------------------------------------------
	// Toggle Color and Opacity: Turn off by uncommenting these lines:
	//if( objID > 1.0 ) 	{	clr.a = 1.0;	}
	//return vec3( pow( clr.a, 2.2 ) );
	
	//----------------------------------------------------------------
	
	// This gets the color of the object that was hit.
	// To show only the antialias outline, comment out these two lines.
	clr = blend( clr, 
	                vec4( getColor( rayOrig, rayDir, sumDist, objID ), 1.0 ) );
	
    return clr.rgb;
}

// end castRay()

//------------------------------------------------------------------------------

// RENDER 
// ------

vec3 render( in vec3 rayOrig, in vec3 rayDir )
{ 
    vec3 clr = castRay( rayOrig, rayDir );
	return vec3( clamp( clr, 0.0, 1.0 ) );    
}

//------------------------------------------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord )

{
	// -1 to 1 screen
	// --------------
	// Adjust aspect ratio, normalize coords, center origin in xy-plane.	
	// xRange = -1.7777778 to 1.775926, yRange = -1.0 to 0.9981482 at 1920x1080
	vec2 p = ( -iResolution.xy + 2.0 * fragCoord.xy ) / iResolution.y;
	
    vec2 m = iMouse.xy / iResolution.xy;
		 
 	mat4 camMat = createCamRotMatrix();
	vec3 camPos = vec3( camMat * vec4( 0.0, 2.0, -CAM_DIST, 1.0 ) );	    
    vec3 rayDir = getRayDir( camPos, normalize( LOOK_AT - camPos ), p );       
	vec3 rayOrig = camPos;
	lightPos = camPos;

    vec3 clr = render( rayOrig, rayDir );
	clr = pow( clr, vec3(0.8) );
	
    fragColor = vec4( clr, 1.0 );
}

//------------------------------------------------------------------------------
// From	"Simple test/port of Mercury's SDF library to WebGL"
// https://www.shadertoy.com/view/Xs3GRB    Uploaded by tomkh in 2015-Dec-16

// CREATE CAMERA ROTATION MATRIX
// -----------------------------

mat4 createCamRotMatrix()
{
	float ang = 0.0, 
	      sinAng = 0.0, 
	      cosAng = 0.0,
	      rotRange = -0.0029;
	
    if( iMouse.z < 1.0 ) 
    {
		ang = iGlobalTime * 0.2;
	}
	else
	{
		// wjb added the 180 degree rotation ( PI ) because the objects were
		// being created on the negative side of the x-axis ( mirrored position
		// across z-plane ) instead of the positive side, where they should be.
		ang = ( iMouse.x - iResolution.x * 0.5 ) * rotRange + PI;
	}
	sinAng = sin(ang); 
	cosAng = cos(ang);
	
	mat4 y_Rot_Cam_Mat = mat4( cosAng, 0.0, sinAng, 0.0,	  
	                              0.0, 1.0,    0.0, 0.0,
	                          -sinAng, 0.0, cosAng, 0.0,
	                              0.0, 0.0,    0.0, 1.0 );
	
    if( iMouse.z < 1.0 ) 
    {
		ang = 0.25 * ( sin( iGlobalTime * 0.1 ) + 1.0 );
	}
	else
	{
		// Scale iMouse.y so x-axis rotation range is only from partway overhead
		// to just about level with ground.
		ang = ( 0.4825 * iMouse.y - iResolution.y * 0.5 ) * rotRange; 
	}

	sinAng = sin(ang); 
	cosAng = cos(ang);
	
	mat4 x_Rot_Cam_Mat = mat4( 1.0,     0.0,    0.0, 0.0,	  
	                           0.0,  cosAng, sinAng, 0.0,
	                           0.0, -sinAng, cosAng, 0.0,
	                           0.0,     0.0,    0.0, 1.0 );
	
	return y_Rot_Cam_Mat * x_Rot_Cam_Mat;
	
}

// end createCamRotMatrix()

//------------------------------------------------------------------------------
// From "Distance Functions Playground, by Ruslan Shestopalyuk, 2014/15
// https://www.shadertoy.com/view/MtXGDr

// GET RAY DIRECTION
// -----------------

vec3 getRayDir( vec3 camPos, vec3 viewDir, vec2 pixelPos ) 
{
    vec3 camRight = normalize( cross( viewDir, vec3( 0.0, 1.0, 0.0 ) ) );
    vec3 camUp = normalize( cross( camRight, viewDir ) );
    
    return normalize( pixelPos.x * camRight + pixelPos.y * camUp + 
                                                    CAM_FOV_FACTOR * viewDir );
}

// end getRayDir()

//------------------------------------------------------------------------------

// APPLY TEXTURE
// -------------

vec3 applyTexture( vec4 hitPosAndID )
{
	vec3 baseColor = vec3( 0.0 ),
	     pos = hitPosAndID.xyz;
	
	int objNum = int( hitPosAndID.w );

	// ground
	if ( objNum == 1 )
	{		
		baseColor = texture1( pos );
	}	
	// inner rings, inner pillars
	else if ( objNum == 2 )
	{
		baseColor = texture2( pos );
	}	
	// outer rings, outer pillars
	else if ( objNum == 3 )
	{
		baseColor = texture3( pos );
	}	
	// roof	
	else if ( objNum == 4 )
	{
		baseColor = texture4( pos );
	}
	// horse			
	else if ( objNum == 5 )
	{
		baseColor = texture5( pos );
	}	
	// pole top sphere
	else if ( objNum == 6 )
	{
		baseColor = texture6( pos );
	}	
	// center sphere
	else if ( objNum == 7 )
	{
		baseColor = texture7( pos );
	}	
	
	return baseColor;
}

// end applyTexture()

//------------------------------------------------------------------------------

// TEXTURE 1
// ---------

vec3 texture1( vec3 pos )
{
	//vec3 objClr = vec3( 0.0, 0.2, 0.7 );	
	vec3 objClr = vec3( 0.0, 1.0, 1.0 );	
		
	float scale = 1.0,
		  complexity = 5.0,
		  mixVal = 0.5;	  
	
	// http://math.hws.edu/graphicsbook/demos/c7/procedural-textures.html
	// Marble( triangular ) #1
	vec3 v = pos * scale;
	float t = (v.x + 2.0*v.y + v.z)*0.25;			
	t += snoise(v);	
	float value = t - floor(t);			
	// smooth out the discontinuity
	value = value*(1.0 - smoothstep(0.95,1.0,value));  
	value = 0.333 + value*0.667;
	vec3 color = vec3(value);		    
    return mix( color, objClr, mixVal );        				
}

// end texture1()

//------------------------------------------------------------------------------

// TEXTURE 2
// ---------

vec3 texture2( vec3 pos )
{
	vec3 objClr = vec3( 1.0, 1.0, 0.0 );	
		
	float scale = 4.0,
		  complexity = 2.5,
		  mixVal = 0.6;	  
	
	// http://math.hws.edu/graphicsbook/demos/c7/procedural-textures.html
	// Combination Marble( triangular) with Marble( sharp ) #10
	// Marble( triangular )
	vec3 v = pos * scale;
	float t = (v.x + 2.0*v.y + v.z)*0.25;			
	t += snoise(v);	
	float value = t - floor(t);			
	// smooth out the discontinuity
	value = value*(1.0 - smoothstep(0.95,1.0,value));  
	value = 0.333 + value*0.667;
	vec3 color = vec3(value);		    
	// Marble ( sharp )  :  wjb added variable complexity factor
	t = (v.x + 2.0*v.y + 3.0*v.z);
	t +=  snoise(v) * complexity;
	value =  abs(sin(t));
	color /= vec3(sqrt(value)); // modified to divide    		    
	return mix( color, objClr, mixVal );        				
}

// end texture2()

//------------------------------------------------------------------------------

// TEXTURE 3
// ---------

vec3 texture3( vec3 pos )
{
	vec3 objClr = vec3( 0.75, 0.0, 1.0 );	
		
	float scale = 1.0,
		  complexity = 1.0,
		  mixVal = 0.5;	  

	// http://math.hws.edu/graphicsbook/demos/c7/procedural-textures.html
	// Marble( triangular ) #1
	vec3 v = pos * scale;
	float t = (v.x + 2.0*v.y + v.z)*0.25;			
	t += snoise(v);	
	float value = t - floor(t);			
	// smooth out the discontinuity
	value = value*(1.0 - smoothstep(0.95,1.0,value));  
	value = 0.333 + value*0.667;
	vec3 color = vec3(value);		    
    return mix( color, objClr, mixVal );        				
}

// end texture3()

//------------------------------------------------------------------------------

// TEXTURE 4
// ---------

vec3 texture4( vec3 pos )
{
	vec3 objClr = vec3( 0.0, 0.15, 1.0 );	
		
	float scale = 2.0,
		  complexity = 0.5,
		  mixVal = 0.6;	  
	
	// wjb modified Perlin Noise 3D ( #19 )
	// With complexity = 1.0, squiggly lines in objColor on white
	vec3 v = pos * scale;
	float value = log( pow( snoise( v ), 2.0 ) ) * complexity; 
    value = 0.75 + value*0.25;
    vec3 color = vec3( value);    		    
    return mix( color, objClr, mixVal );        				
}

// end texture4()

//------------------------------------------------------------------------------

// TEXTURE 5
// ---------

vec3 texture5( vec3 pos )
{
	return vec3( 0.0 );
//	vec3 objClr = vec3( 0.0 );	
//	
//	float scale = 1.0,
//		  //complexity = 5.0,
//		  mixVal = 0.5;	  
//	
//	// http://math.hws.edu/graphicsbook/demos/c7/procedural-textures.html
//	// Marble( triangular ) #1
//	vec3 v = pos * scale;
//	float t = (v.x + 2.0*v.y + v.z)*0.25;			
//	t += snoise(v);	
//	float value = t - floor(t);			
//	// smooth out the discontinuity
//	value = value*(1.0 - smoothstep(0.95,1.0,value));  
//	value = 0.333 + value*0.667;
//	vec3 color = vec3(value);		    
//    return mix( color, objClr, mixVal );        				
}

// end texture5()

//------------------------------------------------------------------------------

// TEXTURE 6
// ---------

vec3 texture6( vec3 pos )
{
	vec3 objClr = vec3( 1.0, 0.0, 0.0 );	
	
	float scale = 2.0,
		  complexity = 5.0,
		  mixVal = 0.9;	  
	
	// wjb modified Perlin Noise 3D ( #21 )
	// Blotches of objClr surrounded by very thin squiggly black lines
	// on white background
	vec3 v = pos * scale;
	float value = exp( inversesqrt( pow( snoise( v ), 2.0 ) * complexity ) ); 
    value = 0.75 + value*0.25;
    vec3 color = vec3( value);    		    
    return mix( color, objClr, mixVal );        					
}

// end texture6()

//------------------------------------------------------------------------------

// TEXTURE 7
// ---------

vec3 texture7( vec3 pos )
{
	vec3 objClr = vec3( 0.0 ),//( 1.0, 0.0, 1.0 ),
	     color = vec3( 0.0 );	
	
	float scale = 2.0,
		  mixVal = 0.5;	  
	
	// http://math.hws.edu/graphicsbook/demos/c7/procedural-textures.html
	// Checkerboard 3D #6
	vec3 v = pos * scale;
	float a = floor( v.x );
	float b = floor( v.y );
	float c = floor( v.z );
	if ( mod( a + b + c, 2.0 ) > 0.5 ) 
	{  // a+b+c is odd
	    color = vec3( 0.3 ); // the dark value
	}
	else 
	{  // a+b+c is even
	    color = vec3( 1.0 ); // the light value
	}    		
	return mix( color, objClr, mixVal );        												
}

// end texture7()

//------------------------------------------------------------------------------

// TRIANGLE - unsigned
// --------
// http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

float dot2( in vec3 v ) { return dot(v,v); }
float udTriangle( vec3 p, vec3 a, vec3 b, vec3 c )
{
    vec3 ba = b - a; vec3 pa = p - a;
    vec3 cb = c - b; vec3 pb = p - b;
    vec3 ac = a - c; vec3 pc = p - c;
    vec3 nor = cross( ba, ac );

    return sqrt(
    (sign(dot(cross(ba,nor),pa)) +
     sign(dot(cross(cb,nor),pb)) +
     sign(dot(cross(ac,nor),pc))<2.0)
     ?
     min( min(
     dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
     dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
     dot2(ac*clamp(dot(ac,pc)/dot2(ac),0.0,1.0)-pc) )
     :
     dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}
//------------------------------------------------------------------------------

// SMOOTH MINIMUM
// --------------
// https://www.shadertoy.com/view/XtjXWD	-Otavio Good
// smooth blending function; k should be negative. -4.0 works nicely.
float smin(float a, float b)
{
	float k = -4.0;
	return log2( exp2( k * a ) + exp2( k * b ) ) / k;
}

//==============================================================================
// The code below is excerpted from :
////////////////////////////////////////////////////////////////
//
//                           HG_SDF
//
//     GLSL LIBRARY FOR BUILDING SIGNED DISTANCE BOUNDS
//
//     version 2015-12-15 (initial release)
//
//     Check http://mercury.sexy/hg_sdf for updates
//     and usage examples. Send feedback to spheretracing@mercury.sexy.
//
//     Brought to you by MERCURY http://mercury.sexy
//
//
//
// Released as Creative Commons Attribution-NonCommercial (CC BY-NC)
//
////////////////////////////////////////////////////////////////

#define clamp(x,a,b) min(max(x,a),b)
#define saturate(x) clamp(x, 0.0, 1.0)

float fSphere(vec3 p, float r) {
	return length(p) - r;
}

// Plane with normal n (n is normalized) at some distance from the origin
float fPlane(vec3 p, vec3 n, float distanceFromOrigin) {
	return dot(p, n) + distanceFromOrigin;
}


// Cylinder standing upright on the xz plane
float fCylinder(vec3 p, float r, float height) {
	float d = length(p.xz) - r;
	d = max(d, abs(p.y) - height);
	return d;
}

// Distance to line segment between <a> and <b>, used for fCapsule() version 2below
float fLineSegment(vec3 p, vec3 a, vec3 b) {
	vec3 ab = b - a;
	float t = saturate(dot(p - a, ab) / dot(ab, ab));
	return length((ab*t + a) - p);
}

// Capsule version 2: between two end points <a> and <b> with radius r 
float fCapsule(vec3 p, vec3 a, vec3 b, float r) {
	return fLineSegment(p, a, b) - r;
}

// Torus in the XZ-plane
float fTorus(vec3 p, float smallRadius, float largeRadius) {
	return length(vec2(length(p.xz) - largeRadius, p.y)) - smallRadius;
}

// Cone with correct distances to tip and base circle. Y is up, 0 is in the middle of the base.
float fCone(vec3 p, float radius, float height) {
	vec2 q = vec2(length(p.xz), p.y);
	vec2 tip = q - vec2(0, height);
	vec2 mantleDir = normalize(vec2(height, radius));
	float mantle = dot(tip, mantleDir);
	float d = max(mantle, -q.y);
	float projected = dot(tip, vec2(mantleDir.y, -mantleDir.x));
	
	// distance to tip
	if ((q.y > height) && (projected < 0.)) {
		d = max(d, length(tip));
	}
	
	// distance to base ring
	if ((q.x > radius) && (projected > length(vec2(height, radius)))) {
		d = max(d, length(q - vec2(radius, 0)));
	}
	return d;
}


// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
float pModPolar(inout vec2 p, float repetitions) {
	float angle = 2.*PI/repetitions;
	float a = atan(p.y, p.x) + angle/2.;
	float r = length(p);
	float c = floor(a/angle);
	a = mod(a,angle) - angle/2.;
	p = vec2(cos(a), sin(a))*r;
	// For an odd number of repetitions, fix cell index of the cell in -x direction
	// (cell index would be e.g. -5 and 5 in the two halves of the cell):
	if (abs(c) >= (repetitions/2.)) c = abs(c);
	return c;
}


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//
    // FOLLOWING CODE was OBTAINED FROM https://github.com/ashima/webgl-noise
    // This is the code for 3D  Perlin noise, using simplex method.
    //
    
    //------------------------------- 3D Noise ------------------------------------------
    
    // Description : Array and textureless GLSL 2D/3D/4D simplex 
    //               noise functions.
    //      Author : Ian McEwan, Ashima Arts.
    //  Maintainer : ijm
    //     Lastmod : 20110822 (ijm)
    //     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
    //               Distributed under the MIT License. See LICENSE file.
    //               https://github.com/ashima/webgl-noise
    // 
    
    vec3 mod289(vec3 x) {
      return x - floor(x * (1.0 / 289.0)) * 289.0;
    }
    
    vec4 mod289(vec4 x) {
      return x - floor(x * (1.0 / 289.0)) * 289.0;
    }
    
    vec4 permute(vec4 x) {
         return mod289(((x*34.0)+1.0)*x);
    }
    
    vec4 taylorInvSqrt(vec4 r)
    {
      return 1.79284291400159 - 0.85373472095314 * r;
    }
    
    float snoise(vec3 v)
      { 
        const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
        const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);
      
      // First corner
        vec3 i  = floor(v + dot(v, C.yyy) );
        vec3 x0 =   v - i + dot(i, C.xxx) ;
      
      // Other corners
        vec3 g = step(x0.yzx, x0.xyz);
        vec3 l = 1.0 - g;
        vec3 i1 = min( g.xyz, l.zxy );
        vec3 i2 = max( g.xyz, l.zxy );
      
        //   x0 = x0 - 0.0 + 0.0 * C.xxx;
        //   x1 = x0 - i1  + 1.0 * C.xxx;
        //   x2 = x0 - i2  + 2.0 * C.xxx;
        //   x3 = x0 - 1.0 + 3.0 * C.xxx;
        vec3 x1 = x0 - i1 + C.xxx;
        vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
        vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y
      
      // Permutations
        i = mod289(i); 
        vec4 p = permute( permute( permute( 
                   i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
                 + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
                 + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));
      
      // Gradients: 7x7 points over a square, mapped onto an octahedron.
      // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
        float n_ = 0.142857142857; // 1.0/7.0
        vec3  ns = n_ * D.wyz - D.xzx;
      
        vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)
      
        vec4 x_ = floor(j * ns.z);
        vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)
      
        vec4 x = x_ *ns.x + ns.yyyy;
        vec4 y = y_ *ns.x + ns.yyyy;
        vec4 h = 1.0 - abs(x) - abs(y);
      
        vec4 b0 = vec4( x.xy, y.xy );
        vec4 b1 = vec4( x.zw, y.zw );
      
        //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
        //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
        vec4 s0 = floor(b0)*2.0 + 1.0;
        vec4 s1 = floor(b1)*2.0 + 1.0;
        vec4 sh = -step(h, vec4(0.0));
      
        vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
        vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;
      
        vec3 p0 = vec3(a0.xy,h.x);
        vec3 p1 = vec3(a0.zw,h.y);
        vec3 p2 = vec3(a1.xy,h.z);
        vec3 p3 = vec3(a1.zw,h.w);
      
      //Normalise gradients
        vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
        p0 *= norm.x;
        p1 *= norm.y;
        p2 *= norm.z;
        p3 *= norm.w;
      
      // Mix final noise value
        vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
        m = m * m;
        return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                      dot(p2,x2), dot(p3,x3) ) );
      }

//------------------------------------------------------------------------------
