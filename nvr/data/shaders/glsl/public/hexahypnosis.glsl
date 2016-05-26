// Shader downloaded from https://www.shadertoy.com/view/4dcGzr
// written by shadertoy user macbooktall
//
// Name: hexahypnosis
// Description: dis one is 4 the haters
// tweaked copy of https://www.shadertoy.com/view/Xds3zN by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec3 hue(vec3 color, float shift) {

    const vec3  kRGBToYPrime = vec3 (0.299, 0.587, 0.114);
    const vec3  kRGBToI     = vec3 (0.596, -0.275, -0.321);
    const vec3  kRGBToQ     = vec3 (0.212, -0.523, 0.311);

    const vec3  kYIQToR   = vec3 (1.0, 0.956, 0.621);
    const vec3  kYIQToG   = vec3 (1.0, -0.272, -0.647);
    const vec3  kYIQToB   = vec3 (1.0, -1.107, 1.704);

    // Convert to YIQ
    float   YPrime  = dot (color, kRGBToYPrime);
    float   I      = dot (color, kRGBToI);
    float   Q      = dot (color, kRGBToQ);

    // Calculate the hue and chroma
    float   hue     = atan (Q, I);
    float   chroma  = sqrt (I * I + Q * Q);

    // Make the user's adjustments
    hue += shift;

    // Convert back to YIQ
    Q = chroma * sin (hue);
    I = chroma * cos (hue);

    // Convert back to RGB
    vec3    yIQ   = vec3 (YPrime, I, Q);
    color.r = dot (yIQ, kYIQToR);
    color.g = dot (yIQ, kYIQToG);
    color.b = dot (yIQ, kYIQToB);

    return color;
}

float sdHexPrism( vec3 p, vec2 h )
{
    vec3 q = abs(p);
    return max(q.z-h.y,max((q.x*0.866025+q.y*0.5),q.y)-h.x);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float opS( float d1, float d2 )
{
    return max(-d1,d2);
}

vec2 opU( vec2 d1, vec2 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}

vec2 map( in vec3 pos )
{
    const float height = .22;
    const float depth = .15;
    const float t = 0.01;
    pos.z = mod(pos.z,depth*10.)-0.5*depth*10.;
	pos.y = mod(pos.y,height*1.9)-0.5*height*1.9;
	pos.x = mod(pos.x,height*2.2)-0.5*height*2.2;
    
   	float cyl = sdHexPrism( pos, vec2(height-t, depth+t));
   	float scyl = sdHexPrism( pos, vec2(height-t*2.0, depth+t+.001));

   return vec2(opS(scyl, cyl), 1.5);
 
}

vec2 castRay( in vec3 ro, in vec3 rd )
{
    float tmin = 0.0;
    float tmax = 100.0;
    
    float t = tmin;
    float m = -1.0;
    for( int i=0; i<100; i++ )
    {
   vec2 res = map( ro+rd*t );
        if(  t>tmax ) break;
        t += res.x;
   m = res.y;
    }

    if( t>tmax ) m=-1.0;
    return vec2( t, m );
}

vec3 calcNormal( in vec3 pos )
{
vec3 eps = vec3( 0.01, 0.0, 0.0 );
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
        sca *= .95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 )*occ;    
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

		col = hue(vec3(0.0,1.0,1.0),pos.z);
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
    vec2 mo = iMouse.xy/iResolution.xy;
 
	// camera
	vec3 ro = vec3(0., 0.,iGlobalTime );
	
    vec3 ta = ro+vec3( 0., 0.,1. );
	
    // camera-to-world transformation
    mat3 ca = setCamera( ro, ta, 3.14159/2.0 );

    // ray direction
	vec3 rd = ca * normalize(vec3(p.xy,2.5));

    // render
    vec3 col = render( ro, rd );

    fragColor=vec4( col, 1.0 );
}