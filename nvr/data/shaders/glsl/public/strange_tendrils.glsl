// Shader downloaded from https://www.shadertoy.com/view/4lfSzf
// written by shadertoy user netgrind
//
// Name: strange tendrils
// Description: spooky
//By Cale Bradbury, 2015

//how many itterations of the fractal
#define LOOPS 10.0

#define BOX
//uncomment the line below to make shit magical
//#define COLOR

//fuck yeah, mirror that shit
#define MIRROR

// Base ray trace code via https://www.shadertoy.com/view/Xds3zN by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

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

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float sphere( vec3 p, float s ){
  return length(p)-s;
}

float qbox( vec3 p, float s ){
  return length(max(abs(p)-vec3(s,s,s),0.0));
}

float box( vec3 p, vec3 b ){
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

vec2 kale(vec2 uv, float angle, float base, float spin) {
	float a = atan(uv.y,uv.x)+spin;
	float d = length(uv)*1.4;
	a = mod(a,angle*2.0);
	a = abs(a-angle);
	uv.x = sin(a+base)*d;
	uv.y = cos(a+base)*d;
    return uv;
}

float f(vec3 pos, float size, float cur){
    return smin(cur,sphere(pos,size), .15);
}
#define pi 3.14158

vec2 map( in vec3 pos )
{
    pos =(opRep(pos,vec3(3.,3.,3.)));
   pos.xy = kale(pos.xy,pi/6.,pi*1.4+cos(iGlobalTime)*.1,0.);
    pos.xz = kale(pos.xz,pi/6.,pi*1.4+sin(iGlobalTime)*.1,0.);
    
    float size = .5;
    float r = f(pos,size,1.);  
    
    for(float i = 0.; i<LOOPS;i++){
        pos+=vec3(size*(sin(iGlobalTime)*.5+1.5),0.,0.);
        size*=(cos(iGlobalTime*2.)*.3+.5);
        r = f(pos,size,r);
    }
    return vec2(r,1.0);
}

vec2 castRay( in vec3 ro, in vec3 rd )
{
    float tmin = 0.;
    float tmax = 20.0;
    
#if 0
    float tp1 = (0.0-ro.y)/rd.y; if( tp1>0.0 ) tmax = min( tmax, tp1 );
    float tp2 = (1.6-ro.y)/rd.y; if( tp2>0.0 ) { if( ro.y>1.6 ) tmin = max( tmin, tp2 );
                                                 else           tmax = min( tmax, tp2 ); }
#endif
    
	float precis = 0.01;
    float t = tmin;
    float m = 0.0;
    for( int i=0; i<30; i++ )
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
    for( int i=0; i<8; i++ )
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

vec3 render( in vec3 ro, in vec3 rd, float c )
{ 
    vec2 res = castRay(ro,rd);
    float t = res.x;
	float m = res.y;
    vec3 col = vec3(c);
    if( m>-.5 )
    {
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos );
        vec3 ref = reflect( rd, nor );
        
        // lighitng        
        float occ = calcAO( pos, nor );
		vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
		float amb = clamp( 0.5+0.5*nor.y, 0.5, 1.0 );
        float dif = clamp( dot( nor, lig ), 0.5, 1.0 );
        float bac = clamp( dot( nor, normalize(vec3(-lig.x,0.0,-lig.z))), 0.0, 1.0 )*clamp( 1.0-pos.y,0.0,1.0);
        float dom = smoothstep( -0.1, 0.1, ref.y );
        float fre = pow( clamp(1.0+dot(nor,rd),0.5,1.0), 2.0 );
		float spe = pow(clamp( dot( ref, lig ), 0.5, 1.0 ),16.0);
        
       dif *= softshadow( pos, lig, 0.01, .5 );
        dom *= softshadow( pos, ref, 0.02, 2.5 );

		vec3 brdf = vec3(0.0);
        brdf += 1.20*dif;
		brdf += 1.20*spe*dif;
        brdf += 0.30*amb*occ;
        brdf += 0.40*dom*occ;
        brdf += 0.30*bac*occ;
        brdf += 0.40*fre*occ;
		//brdf += 0.02;
		col = brdf;
        col*=(1.0-res.x*.11);
        
    	//col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.0005*t*t ) );

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
	float camDist = 5.;
	// camera	
	vec3 ro = vec3(cos(time)*camDist,0.,sin(time)*camDist);
    //vec3( -0.5+camDist*cos(0.1*time), 5.0, 0.5 + camDist*sin(0.1*time) );
	vec3 ta = vec3( -0.001, -0., -0. );
	
	// camera-to-world transformation
    mat3 ca = setCamera( ro, ta, time );
    
    // ray direction
	vec3 rd = ca * normalize( vec3(p.xy,2.5) );

    float bg =  q.y*.2+.1;
    // render	
    vec3 col = render( ro, rd,bg );
    col = vec3(mix(col.r,bg,1.0-col.r));

    col *= 1.-length((q*2.-1.))*.3;
    #ifdef COLOR
    col = sin(col*vec3(10.,6.,15.)*(sin(time*.35)*.5+2.)+time)*.5+.5;
    #endif
    
	col = pow( col, vec3(1.2545) );

    fragColor=vec4( col, 1.0 );
}