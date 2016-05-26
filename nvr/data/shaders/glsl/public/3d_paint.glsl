// Shader downloaded from https://www.shadertoy.com/view/4dVGRR
// written by shadertoy user josh
//
// Name: 3D paint
// Description: 3D painter. Hold mouse button to draw. Hold space to paint with webcam.
// Started with cabbibo's https://www.shadertoy.com/view/Xl2XWt


const float MAX_TRACE_DISTANCE = 3.0;           // max trace distance
const float INTERSECTION_PRECISION = 0.001;        // precision of the intersection
const int NUM_OF_TRACE_STEPS = 100;

const float PI = 3.145;

vec3 spCenter = vec3( 0.0 , 0.0 , -0.8 );
float spRad = 1.1;

//----
// Camera Stuffs
//----
mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

// checks to see which intersection is closer
// and makes the y of the vec2 be the proper id
vec2 opU( vec2 d1, vec2 d2 ){
    
	return (d1.x<d2.x) ? d1 : d2;
    
}


float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}


//--------------------------------
// Modelling 
//--------------------------------
vec2 map( vec3 pos ){  
    
 	vec2 res = vec2( sdSphere( pos - spCenter , spRad ) , 1. );     
    return res;
    
}



vec2 calcIntersection( in vec3 ro, in vec3 rd ){

    
    float h =  INTERSECTION_PRECISION*2.0;
    float t = 0.0;
	float res = -1.0;
    float id = -1.;
    
    for( int i=0; i< NUM_OF_TRACE_STEPS ; i++ ){
        
        if( h < INTERSECTION_PRECISION || t > MAX_TRACE_DISTANCE ) break;
	   	vec2 m = map( ro+rd*t );
        h = m.x;
        t += h;
        id = m.y;
        
    }

    if( t < MAX_TRACE_DISTANCE ) res = t;
    if( t > MAX_TRACE_DISTANCE ) id =-1.0;
    
    return vec2( res , id );
    
}



// Calculates the normal by taking a very small distance,
// remapping the function, and getting normal for that
vec3 calcNormal( in vec3 pos ){
    
	vec3 eps = vec3( 0.001, 0.0, 0.0 );
	vec3 nor = vec3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}




vec3 render( vec2 res , vec3 ro , vec3 rd ){
   

  vec3 color = vec3( 0. );
    
    
  if( res.y > -.5 ){
      
    vec3 pos = ro + rd * res.x;
    vec3 norm = calcNormal( pos );
       
      
    // Balloon
    if( res.y == 1. ){
        
        vec2 bUV;
        bUV.x = 0.5 + atan( norm.z, norm.x ) / (2.0 * PI );
        bUV.y = 0.5 + asin( norm.y ) / PI;
    	vec4 c = texture2D( iChannel0, bUV.xy );
        
        color = c.rgb * c.a  + vec3( 1., 1., 1. ) * ( 1. - c.a );
        vec3 balloonColor = vec3( 1. , 0. , 0. );
    }
        
  }
   
  return color;
    
    
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{ 
    vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;

    float ang = iGlobalTime * 0.2;
    vec3 ro = spCenter + vec3( cos( ang ), 0., sin(ang ) ) * 3.;
    
    // camera matrix
    mat3 camMat = calcLookAtMatrix( ro, spCenter, 0.0 );  // 0.0 is the camera roll
    
	// create view ray
	vec3 rd = normalize( camMat * vec3(p.xy,2.0) ); // 2.0 is the lens length
    
    vec2 res = calcIntersection( ro , rd  );

	
    vec3 color = render( res , ro , rd );
    
	fragColor = vec4(color,1.0);
    
}
