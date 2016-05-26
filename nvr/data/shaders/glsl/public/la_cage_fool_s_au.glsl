// Shader downloaded from https://www.shadertoy.com/view/ldVGWt
// written by shadertoy user wjbgrafx
//
// Name: La Cage Fool's Au
// Description: Started out playing around with stacked cubes, one thing led to another, then I couldn't resist the bad pun. Thank you to Shane for the incredibly well-commented code, a real blessing for beginners.
/*
	"La Cage Fool's Au"  by wjbgrafx
	
	based on
	https://www.shadertoy.com/view/4dt3zn	
	Raymarched Reflections   Uploaded by Shane on 2015-Nov-17

	Additional sources
	------------------	
	HG_SDF GLSL Library for building signed distance bounds by MERCURY
	http://mercury.sexy/hg_sdf

	Camera rotation matrix function
	From	"Simple test/port of Mercury's SDF library to WebGL"
	https://www.shadertoy.com/view/Xs3GRB    Uploaded by tomkh in 2015-Dec-16
	
*/
//==============================================================================

#define PI                      3.1415926535897932384626433832795
#define PI_4					0.78539816339744830961566084581988

#define FAR                     45.0
#define MAX_RAY_STEPS           150
#define MAX_REF_STEPS           30

#define CAM_DIST				18.0
#define CAM_POS                 vec3( 0.0, 0.0, -CAM_DIST )
#define CAM_FOV_FACTOR          4.0
#define LOOK_AT                 vec3( 0.0 )
#define LIGHT_POS               vec3( 0.0, 20.0, -10.0 )
#define LIGHT_ATTEN				0.001


//------------------------------------------------------------------------------
// Function declarations
//----------------------
mat4 createCamRotMatrix();
vec3 getRayDir( vec3 camPos, vec3 viewDir, vec2 pixelPos ) ;

// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is used to specify the angle.
float pModPolar(inout vec2 p, float repetitions);
float fSphere(vec3 p, float r);
// A circular disc with no thickness (i.e. a cylinder with no height).
// Subtract some value to make a flat disc with rounded edge.
float fDisc(vec3 p, float r);
// Cone with correct distances to tip and base circle. 
// Y is up, 0 is in the middle of the base.
float fCone(vec3 p, float radius, float height);
// Torus in the XZ-plane
float fTorus(vec3 p, float smallRadius, float largeRadius);
// Cylinder standing upright on the xz plane
float fCylinder(vec3 p, float r, float height);

float vmax(vec3 v);
vec3 rotateX(vec3 p, float a);
vec3 rotateY(vec3 p, float a);
vec3 rotateZ(vec3 p, float a);

//------------------------------------------------------------------------------
// Based on fBox from HG_SDF
float diamondCube(vec3 p, float side)
{
	p = rotateX( p, PI_4 - 0.17 );
	p = rotateZ( p, PI_4 );
	vec3 d = abs(p) - vec3( side );
	return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}
//------------------------------------------------------------------------------

// MAP
// ---

vec2 map(vec3 p)
{    
	float objID = 1.0;
	vec2 ground = vec2( fDisc( p - vec3( 0.0, -2.25, 0.0 ), 5.0 ), objID );      

	//---------------------
	pModPolar( p.xz, 8.0 );
	// Move the cube tower that was positioned at the origin out to the edge
	// of the disc.
	p.x -= 4.5;
	//---------------------

	objID = 3.0; 
	vec2 cone = vec2( fCone( p - vec3( 0.0, -2.25, 0.0 ), 0.15, 0.5 ), objID );
	
	objID = 2.0;
	vec3 p0 = rotateY( p, iGlobalTime ); 
	vec2 cube1 =                                 
	          vec2( diamondCube( p0 - vec3( 0.0, -1.34, 0.0 ), 0.25 ), objID );

	vec3 p1 = rotateY( p, iGlobalTime * -0.9 );
	vec2 cube2 =                              
	          vec2( diamondCube( p1 - vec3( 0.0, -0.555, 0.0 ), 0.2 ), objID );	
	
	vec3 p2 = rotateY( p, iGlobalTime * 0.8 );
	vec2 cube3 = 
	          vec2( diamondCube( p2 - vec3( 0.0, 0.06, 0.0 ), 0.15 ), objID );	
	
	vec3 p3 = rotateY( p, iGlobalTime * -0.7 );
	vec2 cube4 =                                 
	           vec2( diamondCube( p3 - vec3( 0.0, 0.496, 0.0 ), 0.1 ), objID );	
	
	vec3 p4 = rotateY( p, iGlobalTime * 0.6 );
	vec2 cube5 =
	          vec2( diamondCube( p4 - vec3( 0.0, 0.75, 0.0 ), 0.05 ), objID );	

	//---------------------------------------------------
	
	// Move x-position closer to original origin to position torus.
	// p.x is now at -3.25
	p.x += 1.25;
	objID = 3.0;
	vec2 hoop = vec2( fTorus( p.yzx, 0.1, 3.5 ), objID );
	
	// Move x-position beyond original origin to squeeze the sphere into more
	// of an ellipsoid shape. p.x is now at +0.35.
	p.x += 3.6;
	objID = 4.0;
	vec2 ball = vec2( fSphere( p, 1.05 ), objID );
	
	objID = 3.0;
	vec2 ball2 = vec2( fSphere( p - vec3( 0.0, 3.0, 0.0 ), 0.7 ), objID );
	
	// Move first ring of coins out from center.
	// x-position is now at -2.0;
	p.x -= 2.35;
	vec3 p5 = rotateY( p, iGlobalTime * 4.0 );
	objID = 2.0;
	vec2 coin1 = vec2( 
	         fCylinder( p5.yzx - vec3( -1.95, 0.0, 0.0 ), 0.3, 0.02 ), objID );
		
	// Move second ring of coins farther out and offset from first ring.
	// x-position is now at -3.25;
	p.x -= 1.25;
	p.z -= 0.75;
	objID = 3.0;
	vec3 p6 = rotateY( p, iGlobalTime * 3.0 );
	vec2 coin2 = vec2( 
	         fCylinder( p6.yzx - vec3( -1.95, 0.0, 0.0 ), 0.3, 0.02 ), objID );
		
	//---------------------------------------------------
	
	vec2 closest = ground.s < cone.s ? ground : cone;
	closest = closest.s < cube1.s ? closest : cube1;
	closest = closest.s < cube2.s ? closest : cube2;
	closest = closest.s < cube3.s ? closest : cube3;
	closest = closest.s < cube4.s ? closest : cube4;
	closest = closest.s < cube5.s ? closest : cube5;
	closest = closest.s < hoop.s ? closest : hoop;
	closest = closest.s < ball.s ? closest : ball;
	closest = closest.s < ball2.s ? closest : ball2;
	closest = closest.s < coin1.s ? closest : coin1;
	closest = closest.s < coin2.s ? closest : coin2;

	return closest;
}

// end map()

//------------------------------------------------------------------------------

// TRACE
// -----

vec2 trace( vec3 rayOrig, vec3 rayDir )
{   
    float totalDist = 0.0;
    vec2 distID = vec2( 0.0 );
    
    for ( int i = 0; i < MAX_RAY_STEPS; i++ )
    {
        distID = map( rayOrig + rayDir * totalDist );
        float dist = distID.s;
        
        if( abs( dist ) < 0.0025 || totalDist > FAR ) 
        {
        	break;
        }
        
        totalDist += dist * 0.75;  
    }
    
    return vec2( totalDist, distID.t );
}

// end trace()

//------------------------------------------------------------------------------

// TRACE REFLECTIONS
// -----------------

float traceRef( vec3 rayOrig, vec3 rayDir )
{    
    float totalDist = 0.0;
    
    for ( int i = 0; i < MAX_REF_STEPS; i++ )
    {
        float dist = map( rayOrig + rayDir * totalDist ).s;
        
        if( abs( dist ) < 0.0025 || totalDist > FAR ) 
        {
        	break;
        }
        
        totalDist += dist;
    }
    
    return totalDist;
}

// end traceRef()

//------------------------------------------------------------------------------

// SOFT SHADOW
// -----------

// "k" is a fade-off factor to control how soft the shadows are. Smaller values 
// give a softer penumbra, and larger values give a more hard edged shadow.

float softShadow( vec3 rayOrig, vec3 lightPos, float k )
{
    const int maxIterationsShad = 24;     
    vec3 rayDir = ( lightPos - rayOrig );

    float shade = 1.0;
    float dist = 0.01;    
    float end = max( length( rayDir ), 0.001 );
    float stepDist = end / float( maxIterationsShad );
    
    rayDir /= end;

    for ( int i = 0; i < maxIterationsShad; i++ )
    {
        float h = map( rayOrig + rayDir * dist ).s;
        shade = min( shade, smoothstep( 0.0, 1.0, k * h / dist)); 
        dist += min( h, stepDist * 2.0 ); 
        
        if ( h < 0.001 || dist > end ) 
        {
        	break; 
        }
    }

    // Added 0.5 to the final shade value, which lightens the shadow a bit. 
    return min( max( shade, 0.0 ) + 0.5, 1.0 ); 
}

// end softShadow()

//------------------------------------------------------------------------------

// GET NORMAL
// ----------

// Tetrahedral normal, to save a couple of "map" calls. Courtesy of IQ.

vec3 getNormal( in vec3 p )
{
    // Note the slightly increased sampling distance, to alleviate
    // artifacts due to hit point inaccuracies.
    vec2 e = vec2( 0.005, -0.005 ); 
    return normalize( e.xyy * map( p + e.xyy ).s + 
				      e.yyx * map( p + e.yyx ).s + 
				      e.yxy * map( p + e.yxy ).s + 
				      e.xxx * map( p + e.xxx ).s );

}

// end getNormal()

//------------------------------------------------------------------------------

// GET OBJECT COLOR
// ----------------

vec3 getObjectColor( vec3 p, vec2 distID )
{    
    vec3 col = vec3( 1.0 );
	float objNum = distID.t;
	
	if( objNum == 1.0 )
    {
	    if ( fract( dot( floor( p * 2.0 ), vec3( 0.5 ) ) ) > 0.001 ) 
	    {
	    	col = vec3( 0.0 );
	    }
	}
	else if ( objNum == 2.0 ) // cubes
	{
		col = vec3( 1.0, 0.9, 0.5 );
	}
	else if ( objNum == 3.0 ) // rings
	{
		col = vec3( 0.9, 0.9, 1.0 );
	}
	else if ( objNum == 4.0 ) // ball
	{
		col = vec3( 1.0, 1.0, 0.7 );
	}

    return col;
}

// end getObjectColor()

//------------------------------------------------------------------------------

// DO COLOR
// --------

vec3 doColor( in vec3 sp, in vec3 rayDir, in vec3 surfNorm, in vec2 distID )                                                               
{    
    // Light direction vector.
    vec3 lDir = LIGHT_POS - sp; 

    // Light to surface distance.
    float lDist = max( length( lDir ), 0.001 ); 

    // Normalizing the light vector.
    lDir /= lDist; 
    
    // Attenuating the light, based on distance.
    //float atten = 1.0 / ( 1.0 + lDist * 0.25 + lDist * lDist * 0.05 );
    float atten = 1.0 / ( lDist * lDist * LIGHT_ATTEN );
    
    // Standard diffuse term.
    float diff = max( dot( surfNorm, lDir ), 0.0 );
    
    // Standard specular term.
    float spec = 
            pow( max( dot( reflect( -lDir, surfNorm ), -rayDir ), 0.0 ), 8.0 );
    
    // Coloring the object. You could set it to a single color, to
    // make things simpler, if you wanted.
    vec3 objCol = getObjectColor( sp, distID );
    
    // Combining the above terms to produce the final scene color.
    vec3 sceneCol = ( objCol * ( diff + 0.15 ) + vec3( 1.0, 0.6, 0.2 ) *
                                                          spec * 2.0 ) * atten;  
    return sceneCol;   
}

// end doColor()

//------------------------------------------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// Adjust aspect ratio, normalize coords, center origin in x-axis.	
	vec2 uv = ( -iResolution.xy + 2.0 * fragCoord.xy ) / iResolution.y;

 	mat4 cam_mat = createCamRotMatrix();
	vec3 camPos = vec3( cam_mat * vec4( 0.0, 0.0, -CAM_DIST, 1.0 ) );	    
    vec3 rayDir = getRayDir( camPos, normalize( LOOK_AT - camPos ), uv );   
    vec3 rayOrig = camPos;   
    vec3 lightPos = LIGHT_POS;
	vec3 sceneColor = vec3( 0.0 );
	   
    // FIRST PASS.
    //------------
    vec2 distID = trace( rayOrig, rayDir );
    float totalDist = distID.s;
    
	if ( totalDist >= FAR )
	{
		sceneColor = vec3( 0.0 );
	}
	else
	{
	    // Fog based off of distance from the camera. 
	    float fog = smoothstep( FAR * 0.9, 0.0, totalDist ); 
	    
	    // Advancing the ray origin to the new hit point.
	    rayOrig += rayDir * totalDist;
	    
	    // Retrieving the normal at the hit point.
	    vec3 surfNorm = getNormal( rayOrig );
	    
	    // Retrieving the color at the hit point.
	    sceneColor = doColor( rayOrig, rayDir, surfNorm, distID );
	    
	    float k = 24.0;
	    float shadow = softShadow( rayOrig, lightPos, k );
	   
	    // SECOND PASS - REFLECTED RAY
	    //----------------------------
	    rayDir = reflect( rayDir, surfNorm );
	    totalDist = traceRef( rayOrig +  rayDir * 0.01, rayDir );
	    rayOrig += rayDir * totalDist;
	    
	    // Retrieving the normal at the reflected hit point.
	    surfNorm = getNormal( rayOrig );
	    
	    // Coloring the reflected hit point, then adding a portion of it to the 
	    // final scene color. Factor is percent of reflected color to add.
	    sceneColor += doColor( rayOrig, rayDir, surfNorm, distID ) * 0.35;
	    
	    // APPLYING SHADOWS
	    //-----------------
	    sceneColor *= shadow;
	    sceneColor *= fog;
	    
	} // end else totalDist < FAR
	
	fragColor = vec4(clamp(sceneColor, 0.0, 1.0), 1.0);
    
}

//------------------------------------------------------------------------------

// CREATE CAMERA ROTATION MATRIX
// -----------------------------

// From	"Simple test/port of Mercury's SDF library to WebGL"
// 	https://www.shadertoy.com/view/Xs3GRB    Uploaded by tomkh in 2015-Dec-16

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
		ang = ( iMouse.x - iResolution.x * 0.5 ) * rotRange;
	}
	sinAng = sin(ang); 
	cosAng = cos(ang);
	
	mat4 y_Rot_Cam_Mat = mat4( cosAng, 0.0, sinAng, 0.0,	  
	                              0.0, 1.0,    0.0, 0.0,
	                          -sinAng, 0.0, cosAng, 0.0,
	                              0.0, 0.0,    0.0, 1.0 );
	
    if( iMouse.z < 1.0 ) 
    {
		ang = 0.5 * ( sin( iGlobalTime * 0.1 ) + 1.0 );
	}
	else
	{
        ang = ( 2.0 * iMouse.y - iResolution.y * 1.5 ) * rotRange;
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

vec3 rotateX(vec3 p, float a)
{
  float sa = sin(a);
  float ca = cos(a);
  return vec3(p.x, ca * p.y - sa * p.z, sa * p.y + ca * p.z);
}
vec3 rotateY(vec3 p, float a)
{
  float sa = sin(a);
  float ca = cos(a);
  return vec3(ca * p.x + sa * p.z, p.y, -sa * p.x + ca * p.z);
}
vec3 rotateZ(vec3 p, float a)
{
  float sa = sin(a);
  float ca = cos(a);
  return vec3(ca * p.x - sa * p.y, sa * p.x + ca * p.y, p.z);
}

//------------------------------------------------------------------------------
// The following code is excerpted from:

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


////////////////////////////////////////////////////////////////
//
//             HELPER FUNCTIONS/MACROS
//
////////////////////////////////////////////////////////////////


float vmax(vec3 v) {
	return max(max(v.x, v.y), v.z);
}

////////////////////////////////////////////////////////////////
//
//             PRIMITIVE DISTANCE FUNCTIONS
//
////////////////////////////////////////////////////////////////

float fSphere(vec3 p, float r) {
	return length(p) - r;
}

// Cylinder standing upright on the xz plane
float fCylinder(vec3 p, float r, float height) {
	float d = length(p.xz) - r;
	d = max(d, abs(p.y) - height);
	return d;
}

// Torus in the XZ-plane
float fTorus(vec3 p, float smallRadius, float largeRadius) {
	return length(vec2(length(p.xz) - largeRadius, p.y)) - smallRadius;
}

// A circular disc with no thickness (i.e. a cylinder with no height).
// Subtract some value to make a flat disc with rounded edge.
float fDisc(vec3 p, float r) {
 float l = length(p.xz) - r;
	return l < 0. ? abs(p.y) : length(vec2(p.y, l));
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


////////////////////////////////////////////////////////////////
//
//                DOMAIN MANIPULATION OPERATORS
//
////////////////////////////////////////////////////////////////

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
