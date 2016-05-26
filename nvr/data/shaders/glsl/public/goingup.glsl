// Shader downloaded from https://www.shadertoy.com/view/lst3Rn
// written by shadertoy user macbooktall
//
// Name: goingup
// Description: A mod of @netgrind's beautiful fractal https://www.shadertoy.com/view/ltjGzd
//    Based on iq's raymarch primitives https://www.shadertoy.com/view/Xds3zN
//forked By Cale Bradbury, 2015 from https://www.shadertoy.com/view/ltjGzd

//fuck yeah, mirror that shit
#define MIRROR

// Base ray trace code via https://www.shadertoy.com/view/Xds3zN by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


float opS( float d1, float d2 )
{
    return max(-d2,d1);
}

vec3 opRep( vec3 p, vec3 c )
{
    return mod(p,c)-0.5*c;
}

float qbox( vec3 p, float s )
{
  return length(max(abs(p)-vec3(s,s,s),0.0));
}

float box(vec3 p, vec3 b){ 
    p = abs(p) - b;
    return max(p.x, max(p.y,p.z));
}

vec2 map( in vec3 pos )
{
    float size = .65;
    //pos.z = mod(pos.z,size*5.)-0.5*size*5.;
	pos.y = mod(pos.y,size)-0.5*size;
    float res = qbox(pos,size);

    pos+=size;
    
    float t = iGlobalTime;
    for(float i = 0.0; i<3.;i++){
        size /= 3.0;
        
        float b = box(opRep(pos,vec3(size*5.,size*5.,0)),vec3(size,size,10.));
        res = opS(res,b);
        b = box(opRep(pos,vec3(size*5.25,0.,size*5.)),vec3(size,10.,size));
        res = opS(res,b);
        b = box(opRep(pos,vec3(0.,size*2.,size*6.)),vec3(10.,size,size));
        res = opS(res,b);
    }
	
    return vec2(res,1.0);
}

vec2 castRay( in vec3 ro, in vec3 rd )
{
    float tmin = 0.;
    float tmax = 120.0;
    
	float precis = 0.001;
    float t = tmin;
    float m = 0.0;
    for( int i=0; i<120; i++ )
    {
	    vec2 res = map( ro+rd*t );
        if( res.x<precis || t>tmax ) break;
        t += res.x;
	    m = res.y;
    }

    if( t>tmax ) m=-1.;
    return vec2( t, m );
}

float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<4; i++ )
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

vec3 render( in vec3 ro, in vec3 rd )
{ 
    vec3 col = vec3(1.0);
    vec2 res = castRay(ro,rd);
    float t = res.x;
	float m = res.y;
    
    if( m>-0.5 )
    {
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos );
        vec3 ref = reflect( rd, nor );
        
        // material        
        float occ = calcAO( pos, nor );
		col = occ*smoothstep(vec3(0.8, 0.2, 0.2)*(1.0-occ), vec3(0.2, 0.8, .8)*occ, vec3(occ));
    }

return vec3( clamp(col,0.0,1.0) );
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy/iResolution.xy;
    vec2 p = -1.0+2.0*q;
	p.x *= iResolution.x/iResolution.y;
    #ifdef MIRROR
    p.x = -abs(p.x);
    #endif
		 
	float time = 15.0 + iGlobalTime*.5;
	float camDist = 3.;
	// camera	
	vec3 ro = vec3(-.02, iGlobalTime*.1, 0.);
    //vec3( -0.5+camDist*cos(0.1*time), 5.0, 0.5 + camDist*sin(0.1*time) );
	vec3 ta = ro + vec3(-1., -1., -1. );
	
	// camera-to-world transformation
//    mat3 ca = setCamera( ro, ta, 56.54 );
    mat3 ca = setCamera( ro, ta, 0. );
    // ray direction
	vec3 rd = ca * normalize( vec3(p.xy,5.) );

    // render	
    vec3 col = render( ro, rd);
    col += (vec3(1.)*p.y)*0.35;

    fragColor=vec4( col, 1.0 );
}