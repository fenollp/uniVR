// Shader downloaded from https://www.shadertoy.com/view/4tX3DH
// written by shadertoy user dcm
//
// Name: Harmonic Pendula
// Description: An array of pendula at various lengths such that their periods sync up in various harmonies.  
// Original link: https://www.shadertoy.com/view/Xds3zN
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// A list of usefull distance function to simple primitives, and an example on how to 
// do some interesting boolean operations, repetition and displacement.
//
// More info here: http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm

// Modified by AranHase to implement Gooch shading from:
// http://www.cs.northwestern.edu/~ago820/SIG98/abstract.html
// Very simple technique to auto shade technical illustrations

// modified by dcm to check out an array of pendula

const int num = 40;
const float pi = 3.14159;
const float tau = 2.0*3.14159;
int sticks = 0;

float sdPlane( vec3 p )
{
	return p.y;
}

float sdSphere( vec3 p, float s )
{
    return length(p)-s;
}


float length2( vec2 p )
{
	return sqrt( p.x*p.x + p.y*p.y );
}

float length6( vec2 p )
{
	p = p*p*p; p = p*p;
	return pow( p.x + p.y, 1.0/6.0 );
}

float length8( vec2 p )
{
	p = p*p; p = p*p; p = p*p;
	return pow( p.x + p.y, 1.0/8.0 );
}

float sdTorus82( vec3 p, vec2 t )
{
  vec2 q = vec2(length2(p.xz)-t.x,p.y);
  return length8(q)-t.y;
}

float sdTorus88( vec3 p, vec2 t )
{
  vec2 q = vec2(length8(p.xz)-t.x,p.y);
  return length8(q)-t.y;
}

float sdCylinder6( vec3 p, vec2 h )
{
  return max( length6(p.xz)-h.x, abs(p.y)-h.y );
}

//----------------------------------------------------------------------

float opS( float d1, float d2 )
{
    return max(-d2,d1);
}

vec2 opU( vec2 d1, vec2 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}

vec3 opRep( vec3 p, vec3 c )
{
    return mod(p,c)-0.5*c;
}

vec3 opTwist( vec3 p )
{
    float  c = cos(10.0*p.y+10.0);
    float  s = sin(10.0*p.y+10.0);
    mat2   m = mat2(c,-s,s,c);
    return vec3(m*p.xz,p.y);
}

//----------------------------------------------------------------------

vec2 map( in vec3 pos )
{
    vec2 res = opU( vec2( sdPlane(     pos), 10.0 ),
	                vec2( sdSphere(    pos-vec3( 0.0,-.25, 0.0), 0.15 ), 46.9 ) );
    
    float numsq = float(num*num);
    for(int i = 0; i < num; i+=1)
    {
        float j = float(i)+1.0;
        float theta = pi*cos(j*iGlobalTime/10.0);
        float r = 3.75-3.75*(j*j/numsq);
            
        float c = 24.0;
        //float c = 1.0;
        res = opU( res,
              vec2( sdSphere( pos-vec3( j/2.0, 
                                       4.0 - r*cos(theta), 
                                       r*sin(theta)), 
                             0.25 ), c ) );
        /*
        if (sticks == 1)
        {
        res = opU( res, 
                  vec2( sdCapsule(pos,
                  	vec3(float(j)/2.0, 4.0, 0.0),
                  	vec3(float(j)/2.0, 4.0 - r*cos(theta), 
                                       r*sin(theta)), 0.01
                  ), 1.0));
        }
		*/
    }
    
    return res;
}

vec2 castRay( in vec3 ro, in vec3 rd )
{
    float tmin = 1.0;
    float tmax = float(num);
    
#if 0
    float tp1 = (0.0-ro.y)/rd.y; if( tp1>0.0 ) tmax = min( tmax, tp1 );
    float tp2 = (1.6-ro.y)/rd.y; if( tp2>0.0 ) { if( ro.y>1.6 ) tmin = max( tmin, tp2 );
                                                 else           tmax = min( tmax, tp2 ); }
#endif
    
	float precis = 0.002;
    float t = tmin;
    float m = -1.0;
    for( int i=0; i<500; i++ )
    {
	    vec2 res = map( ro+rd*t );
        if( res.x<precis || t>tmax ) break;
        t += res.x;
	    m = res.y;
    }

    if( t>tmax ) m=-1.0;
    return vec2( t, m );
}


float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<16; i++ )
    {
		float h = map( ro + rd*t ).x;
        res = min( res, 8.0*h/t );
        t += clamp( h, 0.02, 0.10 );
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );

}

vec3 calcNormal( in vec3 pos )
{
	vec3 eps = vec3( 0.001, 0.0, 0.0 );
	vec3 nor = vec3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}

float calcAO( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}




vec3 render( in vec3 ro, in vec3 rd, in vec2 fragCoord )
{ 
    // y = -m(x-0.5)^2 + 1.0
    float xx = fragCoord.y/iResolution.y-0.5;
    xx = -5.000*xx*xx + 1.0;
    vec3 col = vec3(0.5*xx);
    vec2 res = castRay(ro,rd);
    float t = res.x;
	float m = res.y;
    if( m >= 0.0 )
    {
        vec3 view_direction = -rd;
        
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos );
        vec3 ref = reflect( rd, nor );
        
        // Light above is easier for the brain to process
        vec3 lig = normalize( vec3(100, 100, 100)-pos );
        
        
        float b = 0.4;
        float y = 0.4;
        float alpha = 0.2;
        float beta = 0.6;
        
        vec3 kblue = vec3(0, 0, b);
        vec3 kyellow = vec3(y, y, 0);
        
        // Ambient light
        vec3 ka = vec3(0.1);
        
        // Diffuse light intensity
        vec3 kd = vec3(m/55.0, (m-55.0)/55.0, 0.00);
        
        // These values are better explained in the original paper
        // I kept the same names
        vec3 kcool = kblue + alpha*kd;
        vec3 kwarm = kyellow + beta*kd;
        
        
        vec3 I = ((1.0+dot(lig,nor))*0.5)*kcool + ((1.0-(1.0+dot(lig,nor))*0.5))*kwarm;
        float spe = pow(clamp( dot( ref, lig ), 0.0, 1.0 ),16.0);
        col = I + 0.90*spe*vec3(1.00,1.00,1.00) + ka;
    }

	return vec3( clamp(col,0.0,1.0) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    

	vec2 q = fragCoord.xy/iResolution.xy;
    vec2 p = -1.0+2.0*q;
	p.x *= iResolution.x/iResolution.y;
    vec2 mo = iMouse.xy/iResolution.xy;
		 
	float time = 15.0 + iGlobalTime;

	// camera	
	vec3 ro = vec3( -4.0+3.2*cos( + 6.0*mo.x), 0.1 + 2.0*mo.y, 0.0 + 3.2*sin( 6.0*mo.x) );
	vec3 ta = vec3( 1.0, 3.0, 0.5 );
	
	// camera tx
	vec3 cw = normalize( ta-ro );
	vec3 cp = vec3( 0.0, 1.0, 0.0 );
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
	vec3 rd = normalize( p.x*cu + p.y*cv + 2.5*cw );

	
    vec3 col = render( ro, rd, fragCoord);

	//col = pow( col, vec3(0.4545) );

    fragColor=vec4( col, 1.0 );
}