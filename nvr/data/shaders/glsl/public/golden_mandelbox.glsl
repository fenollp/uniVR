// Shader downloaded from https://www.shadertoy.com/view/MtlXR4
// written by shadertoy user LeWiZ
//
// Name: Golden Mandelbox
// Description: A golden mandelbox !
//    
//    But still too slow to visit inside... :-(
// Removing soft shadows improves FPS by a factor ~2.5, but it's less pretty
#define SHADOWS

void sphereFold(inout vec3 z, inout float dz)
{
	float r2 = dot(z,z);
	if (r2 < 0.5)
    { 
		float temp = 2.0;
		z *= temp;
		dz*= temp;
	}
    else if (r2 < 1.0)
    { 
		float temp = 1.0 / r2;
		z *= temp;
		dz*= temp;
	}
}

void boxFold(inout vec3 z, inout float dz)
{
	z = clamp(z, -1.0, 1.0) * 2.0 - z;
}

float mandelbox(vec3 z)
{
    float scale = 2.0;
	vec3 offset = z;
	float dr = 1.0;
	for (int n = 0; n < 10; n++)
    {
		boxFold(z,dr);
		sphereFold(z,dr);
        z = scale * z + offset;
        dr = dr * abs(scale) + 1.0;
	}
	float r = length(z);
	return r / abs(dr);
}

float plane(vec3 pos)
{
	return length(max(abs(pos)-vec3(12.0,0.5,12.0),0.0));
}

float scene(vec3 pos)
{
    return min(mandelbox(pos), plane(pos-vec3(0.0,-6.5,0.0)));
}

float raymarcher( in vec3 ro, in vec3 rd )
{
	const float maxd = 50.0;
	const float precis = 0.01;
    float h = precis*2.0;
    float t = 0.0;
	float res = -1.0;
    for( int i=0; i<100; i++ )
    {
        if( h<precis||t>maxd ) break;
	    h = scene( ro+rd*t );
        t += h * 1.0;
    }

    if( t<maxd ) res = t;
    return res;
}

vec3 normal( in vec3 pos )
{
    const float eps = 0.005;

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*scene( pos + v1*eps ) + 
					  v2*scene( pos + v2*eps ) + 
					  v3*scene( pos + v3*eps ) + 
					  v4*scene( pos + v4*eps ) );
}

float softray( in vec3 ro, in vec3 rd , in float hn)
{
    float res = 1.0;
    float t = 0.0005;
	float h = 1.0;
    for( int i=0; i<40; i++ )
    {
        h = scene(ro + rd*t);
        res = min( res, hn*h/t );
		t += clamp( h, 0.02, 2.0 );
    }
    return clamp(res,0.0,1.0);
}

float ambocc( in vec3 pos, in vec3 nor )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = scene( aopos );
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

vec3 light( in vec3 lightdir, in vec3 lightcol, in vec3 tex, in vec3 norm, in vec3 camdir )
{    
    float cosa = pow(0.5 + 0.5*dot(norm, -lightdir),2.0);
    float cosr = max(dot(-camdir, reflect(lightdir, norm)), -0.0);
    
    float diffuse = cosa;
    float phong = pow(cosr, 8.0);
    
    return lightcol * (tex * diffuse + phong);
}

vec3 background( in vec3 rd )
{
	return vec3(1.0+2.0*rd.y);
}

vec3 material( in vec3 pos , in vec3 camdir )
{    
	vec3 norm = normal(pos);
    
    vec3 d1 = -normalize(vec3(5.0,10.0,-20.0));
    vec3 d2 = -normalize(vec3(-5,10.0,20.0));
    vec3 d3 = -normalize(vec3(20,5.0,-5.0));
    vec3 d4 = -normalize(vec3(-20.0,5.0,5.0));
	
    vec3 tex = vec3(0.2);
    if (pos.y > -5.95) tex = vec3(0.32,0.28,0.0);
    
    #ifdef SHADOWS
    float sha = 0.7 * softray(pos, -d1, 32.0) + 0.3 * softray(pos, -d4, 16.0);
    #else
    float sha = 1.0;
    #endif
    float ao = ambocc(pos, norm);
    
    vec3 l1 = light(d1, vec3(1.0,0.9,0.8), tex, norm, camdir);
    vec3 l2 = light(d2, vec3(0.8,0.7,0.6), tex, norm, camdir);
    vec3 l3 = light(d3, vec3(0.3,0.3,0.4), tex, norm, camdir);
    vec3 l4 = light(d4, vec3(0.5,0.5,0.5), tex, norm, camdir);
    
    #ifdef SHADOWS
    return 0.2 * ao + 0.8 * (l1+l2+l3+l4)*sha;
    #else
    return 0.5 * ao + 0.5 * (l1+l2+l3+l4)*sha;
    #endif
}

mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

vec3 rayrender(vec3 pos, vec3 dir)
{
   vec3 col = vec3(0.0);
    
   float dist = raymarcher(pos, dir);
    
    if (dist==-1.0) col = background(dir);
    else
    {
    	vec3 inters = pos + dist * dir;
    	col = material(inters, dir);
    }
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime;
    
    vec2 xy = (fragCoord.xy - iResolution.xy/2.0) / max(iResolution.xy.x, iResolution.xy.y);
    
    vec3 campos = vec3(35.0*cos(t/5.0),10.0,35.0*sin(t/5.0));
    vec3 camtar = vec3(0.0,0.0,0.0);
    
    mat3 camMat = calcLookAtMatrix( campos, camtar, 0.0 );
	vec3 camdir = normalize( camMat * vec3(xy,0.9) );
    
    vec3 col = rayrender(campos, camdir);
    
    #ifdef SHADOWS
    col = pow(col, vec3(1.0/2.2));
    #else
    col = pow(col, vec3(1.0));
    #endif
    
	fragColor = vec4(col,1.0);
}
