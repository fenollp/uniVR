// Shader downloaded from https://www.shadertoy.com/view/ldt3R7
// written by shadertoy user macbooktall
//
// Name: mandala thing
// Description: tweaked copy of https://www.shadertoy.com/view/Xds3zN by inigo quilez - iq/2013
//    Using palette from http://www.iquilezles.org/www/articles/palettes/palettes.htm
//    Thanks to Cabbibo for the suggestion!! &lt;3
// tweaked copy of https://www.shadertoy.com/view/Xds3zN by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec2 rotate(vec2 v, float a){
	float t = atan(v.y,v.x)+a;
    float d = length(v);
    v.x = cos(t)*d;
    v.y = sin(t)*d;
    return v;
}

float sdHexPrism( vec3 p, vec2 h )
{
    vec3 q = abs(p);
    return max(q.z-h.y,max((q.x*0.866025+q.y*0.5),q.y)-h.x);
}

float opS( float d1, float d2 )
{
    return max(-d1,d2);
}

vec2 map( in vec3 pos )
{
    const float height = .22;
    const float depth = .05;
    const float t = 0.01;
    pos.z = mod(pos.z,depth*10.)-0.5*depth*10.;
	pos.y = mod(pos.y,height*2.2)-0.5*height*2.2;
	pos.x = mod(pos.x,height*2.2)-0.5*height*2.2;
    
   	float cyl = sdHexPrism( pos, vec2(height-t, depth+t));
   	float scyl = sdHexPrism( pos, vec2(height-t*2.0, depth+t+.001));

    return vec2(opS(scyl, cyl), 1.5);
}

vec2 castRay( in vec3 ro, in vec3 rd )
{
    float tmin = 0.0;
    float tmax = 80.0;
    
    float t = tmin;
    float m = -1.0;
    for( int i=0; i<80; i++ )
    {
   		vec2 res = map( ro+rd*t );
        if(  t>tmax ) break;
        t += res.x;
		m = res.y;
    }

    if( t>tmax ) m=-1.0;
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

    const vec3 a = vec3(0.5, 0.5, 0.5);
    const vec3 b = vec3(0.5, 0.5, 0.5);
    const vec3 c = vec3(2., 1., 0.);
    const vec3 d = vec3(0.5, 0.2, 0.25);

    col = palette(res.x, a, b, c, d);
    col = mix( col, vec3(1.0), 1.0-exp( -.25*res.x*res.x ) );

	return col;
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
    p = rotate(p,2.*atan(p.y, p.x));
 
	// camera
	vec3 ro = vec3(0., 0.,iGlobalTime*0.2 );
	
    vec3 ta = ro+vec3( 0., 0.,1. );
	
    // camera-to-world transformation
    mat3 ca = setCamera( ro, ta, 3.14159/2.0 );

    // ray direction
	vec3 rd = ca * normalize(vec3(p.xy,.5));

    // render
    vec3 col = render( ro, rd );

    fragColor=vec4( col, 1.0 );
}