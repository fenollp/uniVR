// Shader downloaded from https://www.shadertoy.com/view/ltBXWd
// written by shadertoy user macbooktall
//
// Name: electric feelss 
// Description: small mod to my tunnel shader
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

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float sdCappedCylinder( vec3 p, vec2 h ) {
  vec2 d = abs(vec2(length(p.xy),p.z)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

vec2 map( in vec3 pos )
{
    //pos.x += sin(pos.x+25.0+iGlobalTime)*0.2;
    pos.y += cos(pos.x+pos.z+25.0+iGlobalTime)*0.2;
    
    float size = .25;
    vec3 p = abs(mod(pos.xyz+size,size*2.)-size);
    float cyl = sdCappedCylinder( p, vec2(.31, .32));
     
    vec2  res = vec2(cyl,1.5); 
    
    return res;
}

vec2 castRay( in vec3 ro, in vec3 rd )
{
    const float tmin = 0.0;
    const float tmax = 50.0;
    
    float t = tmin;
    float m = -1.0;
    for( int i=0; i<50; i++ )
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
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}




vec3 render( in vec3 ro, in vec3 rd )
{ 
    vec3 col = vec3(0.0, 0.0, 0.0);
    vec2 res = castRay(ro,rd);
    float t = res.x;
	float m = res.y;
    
    if( m>-0.5 )
    {
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos );
        vec3 ref = reflect( rd, nor );
		col = 1.0 - hue(vec3(ref),iGlobalTime+pos.z);
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
    mat3 ca = setCamera( ro, ta, 0. );

    // ray direction
	vec3 rd = ca * normalize(vec3(p.xy,1.5));

    // render
    vec3 col = render( ro, rd );

    fragColor=vec4( col, 1.0 );
}