// Shader downloaded from https://www.shadertoy.com/view/ldc3Dn
// written by shadertoy user macbooktall
//
// Name: zinetest3
// Description: color palette and base ray march code by iq https://www.shadertoy.com/view/Xds3zN
//    menger sponge by Cale https://www.shadertoy.com/view/ltjGzd
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
    float size = .35;
    pos = mod(pos,size)-0.5*size;
	
    float res = qbox(pos,size);

    pos+=size;
    
    for(float i = 0.0; i<3.;i++){
        size /= 3.0;
        
        float b = box(opRep(pos,vec3(size*3.,size*3.,0)),vec3(size,size,10.));
        res = opS(res,b);
        b = box(opRep(pos,vec3(size*6.,0.,size*6.)),vec3(size,10.,size));
        res = opS(res,b);
        b = box(opRep(pos,vec3(0.,size*6.,size*6.)),vec3(10.,size,size));
        res = opS(res,b);
    }
	
    return vec2(res,1.0);
}

vec2 castRay( in vec3 ro, in vec3 rd )
{
    float tmin = 0.;
    float tmax = 120.0;
    
	float precis = 0.0001;
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

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 render( in vec3 ro, in vec3 rd )
{ 
    vec3 col = vec3(1.0);
    vec2 res = castRay(ro,rd);
    
    const vec3 a = vec3(.5, .0, .5);
    const vec3 b = vec3(.5, 1., .5);
    const vec3 c = vec3(1., 1., 1.);
    const vec3 d = vec3(.0, .1, 0.2);
    
    col = palette(0.3+res.x*2., a, b, c, d);
    col = mix( col, vec3(1.0), 1.0-exp( -.5*res.x*res.x ) );

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
	vec2 p = -1.0+2.0*(fragCoord.xy / iResolution.xy);
	p.x *= iResolution.x/iResolution.y;

    // camera	
	vec3 ro = vec3(0., .0, -iGlobalTime*0.4 );
    //vec3( -0.5+camDist*cos(0.1*time), 5.0, 0.5 + camDist*sin(0.1*time) );
	vec3 ta = ro + vec3(0., 0., -1. );
	
	// camera-to-world transformation
//    mat3 ca = setCamera( ro, ta, 56.54 );
    mat3 ca = setCamera( ro, ta, 0. );
    // ray direction
	vec3 rd = ca * normalize( vec3(p.xy,.8) );

    // render	
    vec3 col = render( ro, rd);
    col += (vec3(1.)*p.y)*0.35;

	fragColor = vec4( col, 1.0 );
}